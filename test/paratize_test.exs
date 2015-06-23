defmodule ParatizeTest do
  use ExUnit.Case
  doctest Paratize

  test ".pc_each is able to execute the task in parallel and returns :ok." do
    args = [1,2,3,4,5]
    {:ok, store_pid} = Agent.start_link(fn-> [] end)
    worker_fun = fn(arg) ->
      Agent.update(store_pid, fn(item) -> [arg|item] end)
      :timer.sleep(100)
      arg * 2
    end

    {time, result} = :timer.tc fn ->
      args |> Paratize.pc_each(worker_fun, pool_size: 2)
    end

    assert Set.equal?(
      Agent.get(store_pid, &(&1)) |> Enum.into(HashSet.new),
      [5,4,3,2,1] |> Enum.into(HashSet.new))
    assert result == :ok
    assert time/1000 in 300..500
  end

  test ".pc_map is able to execute the task in parallel and return the list of results" do
    args = [1,2,3,4,5]
    {:ok, store_pid} = Agent.start_link(fn-> [] end)
    worker_fun = fn(arg) ->
      Agent.update(store_pid, fn(item) -> [arg|item] end)
      :timer.sleep(100)
      arg * 2
    end

    {time, result} = :timer.tc fn ->
      args |> Paratize.pc_map(worker_fun, pool_size: 2)
    end

    assert Set.equal?(
      Agent.get(store_pid, &(&1)) |> Enum.into(HashSet.new),
      [5,4,3,2,1] |> Enum.into(HashSet.new))
    assert result == [2,4,6,8,10]
    assert time/1000 in 300..500
  end

  test ".pc_exec is able to execute the functions in parallel and return the list of results" do
    fun_list = [
      fn -> :timer.sleep(100); 1 end,
      {:b, fn -> :timer.sleep(100); 2 end},
      fn -> :timer.sleep(100); 3 end,
      {:d, fn -> :timer.sleep(100); 4 end},
      fn -> :timer.sleep(100); 5 end,
    ]

    {time, result} = :timer.tc fn -> Paratize.pc_exec(fun_list, pool_size: 2) end

    assert result == [1, {:b, 2}, 3, {:d, 4}, 5]
    assert time/1000 in 300..500
  end

end
