defmodule Konew.Format do
  def human_date(%DateTime{day: day, month: month, year: year, hour: hour, minute: minute}) do
    "#{zero_pad(day)}/#{zero_pad(month)}/#{zero_pad(year)} #{zero_pad(hour)}:#{zero_pad(minute)}"
  end

  defp zero_pad(number, count \\ 2) do
    number
    |> Integer.to_string()
    |> String.pad_leading(count, "0")
  end
end
