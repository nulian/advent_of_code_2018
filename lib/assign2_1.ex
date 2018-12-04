defmodule Assign2_1 do
  @moduledoc false

  def assignment do
    {value1, value2} = "data/assign2.data"
             |> File.read!()
             |> String.split("\r\n")
             |> Enum.reduce({0, 0}, fn item, value ->
      calculate(item, value)
    end)

    value1 * value2
  end

  def calculate(item, {twice, thrice}) do
    result = item
    |> String.to_charlist()
    |> Enum.reduce(%{}, fn x, acc -> Map.update(acc, x, 1, &(&1 + 1)) end)
    |> Map.values()

    two = if 2 in result, do: 1, else: 0
    three = if 3 in result, do: 1, else: 0
    {twice + two, thrice + three}
  end
end
