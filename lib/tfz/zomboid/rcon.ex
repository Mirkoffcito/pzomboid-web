defmodule Tfz.Zomboid.Rcon do
  @moduledoc false

  # Source RCON packet types
  @serverdata_response_value 0
  @serverdata_exec_command 2
  @serverdata_auth 3
  @serverdata_auth_response 2

  def host, do: System.get_env("RCON_HOST", "zomboid")

  def port do
    System.get_env("RCON_PORT", "27015")
    |> String.to_integer()
  end

  def password do
    System.fetch_env!("RCON_PASSWORD")
  end

  def timeout_ms do
    System.get_env("RCON_TIMEOUT_MS", "5000")
    |> String.to_integer()
  end

  def players do
    with {:ok, sock} <- connect(),
         :ok <- auth(sock, password()),
         {:ok, out} <- exec(sock, "players") do
      :gen_tcp.close(sock)
      {:ok, parse_players(out)}
    else
      {:error, _reason} = err ->
        err

      other ->
        {:error, other}
    end
  end

  defp connect do
    # Use DNS inside docker network; :gen_tcp accepts charlists
    :gen_tcp.connect(String.to_charlist(host()), port(), [:binary, active: false], timeout_ms())
  end

  defp auth(sock, pass) do
    id = new_id()
    :ok = send_packet(sock, id, @serverdata_auth, pass)

    # Zomboid (like Source) can send extra packets; keep reading until auth response
    case recv_until(sock, fn {_id, type, _body} -> type == @serverdata_auth_response end) do
      {:ok, {-1, @serverdata_auth_response, _}} -> {:error, :auth_failed}
      {:ok, {^id, @serverdata_auth_response, _}} -> :ok
      {:ok, {other_id, @serverdata_auth_response, _}} -> {:error, {:unexpected_auth_id, other_id}}
      {:error, _} = err -> err
    end
  end

  defp exec(sock, cmd) do
    id = new_id()
    term_id = id + 1

    :ok = send_packet(sock, id, @serverdata_exec_command, cmd)
    # terminator packet: tells us when the full multi-packet response is complete
    :ok = send_packet(sock, term_id, @serverdata_exec_command, "")

    collect_exec(sock, id, term_id, [])
  end

  defp collect_exec(sock, id, term_id, acc) do
    case recv_packet(sock) do
      {:ok, {^term_id, @serverdata_response_value, _body}} ->
        {:ok, acc |> Enum.reverse() |> IO.iodata_to_binary()}

      {:ok, {^id, @serverdata_response_value, body}} ->
        collect_exec(sock, id, term_id, [body | acc])

      {:ok, {_other_id, _type, _body}} ->
        # ignore unrelated packets
        collect_exec(sock, id, term_id, acc)

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp recv_until(sock, pred) do
    case recv_packet(sock) do
      {:ok, pkt} ->
        if pred.(pkt), do: {:ok, pkt}, else: recv_until(sock, pred)

      {:error, _} = err ->
        err
    end
  end

  # Packet format (little endian):
  # int32 length (bytes after this field)
  # int32 request_id
  # int32 type
  # payload (N bytes)
  # 0x00 0x00 (two null terminators)
  defp send_packet(sock, id, type, payload) when is_binary(payload) do
    body = <<id::little-signed-32, type::little-signed-32, payload::binary, 0, 0>>
    pkt = <<byte_size(body)::little-signed-32, body::binary>>
    :gen_tcp.send(sock, pkt)
  end

  defp recv_packet(sock) do
    with {:ok, <<len::little-signed-32>>} <- :gen_tcp.recv(sock, 4, timeout_ms()),
         {:ok, data} <- :gen_tcp.recv(sock, len, timeout_ms()) do
      <<id::little-signed-32, type::little-signed-32, rest::binary>> = data

      # rest ends with 2 nulls; strip them safely
      body =
        case rest do
          <<payload::binary-size(byte_size(rest) - 2), 0, 0>> -> payload
          other -> other
        end

      {:ok, {id, type, body}}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp new_id do
    # Keep it positive and stable
    :rand.uniform(2_000_000_000)
  end

  defp parse_players(output) when is_binary(output) do
    output
    |> String.split(["\r\n", "\n"], trim: true)
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
    |> Enum.reject(&String.starts_with?(&1, "Players connected"))
    |> Enum.map(fn line -> String.trim_leading(line, "-") end)
  end
end
