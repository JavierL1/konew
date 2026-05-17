defmodule Konew.Repo.Migrations.CreateSessions do
  use Ecto.Migration

  def change do
    create table(:sessions) do
      add :config, :map, null: false, default: "{}"
      add :state, :map, null: false, default: "{}"
      add :room_id, references(:rooms, on_delete: :delete_all)
      add :mechanic_id, references(:mechanics, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:sessions, [:room_id])
    create index(:sessions, [:mechanic_id])
  end
end
