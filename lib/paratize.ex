defmodule Paratize do
  @moduledoc """
  Provides a set of functions that does parallel processing on collection of data or functions.

  Paratize.Pool contains the pool implementation of exec. (Default)

  Paratize.Chunk contains the chunk implementation of exec.
  """


  @typedoc """
  * size - number of workers, default: fun_list count. :schedulers will use the number of system cores.
  * timeout - timeout in ms, integer, default: 5000, exit(:timeout,...) if no result is return by any of the workers within the period.
  """
  @type task_options :: [size: pos_integer, timeout: pos_integer]
  @typedoc "Default :pool"
  @type mode :: :chunk | :pool

  defp get_module(mode) do
    %{
      chunk: Paratize.Chunk,
      pool: Paratize.Pool,
    } |> Dict.get(mode, Paratize.Pool)
  end

  @doc """
  Parallel execution of the list of functions.
  Returns list of results in order.

  ### Args
  * fun_list - list of functions to be executed
  * `mode`
  * `task_options`
  """
  @spec exec(List.t, mode, task_options) :: List.t
  def exec(fun_list, mode, task_options \\ []) when is_atom(mode) do
    module = get_module(mode)
    fun_list |> module.exec(task_options)
  end

  @doc """
  Parallel processing of .map function via `exec/2`.
  Returns list of results in order with its arguments.

  ### Args
  * args_list - list of arguments to be applied to fun
  * fun - function taking in each argument
  * `mode`
  * `task_options`
  """
  @spec map(List.t, Fun, mode, task_options) :: List.t
  def map(args_list, fun, mode, task_options \\ []) when is_atom(mode) do
    args_list |> Enum.map(fn(arg) ->
      fn -> fun.(arg) end
    end) |> exec(mode, task_options)
  end

  @doc """
  Parallel processing of .each function via `exec/2`.
  Returns :ok

  ### Args
  * args_list - list of arguments to be applied to fun
  * fun - function taking in each argument
  * `mode`
  * `task_options`
  """
  @spec each(List.t, Fun, mode, task_options) :: :ok
  def each(args_list, fun, mode, task_options \\ []) when is_atom(mode) do
    args_list |> Enum.map(fn(arg) ->
      fn -> fun.(arg); nil end # fn to return nil to ensure return value can be deallocated.
    end) |> exec(mode, task_options)
    :ok
  end

end
