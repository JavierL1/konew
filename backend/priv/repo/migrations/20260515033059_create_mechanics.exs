defmodule Konew.Repo.Migrations.CreateMechanics do
  use Ecto.Migration

  def change do
    create table(:mechanics) do
      add :name, :string
      add :type, :string, null: false, default: "default"
      add :description, :text
      add :config, :map, null: false, default: "{}"

      timestamps(type: :utc_datetime)
    end
  end
end
