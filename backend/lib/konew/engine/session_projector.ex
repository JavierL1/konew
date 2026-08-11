defmodule Konew.Engine.SessionProjector do
  alias Konew.Engine.SessionEvent
  alias Konew.Library.Drawing
  alias Konew.Interactions.Reaction

  @spec project_drawings(list(SessionEvent.t())) :: list(Drawing.t())
  def project_drawings(events) when is_list(events) do
    events
    |> Enum.reduce(
      %{},
      fn event, acc ->
        apply_event(event, acc)
      end
    )
    |> Map.values()
    |> Enum.sort_by(& &1.id)
  end

  def apply_event(%SessionEvent{type: "drawing_submitted"} = event, acc) do
    user_id = event.user_id

    Map.put(
      acc,
      event.sequence_number,
      %Drawing{
        id: event.sequence_number,
        image_data: event.data["image_base64"],
        content_type: event.data["content_type"],
        user_id: user_id,
        reactions: [],
        inserted_at: event.inserted_at,
        updated_at: event.inserted_at
      }
    )
  end

  def apply_event(%SessionEvent{type: "drawing_cleared"} = event, acc) do
    cleared_drawing_id = Utils.Integer.parse(event.data["drawing_id"])

    acc
    |> Map.get(cleared_drawing_id)
    |> case do
      %Drawing{user_id: user_id} when user_id == event.user_id ->
        Map.delete(acc, cleared_drawing_id)

      _ ->
        acc
    end
  end

  def apply_event(%SessionEvent{type: "drawing_reacted"} = event, acc) do
    reacted_drawing_id = Utils.Integer.parse(event.data["drawing_id"])

    acc
    |> Map.get(reacted_drawing_id)
    |> case do
      %Drawing{reactions: reactions} = drawing ->
        Map.put(acc, reacted_drawing_id, %Drawing{
          drawing
          | reactions: [
              %Reaction{
                id: event.sequence_number,
                user_id: event.user_id,
                drawing_id: reacted_drawing_id,
                emoji: event.data["emoji"],
                inserted_at: event.inserted_at
              }
              | reactions
            ]
        })

      _ ->
        acc
    end
  end

  def apply_event(_other_event, acc), do: acc
end
