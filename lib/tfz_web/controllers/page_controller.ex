defmodule TfzWeb.PageController do
  use TfzWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
