defmodule Konew.Seed do
  def run() do
    Konew.Engine.create_mechanic(%{
      name: "Free Drawing",
      type: "chill",
      description: "Just chill and draw with your friends",
      config: %{}
    })
  end
end
