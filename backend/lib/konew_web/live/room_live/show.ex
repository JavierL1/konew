defmodule KonewWeb.RoomLive.Show do
  use KonewWeb, :live_view
  alias Konew.Groups

  @impl true
  def mount(%{"invite_code" => code}, _session, socket) do
    case Groups.get_room_by_code(code) do
      nil ->
        {:ok,
         socket
         |> put_flash(:error, "Room not found")
         |> push_navigate(to: ~p"/rooms")}

      room ->
        room = Konew.Repo.preload(room, :members)
        {:ok, assign(socket, :room, room)}
    end
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end
end
