defmodule KonewWeb.DrawingController do
  use KonewWeb, :controller

  import KonewWeb.CoreComponents, only: [translate_error: 1]

  def new(conn, _params) do
    render(conn, :new)
  end

  def create(conn, %{"drawing" => %Plug.Upload{} = upload}) do
    binary_data = File.read!(upload.path)
    user = conn.assigns.current_scope.user

    %{
      image_data: binary_data,
      content_type: upload.content_type,
      user_id: user.id
    }
    |> Konew.Library.create_drawing()
    |> case do
      {:ok, drawing} ->
        create_success(conn, drawing)

      {:error, changeset} ->
        create_error(conn, changeset)
    end
  end

  defp create_success(conn, drawing) do
    case get_format(conn) do
      "json" ->
        conn
        |> put_status(:created)
        |> json(%{id: drawing.id, message: "Drawing uploaded successfully"})

      _ ->
        conn
        |> put_flash(:info, "Drawing shared with the world!")
        |> redirect(to: ~p"/drawings")
    end
  end

  defp create_error(conn, changeset) do
    case get_format(conn) do
      "json" ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: Ecto.Changeset.traverse_errors(changeset, &translate_error/1)})

      _ ->
        conn
        |> put_flash(:error, "Could not save drawing.")
        |> render(:new)
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
