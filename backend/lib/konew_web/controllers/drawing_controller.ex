defmodule KonewWeb.DrawingController do
  use KonewWeb, :controller

  import KonewWeb.CoreComponents, only: [translate_error: 1]

  def create(conn, %{"drawing" => %Plug.Upload{} = upload}) do
    binary_data = File.read!(upload.path)

    %{
      image_data: binary_data,
      content_type: upload.content_type
    }
    |> Konew.Library.create_drawing()
    |> case do
      {:ok, drawing} ->
        conn
        |> put_status(:created)
        |> json(%{id: drawing.id, message: "Drawing uploaded successfully"})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: Ecto.Changeset.traverse_errors(changeset, &translate_error/1)})
    end
  end
end
