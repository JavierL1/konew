defmodule Konew.EngineTest do
  use Konew.DataCase

  alias Konew.Engine

  describe "mechanics" do
    alias Konew.Engine.Mechanic

    import Konew.EngineFixtures

    @invalid_attrs %{name: nil, type: nil, config: nil, description: nil}

    test "list_mechanics/0 returns all mechanics" do
      mechanic = mechanic_fixture()
      assert Engine.list_mechanics() == [mechanic]
    end

    test "get_mechanic!/1 returns the mechanic with given id" do
      mechanic = mechanic_fixture()
      assert Engine.get_mechanic!(mechanic.id) == mechanic
    end

    test "create_mechanic/1 with valid data creates a mechanic" do
      valid_attrs = %{name: "some name", type: "some type", config: %{}, description: "some description"}

      assert {:ok, %Mechanic{} = mechanic} = Engine.create_mechanic(valid_attrs)
      assert mechanic.name == "some name"
      assert mechanic.type == "some type"
      assert mechanic.config == %{}
      assert mechanic.description == "some description"
    end

    test "create_mechanic/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Engine.create_mechanic(@invalid_attrs)
    end

    test "update_mechanic/2 with valid data updates the mechanic" do
      mechanic = mechanic_fixture()
      update_attrs = %{name: "some updated name", type: "some updated type", config: %{}, description: "some updated description"}

      assert {:ok, %Mechanic{} = mechanic} = Engine.update_mechanic(mechanic, update_attrs)
      assert mechanic.name == "some updated name"
      assert mechanic.type == "some updated type"
      assert mechanic.config == %{}
      assert mechanic.description == "some updated description"
    end

    test "update_mechanic/2 with invalid data returns error changeset" do
      mechanic = mechanic_fixture()
      assert {:error, %Ecto.Changeset{}} = Engine.update_mechanic(mechanic, @invalid_attrs)
      assert mechanic == Engine.get_mechanic!(mechanic.id)
    end

    test "delete_mechanic/1 deletes the mechanic" do
      mechanic = mechanic_fixture()
      assert {:ok, %Mechanic{}} = Engine.delete_mechanic(mechanic)
      assert_raise Ecto.NoResultsError, fn -> Engine.get_mechanic!(mechanic.id) end
    end

    test "change_mechanic/1 returns a mechanic changeset" do
      mechanic = mechanic_fixture()
      assert %Ecto.Changeset{} = Engine.change_mechanic(mechanic)
    end
  end

  describe "sessions" do
    alias Konew.Engine.Session

    import Konew.EngineFixtures

    @invalid_attrs %{state: nil, config: nil}

    test "list_sessions/0 returns all sessions" do
      session = session_fixture()
      assert Engine.list_sessions() == [session]
    end

    test "get_session!/1 returns the session with given id" do
      session = session_fixture()
      assert Engine.get_session!(session.id) == session
    end

    test "create_session/1 with valid data creates a session" do
      valid_attrs = %{state: %{}, config: %{}}

      assert {:ok, %Session{} = session} = Engine.create_session(valid_attrs)
      assert session.state == %{}
      assert session.config == %{}
    end

    test "create_session/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Engine.create_session(@invalid_attrs)
    end

    test "update_session/2 with valid data updates the session" do
      session = session_fixture()
      update_attrs = %{state: %{}, config: %{}}

      assert {:ok, %Session{} = session} = Engine.update_session(session, update_attrs)
      assert session.state == %{}
      assert session.config == %{}
    end

    test "update_session/2 with invalid data returns error changeset" do
      session = session_fixture()
      assert {:error, %Ecto.Changeset{}} = Engine.update_session(session, @invalid_attrs)
      assert session == Engine.get_session!(session.id)
    end

    test "delete_session/1 deletes the session" do
      session = session_fixture()
      assert {:ok, %Session{}} = Engine.delete_session(session)
      assert_raise Ecto.NoResultsError, fn -> Engine.get_session!(session.id) end
    end

    test "change_session/1 returns a session changeset" do
      session = session_fixture()
      assert %Ecto.Changeset{} = Engine.change_session(session)
    end
  end

  describe "session_events" do
    alias Konew.Engine.SessionEvent

    import Konew.AccountsFixtures, only: [user_scope_fixture: 0]
    import Konew.EngineFixtures

    @invalid_attrs %{data: nil, type: nil, sequence_number: nil}

    test "list_session_events/1 returns all scoped session_events" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      session_event = session_event_fixture(scope)
      other_session_event = session_event_fixture(other_scope)
      assert Engine.list_session_events(scope) == [session_event]
      assert Engine.list_session_events(other_scope) == [other_session_event]
    end

    test "get_session_event!/2 returns the session_event with given id" do
      scope = user_scope_fixture()
      session_event = session_event_fixture(scope)
      other_scope = user_scope_fixture()
      assert Engine.get_session_event!(scope, session_event.id) == session_event
      assert_raise Ecto.NoResultsError, fn -> Engine.get_session_event!(other_scope, session_event.id) end
    end

    test "create_session_event/2 with valid data creates a session_event" do
      valid_attrs = %{data: %{}, type: "some type", sequence_number: 42}
      scope = user_scope_fixture()

      assert {:ok, %SessionEvent{} = session_event} = Engine.create_session_event(scope, valid_attrs)
      assert session_event.data == %{}
      assert session_event.type == "some type"
      assert session_event.sequence_number == 42
      assert session_event.user_id == scope.user.id
    end

    test "create_session_event/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Engine.create_session_event(scope, @invalid_attrs)
    end

    test "update_session_event/3 with valid data updates the session_event" do
      scope = user_scope_fixture()
      session_event = session_event_fixture(scope)
      update_attrs = %{data: %{}, type: "some updated type", sequence_number: 43}

      assert {:ok, %SessionEvent{} = session_event} = Engine.update_session_event(scope, session_event, update_attrs)
      assert session_event.data == %{}
      assert session_event.type == "some updated type"
      assert session_event.sequence_number == 43
    end

    test "update_session_event/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      session_event = session_event_fixture(scope)

      assert_raise MatchError, fn ->
        Engine.update_session_event(other_scope, session_event, %{})
      end
    end

    test "update_session_event/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      session_event = session_event_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Engine.update_session_event(scope, session_event, @invalid_attrs)
      assert session_event == Engine.get_session_event!(scope, session_event.id)
    end

    test "delete_session_event/2 deletes the session_event" do
      scope = user_scope_fixture()
      session_event = session_event_fixture(scope)
      assert {:ok, %SessionEvent{}} = Engine.delete_session_event(scope, session_event)
      assert_raise Ecto.NoResultsError, fn -> Engine.get_session_event!(scope, session_event.id) end
    end

    test "delete_session_event/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      session_event = session_event_fixture(scope)
      assert_raise MatchError, fn -> Engine.delete_session_event(other_scope, session_event) end
    end

    test "change_session_event/2 returns a session_event changeset" do
      scope = user_scope_fixture()
      session_event = session_event_fixture(scope)
      assert %Ecto.Changeset{} = Engine.change_session_event(scope, session_event)
    end
  end
end
