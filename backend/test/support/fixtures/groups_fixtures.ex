defmodule Konew.GroupsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Konew.Groups` context.
  """

  @doc """
  Generate a unique room invite_code.
  """
  def unique_room_invite_code, do: "some invite_code#{System.unique_integer([:positive])}"

  @doc """
  Generate a room.
  """
  def room_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        invite_code: unique_room_invite_code(),
        is_public: true,
        name: "some name"
      })

    {:ok, room} = Konew.Groups.create_room(scope, attrs)
    room
  end
end
