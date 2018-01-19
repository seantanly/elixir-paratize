defmodule Paratize.TaskOptions do
  @moduledoc """
  Struct holding the configurations for executing the workload in parallel.
  """

  @doc """
  * size - number of workers, default: the number of CPU cores given by `:erlang.system_info(:schedulers)`.
  * timeout - timeout in ms, integer, default: 5000, exit(:timeout,...) if no result is return by any of the workers within the period. To disable timeout, use `:infinity`.
  """
  defstruct size: :schedulers, timeout: 5000

  @type t :: %__MODULE__{
          size: :schedulers | non_neg_integer,
          timeout: :infinity | non_neg_integer
        }

  @doc """
  Returns the actual worker count based on %Paratize.TaskOptions{}.
  """
  @spec worker_count(t) :: non_neg_integer
  def worker_count(%__MODULE__{size: size}) do
    case size do
      :schedulers -> :erlang.system_info(:schedulers)
      size -> size
    end
  end
end
