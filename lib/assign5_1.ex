defmodule Assign5_1 do
  @moduledoc false

  @lowercase ?a..?z

  def assignment do
    data = "data/assign5.data"
           |> File.read!()
    |> String.to_charlist()

    reduce_string(data, length(data)) |> length
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
