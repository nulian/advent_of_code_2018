defmodule Assign4_2 do
  @moduledoc false
  def assignment do
    data = "data/assign4.data" |> File.read!() |> String.split("\n")
    {_,chart_map} = Enum.map(data, fn item ->
      ["[" <> timestamp, text] = item
      |> String.split("]")

      {timestamp, String.trim(text)}
    end)
    |> Enum.sort(&(elem(&1, 0) < elem(&2, 0)))
    |> Enum.map(fn {timestamp, text} ->
      {Timex.parse!(timestamp, "{YYYY}-{0M}-{D} {h24}:{m}"), text}
    end)
    |> Enum.reduce({{0, 0}, %{}}, fn {time, text}, {{guard_id, start_time}, cb} ->
      case text do
        "falls asleep" -> {{guard_id, time.minute}, cb}
        "wakes up" -> {{guard_id,0}, Enum.reduce(start_time..time.minute, cb, fn minute, acc ->
          Map.update(acc, guard_id, %{minute => 1}, fn map -> Map.update(map, minute, 1, & &1 + 1) end)
          #          {Map.update(guard_id_sleep_acc, minute, [guard_id], &[guard_id | &1]), Map.update(guard_id_total_minute_acc, guard_id, 1, &(&1 + 1))}
        end)}
        text ->
          guard_id = ~r/#(\d*)/ |> Regex.scan(text, capture: :all_but_first) |> hd() |> hd() |> String.to_integer()
          {{guard_id, 0}, cb}
      end
    end)
    chart_map
    |> Map.to_list |> Enum.map(fn {key, timemap} -> {key, timemap |> Enum.sort(& elem(&1, 1) > elem(&2, 1)) |> hd()} end) |> Enum.sort(& elem(elem(&1, 1), 1) >  elem(elem(&2, 1), 1)) # manually double check the guard_id of highest element he has 2 minutes with same amount
  end

end
