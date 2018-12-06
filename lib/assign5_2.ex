defmodule Assign5_2 do
  @moduledoc false

  @lowercase ?a..?z
  @uppercase ?A..?Z

  def assignment do
    data = "data/assign5.data"
           |> File.read!()
    |> String.to_charlist()
    Enum.reduce(?a..?z, %{}, fn x, acc ->
      filtered_data = Enum.reject(data, & &1 == x || &1 == :string.to_upper(x))
      result = reduce_string(filtered_data, length(filtered_data)) |> length
      Map.put(acc, x, result)
    end)
    |> Enum.sort(& elem(&1, 1) < elem(&2, 1))
    |> hd()
    |> elem(1)
  end

  def reduce_string(string, length) do
  result =string
    |> Enum.reduce({nil, []}, fn
      char, {nil, []} -> {char, [char]}
      char, {nil, list} -> {char, [char | list]}
      char, {prev, list} when (prev in @lowercase and char in @lowercase) or (prev in @uppercase and char in @uppercase) -> {char, [char | list]}
      char, {prev, list} ->
        if :string.to_lower([char]) == :string.to_lower([prev]) do
          {nil, tl(list)}
        else
          {char, [char | list]}
        end
    end)
    |> elem(1)
    |> Enum.reverse()

    if length(result) != length do
      reduce_string(result, length(result))
    else
      result
    end
  end

end
