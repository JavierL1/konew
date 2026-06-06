defmodule Konew.Release do
  @moduledoc """
  Execution tasks for compiled production releases (e.g., running migrations).
  """
  @app :konew

  def migrate do
    # 1. Ensure minimal storage applications are active
    Application.load(@app)
    {:ok, _} = Application.ensure_all_started(:ecto_sqlite3)
    {:ok, _} = Application.ensure_all_started(:ecto_sql)

    # 2. Iterate through all configured Ecto repositories
    for repo <- Application.get_env(@app, :ecto_repos, []) do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end
end
