defmodule Konew.Engine.SessionProjectorTest do
  use Konew.DataCase

  import Konew.EngineFixtures
  import Konew.AccountsFixtures, only: [user_scope_fixture: 0]

  describe "project_drawings/1" do
    test "returns an empty list when empty list is received" do
      assert Konew.Engine.SessionProjector.project_drawings([]) == []
    end

    test "returns a list containing a drawing if a drawing_submitted event is received" do
      scope = user_scope_fixture()
      session = session_fixture()
      drawing_submitted_event = drawing_submitted_fixture(scope, session)

      assert [drawing | []] =
               Konew.Engine.SessionProjector.project_drawings([drawing_submitted_event])

      check_drawing_and_drawing_submitted_event(drawing, drawing_submitted_event)
    end
  end

  describe "project_drawings/1 when receiving a drawing_cleared event" do
    test "returns an empty list when it corresponds with a drawing_submitted event" do
      scope = user_scope_fixture()
      session = session_fixture()
      drawing_submitted_event = drawing_submitted_fixture(scope, session)

      drawing_cleared_event =
        session_event_fixture(scope, session, %{
          type: "drawing_cleared",
          data: %{"drawing_id" => drawing_submitted_event.sequence_number},
          sequence_number: drawing_submitted_event.sequence_number + 1
        })

      assert [] =
               Konew.Engine.SessionProjector.project_drawings([
                 drawing_submitted_event,
                 drawing_cleared_event
               ])
    end

    test "returns a list containing a drawing when its user_id does not correspond to existing drawing" do
      scope = user_scope_fixture()
      session = session_fixture()
      drawing_submitted_event = drawing_submitted_fixture(scope, session)

      other_scope = user_scope_fixture()

      drawing_cleared_event =
        session_event_fixture(other_scope, session, %{
          type: "drawing_cleared",
          data: %{"drawing_id" => drawing_submitted_event.sequence_number},
          sequence_number: drawing_submitted_event.sequence_number + 1
        })

      assert [drawing | []] =
               Konew.Engine.SessionProjector.project_drawings([
                 drawing_submitted_event,
                 drawing_cleared_event
               ])

      check_drawing_and_drawing_submitted_event(drawing, drawing_submitted_event)
    end
  end

  describe "project_drawings/1 when receiving a drawing_reacted event" do
    test "returns a drawing with reactions array when it matches a drawing_submitted event" do
      scope = user_scope_fixture()
      session = session_fixture()
      drawing_submitted_event = drawing_submitted_fixture(scope, session)

      other_scope = user_scope_fixture()
      reaction_emoji = "😳"

      drawing_reacted_event =
        session_event_fixture(other_scope, session, %{
          type: "drawing_reacted",
          data: %{
            "drawing_id" => drawing_submitted_event.sequence_number,
            "emoji" => reaction_emoji
          },
          sequence_number: drawing_submitted_event.sequence_number + 1
        })

      assert [drawing | []] =
               Konew.Engine.SessionProjector.project_drawings([
                 drawing_submitted_event,
                 drawing_reacted_event
               ])

      check_drawing_and_drawing_submitted_event(drawing, drawing_submitted_event)
      assert [reaction | []] = drawing.reactions
      assert %Konew.Interactions.Reaction{} = reaction
      assert reaction.id == drawing_reacted_event.sequence_number
      assert reaction.user_id == drawing_reacted_event.user_id
      assert reaction.drawing_id == drawing.id
      assert reaction.emoji == reaction_emoji
    end
  end

  defp check_drawing_and_drawing_submitted_event(drawing, drawing_submitted_event) do
    assert %Konew.Library.Drawing{} = drawing
    assert drawing.id == drawing_submitted_event.sequence_number
    assert drawing.image_data == drawing_submitted_event.data["image_base64"]
    assert drawing.content_type == drawing_submitted_event.data["content_type"]
    assert drawing.user_id == drawing_submitted_event.user_id
    assert drawing.inserted_at == drawing_submitted_event.inserted_at
    assert drawing.updated_at == drawing_submitted_event.inserted_at
  end
end
