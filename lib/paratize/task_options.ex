defmodule Paratize.TaskOptions do
  @moduledoc """
  Struct holding the configurations for executing the workload in parallel.
  """

  @doc """
  * size - number of workers, default: the number of CPU cores given by `:erlang.system_info(:schedulers)`.
  * timeout - timeout in ms, integer, default: 5000, exit(:timeout,...) if no result is return by any of the workers within the period. To disable timeout, use `:infinity`.
  """
  defstruct size: :schedulers, timeout: 5000

  def worker_count(task_options=%__MODULE__{}) do
    case task_options.size do
      :schedulers -> :erlang.system_info(:schedulers)
      :infinity -> :infinity
      size -> size
    end
  end

end
