defmodule Assign4_1 do
  @moduledoc false
  def assignment do
    data = "data/assign4.data" |> File.read!() |> String.split("\n")
    result = Enum.map(data, fn item ->
      ["[" <> timestamp, text] = item
      |> String.split("]")

      {timestamp, String.trim(text)}
    end)
    |> Enum.sort(&(elem(&1, 0) < elem(&2, 0)))
    |> Enum.map(fn {timestamp, text} ->
      {Timex.parse!(timestamp, "{YYYY}-{0M}-{D} {h24}:{m}"), text}
    end)
    |> Enum.reduce()
  end
end
