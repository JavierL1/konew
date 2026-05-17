defmodule KonewWeb.RoomLive.Show do
  use KonewWeb, :live_view

  alias Konew.Groups
  alias Konew.Engine

  @impl true
  def mount(%{"invite_code" => code}, _session, socket) do
    case Groups.get_room_by_code(code) do
      nil ->
        {:ok,
         socket
         |> put_flash(:error, "Room not found")
         |> push_navigate(to: ~p"/rooms")}

      room ->
        # Preload members along with the session and its nested mechanic blueprint
        room = Konew.Repo.preload(room, [:members, session: :mechanic])

        {:ok,
         socket
         |> assign(:room, room)
         |> assign(:mechanics, [])}
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  # --- Live Actions Pattern Matching ---

  # Executed when navigating to /rooms/:invite_code/mechanics
  defp apply_action(socket, :select_mechanic, _params) do
    socket
    |> assign(:page_title, "Select Game Mechanic")
    |> assign(:mechanics, Engine.list_mechanics())
  end

  # Default fallback when simply viewing the room container
  defp apply_action(socket, _action, _params) do
    socket
    |> assign(:page_title, socket.assigns.room.name)
  end

  # --- UI Event Handlers ---

  @impl true
  def handle_event("select-mechanic", %{"mechanic-id" => mech_id}, socket) do
    room = socket.assigns.room

    case Engine.start_session_for_room(room.id, mech_id) do
      {:ok, _session} ->
        # Reload the room aggregate from the database to reflect the new state
        updated_room = Groups.get_room_by_code(room.invite_code) |> Konew.Repo.preload([:members, session: :mechanic])

        {:noreply,
         socket
         |> put_flash(:info, "Mechanic initialized successfully!")
         |> assign(:room, updated_room)
         |> push_patch(to: ~p"/rooms/#{room.invite_code}")}

      {:error, :session_already_exists} ->
        {:noreply,
         socket
         |> put_flash(:error, "This room already has an active session. Resetting must be explicit!")
         |> push_patch(to: ~p"/rooms/#{room.invite_code}")}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Could not initialize mechanic.")}
    end
  end
end
