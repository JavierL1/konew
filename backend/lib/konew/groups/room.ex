defmodule Konew.Groups.Room do
  use Ecto.Schema
  import Ecto.Changeset

  schema "rooms" do
    field :name, :string
    field :invite_code, :string
    field :is_public, :boolean, default: false

    belongs_to :owner, Konew.Accounts.User, foreign_key: :owner_id
    many_to_many :members, Konew.Accounts.User, join_through: Konew.Groups.RoomMembership

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
