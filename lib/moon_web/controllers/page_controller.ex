defmodule MoonWeb.PageController do
  use MoonWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
