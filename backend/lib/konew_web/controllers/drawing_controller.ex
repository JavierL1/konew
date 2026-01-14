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

  def show_image(conn, %{"id" => id}) do
    drawing = Konew.Library.get_drawing!(id)

    conn
    |> put_resp_content_type(drawing.content_type)
    |> send_resp(200, drawing.image_data)
  end

  def index(conn, _params) do
    drawings = Konew.Library.list_drawings()
    render(conn, :index, drawings: drawings)
  end
end
