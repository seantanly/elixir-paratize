defmodule Paratize.TaskOptions do
  @moduledoc """
  Struct holding the configurations for executing the workload in parallel.
  """

  @doc """
  * mode - :chunk | :pool (default :pool).
  * size - number of workers, default: the number of CPU cores.
  * timeout - timeout in ms, integer, default: 5000, exit(:timeout,...) if no result is return by any of the workers within the period.
  """
  defstruct mode: :pool, size: :erlang.system_info(:schedulers), timeout: 5000

end
