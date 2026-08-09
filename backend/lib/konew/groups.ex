defmodule Konew.Groups do
  @moduledoc """
  The Groups context.
  """

  import Ecto.Query, warn: false
  alias Ecto.Multi
  alias Konew.Repo

  alias Konew.Groups.{Room, RoomMembership}
  alias Konew.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any room changes.

  The broadcasted messages match the pattern:

    * {:created, %Room{}}
    * {:updated, %Room{}}
    * {:deleted, %Room{}}

  """
  def subscribe_rooms(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(Konew.PubSub, "user:#{key}:rooms")
  end

  defp broadcast_room(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(Konew.PubSub, "user:#{key}:rooms", message)
  end

  @doc """
  Returns the list of rooms.

  ## Examples

      iex> list_rooms()
      [%Room{}, ...]

  """
  def list_rooms() do
    Repo.all(Room)
  end

  @doc """
  Gets a single room.

  Raises `Ecto.NoResultsError` if the Room does not exist.

  ## Examples

      iex> get_room!(123)
      %Room{}

      iex> get_room!(456)
      ** (Ecto.NoResultsError)

  """
  def get_room!(id) do
    Repo.get_by!(Room, id: id)
  end

  @spec get_rooms_by_owner(integer()) :: list(Room.t())
  def get_rooms_by_owner(owner_id) do
    from(
      room in Room,
      where: room.owner_id == ^owner_id
    )
    |> Konew.Repo.all()
  end

  def get_rooms_by_member(member_id) do
    from(
      room in Room,
      join: membership in RoomMembership,
      on: room.id == membership.room_id,
      where: membership.user_id == ^member_id,
      select: room,
      distinct: true
    )
    |> Konew.Repo.all()
  end

  @doc """
  Get a single room by its code
  """
  def get_room_by_code(code) do
    Konew.Repo.get_by(Konew.Groups.Room, invite_code: String.upcase(code))
  end

  @doc """
  Creates a room.

  ## Examples

      iex> create_room(scope, %{field: value})
      {:ok, %Room{}}

      iex> create_room(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_room(%Scope{} = scope, attrs) do
    invite_code = generate_6_char_code()

    attrs_with_defaults =
      Enum.into(attrs, %{"owner_id" => scope.user.id, "invite_code" => invite_code})

    Multi.new()
    |> Multi.insert(:room, Room.changeset(%Room{}, attrs_with_defaults))
    |> Multi.insert(:membership, fn %{room: room} ->
      RoomMembership.changeset(%RoomMembership{}, %{
        user_id: scope.user.id,
        room_id: room.id
      })
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{room: room}} ->
        {:ok, room}

      {:error, :room, changeset, _context} ->
        {:error, changeset}

      error ->
        error
    end
  end

  @doc """
  Updates a room.

  ## Examples

      iex> update_room(scope, room, %{field: new_value})
      {:ok, %Room{}}

      iex> update_room(scope, room, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_room(%Scope{} = scope, %Room{} = room, attrs) do
    true = room.owner_id == scope.user.id
    attrs_with_owner = Map.put(attrs, :owner_id, scope.user.id)

    with {:ok, room = %Room{}} <-
           room
           |> Room.changeset(attrs_with_owner)
           |> Repo.update() do
      broadcast_room(scope, {:updated, room})
      {:ok, room}
    end
  end

  @doc """
  Deletes a room.

  ## Examples

      iex> delete_room(scope, room)
      {:ok, %Room{}}

      iex> delete_room(scope, room)
      {:error, %Ecto.Changeset{}}

  """
  def delete_room(%Scope{} = scope, %Room{} = room) do
    true = room.owner_id == scope.user.id

    with {:ok, room = %Room{}} <-
           Repo.delete(room) do
      broadcast_room(scope, {:deleted, room})
      {:ok, room}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking room changes.

  ## Examples

      iex> change_room(scope, room)
      %Ecto.Changeset{data: %Room{}}

  """
  def change_room(%Scope{} = scope, %Room{} = room, attrs \\ %{}) do
    attrs_with_owner = Map.put(attrs, "owner_id", scope.user.id)

    Room.changeset(room, attrs_with_owner)
  end

  def join_room(%Scope{} = scope, %Room{} = room) do
    RoomMembership.changeset(%RoomMembership{}, %{
      user_id: scope.user.id,
      room_id: room.id
    })
    |> Repo.insert()
  end

  defp generate_6_char_code do
    alphabet =
      "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789" |> String.split("", trim: true)

    1..6
    |> Enum.map(fn _ -> Enum.random(alphabet) end)
    |> Enum.join()
  end
end
