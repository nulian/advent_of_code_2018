defmodule Assign6_1 do
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
    coord_map = Enum.into(coord_map, %{})
    {_, size} = coord_map
    |> get_non_infinite_points(bounds)
    |> Enum.map(fn index ->
      calculate_owned_area(coord_map, index, bounds)
    end)
    |> Enum.sort(& elem(&1,1) > elem(&2,1) )
    |> hd()

    size
  end

  def calculate_manhatten_distance({coord1_x, coord1_y}, {coord2_x, coord2_y}) do
    abs(abs(coord1_x - coord2_x) + abs(coord1_y - coord2_y))
  end

  def find_closest_matching_coords(coord_map, coord) do
    Enum.reduce(coord_map, [{nil, nil}], fn
      {id, ^coord}, best -> [{0, id}]
      {id, coord1}, best ->
      {distance, bid} = hd(best)
      dist = Assign6_1.calculate_manhatten_distance(coord1, coord)
      case distance do
        nil -> [{dist, id}]
        num when num == dist -> [{dist, id} | best]
        num when num > dist -> [{dist, id}]
        _ -> best
      end
    end)
  end

  def find_infinite_points(coord_map, {minx, miny, maxx, maxy}) do
    result = Enum.reduce((minx-1)..(maxx+1), [], fn x, acc ->
      coord = {x, miny - 1}
      [find_closest_matching_coords(coord_map, coord)| acc]
    end)
    result = Enum.reduce((minx-1)..(maxx+1), result, fn x, acc ->
      coord = {x, maxy + 1}
      [find_closest_matching_coords(coord_map, coord)| acc]
    end)
    result = Enum.reduce((miny-1)..(maxy+1), result, fn y, acc ->
      coord = {minx - 1, y}
      [find_closest_matching_coords(coord_map, coord)| acc]
    end)
    Enum.reduce((miny-1)..(maxy+1), result, fn y, acc ->
      coord = {maxx + 1, y}
      [find_closest_matching_coords(coord_map, coord)| acc]
    end)
    |> Enum.filter(& tl(&1) == [])
    |> List.flatten()
    |> Enum.map(& elem(&1, 1))
    |> Enum.uniq()
  end

  def get_non_infinite_points(coord_map, bounds) do
    infinite_points = find_infinite_points(coord_map, bounds)

    MapSet.difference(MapSet.new(0..49), MapSet.new(infinite_points)) |> MapSet.to_list()
  end

  def calculate_owned_area(coord_map, coord_index, {minx, miny, maxx, maxy}) do
    {x, y} = coord = Map.fetch!(coord_map, coord_index)

    coord_maxx = Enum.reduce_while((x+1)..maxx, x, fn mx, acc ->
      case Assign6_1.find_closest_matching_coords(coord_map, {mx, y}) do
        [{_, ^coord_index}] -> {:cont, mx}
        _ -> {:halt, acc}
      end
    end)

    coord_minx = Enum.reduce_while((x-1)..minx, x, fn mx, acc ->
      case Assign6_1.find_closest_matching_coords(coord_map, {mx, y}) do
        [{_, ^coord_index}] -> {:cont, mx}
        _ -> {:halt, acc}
      end
    end)

    coord_maxy = Enum.reduce_while((y+1)..maxy, y, fn my, acc ->
      case Assign6_1.find_closest_matching_coords(coord_map, {x, my}) do
        [{_, ^coord_index}] -> {:cont, my}
        _ -> {:halt, acc}
      end
    end)

    coord_miny = Enum.reduce_while((y-1)..miny, y, fn my, acc ->
      case Assign6_1.find_closest_matching_coords(coord_map, {x, my}) do
        [{_, ^coord_index}] -> {:cont, my}
        _ -> {:halt, acc}
      end
    end)
    {coord_minx, coord_maxx, coord_miny, coord_maxy}


    result = Enum.reduce((coord_minx)..(coord_maxx), 0, fn x, acc ->
      Enum.reduce((coord_miny)..(coord_maxy), acc, fn y, com ->
        scan_coord = {x, y}
        case Assign6_1.find_closest_matching_coords(coord_map, scan_coord) do
          [{_, ^coord_index}] -> com + 1
          _ -> com
        end
      end)
    end)
    {coord_index, result}
  end
end
