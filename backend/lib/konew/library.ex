defmodule Konew.Library do
  @moduledoc """
  The Library context.
  """

  import Ecto.Query, warn: false
  alias Konew.Repo

  alias Konew.Library.Drawing

  @doc """
  Returns the list of drawings.

  ## Examples

      iex> list_drawings()
      [%Drawing{}, ...]

  """
  def list_drawings do
    Repo.all(Drawing)
  end

  @doc """
  Gets a single drawing.

  Raises `Ecto.NoResultsError` if the Drawing does not exist.

  ## Examples

      iex> get_drawing!(123)
      %Drawing{}

      iex> get_drawing!(456)
      ** (Ecto.NoResultsError)

  """
  def get_drawing!(id), do: Repo.get!(Drawing, id)

  @doc """
  Creates a drawing.

  ## Examples

      iex> create_drawing(%{field: value})
      {:ok, %Drawing{}}

      iex> create_drawing(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_drawing(attrs) do
    %Drawing{}
    |> Drawing.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a drawing.

  ## Examples

      iex> update_drawing(drawing, %{field: new_value})
      {:ok, %Drawing{}}

      iex> update_drawing(drawing, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_drawing(%Drawing{} = drawing, attrs) do
    drawing
    |> Drawing.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a drawing.

  ## Examples

      iex> delete_drawing(drawing)
      {:ok, %Drawing{}}

      iex> delete_drawing(drawing)
      {:error, %Ecto.Changeset{}}

  """
  def delete_drawing(%Drawing{} = drawing) do
    Repo.delete(drawing)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking drawing changes.

  ## Examples

      iex> change_drawing(drawing)
      %Ecto.Changeset{data: %Drawing{}}

  """
  def change_drawing(%Drawing{} = drawing, attrs \\ %{}) do
    Drawing.changeset(drawing, attrs)
  end
end
