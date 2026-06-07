defmodule Konew.LibraryFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Konew.Library` context.
  """

  @doc """
  Generate a drawing.
  """
  def drawing_fixture(scope, attrs \\ %{}) do
    attrs =
      attrs
      |> Enum.into(%{
        content_type: "some content_type",
        image_data: "some image_data"
      })

    {:ok, drawing} = Konew.Library.create_drawing(scope, attrs)

    drawing
  end
end
