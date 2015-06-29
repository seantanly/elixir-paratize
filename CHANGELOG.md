Changelog
====

## Version 2.0.0 (2015-06-29)

Refactored the API again!

* Paratize.* functions are moved to their respective module.
* exec/2 are renamed to parallel_exec/2 for Paratize.Pool and Paratize.Chunk.

Common API for both `Paratize.Chunk` and `Paratize.Pool` processors. 

* `parallel_exec(fun_list, task_options)`
* `parallel_map(arg_list, fun, task_options)`
* `parallel_each(arg_list, fun, task_options)`
