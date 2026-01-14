defmodule Konew.LibraryTest do
  use Konew.DataCase

  alias Konew.Library

  describe "drawings" do
    alias Konew.Library.Drawing

    import Konew.LibraryFixtures

    @invalid_attrs %{image_data: nil, content_type: nil}

    test "list_drawings/0 returns all drawings" do
      drawing = drawing_fixture()
      assert Library.list_drawings() == [drawing]
    end

    test "get_drawing!/1 returns the drawing with given id" do
      drawing = drawing_fixture()
      assert Library.get_drawing!(drawing.id) == drawing
    end

    test "create_drawing/1 with valid data creates a drawing" do
      valid_attrs = %{image_data: "some image_data", content_type: "some content_type"}

      assert {:ok, %Drawing{} = drawing} = Library.create_drawing(valid_attrs)
      assert drawing.image_data == "some image_data"
      assert drawing.content_type == "some content_type"
    end

    test "create_drawing/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Library.create_drawing(@invalid_attrs)
    end

    test "update_drawing/2 with valid data updates the drawing" do
      drawing = drawing_fixture()
      update_attrs = %{image_data: "some updated image_data", content_type: "some updated content_type"}

      assert {:ok, %Drawing{} = drawing} = Library.update_drawing(drawing, update_attrs)
      assert drawing.image_data == "some updated image_data"
      assert drawing.content_type == "some updated content_type"
    end

    test "update_drawing/2 with invalid data returns error changeset" do
      drawing = drawing_fixture()
      assert {:error, %Ecto.Changeset{}} = Library.update_drawing(drawing, @invalid_attrs)
      assert drawing == Library.get_drawing!(drawing.id)
    end

    test "delete_drawing/1 deletes the drawing" do
      drawing = drawing_fixture()
      assert {:ok, %Drawing{}} = Library.delete_drawing(drawing)
      assert_raise Ecto.NoResultsError, fn -> Library.get_drawing!(drawing.id) end
    end

    test "change_drawing/1 returns a drawing changeset" do
      drawing = drawing_fixture()
      assert %Ecto.Changeset{} = Library.change_drawing(drawing)
    end
  end
end
