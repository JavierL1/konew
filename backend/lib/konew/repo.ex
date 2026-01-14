defmodule Konew.Repo do
  use Ecto.Repo,
    otp_app: :konew,
    adapter: Ecto.Adapters.Postgres
end
