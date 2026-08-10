defmodule Utils.Integer do
  def parse(value) when is_integer(value), do: value

  def parse(value) when is_binary(value) do
    Integer.parse(value)
    |> case do
      {int_value, _} ->
        int_value

      _ ->
        0
    end
  end
end
