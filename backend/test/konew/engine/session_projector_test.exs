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

      assert %Konew.Library.Drawing{} = drawing
      assert drawing.id == drawing_submitted_event.sequence_number
      assert drawing.image_data == drawing_submitted_event.data["image_base64"]
      assert drawing.content_type == drawing_submitted_event.data["content_type"]
      assert drawing.user_id == drawing_submitted_event.user_id
      assert drawing.inserted_at == drawing_submitted_event.inserted_at
      assert drawing.updated_at == drawing_submitted_event.inserted_at
    end
  end
end
