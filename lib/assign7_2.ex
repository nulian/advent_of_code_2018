defmodule Assign7_2 do
  @moduledoc false

  defmodule Worker do
    defstruct id: nil, current_task: nil, remaining_duration: 0, previous_tasks: []

    def set_current_task(%Worker{} = worker, task) do
      %Worker{worker | current_task: task, remaining_duration: calculate_char_value(task)}
    end

    def check_worker(%Worker{remaining_duration: duration} = worker) when (duration - 1) != 0 do
      %Worker{worker | remaining_duration: duration - 1}
    end

    def check_worker(%Worker{current_task: task, previous_tasks: prev_tasks} = worker) do
      %Worker{worker | remaining_duration: 0, current_task: nil, previous_tasks: [task | prev_tasks]}
    end

    def calculate_char_value(char) do
      char
      |> String.to_charlist()
      |> hd()
      |> Kernel.-(4)
    end
  end

  defmodule WorkerPool do
    defstruct free_workers: [], busy_workers: []

    def new(pool_size) do
      %WorkerPool{free_workers: Enum.map(1..pool_size, &(%Worker{id: &1}))}
    end

    def start_worker(%WorkerPool{free_workers: []}, _), do: :error
    def start_worker(%WorkerPool{free_workers: [free_worker | rest_workers], busy_workers: busy_workers} = pool, task) do
      updated_worker = Worker.set_current_task(free_worker, task)
      %WorkerPool{pool | free_workers: rest_workers, busy_workers: [updated_worker | busy_workers]}
    end

    def scan_for_completed_tasks(%WorkerPool{busy_workers: busy_workers, free_workers: free_workers} = worker_pool) do
      {b_worker, f_worker, result} = Enum.reduce(busy_workers, {[], free_workers, []}, fn worker, {b_worker, f_worker, result} ->
        case Worker.check_worker(worker) do
          %Worker{current_task: nil, previous_tasks: [task | _]} = worker ->  {b_worker, [worker | f_worker], [task | result]}
          worker -> {[worker | b_worker], f_worker, result}
        end
      end)

      {%WorkerPool{worker_pool | busy_workers: b_worker, free_workers: f_worker}, result |> Enum.reverse() |> List.flatten()}
    end
  end

  defmodule Task do
    defstruct dependent_graph: %{}, lookup_graph: %{}, worker_pool: nil, current_time: 0, time_till_next_job_finish: 0, result: []

    def new({dependent_graph, lookup_graph}, pool) do
      %Task{dependent_graph: dependent_graph, lookup_graph: lookup_graph, worker_pool: WorkerPool.new(pool)}
    end

    def start_job(%Task{dependent_graph: dependents, worker_pool: %WorkerPool{} = worker_pool} = task, current_task) do
      worker_pool = WorkerPool.start_worker(worker_pool, current_task)
      %Task{task | dependent_graph: Map.delete(dependents, current_task),worker_pool: worker_pool}
    end

    def check_jobs(%Task{worker_pool: worker_pool, current_time: current_time} = task) do
      {updated_worker_pool, results} = worker_pool
      |> WorkerPool.scan_for_completed_tasks()
      updated_task = process_results(results, %Task{task | worker_pool: updated_worker_pool})
      %Task{updated_task | current_time: current_time + 1}
    end

    def process_results([], task), do: task
    def process_results([key | tail], %Task{dependent_graph: dependent_on, lookup_graph: graph, result: results} = acc) do
      to_remove = graph[key]
      if to_remove do
        dependent = Enum.reduce(to_remove, dependent_on, fn d_key, acc ->
          Map.update!(acc, d_key, &List.delete(&1, key))
        end)
        |> Map.delete(key)

        process_results(tail, %Task{acc | dependent_graph: dependent, result: [key | results]})
      else
        %Task{acc | result: [key | results]}
      end
    end
  end

  def assignment(worker_pool \\ 5) do
    "data/assign7.data" |> File.read!() |> String.split("\n")
    |> Enum.map(fn text ->
      [[char, con]] = Regex.scan(~r/Step (.) must be finished before step (.)/, text, capture: :all_but_first)
      {char, con}
    end)
    |> get_dependency_graph()
    |> Task.new(worker_pool)
    |> calculate_loop()
    |> Map.get(:current_time)
  end



  def calculate_loop(%Task{dependent_graph: dependent_on} = task) when dependent_on != %{} do
      updated_task = dependent_on
      |> Map.keys()
      |> Enum.reduce_while(task, fn
      _, %Task{dependent_graph: dependents} = acc when dependents == %{} -> {:halt, acc}
      key, %Task{dependent_graph: dependents, worker_pool: %WorkerPool{free_workers: free_workers}} = acc when free_workers != [] ->
      if Map.has_key?(dependents, key) do
        case dependents[key] do
          [] -> {:cont, Task.start_job(acc, key)}
          _ -> {:cont, acc}
        end
      else
        {:cont, acc}
      end
      _, acc -> {:halt, acc}
    end)

    updated_task
    |> Task.check_jobs()
    |> calculate_loop()
  end

  def calculate_loop(%Task{worker_pool: %WorkerPool{busy_workers: workers}} = task) when workers != [] do
    task
    |> Task.check_jobs()
    |> calculate_loop()
  end

  def calculate_loop(task), do: task


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
end
