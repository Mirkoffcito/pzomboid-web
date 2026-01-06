defmodule Tfz.Zomboid.ServerInfo do
  @moduledoc false

  def name, do: get(:name)
  def host, do: get(:host)
  def port, do: get(:port)

  def info do
    %{name: name(), host: host(), port: port()}
  end

  defp get(key) do
    :tfz
    |> Application.get_env(:zomboid_server, [])
    |> Keyword.get(key)
  end
end
