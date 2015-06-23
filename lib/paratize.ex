defmodule Paratize do
  @moduledoc """
  Provides a set of functions that does parallel processing on collection of data or functions.
  """

  @doc """
  Provides a handy function to do parallel processing of each via chunks.
  It calls the fun with each argument.
  The pool_size default is size of arg_list. Setting pool_size to :schedulers will use the number of system cores.
  """
  def pc_each(arg_list, fun, kargs \\ []) do
    kargs = Keyword.merge([pool_size: Enum.count(arg_list), timeout: 5000], kargs)
    if kargs[:pool_size] == :schedulers, do: kargs = kargs |> Keyword.put(:pool_size, :erlang.system_info(:schedulers))

    arg_list |> Enum.chunk(kargs[:pool_size], kargs[:pool_size], []) |> Enum.each(fn(args) ->
      Enum.map(args, fn(arg) -> Task.async(fn ->
        fun.(arg)
      end) end)
      |> Enum.each(&Task.await(&1, kargs[:timeout]))
    end)
  end

  @doc """
  Provides a handy function to do parallel processing of map via chunks.
  It calls the fun with each argument and returns the list of result.
  Ordering of result is assured via sequential Task.await on collected Task pids.
  The pool_size default is size of arg_list. Setting pool_size to :schedulers will use the number of system cores.
  """
  def pc_map(arg_list, fun, kargs \\ []) do
    kargs = Keyword.merge([pool_size: Enum.count(arg_list), timeout: 5000], kargs)
    if kargs[:pool_size] == :schedulers, do: kargs = kargs |> Keyword.put(:pool_size, :erlang.system_info(:schedulers))

    arg_list |> Enum.chunk(kargs[:pool_size], kargs[:pool_size], []) |> Enum.map(fn(args) ->
      Enum.map(args, fn(arg) -> Task.async(fn ->
        fun.(arg)
      end) end)
      |> Enum.map(&Task.await(&1, kargs[:timeout]))
    end) |> List.flatten
  end

  @doc """
  Provides a handy function to do parallel processing of functions via chunks.
  It calls each fun in fun_list and returns the list of result. Keyword list is supported.
  Ordering of result is assured via sequential Task.await on collected Task pids.
  The pool_size default is size of arg_list. Setting pool_size to :schedulers will use the number of system cores.

  iex> [fn -> 1 end, {:b, fn -> 2 end}, fn -> 3 end] |> Paratize.pc_exec
  [1, {:b,2}, 3]
  """
  def pc_exec(fun_list, kargs \\ []) when is_list(fun_list) do
    kargs = Keyword.merge([pool_size: Enum.count(fun_list), timeout: 5000], kargs)
    if kargs[:pool_size] == :schedulers, do: kargs = kargs |> Keyword.put(:pool_size, :erlang.system_info(:schedulers))

    fun_list |> Enum.chunk(kargs[:pool_size], kargs[:pool_size], []) |> Enum.map(fn(funs) ->
      Enum.map(funs, fn(fun) ->
        case fun do
          {key, func} when is_function(func) -> Task.async(fn -> {key, func.()} end)
          _ -> Task.async(fun)
        end
      end)
      |> Enum.map(&Task.await(&1, kargs[:timeout]))
    end) |> List.flatten
  end

end
