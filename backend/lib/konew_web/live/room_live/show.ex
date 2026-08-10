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
        if connected?(socket) do
          Phoenix.PubSub.subscribe(Konew.PubSub, "room:#{room.invite_code}")
        end

        # Preload members along with the session and its nested mechanic blueprint
        room = Konew.Repo.preload(room, [:members, session: [:mechanic, :events]])

        drawings =
          if room.session do
            fetch_drawings(room.session.events, room.members)
          else
            []
          end

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
          |> Konew.Repo.preload([:members, session: [:mechanic, :events]])

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
    room = socket.assigns.room
    ["data:" <> content_type_and_encoding, base64_data] = String.split(data_uri, ",", parts: 2)
    [content_type, "base64"] = String.split(content_type_and_encoding, ";", parts: 2)

    event_params = %{
      type: "drawing_submitted",
      data: %{
        "content_type" => content_type,
        "image_base64" => base64_data,
        "strokes" => strokes
      }
    }

    insert_event_with_retry(socket, event_params)
    |> case do
      {:ok, saved_event} ->
        Phoenix.PubSub.broadcast(
          Konew.PubSub,
          "room:#{socket.assigns.room.invite_code}",
          {:session_event_fired, saved_event}
        )

        drawings = fetch_drawings(room.session.events, room.members)

        {:noreply,
         socket
         |> put_flash(:info, "Masterpiece posted!")
         |> push_patch(to: ~p"/rooms/#{room.invite_code}")
         |> assign(:drawings, drawings)}

      {:error, changeset} ->
        Logger.error(
          "Failed to write session drawing_submitted event: #{inspect(changeset.errors)}"
        )

        {:noreply, put_flash(socket, :error, "Could not save your drawing. Please try again.")}
    end
  end

  @impl true
  def handle_event("delete-drawing", %{"id" => id}, socket) do
    room = socket.assigns.room

    event_params = %{
      type: "drawing_cleared",
      data: %{
        "drawing_id" => id
      }
    }

    insert_event_with_retry(socket, event_params)
    |> case do
      {:ok, saved_event} ->
        Phoenix.PubSub.broadcast(
          Konew.PubSub,
          "room:#{socket.assigns.room.invite_code}",
          {:session_event_fired, saved_event}
        )

        drawings = fetch_drawings(room.session.events, room.members)

        {:noreply,
         socket
         |> put_flash(:info, "Drawing deleted")
         |> push_patch(to: ~p"/rooms/#{room.invite_code}")
         |> assign(:drawings, drawings)}

      {:error, changeset} ->
        Logger.error(
          "Failed to write session drawing_cleared event: #{inspect(changeset.errors)}"
        )

        {:noreply, put_flash(socket, :error, "Could not delete your drawing. Please try again.")}
    end
  end

  @impl true
  def handle_info({:session_event_fired, event}, socket) do
    # Pass the single incoming event through our existing Projector clause block
    # (Remember to ensure `apply_event/2` is defined as public `def` instead of `defp` in RoomProjector!)
    updated_drawings =
      Konew.Engine.SessionProjector.apply_event(event, socket.assigns.drawings)
      |> hydrate_drawings(socket.assigns.room.members)

    # LiveView automatically recalculates the DOM differentials and updates the HTML instantly!
    {:noreply, assign(socket, :drawings, updated_drawings)}
  end

  defp fetch_drawings(events, members) do
    Engine.SessionProjector.project_drawings(events)
    |> hydrate_drawings(members)
  end

  defp hydrate_drawings(drawings, members) do
    members_by_id = Map.new(members, &{&1.id, &1})

    Enum.map(drawings, fn drawing ->
      drawing
      |> Map.put(:human_timestamp, Konew.Format.human_date(drawing.inserted_at))
      |> Map.put(:user, Map.get(members_by_id, drawing.user_id))
    end)
  end

  defp insert_event_with_retry(socket, event_params, attempt \\ 0) do
    session_id = socket.assigns.room.session.id
    next_sequence = Engine.get_next_sequence_number(session_id)

    event_params =
      Enum.into(event_params, %{
        session_id: session_id,
        sequence_number: next_sequence
      })

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

          insert_event_with_retry(socket, event_params, attempt + 1)
        else
          {:error, changeset}
        end
    end
  end
end
