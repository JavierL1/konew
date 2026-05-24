defmodule Konew.Engine do
  @moduledoc """
  The Engine context.
  """

  import Ecto.Query, warn: false
  alias Konew.Repo

  alias Konew.Engine.Mechanic

  @doc """
  Returns the list of mechanics.

  ## Examples

      iex> list_mechanics()
      [%Mechanic{}, ...]

  """
  def list_mechanics do
    Repo.all(Mechanic)
  end

  @doc """
  Gets a single mechanic.

  Raises `Ecto.NoResultsError` if the Mechanic does not exist.

  ## Examples

      iex> get_mechanic!(123)
      %Mechanic{}

      iex> get_mechanic!(456)
      ** (Ecto.NoResultsError)

  """
  def get_mechanic!(id), do: Repo.get!(Mechanic, id)

  @doc """
  Creates a mechanic.

  ## Examples

      iex> create_mechanic(%{field: value})
      {:ok, %Mechanic{}}

      iex> create_mechanic(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_mechanic(attrs) do
    %Mechanic{}
    |> Mechanic.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a mechanic.

  ## Examples

      iex> update_mechanic(mechanic, %{field: new_value})
      {:ok, %Mechanic{}}

      iex> update_mechanic(mechanic, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_mechanic(%Mechanic{} = mechanic, attrs) do
    mechanic
    |> Mechanic.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a mechanic.

  ## Examples

      iex> delete_mechanic(mechanic)
      {:ok, %Mechanic{}}

      iex> delete_mechanic(mechanic)
      {:error, %Ecto.Changeset{}}

  """
  def delete_mechanic(%Mechanic{} = mechanic) do
    Repo.delete(mechanic)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking mechanic changes.

  ## Examples

      iex> change_mechanic(mechanic)
      %Ecto.Changeset{data: %Mechanic{}}

  """
  def change_mechanic(%Mechanic{} = mechanic, attrs \\ %{}) do
    Mechanic.changeset(mechanic, attrs)
  end

  alias Konew.Engine.Session

  @doc """
  Returns the list of sessions.

  ## Examples

      iex> list_sessions()
      [%Session{}, ...]

  """
  def list_sessions do
    Repo.all(Session)
  end

  @doc """
  Gets a single session.

  Raises `Ecto.NoResultsError` if the Session does not exist.

  ## Examples

      iex> get_session!(123)
      %Session{}

      iex> get_session!(456)
      ** (Ecto.NoResultsError)

  """
  def get_session!(id), do: Repo.get!(Session, id)

  @doc """
  Creates a session.

  ## Examples

      iex> create_session(%{field: value})
      {:ok, %Session{}}

      iex> create_session(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_session(attrs) do
    %Session{}
    |> Session.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a session.

  ## Examples

      iex> update_session(session, %{field: new_value})
      {:ok, %Session{}}

      iex> update_session(session, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_session(%Session{} = session, attrs) do
    session
    |> Session.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a session.

  ## Examples

      iex> delete_session(session)
      {:ok, %Session{}}

      iex> delete_session(session)
      {:error, %Ecto.Changeset{}}

  """
  def delete_session(%Session{} = session) do
    Repo.delete(session)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking session changes.

  ## Examples

      iex> change_session(session)
      %Ecto.Changeset{data: %Session{}}

  """
  def change_session(%Session{} = session, attrs \\ %{}) do
    Session.changeset(session, attrs)
  end

  @doc """
  Starts a new session for a room using a specific mechanic template.
  Fails if an active session already exists for the given room.
  """
  def start_session_for_room(room_id, mechanic_id) do
    Repo.transaction(fn ->
      case Repo.get_by(Session, room_id: room_id) do
        %Session{} ->
          Repo.rollback(:session_already_exists)

        nil ->
          mechanic = Repo.get!(Mechanic, mechanic_id)

          %Session{}
          |> Session.changeset(%{
            room_id: room_id,
            mechanic_id: mechanic_id,
            config: mechanic.config,
            state: %{}
          })
          |> Repo.insert!()
      end
    end)
  end

  alias Konew.Engine.SessionEvent
  alias Konew.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any session_event changes.

  The broadcasted messages match the pattern:

    * {:created, %SessionEvent{}}
    * {:updated, %SessionEvent{}}
    * {:deleted, %SessionEvent{}}

  """
  def subscribe_session_events(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(Konew.PubSub, "user:#{key}:session_events")
  end

  defp broadcast_session_event(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(
      Konew.PubSub,
      "user:#{key}:session_events",
      message
    )
  end

  @doc """
  Returns the list of session_events.

  ## Examples

      iex> list_session_events(scope)
      [%SessionEvent{}, ...]

  """
  def list_session_events(%Scope{} = scope) do
    Repo.all_by(SessionEvent, user_id: scope.user.id)
  end

  @doc """
  Gets a single session_event.

  Raises `Ecto.NoResultsError` if the Session event does not exist.

  ## Examples

      iex> get_session_event!(scope, 123)
      %SessionEvent{}

      iex> get_session_event!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_session_event!(%Scope{} = scope, id) do
    Repo.get_by!(SessionEvent, id: id, user_id: scope.user.id)
  end

  @doc """
  Creates a session_event.

  ## Examples

      iex> create_session_event(scope, %{field: value})
      {:ok, %SessionEvent{}}

      iex> create_session_event(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_session_event(%Scope{} = scope, attrs) do
    with {:ok, session_event = %SessionEvent{}} <-
           %SessionEvent{}
           |> SessionEvent.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_session_event(scope, {:created, session_event})
      {:ok, session_event}
    end
  end

  @doc """
  Updates a session_event.

  ## Examples

      iex> update_session_event(scope, session_event, %{field: new_value})
      {:ok, %SessionEvent{}}

      iex> update_session_event(scope, session_event, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_session_event(
        %Scope{} = scope,
        %SessionEvent{} = session_event,
        attrs
      ) do
    true = session_event.user_id == scope.user.id

    with {:ok, session_event = %SessionEvent{}} <-
           session_event
           |> SessionEvent.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_session_event(scope, {:updated, session_event})
      {:ok, session_event}
    end
  end

  @doc """
  Deletes a session_event.

  ## Examples

      iex> delete_session_event(scope, session_event)
      {:ok, %SessionEvent{}}

      iex> delete_session_event(scope, session_event)
      {:error, %Ecto.Changeset{}}

  """
  def delete_session_event(%Scope{} = scope, %SessionEvent{} = session_event) do
    true = session_event.user_id == scope.user.id

    with {:ok, session_event = %SessionEvent{}} <-
           Repo.delete(session_event) do
      broadcast_session_event(scope, {:deleted, session_event})
      {:ok, session_event}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking session_event changes.

  ## Examples

      iex> change_session_event(scope, session_event)
      %Ecto.Changeset{data: %SessionEvent{}}

  """
  def change_session_event(
        %Scope{} = scope,
        %SessionEvent{} = session_event,
        attrs \\ %{}
      ) do
    true = session_event.user_id == scope.user.id

    SessionEvent.changeset(session_event, attrs, scope)
  end
end
