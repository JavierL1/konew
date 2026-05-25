defmodule Konew.Engine.SessionProjector do
  alias Konew.Engine.SessionEvent
  alias Konew.Library.Drawing

  @spec project_drawings(list(SessionEvent.t())) :: list(Drawing.t())
  def project_drawings(events) when is_list(events) do
    Enum.reduce(events, [], fn event, acc ->
      apply_event(event, acc)
    end)
  end

  def apply_event(%SessionEvent{type: "drawing_submitted"} = event, acc) do
    user_id = event.user_id

    [
      %Drawing{
        id: event.sequence_number,
        image_data: event.data["image_base64"],
        content_type: event.data["content_type"],
        user_id: user_id,
        inserted_at: event.inserted_at,
        updated_at: event.inserted_at
      }
      | acc
    ]
  end

  def apply_event(%SessionEvent{type: "drawing_cleared"} = event, acc) do
    cleared_drawing_id = event.data["drawing_id"]

    Enum.reject(acc, &(&1.id == cleared_drawing_id))
  end

  def apply_event(_other_event, acc), do: acc
end
