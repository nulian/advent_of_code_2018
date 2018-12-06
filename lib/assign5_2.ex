defmodule Assign5_2 do
  @moduledoc false

  @lowercase ?a..?z

  def assignment do
    data = "data/assign5.data"
           |> File.read!()
    |> String.to_charlist()
    Enum.reduce(@lowercase, %{}, fn x, acc ->
      filtered_data = Enum.reject(data, & &1 == x || &1 == :string.to_upper(x))
      result = reduce_string(filtered_data, length(filtered_data)) |> length
      Map.put(acc, x, result)
    end)
    |> Enum.sort(& elem(&1, 1) < elem(&2, 1))
    |> hd()
    |> elem(1)
  end

  def reduce_string(string, length) do
    string
    |> Enum.reduce([], fn
      char, [] -> [char]
      char, [prev | rest] = list ->
        if :string.to_lower([char]) == :string.to_lower([prev]) do
          rest
        else
          [char | list]
        end
    end)
  end

end
