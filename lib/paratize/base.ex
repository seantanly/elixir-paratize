defmodule Paratize.Base do
  use Behaviour

  @moduledoc """
  Provides the base implementation for `parallel_each/3` and `parallel_map/3`.

  To create an implementation, do `use Paratize.Base` and provide the implementation of `parallel_exec/2`.
  """

  @doc """
  Parallel processing of functions.
  Returns the list of result in order.

  ### Args:
    * fun_list - list of functions to execute in parallel.
    * task_options - `Paratize.TaskOptions`
  """
  defcallback parallel_exec(List.t, TaskOptions.t)

  defmacro __using__(_) do
    quote location: :keep do
      @behaviour unquote(__MODULE__)

      @doc """
      Parallel processing of .map function via `exec/2`.
      Returns list of results in order.

      ### Args
      * args_list - list of arguments to be applied to fun
      * fun - function taking in each argument
      * task_options - `Paratize.TaskOptions`
      """
      @spec parallel_map(List.t, Fun, Paratize.TaskOptions.t) :: List.t
      def parallel_map(args_list, fun, task_options \\ %Paratize.TaskOptions{}) do
        args_list |> Enum.map(fn(arg) ->
          fn -> fun.(arg) end
        end) |> parallel_exec(task_options)
      end

      @doc """
      Parallel processing of .each function via `exec/2`.
      Returns :ok

      ### Args
      * args_list - list of arguments to be applied to fun
      * fun - function taking in each argument
      * task_options - `Paratize.TaskOptions`
      """
      @spec parallel_each(List.t, Fun, Paratize.TaskOptions.t) :: :ok
      def parallel_each(args_list, fun, task_options \\ %Paratize.TaskOptions{}) do
        args_list |> Enum.map(fn(arg) ->
          fn -> fun.(arg); nil end # fn to return nil to ensure return value can be deallocated.
        end) |> parallel_exec(task_options)
        :ok
      end

    end
  end

end
