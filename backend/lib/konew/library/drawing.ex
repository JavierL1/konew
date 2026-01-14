defmodule Konew.Library.Drawing do
  use Ecto.Schema
  import Ecto.Changeset

  schema "drawings" do
    field :image_data, :binary
    field :content_type, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(drawing, attrs) do
    drawing
    |> cast(attrs, [:image_data, :content_type])
    |> validate_required([:image_data, :content_type])
  end
end
