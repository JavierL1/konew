defmodule Konew.Repo.Migrations.CreateDrawings do
  use Ecto.Migration

  def change do
    create table(:drawings) do
      add :image_data, :binary
      add :content_type, :string

      timestamps(type: :utc_datetime)
    end
  end
end
