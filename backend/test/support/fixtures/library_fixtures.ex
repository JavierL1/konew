defmodule Konew.LibraryFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Konew.Library` context.
  """

  @doc """
  Generate a drawing.
  """
  def drawing_fixture(attrs \\ %{}) do
    {:ok, drawing} =
      attrs
      |> Enum.into(%{
        content_type: "some content_type",
        image_data: "some image_data"
      })
      |> Konew.Library.create_drawing()

    drawing
  end
end
