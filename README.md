Paratize
========
[![Build Status](https://semaphoreci.com/api/v1/projects/440099da-1586-4a89-85e9-9603659b2c80/463862/shields_badge.svg)](https://semaphoreci.com/seantanly/elixir-paratize)

Elixir library providing some handy parallel processing facilities that supports configuring number of workers and timeout.

This library is inspired by [Parex](https://github.com/StevenJL/parex).

## Examples

Paratize is designed to run slow tasks in parallel. There are two processor implementatons, first the chunk based implementation `Paratize.Chunk` and the second the pool worker based implementation `Paratize.Pool`. Both modules have the same API.

* `parallel_exec(fun_list, task_options)`
* `parallel_map(arg_list, fun, task_options)`
* `parallel_each(arg_list, fun, task_options)`

To execute a list of functions in parallel,

```
import Paratize.Pool

function_list = [
  fn() -> Math.fib(40) end,
  fn() -> :timer.sleep(5000) end,
  fn() -> HTTPotion.get("http://wwww.reddit.com") end
]

parallel_exec(function_list) # => [102334155, :ok, %HTTPotion.Response{body...}]

function_keyword_list = [
  fib: fn() -> Math.fib(40) end,
  hang: fn() -> :timer.sleep(5000) end,
  web_request: fn() -> HTTPotion.get("http://wwww.reddit.com") end
]

parallel_exec(function_keyword_list) # => [fib: 102334155, hang: :ok, web_request: %HTTPotion.Response{body...}]

```

To execute a map in parallel,  
(useful when results are needed for further processing)

```
import Paratize.Pool

slow_func = fn(arg) -> :timer.sleep(1000); arg + 1 end
workload = 1..100

{time, result} = :timer.tc fn -> workload |> parallel_map(slow_func) |> Enum.join(", ") end
time # => 13034452 (8 CPU cores system, running 8 workers)
```

To execute a each in parallel,  
(useful when resultset is large, and can be processed individually to prevent memory hog)

```
import Paratize.Pool

lots_of_urls |> parallel_each(fn(url) -> 
  HTTPotion.get(url) |> parse_page |> save_meta_data
end)

```

## Task Options

Each function accepts task options to customize the parallel processing.

* size - the number of parallel workers, defaults to the number of system cores given by `:erlang.system_info(:schedulers)`
* timeout - in milliseconds, the minimum time given for a function to complete. If the function is timeout, the entire parallel processing crashes with `exit(:timeout,...)`.

## Considerations

To achieve maximum parallelism, `%Paratize.TaskOptions{}` size should be set to size of your workload,

```
alias Paratize.Pool
alias Paratize.TaskOptions

slow_func = fn(arg) -> :timer.sleep(1000); arg + 1 end
workload = 1..100

{time, result} = :timer.tc fn -> 
    workload |> Pool.parallel_map(slow_func, %TaskOptions{size: Enum.count(workload)}) |> Enum.join(", ") 
end
time # => 1004370 (Running 100 workers)

```

The `%Paratize.TaskOptions{}` timeout should not be relied upon for precise timing out of each workload, because it is not strictly enforced. It is an implementation detail that *reasonably* crashes the processor if no further work is completed after the timeout period has lapsed. 