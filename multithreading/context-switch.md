#### Context Switch

In scope of JVM, when `os::PlatformEvent::park()` is invoked - JVM uses POSIX (for linux) `pthread_mutex_lock` and `pthread_cond_wait` system-calls for Thread's state control, which involves OS Thread Scheduler. The Scheduler make a decision about switching the threads and the following steps are taken (note that `Context Switching` is allowed only in `kernel mode` since it operates on operating system native threads):
1. Just like with System-Calls `Context Switch` also requires switching between `user mode` and `kernel mode`. Every native Thread uses `user stack` and `kernel stack` respectively: 
   * `User stack` is used during normal user Application execution and is allocated in `user mode` virtual address space. `User stack` holds local variables, function arguments, frame pointer and function return address.
   * `Kernel stack` is used during `Context Switch` in `kernel mode` and is allocated in `kernel mode` address space. `Kernel stack` is intended for saving current values from CPU registers (that is, storing current CPU execution state).     
   
   `User` and `Kernel` stacks are separated for the same security and stability reasons as `mode`'s. So, the first step that the operating system takes is switching between `User mode` to `Kernel mode`. 
2. In `Kernel mode` OS saves values from CPU registers (Program Counter, Stack Pointer, etc.) to Thread's `Kernel stack` and Thread Control Block (`TCB`).
3. On the top of the kernel stack the value of `User mode` Stack Pointer is stored. This allows the Thread to store the point of user's execution state when it comes back from `Kernel mode` to `User mode`.
4. 


// OS Kernel saves `Thread Context` that consists of data stored on CPU registers into the dedicated place in memory (kernel stack).

#### CPU registers and TCB
