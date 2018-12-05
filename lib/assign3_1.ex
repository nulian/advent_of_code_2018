defmodule Assign3_1 do
  @moduledoc false

  def assignment do
    claims = "data/assign3.data" |> File.read!() |> String.split("\r\n")

    result = Enum.reduce(claims, %{}, fn item, acc ->
      [margin, size] = item
      |> String.split("@")
      |> Enum.at(-1)
      |> String.split(":")

      [left_margin, top_margin] = parse_string(margin, ",")
      [left_size, top_size] = parse_string(size, "x")

      Enum.reduce(((left_margin+1)..(left_margin+left_size)), acc, fn x, acum ->
        Enum.reduce(((top_margin+1)..(top_margin+top_size)), acum, fn y, ac ->
         Map.update(ac, x, %{y => 1}, fn value -> Map.update(value, y, 1, &(&1 + 1)) end)
       end)
     end)

    end)

    Enum.reduce(result, 0, fn {_, map}, total ->
      Enum.reduce(map, total, fn
        {_, 1}, acc -> acc
        {_, item}, acc -> acc + 1
      end)
    end)
  end

  def parse_string(string, split_element) do
    string |> String.trim() |> String.split(split_element) |> Enum.map(&elem(Integer.parse(&1), 0))
  end
end
