defmodule Konew.Repo do
  use Ecto.Repo,
    otp_app: :konew,
    adapter: Ecto.Adapters.SQLite3
end
