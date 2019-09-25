#### Context Switch

In scope of JVM, when `os::PlatformEvent::park()` is invoked - JVM uses POSIX (for linux) `pthread_mutex_lock` and `pthread_cond_wait` system-calls for Thread's state control, which involves OS Thread Scheduler. The Scheduler make a decision about switching the threads and the following steps are taken (note that `Context Switching` is allowed only in `kernel mode` since it operates on operating system native threads):
1. Just like with System-Calls `Context Switch` also requires switching between `user mode` to `kernel mode`. Every native Thread's stack is divided into two isolated parts : `user stack` and `kernel stack`: 
   * `User stack` is used during normal user Application execution and is allocated in `user mode` virtual address space. `User stack` holds local variables, function arguments, frame pointer, function return address, etc.
   * `Kernel stack` is used during `Context Switch` in `kernel mode` and is allocated in `kernel mode` address space. `Kernel stack` is intended for saving current values from CPU registers (that is, storing current CPU execution state).     
   
   `User` and `Kernel` stacks are separated for the same security and stability reasons as `mode`'s address spaces.   
   So, the first step that the operating system takes is switching between `User mode` to `Kernel mode`. 
2. In `Kernel mode` OS saves values from CPU registers (Program Counter, Stack Pointer, etc.) to Thread's `Kernel stack` and Thread Control Block (`TCB`). It allows to store CPU execution state for current Thread. In fact, `Kernel stack` is as part of `TCB`. Actually, when Thread crosses into `Kernel mode` the `Kernel Stack` for this Thread is empty, since every time Thread goes back from `Kernel mode` to `User mode` the `Kernel Stack` get cleaned.
3. On the top of the `Kernel stack` the so-called "interrupt" stack frame is allocated, in which the value of `User mode` Stack Pointer is stored. This allows the Thread to restore the point of user's application execution state when it switches back from `Kernel mode` to `User mode`. The figure below depicts the state of stack parts at this point.  
```C
                             W  H  O  L  E      R  A  M
 _________________________________________________________________________________
|        user mode address space                      | kernel mode address space |
|_____________________________________________________|___________________________|


                     U  S  E  R      M  O  D  E      S  P  A  C  E      
 _________________________________________________________________________________
|                 |     user stack       |                         |              | 
|     .......     |local vars, args, etc.|                         |    ......    |
|_________________|______________________|_________________________|______________| 
                      Specific Process/Application virtual space              

         
            K  E  R  N  E  L      M  O  D  E      S  P  A  C  E      
 _______________________________________________________________________
|          kernel stack           |              |                      |
| stack pointer | cpu regs values |              |       .........      |
|_______________|_________________|______________|______________________|
|interrupt frame|                                |
|               |                                | 
|              T C B (task_struct)               |             
```
4. When it comes for switching back from `Kernel mode` to `User mode` - OS restores CPU registers values from `TCB / Kernel stack` back to CPU, including Stack Pointer to continue the Thread in `User mode` from the actual point. Immediately after all CPU values were restored the `Kernel stack` get cleaned. 

#### TCB

`TCB` actually is a data structure (`struct task_struct` in Linux kernel https://github.com/torvalds/linux/blob/master/include/linux/sched.h), which contains Thread's `Kernel stack` and related Thread's system data. `TCB` is located in `Kernel space` and consists of:
   * Thread Identifier: Unique id (TID)
   * Stack Pointer to `User stack` ("interrupt" frame)
   * Program Counter: points to the **current** program instruction of the thread
   * State of the thread (running, ready, waiting...)
   * CPU registers values
   * Pointer to the Process Control Block (PCB) of the process that the thread lives on
   
#### CPU registers
