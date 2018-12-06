defmodule Assign5_1 do
  @moduledoc false

  @lowercase ?a..?z
  @uppercase ?A..?Z

  def assignment do
    data = "data/assign5.data"
           |> File.read!()
    |> String.to_charlist()

    reduce_string(data, length(data)) |> length
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
