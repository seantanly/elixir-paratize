defmodule ParatizeTest do
  use ExUnit.Case
  doctest Paratize

  test ".each is able to execute the task in parallel and returns :ok." do
    args = [1,2,3,4,5]
    {:ok, store_pid} = Agent.start_link(fn-> [] end)
    worker_fun = fn(arg) ->
      Agent.update(store_pid, fn(item) -> [arg|item] end)
      :timer.sleep(100)
      arg * 2
    end

    {time, result} = :timer.tc fn ->
      args |> Paratize.each(worker_fun, :pool, size: 2)
    end

    assert Set.equal?(
      Agent.get(store_pid, &(&1)) |> Enum.into(HashSet.new),
      [5,4,3,2,1] |> Enum.into(HashSet.new))
    assert result == :ok
    assert time/1000 in 300..500
  end

  test ".map is able to execute the task in parallel and return the list of results" do
    args = [1,2,3,4,5]
    {:ok, store_pid} = Agent.start_link(fn-> [] end)
    worker_fun = fn(arg) ->
      Agent.update(store_pid, fn(item) -> [arg|item] end)
      :timer.sleep(100)
      arg * 2
    end

    {time, result} = :timer.tc fn ->
      args |> Paratize.map(worker_fun, :pool, size: 2)
    end

    assert Set.equal?(
      Agent.get(store_pid, &(&1)) |> Enum.into(HashSet.new),
      [5,4,3,2,1] |> Enum.into(HashSet.new))
    assert result == [2,4,6,8,10]
    assert time/1000 in 300..500
  end

  test ".exec is able to call the appropriate module's exec/2" do
  end

end
