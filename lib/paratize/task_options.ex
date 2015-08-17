defmodule Paratize.TaskOptions do
  @moduledoc """
  Struct holding the configurations for executing the workload in parallel.
  """

  @doc """
  * size - number of workers, default: the number of CPU cores given by `:erlang.system_info(:schedulers)`.
  * timeout - timeout in ms, integer, default: 5000, exit(:timeout,...) if no result is return by any of the workers within the period. To disable timeout, use `:infinity`.
  """
  defstruct size: :erlang.system_info(:schedulers), timeout: 5000

end

defimpl Collectable, for: Paratize.TaskOptions do

  def into(original) do
    {original, fn
        acc, {:cont, {k, v}} -> Map.update!(acc, k, fn(_old_v) -> v end)
        acc, :done -> acc
        _, :halt -> :ok
    end}
  end

end
