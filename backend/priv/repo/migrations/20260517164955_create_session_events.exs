defmodule Konew.Repo.Migrations.CreateSessionEvents do
  use Ecto.Migration

  def change do
    create table(:session_events) do
      add :type, :string, null: false
      add :data, :map, null: false, default: "{}"
      add :sequence_number, :integer, null: false
      add :session_id, references(:sessions, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :nilify_all), null: true

      timestamps(type: :utc_datetime, updated_at: false)
    end

    create unique_index(:session_events, [:session_id, :sequence_number])
    create index(:session_events, [:session_id])
    create index(:session_events, [:user_id])
  end
end
