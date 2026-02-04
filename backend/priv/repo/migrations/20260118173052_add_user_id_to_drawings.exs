defmodule Konew.Repo.Migrations.AddUserIdToDrawings do
  use Ecto.Migration

  def change do
    alter table(:drawings) do
      add(:user_id, references(:users, on_delete: :delete_all), null: false)
    end

    create(index(:drawings, [:user_id]))
  end
end
