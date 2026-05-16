defmodule Konew.Engine.Mechanic do
  use Ecto.Schema
  import Ecto.Changeset

  @type t() :: %__MODULE__{
          id: integer(),
          name: String.t(),
          type: String.t(),
          description: String.t(),
          config: map(),
          sessions: list(Konew.Engine.Session.t()) | Ecto.Association.NotLoaded.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "mechanics" do
    field :name, :string
    field :type, :string
    field :description, :string
    field :config, :map
    has_many :sessions, Konew.Engine.Session

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(mechanic, attrs) do
    mechanic
    |> cast(attrs, [:name, :type, :description, :config])
    |> validate_required([:name, :description])
  end
end
