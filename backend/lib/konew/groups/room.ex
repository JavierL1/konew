defmodule Konew.Groups.Room do
  use Ecto.Schema
  import Ecto.Changeset

  @type t() :: %{
          name: String.t(),
          invite_code: String.t(),
          is_public: boolean(),
          owner_id: integer(),
          owner: Konew.Accounts.User.t() | Ecto.Association.NotLoaded.t(),
          members: list(Konew.Accounts.User.t()) | Ecto.Association.NotLoaded.t(),
          session: Konew.Engine.Session.t() | Ecto.Association.NotLoaded.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "rooms" do
    field :name, :string
    field :invite_code, :string
    field :is_public, :boolean, default: false

    belongs_to :owner, Konew.Accounts.User, foreign_key: :owner_id
    many_to_many :members, Konew.Accounts.User, join_through: Konew.Groups.RoomMembership
    has_one :session, Konew.Engine.Session

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(room, attrs) do
    room
    |> cast(attrs, [:name, :invite_code, :is_public, :owner_id])
    |> validate_required([:name, :invite_code, :is_public, :owner_id])
    |> unique_constraint(:invite_code)
  end
end
