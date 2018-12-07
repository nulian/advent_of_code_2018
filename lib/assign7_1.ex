defmodule Assign7_1 do
  @moduledoc false

  def assignment do
    {dependent_on, graph} = "data/assign7.data" |> File.read!() |> String.split("\n")
    |> Enum.map(fn text ->
      [[char, con]] = Regex.scan(~r/Step (.) must be finished before step (.)/, text, capture: :all_but_first)
      {char, con}
    end)
    |> get_dependency_graph()
    calculate_loop(dependent_on, graph, [])
    |> Enum.reverse()
    |> Enum.join()
  end

  def get_dependency_graph(map) do
    {dependent_on, graph} = Enum.reduce(map, {%{}, %{}} , fn {new, dependent}, {check, triggers} ->
      {Map.update(check, dependent, [new], & [new | &1]), Map.update(triggers, new, [dependent], & [dependent | &1])}
    end)
    keys = Enum.map(map, & elem(&1, 0))
    dependent = Enum.reduce(keys, dependent_on, fn key, acc ->
      Map.put_new(acc, key, [])
    end)
    {dependent, graph}
  end

  def calculate_loop(dependent_on, graph, results) when dependent_on != %{} do
    keys = dependent_on |> Map.keys()
    {result, dependent} = Enum.reduce_while(keys, {results, dependent_on}, fn
      _, {col, dependents} when dependents == %{} -> {:halt, col}
      key, {col, dependents} = acc ->
      if Map.has_key?(dependents, key) do
        case dependents[key] do
          [] -> {:halt, {[key | col],execute_key(graph, dependents, key)}}
          _ -> {:cont, acc}
        end
      else
        {:cont, acc}
      end
    end)

    calculate_loop(dependent, graph, result)
  end

  def calculate_loop(_, _, results), do: results

  def execute_key(graph, dependents, key) do
    to_remove = graph[key]
    if to_remove do
    Enum.reduce(to_remove, dependents, fn d_key, acc ->
      Map.update!(acc, d_key, &List.delete(&1, key))
    end)
    |> Map.delete(key)
    else
      %{}
    end

  end

end
