defmodule Assign2_2 do
  @moduledoc false
  #MapSet difference on string list might been an easier solution
  def assignment do
    list = "data/assign2.data"
             |> File.read!()
             |> String.split("\r\n")

    Enum.map(list, fn item ->
      {item, calculate(item, list)}
    end)
    Enum.sort(result, &(elem(elem(&1, 1),1) > elem(elem(&2,1),1)))

  end

  def calculate(item, list) do

    list
    |> Enum.map(fn element ->
      {element, String.jaro_distance(item, element)}
    end)
    |> Enum.sort(&(elem(&1, 1) > elem(&2,1)))
    |> Enum.at(1)
  end
end
