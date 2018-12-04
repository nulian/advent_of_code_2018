defmodule Assign1_2 do
  @moduledoc false

  def assign1 do
    result = "data/assign1.data"
             |> File.read!()
             |> String.split("\r\n")
             |> check_duplicate_sum()
  end

  def check_duplicate_sum(list, acc \\ {0, []}) do
    result = Enum.reduce_while(list, acc, fn item, {total, col_items} ->
      value = calculate(item, total)
      if value in col_items, do: {:halt, value}, else: {:cont, {value, [value | col_items]}}
    end)

    case result do
      con_acc when is_tuple(con_acc) -> check_duplicate_sum(list, con_acc)
      value -> value
    end
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
