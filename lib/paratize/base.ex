defmodule Paratize.Base do
  @moduledoc """
  Provides the base implementation for `parallel_each/3` and `parallel_map/3`.

  To create an implementation, do `use Paratize.Base` and provide the implementation of `parallel_exec/2`.
  """

  @doc """
  Parallel processing of functions.
  Returns the list of results in order.

  ### Args:
    * fun_list - list of functions to execute in parallel.
    * task_options - `Paratize.TaskOptions`
  """
  @callback parallel_exec(List.t, TaskOptions.t) :: List.t

  defmacro __using__(_) do
    quote location: :keep do
      @behaviour unquote(__MODULE__)
      alias Paratize.TaskOptions

      @doc """
      `parallel_map/3` with default task_options.
      """
      def parallel_map(args_list, fun, task_options \\ %TaskOptions{})
      def parallel_map(args_list, fun, task_options) when is_list(task_options) do
        parallel_map(args_list, fun, struct(TaskOptions, task_options))
      end
      @doc """
      Parallel processing of .map function via `exec/2`.
      Returns list of results in order.

      ### Args
      * args_list - list of arguments to be applied to fun
      * fun - function taking in each argument
      * task_options - `Paratize.TaskOptions`
      """
      @spec parallel_map(List.t, Fun, TaskOptions.t | Keyword.t) :: List.t
      def parallel_map(args_list, fun, %TaskOptions{} = task_options) do
        args_list |> Enum.map(fn(arg) ->
          fn -> fun.(arg) end
        end) |> parallel_exec(task_options)
      end

      @doc """
      `parallel_each/3` with default task_options.
      """
      def parallel_each(args_list, fun, task_options \\ %TaskOptions{})
      def parallel_each(args_list, fun, task_options) when is_list(task_options) do
        parallel_each(args_list, fun, struct(TaskOptions, task_options))
      end
      @doc """
      Parallel processing of .each function via `exec/2`.
      Returns :ok

      ### Args
      * args_list - list of arguments to be applied to fun
      * fun - function taking in each argument
      * task_options - `Paratize.TaskOptions`
      """
      @spec parallel_each(List.t, Fun, TaskOptions.t | Keyword.t) :: :ok
      def parallel_each(args_list, fun, %TaskOptions{} = task_options) do
        args_list |> Enum.map(fn(arg) ->
          fn -> fun.(arg); :ok end # fn to return :ok to allow return value be garbage collected.
        end) |> parallel_exec(task_options)
        :ok
      end

      @doc """
      `parallel_exec/3` with default task_options.
      """
      @spec parallel_exec(List.t, TaskOptions.t | Keyword.t) :: List.t
      def parallel_exec(fun_list, task_options \\ %TaskOptions{})
      def parallel_exec(fun_list, task_options) when is_list(task_options) do
        parallel_exec(fun_list, struct(TaskOptions, task_options))
      end

    end
  end

end
