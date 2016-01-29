defmodule Paratize.Pool do
  @moduledoc """
  Implementation of parallel exec via pool of spawned workers processes.

  `Paratize.Pool` implements the `Paratize.Base` behaviour and inherits the implementation for `parallel_each/3` and `parallel_map/3`.

  True parallelism for the entire workload of functions, in which workers will fetch jobs from the fun_list until empty.
  """

  use Paratize.Base

  @doc """
  Parallel processing of functions via pool of workers.
  Returns the list of result in order.

  ### Args:
    * fun_list - list of functions to execute in parallel.
    * task_options - `Paratize.TaskOptions`

  iex> [fn -> 1 end, {:b, fn -> 2 end}, fn -> 3 end] |> Paratize.Pool.parallel_exec
  [1, {:b,2}, 3]

  """
  @spec parallel_exec(List.t, Paratize.TaskOptions.t | Keyword.t) :: List.t
  def parallel_exec(fun_list, task_options=%Paratize.TaskOptions{}) when is_list(fun_list) do
    worker_count = [Enum.count(fun_list), Paratize.TaskOptions.worker_count(task_options)] |> Enum.min

    worker_pids = 1..worker_count |> Enum.map(fn(_) ->
      spawn_link(__MODULE__, :worker_func, [self])
    end)
    ifun_list = fun_list |> Enum.with_index |> Enum.map(fn {fun, index} -> {index, fun} end)
    acc = []

    do_exec(worker_pids, ifun_list, acc, task_options)
  end

  defp do_exec(_worker_pids=[], _ifun_list, acc, _task_options) do
    acc
      |> Enum.sort(fn({index1, _result1}, {index2, _result2}) -> index1 < index2 end )
      |> Enum.map(fn {_index, result} -> result end)
  end
  defp do_exec(worker_pids, ifun_list, acc, task_options) do
    receive do
      {sender, :get_job} when ifun_list == [] ->
        send sender, {:terminate}
        worker_pids = worker_pids |> List.delete(sender)
        do_exec(worker_pids, ifun_list, acc, task_options)

      {sender, :get_job} ->
        [ifun | ifun_list] = ifun_list
        send sender, {:job, ifun}
        do_exec(worker_pids, ifun_list, acc, task_options)

      {_sender, :job_result, {index, result}} ->
        do_exec(worker_pids, ifun_list, [{index, result} | acc], task_options)
    after
      task_options.timeout ->
        exit({:timeout, {__MODULE__, :parallel_exec, task_options.timeout}})
    end
  end

  @doc false
  def worker_func(main_pid) do
    send main_pid, {self, :get_job}
    receive do
      {:job, {index, fun}} ->
        result = case fun do
          {key, func} when is_function(func) -> {key, func.()}
          _ -> fun.()
        end
        send main_pid, {self, :job_result, {index, result}}
        worker_func(main_pid)

      {:terminate} ->
        :ok
    end
  end

end
