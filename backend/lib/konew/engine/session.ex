defmodule Konew.Engine.Session do
  use Ecto.Schema
  import Ecto.Changeset

  @type t() :: %__MODULE__{
          id: integer(),
          config: map(),
          state: map(),
          room_id: integer(),
          room: Konew.Groups.Room.t() | Ecto.Association.NotLoaded.t(),
          mechanic_id: integer(),
          mechanic: Konew.Engine.Mechanic.t() | Ecto.Association.NotLoaded.t(),
          events: list(Konew.Engine.SessionEvent.t()) | Ecto.Association.NotLoaded.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "sessions" do
    field :config, :map
    field :state, :map

    belongs_to :room, Konew.Groups.Room
    belongs_to :mechanic, Konew.Engine.Mechanic
    has_many :events, Konew.Engine.SessionEvent

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(session, attrs) do
    session
    |> cast(attrs, [:room_id, :mechanic_id, :config, :state])
    |> validate_required([])
  end
end
