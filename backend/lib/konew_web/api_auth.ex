defmodule KonewWeb.ApiAuth do
  import Plug.Conn
  alias Konew.Accounts

  def init(opts), do: opts

  def call(conn, _opts) do
    fetch_api_user(conn, [])
  end

  @spec fetch_api_user(Plug.Conn.t(), Keyword.t()) :: Plug.Conn.t()
  def fetch_api_user(conn, _opts) do
    with [<<bearer::binary-size(6), " ", token::binary>>] <- get_req_header(conn, "authorization"),
         true <- String.downcase(bearer) == "bearer",
         {:ok, user} <- Accounts.fetch_user_by_api_token(token) do
      conn
      |> assign(:current_user, user)
      |> assign(:current_scope, Accounts.Scope.for_user(user))
    else
      _ ->
        conn
    end
  end

  @spec ensure_authenticated(Plug.Conn.t(), Keyword.t()) :: Plug.Conn.t()
  def ensure_authenticated(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
    else
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(401, Jason.encode!(%{error: "Unauthenticated"}))
      |> halt()
    end
  end
end
