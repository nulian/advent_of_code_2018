defmodule Assign1_1 do
  @moduledoc """
  Documentation for AdventOfCode.
  """

  @doc """
  Hello world.

  ## Examples

      iex> AdventOfCode.hello()
      :world

  """
  def assign1 do
    result = "data/assign1.data"
    |> File.read!()
    |> String.split("\r\n")
    |> Enum.reduce(0, fn item, value ->
      calculate(item, value)
    end)
  end

  def calculate("+" <> rest, acc) do
    acc + parse_string(rest)
  end

  def calculate("-" <> rest, acc) do
    acc - parse_string(rest)
  end

  def parse_string(value) do
    elem(Integer.parse(value), 0)
  end
end
