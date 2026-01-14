defmodule KonewWeb.PageController do
  use KonewWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
