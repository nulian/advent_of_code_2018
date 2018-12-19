defmodule Assign12 do
  alias Assign12.{Field, Row}
  import ExProf.Macro

  def assignment(generations) do
    lines = "data/assign12.data" |> File.read!() |> String.split("\r\n")
    [initial_stage, _ | rest] = lines

    [[init_stage_look]] = Regex.scan(~r/initial state: (.*)/, initial_stage, capture: :all_but_first)
    lookup_map = Enum.map(rest, fn item ->
      [[pattern, result]] = Regex.scan(~r/([\.\#]{5}) \=\> (.)/, item, capture: :all_but_first)
      {String.to_charlist(pattern), String.to_charlist(result)}
    end)

    field = Field.new(init_stage_look, Enum.into(lookup_map, %{}))

     result = Field.calculate_number_generations(field, generations)

    rows = result.generations
    row = rows |> hd()
    Row.calculate_value(row.head, row.start, 0)
  end

  defmodule Row do
    @dot 46
    @h 35

    @lookup_list ~w(.#.## .#.#. ..#.# ##.#. ##... ..### .##.. ..#.. .##.# ####. #...# ###.# ...#. .#..# #.##.) |> Enum.map(&String.to_charlist(&1))

    defstruct head: [], scan_cursor: [], tail: [], start: 0, result: 0

    def new(%Row{head: [@dot, @dot, @dot, @dot, e | rest], start: start}) do
      %Row{scan_cursor: [@dot, @dot, @dot, @dot, e], tail: rest, start: start}
    end

    def new(%Row{head: head, start: start} = row) do
      new(%Row{row | head: [@dot | head], start: start - 1})
    end

    def new(stage) do
      %Row{head: String.to_charlist(".....") ++ String.to_charlist(stage), start: -5}
    end

    def move_cursor(%Row{head: head, scan_cursor: []} = row), do: {:done, %Row{row | head: Enum.reverse(head)}}

    def move_cursor(%Row{head: head, scan_cursor: [@dot, @dot, @dot, @dot, @dot] = cursor, tail: []} = row) do
      {:done, %Row{row | head: Enum.reverse([@dot, @dot, @dot, @dot, @dot | head]), scan_cursor: [], tail: []}}
    end

    def move_cursor(%Row{head: head, scan_cursor: [old_cur, a,b,c,d], tail: []} = row) do
      %Row{row | head: [old_cur | head], scan_cursor: [a,b,c,d,@dot], tail: []}
    end

    def move_cursor(%Row{head: head, scan_cursor: [old_cur, a,b,c,d], tail: [char | rest]} = row) do
      %Row{row | head: [old_cur | head], scan_cursor: [a,b,c,d,char], tail: rest}
    end

    def scan_cursor(%Row{scan_cursor: cursor} = row, lookup_map) do
      result = case cursor in @lookup_list do
        false -> @dot
        true -> @h
      end

      result
    end

    def replace_current(%Row{scan_cursor: [_f, _s, middle | rest] = cursor} = row, new_cursor) when new_cursor == middle, do: row
    def replace_current(%Row{scan_cursor: [f, s, middle | rest] = cursor} = row, new_cursor) do
      %Row{row | scan_cursor: [f, s, new_cursor | rest]}
    end

    def calculate_value([], _, acc), do: acc

    def calculate_value([@h | rest], current_value, acc) do
      calculate_value(rest, current_value + 1, acc + current_value)
    end
    def calculate_value([_ | rest], current_value, acc) do
      calculate_value(rest, current_value + 1, acc)
    end
  end

  defmodule Field do
    defstruct generations: [], lookup_map: %{}

    def new(first_generation, lookup_map) do
      %Field{generations: [Row.new(first_generation)], lookup_map: lookup_map}
    end

    def calculate_number_generations(field, 0), do: field
    def calculate_number_generations(%Field{generations: [head | _rest] = gen, lookup_map: lookup_map} = field, number) do
      calculate_number_generations(%Field{field | generations: [scan_loop(Row.new(head), lookup_map, Row.new(head)) | head]}, number - 1)
    end

    def scan_loop(previous_gen, lookup_map, {:done, row}), do: row
    def scan_loop({:done, previous_gen}, lookup_map, row), do: scan_loop({:done, previous_gen}, lookup_map, Row.move_cursor(row))
    def scan_loop(previous_gen, lookup_map, %Row{} = row) do
      new_value = Row.scan_cursor(previous_gen, lookup_map)
      updated_row = Row.replace_current(row, new_value)
      scan_loop(Row.move_cursor(previous_gen), lookup_map, Row.move_cursor(updated_row))
    end
  end
end
