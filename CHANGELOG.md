Changelog
====

## Version 2.1.2 (2016-02-14)

Bugfix & refactoring.

* Bugfix: `Paratize.TaskOptions.size` default :scheduler value was baked in
  during compile time, now determined during run time.
* Remove unnecessary Collectable protocol impl for %Paratize.TaskOptions{}.
* General refactoring


## Version 2.1.1 (2015-10-25)

* Upgrade to Elixir v1.1 as minimum supported version.
* Update docs generated from ex_doc v0.10.
* Documentation updated with CHANGELOG, README and LICENSE included.


## Version 2.1.0 (2015-08-17)

Added support for using the convenient Keyword arguments to define `%Paratize.TaskOptions`.


## Version 2.0.1 (2015-08-13)

Bugfix for tests. Improved documentation.


## Version 2.0.0 (2015-06-29)

Refactored the API again!

* Paratize.* functions are moved to their respective module.
* exec/2 are renamed to parallel_exec/2 for Paratize.Pool and Paratize.Chunk.

Common API for both `Paratize.Chunk` and `Paratize.Pool` processors. 

* `parallel_exec(fun_list, task_options)`
* `parallel_map(arg_list, fun, task_options)`
* `parallel_each(arg_list, fun, task_options)`
