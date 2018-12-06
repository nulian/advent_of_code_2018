defmodule Assign6_2 do
  @moduledoc false

  def assignment do
    data = "data/assign6.data" |> File.read!() |> String.split("\r\n")

    {coord_map, bounds} = data |> Stream.with_index() |> Enum.reduce({[], {1000, 1000, 0, 0}}, fn {item, index}, {list, {minx, miny, maxx, maxy}} ->
      [x, y] = String.split(item, ",")
      x = String.to_integer(x)
      y = String.to_integer(String.trim(y))
      minx = if x < minx, do: x, else: minx
      miny = if y < miny, do: y, else: miny
      maxx = if x > maxx, do: x, else: maxx
      maxy = if y > maxy, do: y, else: maxy
      {[{index, {x, y}} | list],{minx, miny, maxx, maxy}}
    end)

    coord_map
    |> Enum.into(%{})
    |> coord_loop(bounds)
  end

  def calculate_manhatten_distance({coord1_x, coord1_y}, {coord2_x, coord2_y}) do
    abs(abs(coord1_x - coord2_x) + abs(coord1_y - coord2_y))
  end

  def find_total_matching_distance(coord_map, coord) do
    Enum.reduce(coord_map, 0, fn
      {id, ^coord}, total_distance -> total_distance
      {id, coord1}, total_distance ->
      dist = calculate_manhatten_distance(coord1, coord)
      total_distance + dist
    end)
  end

  def coord_loop(coord_map, {minx, miny, maxx, maxy}) do
    result = Enum.reduce((minx)..(maxx), 0, fn x, acc ->
      Enum.reduce((miny)..(maxy), acc, fn y, com ->
        scan_coord = {x, y}
        case find_total_matching_distance(coord_map, scan_coord) do
          distance when distance < 10000 -> com + 1
          _ -> com
        end
      end)
    end)
  end
end
