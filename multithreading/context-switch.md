#### Context Switch

In scope of JVM, when `os::PlatformEvent::park()` is invoked - JVM uses POSIX (for linux) `pthread_mutex_lock` and `pthread_cond_wait` system-calls for Thread's state control, which involves OS Thread Scheduler. The Scheduler make a decision about switching the threads and the following steps are taken (note that `Context Switching` is allowed only in `kernel mode`):
1. OS Kernel saves `Thread Context` that consists of data stored on CPU registers into the dedicated place in memory (kernel stack).
2. 
