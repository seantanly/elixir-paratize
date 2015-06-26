defmodule Paratize.Pool do
  @moduledoc """
  Implementation of parallel exec via pool of spawned workers processes.

  True parallelism for the entire workload of functions, in which workers will fetch jobs from the fun_list until empty.
  """

  @doc """
  Does parallel processing of functions via pool of workers, using default `Paratize.TaskOptions`.
  Returns the list of result in order.

  ### Args:
    * fun_list - list of functions to execute in parallel.

  iex> [fn -> 1 end, {:b, fn -> 2 end}, fn -> 3 end] |> Paratize.Pool.exec
  [1, {:b,2}, 3]

  """
  @spec exec(List.t) :: List.t
  def exec(fun_list) when is_list(fun_list), do: exec(fun_list, %Paratize.TaskOptions{mode: :pool})

  @doc """
  Does parallel processing of functions via pool of workers.
  Returns the list of result in order.

  ### Args:
    * fun_list - list of functions to execute in parallel.
    * task_options - `Paratize.TaskOptions`

  iex> [fn -> 1 end, {:b, fn -> 2 end}, fn -> 3 end] |> Paratize.Pool.exec(%Paratize.TaskOptions{mode: :pool})
  [1, {:b,2}, 3]

  """
  @spec exec(List.t, Paratize.TaskOptions.t) :: List.t
  def exec(fun_list, task_options=%Paratize.TaskOptions{mode: :pool}) when is_list(fun_list) do
    worker_count = [Enum.count(fun_list), task_options.size] |> Enum.min

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
        exit({:timeout, {__MODULE__, :pp_exec, task_options.timeout}})
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
