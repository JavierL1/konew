defmodule Konew.Repo.Migrations.CreateRooms do
  use Ecto.Migration

  def change do
    create table(:rooms) do
      add :name, :string
      add :invite_code, :string
      add :is_public, :boolean, default: false, null: false
      add :owner_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:rooms, [:invite_code])
    create index(:rooms, [:owner_id])
  end
end
