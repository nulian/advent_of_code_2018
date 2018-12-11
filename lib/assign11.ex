defmodule Assign11 do
  @moduledoc false

  @size 300
  @serial 8

  def assignment(serial) do
    Enum.reduce(1..@size, %{}, fn y, acum ->
      Enum.reduce(1..@size, acum, fn x, acc ->
        Map.update(acc, y, %{x => calculate_power_level(x, y, serial)}, fn value -> Map.put(value, x, calculate_power_level(x,y, serial)) end)
      end)
    end)
  end

  def calculate_power_level(x, y, serial) do
    rack_id = x + 10

    value = rack_id
    |> Kernel.*(y)
    |> Kernel.+(serial)
    |> Kernel.*(rack_id)

    num = case value |> Integer.to_charlist() |> Enum.at(-3) do
      nil -> 0
      value -> List.to_integer([value])
    end

    num - 5
  end

  def find_highest_value(field, size) do
    Enum.reduce(1..@size, {0, 0, 0}, fn
      y, acum when y > (@size - size + 1) -> acum
      y, acum ->
      Enum.reduce(1..@size, acum, fn
        x, acc when x > (@size - size + 1) -> acc
        x, {value, _, _} = acc ->
        new_value = calculate_3x3_grid_value(x, y, field, size)

        if new_value > value do
          {new_value, x, y}
        else
          acc
        end
      end)
    end)
  end

  def calculate_3x3_grid_value(x, y, map, size) do
    Enum.map(y..(y+size-1), fn y ->
      Enum.map(x..(x+size-1), fn x ->
        Map.get(Map.get(map, y),x)
      end)
    end)
    |> List.flatten()
    |> Enum.sum()
  end

end
