defmodule Konew.Engine.SessionEvent do
  use Ecto.Schema
  import Ecto.Changeset

  @type t() :: %__MODULE__{
          id: integer(),
          type: String.t(),
          data: map(),
          sequence_number: integer(),
          session_id: integer(),
          session: Konew.Engine.Session.t() | Ecto.Association.NotLoaded.t(),
          user_id: integer(),
          user: Konew.Accounts.User.t() | Ecto.Association.NotLoaded.t(),
          inserted_at: DateTime.t()
        }

  schema "session_events" do
    field :type, :string
    field :data, :map
    field :sequence_number, :integer

    belongs_to :session, Konew.Engine.Session
    belongs_to :user, Konew.Accounts.User

    timestamps(type: :utc_datetime, updated_at: false)
  end

  @doc false
  def changeset(session_event, attrs, user_scope) do
    session_event
    |> cast(attrs, [:type, :data, :sequence_number, :session_id])
    |> validate_required([:type, :sequence_number, :session_id])
    |> put_change(:user_id, user_scope.user.id)
    |> unique_constraint([:session_id, :sequence_number],
      name: :session_events_session_id_sequence_number_index
    )
  end
end
