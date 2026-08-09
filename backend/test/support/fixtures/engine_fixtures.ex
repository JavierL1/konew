defmodule Konew.EngineFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Konew.Engine` context.
  """

  @doc """
  Generate a mechanic.
  """
  def mechanic_fixture(attrs \\ %{}) do
    {:ok, mechanic} =
      attrs
      |> Enum.into(%{
        config: %{},
        description: "some description",
        name: "some name",
        type: "some type"
      })
      |> Konew.Engine.create_mechanic()

    mechanic
  end

  @doc """
  Generate a session.
  """
  def session_fixture(attrs \\ %{}) do
    {:ok, session} =
      attrs
      |> Enum.into(%{
        config: %{},
        state: %{}
      })
      |> Konew.Engine.create_session()

    session
  end

  @doc """
  Generate a session_event.
  """
  def session_event_fixture(scope, session, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        data: %{},
        sequence_number: 42,
        type: "some type",
        session_id: session.id
      })

    {:ok, session_event} = Konew.Engine.create_session_event(scope, attrs)
    session_event
  end

  def drawing_submitted_fixture(scope, session, attrs \\ %{}) do
    {:ok, data} = get_json("test/support/sample_drawing.json")

    attrs = Enum.into(attrs, %{data: data, type: "drawing_submitted"})

    session_event_fixture(scope, session, attrs)
  end

  def get_json(filename) do
    with {:ok, body} <- File.read(filename), {:ok, json} <- Jason.decode(body), do: {:ok, json}
  end
end
