defmodule Assign5_1 do
  @moduledoc false

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
      char, [prev | rest] when abs(char - prev) == 32 -> rest
      char, list -> [char | list]
    end)
  end

end
