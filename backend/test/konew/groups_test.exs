defmodule Konew.GroupsTest do
  use Konew.DataCase

  alias Konew.Groups

  describe "rooms" do
    alias Konew.Groups.Room

    import Konew.AccountsFixtures, only: [user_scope_fixture: 0]
    import Konew.GroupsFixtures

    @invalid_attrs %{name: nil, invite_code: nil, is_public: nil}

    test "list_rooms/1 returns all scoped rooms" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      room = room_fixture(scope)
      other_room = room_fixture(other_scope)
      assert Groups.list_rooms(scope) == [room]
      assert Groups.list_rooms(other_scope) == [other_room]
    end

    test "get_room!/2 returns the room with given id" do
      scope = user_scope_fixture()
      room = room_fixture(scope)
      other_scope = user_scope_fixture()
      assert Groups.get_room!(scope, room.id) == room
      assert_raise Ecto.NoResultsError, fn -> Groups.get_room!(other_scope, room.id) end
    end

    test "create_room/2 with valid data creates a room" do
      valid_attrs = %{name: "some name", invite_code: "some invite_code", is_public: true}
      scope = user_scope_fixture()

      assert {:ok, %Room{} = room} = Groups.create_room(scope, valid_attrs)
      assert room.name == "some name"
      assert room.invite_code == "some invite_code"
      assert room.is_public == true
      assert room.user_id == scope.user.id
    end

    test "create_room/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Groups.create_room(scope, @invalid_attrs)
    end

    test "update_room/3 with valid data updates the room" do
      scope = user_scope_fixture()
      room = room_fixture(scope)

      update_attrs = %{
        name: "some updated name",
        invite_code: "some updated invite_code",
        is_public: false
      }

      assert {:ok, %Room{} = room} = Groups.update_room(scope, room, update_attrs)
      assert room.name == "some updated name"
      assert room.invite_code == "some updated invite_code"
      assert room.is_public == false
    end

    test "update_room/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      room = room_fixture(scope)

      assert_raise MatchError, fn ->
        Groups.update_room(other_scope, room, %{})
      end
    end

    test "update_room/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      room = room_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Groups.update_room(scope, room, @invalid_attrs)
      assert room == Groups.get_room!(scope, room.id)
    end

    test "delete_room/2 deletes the room" do
      scope = user_scope_fixture()
      room = room_fixture(scope)
      assert {:ok, %Room{}} = Groups.delete_room(scope, room)
      assert_raise Ecto.NoResultsError, fn -> Groups.get_room!(scope, room.id) end
    end

    test "delete_room/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      room = room_fixture(scope)
      assert_raise MatchError, fn -> Groups.delete_room(other_scope, room) end
    end

    test "change_room/2 returns a room changeset" do
      scope = user_scope_fixture()
      room = room_fixture(scope)
      assert %Ecto.Changeset{} = Groups.change_room(scope, room)
    end
  end
end
