defmodule Assign3_2 do
  @moduledoc false

  def assignment do
    claims = "data/assign3.data" |> File.read!() |> String.split("\r\n")

    result = Enum.reduce(claims, %{}, fn item, acc ->
      [margin, size] = item
      |> String.split("@")
      |> Enum.at(-1)
      |> String.split(":")

      claim = item |> String.split("@") |> hd() |> String.trim() |> String.slice(1, 100) |> Integer.parse() |> elem(0)

      [left_margin, top_margin] = parse_string(margin, ",")
      [left_size, top_size] = parse_string(size, "x")

      Enum.reduce(((left_margin+1)..(left_margin+left_size)), acc, fn x, acum ->
        Enum.reduce(((top_margin+1)..(top_margin+top_size)), acum, fn y, ac ->
         Map.update(ac, x, %{y => [claim]}, fn value -> Map.update(value, y, [claim], fn item -> [claim | item] end) end)
       end)
     end)

    end)
    result
    |> Enum.reduce([], fn {_, map}, total ->
      Enum.reduce(map, total, fn
        {_, [_item]}, acc -> acc
        {_, items}, acc -> [items | acc]
      end)
    end)
    |> List.flatten
    |> Enum.uniq
    |> Enum.sort
    |> Enum.reduce_while(0, fn item, acc -> if item == (acc + 1), do: {:cont, item}, else: {:halt, acc + 1} end)
  end

  def parse_string(string, split_element) do
    string |> String.trim() |> String.split(split_element) |> Enum.map(&elem(Integer.parse(&1), 0))
  end
end
