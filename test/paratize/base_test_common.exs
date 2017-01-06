defmodule Paratize.BaseTest.Common do

  defmacro __using__([test_impl: test_impl]) do
    quote location: :keep do
      doctest unquote(test_impl)

      def test_impl, do: unquote(test_impl)

      test "parallel_each/3 is able to execute the task in parallel and returns :ok." do
        args = [1,2,3,4,5]
        {:ok, store_pid} = Agent.start_link(fn-> [] end)
        worker_fun = fn(arg) ->
          Agent.update(store_pid, fn(item) -> [arg|item] end)
          :timer.sleep(100)
          arg * 2
        end

        {time, result} = :timer.tc fn ->
          args |> test_impl().parallel_each(worker_fun, %Paratize.TaskOptions{size: 2})
        end

        assert MapSet.equal?(
          Agent.get(store_pid, &(&1)) |> Enum.into(MapSet.new),
          [5,4,3,2,1] |> Enum.into(MapSet.new))
        assert result == :ok
        assert div(time, 1000) in 300..500
      end

      test "parallel_map/3 is able to execute the task in parallel and return the list of results" do
        args = [1,2,3,4,5]
        {:ok, store_pid} = Agent.start_link(fn-> [] end)
        worker_fun = fn(arg) ->
          Agent.update(store_pid, fn(item) -> [arg|item] end)
          :timer.sleep(100)
          arg * 2
        end

        {time, result} = :timer.tc fn ->
          args |> test_impl().parallel_map(worker_fun, %Paratize.TaskOptions{size: 2})
        end

        assert MapSet.equal?(
          Agent.get(store_pid, &(&1)) |> Enum.into(MapSet.new),
          [5,4,3,2,1] |> Enum.into(MapSet.new))
        assert result == [2,4,6,8,10]
        assert div(time, 1000) in 300..500
      end
    end
  end

end
