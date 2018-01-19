defmodule Paratize.ChunkTest do
  use ExUnit.Case, async: true
  use Paratize.BaseTest.Common, test_impl: Paratize.Chunk

  test "parallel_exec/2 is able to execute functions in parallel and return their results in order" do
    fun_list = [
      fn ->
        :timer.sleep(100)
        1
      end,
      {:b,
       fn ->
         :timer.sleep(100)
         2
       end},
      fn ->
        :timer.sleep(100)
        3
      end,
      {:d,
       fn ->
         :timer.sleep(100)
         4
       end},
      fn ->
        :timer.sleep(100)
        5
      end
    ]

    {time, result} =
      :timer.tc(fn ->
        fun_list |> Paratize.Chunk.parallel_exec(%Paratize.TaskOptions{size: 3, timeout: 1000})
      end)

    assert result == [1, {:b, 2}, 3, {:d, 4}, 5]
    assert div(time, 1000) in 200..300
  end
end
