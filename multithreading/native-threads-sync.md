**OS-based native Threads synchronization is slow mostly for 3 reasons:**
1. System-call for Thread parking is expensive, since, for the sake of execution some System/OS function - Processor needs to switch from `user mode` (user application) to `kernel mode` (system scope). In `user mode` Processor has access to dedicated virtual address space specifically for current User Application. `User mode` forbids Processor for any access to kernel virtual address space, since errors in kernel space may lead to OS crash. For the sake of System-call - Processor switches from `user mode` to `kernel mode`, executes System/OS function and switches back to `user mode` again for further execution of Application.
2. `unpark()` time is not deterministic, due to OS Thread Scheduler mechanics. After `unpark()` System-call was invoked, it may take a long time for actual Thread awakening, as there could be other busy Threads in OS, which Scheduler can decide to execute instead of those currently requested for awakening.
3. For switching between native Threads OS performs so-called `Context Switch` and it's fairly expensive procedure.

#### Context Switch
