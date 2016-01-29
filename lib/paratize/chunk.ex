defmodule Paratize.Chunk do
  @moduledoc """
  Implementation of parallel exec via chunks and Task.async / Task.await.

  `Paratize.Chunk` implements the `Paratize.Base` behaviour and inherits the implementation for `parallel_each/3` and `parallel_map/3`.

  Parallelism is achieved within each chunk of functions. Processing on the next chunk starts only after the current chunk is completed.
  """

  use Paratize.Base

  @doc """
  Parallel processing of functions via chunks.
  Returns the list of result in order.

  ### Args:
    * fun_list - list of functions to execute in parallel.
    * task_options - `Paratize.TaskOptions`

  iex> [fn -> 1 end, {:b, fn -> 2 end}, fn -> 3 end] |> Paratize.Chunk.parallel_exec
  [1, {:b,2}, 3]

  """
  @spec parallel_exec(List.t, Paratize.TaskOptions.t | Keyword.t) :: List.t
  def parallel_exec(fun_list, task_options=%Paratize.TaskOptions{}) when is_list(fun_list) do
    worker_count = [Enum.count(fun_list), Paratize.TaskOptions.worker_count(task_options)] |> Enum.min

    fun_list |> Enum.chunk(worker_count, worker_count, []) |> Enum.map(fn(funs) ->
      Enum.map(funs, fn(fun) ->
        case fun do
          {key, func} when is_function(func) -> Task.async(fn -> {key, func.()} end)
          _ -> Task.async(fun)
        end
      end)
      |> Enum.map(&Task.await(&1, task_options.timeout))
    end) |> List.flatten
  end

end
