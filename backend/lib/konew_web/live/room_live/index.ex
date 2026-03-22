defmodule KonewWeb.RoomLive.Index do
  use KonewWeb, :live_view

  alias Konew.Groups
  alias Konew.Groups.Room

  @impl true
  def mount(_params, _session, socket) do
    # We list the rooms the user is already a member of
    {:ok, assign(socket, :rooms, Groups.list_rooms())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  # When the URL is /rooms/new, we initialize a blank form
  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Room")
    |> assign(:room, %Room{})
    |> assign(:form, to_form(Groups.change_room(socket.assigns.current_scope, %Room{})))
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "My Boxes")
    |> assign(:room, nil)
  end

  @impl true
  def handle_event("validate", %{"room" => room_params}, socket) do
    changeset =
      socket.assigns.current_scope
      |> Groups.change_room(%Room{}, room_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  @impl true
  def handle_event("save", %{"room" => room_params}, socket) do
    case Groups.create_room(socket.assigns.current_scope, room_params) do
      {:ok, %{room: room}} ->
        {:noreply,
         socket
         |> put_flash(:info, "Box created successfully!")
         |> push_navigate(to: ~p"/rooms/#{room.invite_code}")}

      {:error, :room, changeset, _} ->
        {:noreply, assign(socket, form: to_form(changeset))}

      _ ->
        {:noreply, put_flash(socket, :error, "Something went wrong.")}
    end
  end
end
