defmodule Konew.Interactions.Reaction do
  use Ecto.Schema
  import Ecto.Changeset

  @type t() :: %__MODULE__{
          id: integer(),
          user_id: integer(),
          drawing_id: integer(),
          emoji: String.t(),
          inserted_at: DateTime.t()
        }

  embedded_schema do
    field :user_id, :integer
    field :drawing_id, :integer
    field :emoji, :string
    field :inserted_at, :utc_datetime
  end

  @doc false
  def changeset(reaction, attrs) do
    reaction
    |> cast(attrs, [:id, :user_id, :drawing_id, :emoji, :inserted_at])
    |> validate_required([:id, :user_id, :drawing_id, :emoji, :inserted_at])
  end
end
