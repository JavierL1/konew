defmodule KonewWeb.RoomLive.Show do
  use KonewWeb, :live_view

  require Logger

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

        drawings = fetch_room_drawings(room)

        {:ok,
         socket
         |> assign(:room, room)
         |> assign(:mechanics, [])
         |> assign(:drawings, drawings)}
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
        updated_room =
          Groups.get_room_by_code(room.invite_code)
          |> Konew.Repo.preload([:members, session: :mechanic])

        {:noreply,
         socket
         |> put_flash(:info, "Mechanic initialized successfully!")
         |> assign(:room, updated_room)
         |> push_patch(to: ~p"/rooms/#{room.invite_code}")}

      {:error, :session_already_exists} ->
        {:noreply,
         socket
         |> put_flash(
           :error,
           "This room already has an active session. Resetting must be explicit!"
         )
         |> push_patch(to: ~p"/rooms/#{room.invite_code}")}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Could not initialize mechanic.")}
    end
  end

  @impl true
  def handle_event("submit-drawing", %{"image-data" => data_uri, "strokes" => strokes}, socket) do
    ["data:" <> content_type_and_encoding, base64_data] = String.split(data_uri, ",", parts: 2)
    [content_type, "base64"] = String.split(content_type_and_encoding, ";", parts: 2)

    event_data = %{
      "content_type" => content_type,
      "image_base64" => base64_data,
      "strokes" => strokes
    }

    insert_event_with_retry(socket, event_data, 0)
    |> case do
      {:ok, saved_event} ->
        Phoenix.PubSub.broadcast(
          Konew.PubSub,
          "room:#{socket.assigns.room.invite_code}",
          {:session_event_fired, saved_event}
        )

        {:noreply,
         socket
         |> put_flash(:info, "Masterpiece posted!")
         |> push_patch(to: ~p"/rooms/#{socket.assigns.room.invite_code}")}

      {:error, changeset} ->
        Logger.error("Failed to write session drawing event: #{inspect(changeset.errors)}")
        {:noreply, put_flash(socket, :error, "Could not save your drawing. Please try again.")}
    end
  end

  defp fetch_room_drawings(_room) do
    Konew.Library.list_drawings()
    |> Konew.Repo.preload([:user])
    |> Enum.map(fn drawing ->
      Map.put(drawing, :human_timestamp, Konew.Format.human_date(drawing.inserted_at))
    end)
  end

  defp insert_event_with_retry(socket, event_data, attempt) do
    session_id = socket.assigns.room.session.id

    IO.inspect(socket.assigns.room)

    next_sequence = Engine.get_next_sequence_number(session_id)

    event_params = %{
      session_id: session_id,
      type: "drawing_submitted",
      sequence_number: next_sequence,
      data: event_data
    }

    %Engine.SessionEvent{}
    |> Engine.SessionEvent.changeset(event_params, socket.assigns.current_scope)
    |> Konew.Repo.insert()
    |> case do
      {:ok, event} ->
        {:ok, event}

      {:error, %Ecto.Changeset{} = changeset} ->
        is_unique_collision =
          Enum.any?(changeset.errors, fn
            {:sequence_number, {_, [constraint: :unique, constraint_name: _]}} -> true
            _ -> false
          end)

        if is_unique_collision do
          Logger.info(
            "🔄 Sequence collision detected on sequence ##{next_sequence} (Attempt #{attempt}). Retrying..."
          )

          insert_event_with_retry(socket, event_data, attempt + 1)
        else
          {:error, changeset}
        end
    end
  end
end
