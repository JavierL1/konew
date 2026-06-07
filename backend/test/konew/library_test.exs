defmodule Konew.LibraryTest do
  use Konew.DataCase

  alias Konew.Library

  describe "drawings" do
    alias Konew.Library.Drawing

    import Konew.AccountsFixtures, only: [user_scope_fixture: 0]
    import Konew.LibraryFixtures

    @invalid_attrs %{image_data: nil, content_type: nil}

    test "list_drawings/0 returns all drawings" do
      scope = user_scope_fixture()
      drawing = drawing_fixture(scope)
      assert Library.list_drawings() == [drawing]
    end

    test "get_drawing!/1 returns the drawing with given id" do
      scope = user_scope_fixture()
      drawing = drawing_fixture(scope)
      assert Library.get_drawing!(drawing.id) == drawing
    end

    test "create_drawing/1 with valid data creates a drawing" do
      scope = user_scope_fixture()

      valid_attrs = %{
        image_data: "some image_data",
        content_type: "some content_type"
      }

      assert {:ok, %Drawing{} = drawing} = Library.create_drawing(scope, valid_attrs)
      assert drawing.image_data == "some image_data"
      assert drawing.content_type == "some content_type"
    end

    test "create_drawing/1 with invalid data returns error changeset" do
      scope = user_scope_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Library.create_drawing(scope, @invalid_attrs)
    end

    test "update_drawing/2 with valid data updates the drawing" do
      scope = user_scope_fixture()
      drawing = drawing_fixture(scope)

      update_attrs = %{
        image_data: "some updated image_data",
        content_type: "some updated content_type"
      }

      assert {:ok, %Drawing{} = drawing} =
               Library.update_drawing(scope, drawing, update_attrs)

      assert drawing.image_data == "some updated image_data"
      assert drawing.content_type == "some updated content_type"
    end

    test "update_drawing/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      drawing = drawing_fixture(scope)

      assert {:error, %Ecto.Changeset{}} =
               Library.update_drawing(scope, drawing, @invalid_attrs)

      assert drawing == Library.get_drawing!(drawing.id)
    end

    test "delete_drawing/1 deletes the drawing" do
      scope = user_scope_fixture()
      drawing = drawing_fixture(scope)

      assert {:ok, %Drawing{}} = Library.delete_drawing(drawing)

      assert_raise Ecto.NoResultsError, fn ->
        Library.get_drawing!(drawing.id)
      end
    end

    test "change_drawing/1 returns a drawing changeset" do
      scope = user_scope_fixture()
      drawing = drawing_fixture(scope)
      assert %Ecto.Changeset{} = Library.change_drawing(scope, drawing)
    end
  end
end
