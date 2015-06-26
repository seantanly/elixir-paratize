defmodule Paratize do
  @moduledoc """
  Provides a set of functions that does parallel processing on collection of data or functions.

  There are two implementation strategies, `Paratize.Chunk` and `Paratize.Pool`.
  Checkout `Paratize.TaskOptions` for what are the configurations available.
  """


  @doc """
  Parallel execution of the list of functions.
  Returns list of results in order.

  ### Args
  * fun_list - list of functions to be executed
  * task_options - `Paratize.TaskOptions`
  """
  @spec exec(List.t, Paratize.TaskOptions.t) :: List.t
  def exec(fun_list, task_options=%Paratize.TaskOptions{mode: :chunk}), do: fun_list |> Paratize.Chunk.exec(task_options)
  def exec(fun_list, task_options=%Paratize.TaskOptions{mode: :pool}), do: fun_list |> Paratize.Pool.exec(task_options)

  @doc """
  Parallel processing of .map function via `exec/2`.
  Returns list of results in order.

  ### Args
  * args_list - list of arguments to be applied to fun
  * fun - function taking in each argument
  * task_options - `Paratize.TaskOptions`
  """
  @spec map(List.t, Fun, Paratize.TaskOptions.t) :: List.t
  def map(args_list, fun, task_options=%Paratize.TaskOptions{}) do
    args_list |> Enum.map(fn(arg) ->
      fn -> fun.(arg) end
    end) |> exec(task_options)
  end

  @doc """
  Parallel processing of .each function via `exec/2`.
  Returns :ok

  ### Args
  * args_list - list of arguments to be applied to fun
  * fun - function taking in each argument
  * task_options - `Paratize.TaskOptions`
  """
  @spec each(List.t, Fun, Paratize.TaskOptions.t) :: :ok
  def each(args_list, fun, task_options=%Paratize.TaskOptions{}) do
    args_list |> Enum.map(fn(arg) ->
      fn -> fun.(arg); nil end # fn to return nil to ensure return value can be deallocated.
    end) |> exec(task_options)
    :ok
  end

end
