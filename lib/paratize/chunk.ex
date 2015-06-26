defmodule Paratize.Chunk do
  @moduledoc """
  Implementation of parallel exec via chunks and Task.async / Task.await.

  Parallelism is achieved within each chunk of functions. Processing on the next chunk starts only after the current chunk is completed.
  """

  @doc """
  Does parallel processing of functions via chunks.
  Returns the list of result in order.

  ### Args:
    * fun_list - list of functions to execute in parallel.
    * task_options - Keyword of options.
  #### task_options:
    * size - number of workers, default: fun_list count. :schedulers will use the number of system cores.
    * timeout - timeout in ms, integer, default: 5000, exit(:timeout,...) if no result is return by any of the workers within the period.

  iex> [fn -> 1 end, {:b, fn -> 2 end}, fn -> 3 end] |> Paratize.Chunk.exec
  [1, {:b,2}, 3]

  """
  @spec exec(List.t, Paratize.task_options) :: List.t
  def exec(fun_list, task_options \\ []) when is_list(fun_list) do
    task_options = Keyword.merge([size: Enum.count(fun_list), timeout: 5000], task_options)
    if task_options[:size] == :schedulers, do: task_options = task_options |> Keyword.put(:size, :erlang.system_info(:schedulers))

    fun_list |> Enum.chunk(task_options[:size], task_options[:size], []) |> Enum.map(fn(funs) ->
      Enum.map(funs, fn(fun) ->
        case fun do
          {key, func} when is_function(func) -> Task.async(fn -> {key, func.()} end)
          _ -> Task.async(fun)
        end
      end)
      |> Enum.map(&Task.await(&1, task_options[:timeout]))
    end) |> List.flatten
  end

end
