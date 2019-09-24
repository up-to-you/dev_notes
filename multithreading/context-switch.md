#### Context Switch

In scope of JVM, when `os::PlatformEvent::park()` is invoked - JVM uses POSIX (for linux) `pthread_mutex_lock` and `pthread_cond_wait` system-calls for Thread's state control, which involves OS Thread Scheduler. The Scheduler make a decision about switching the threads and the following steps are taken (note that `Context Switching` is allowed only in `kernel mode` since it operates on operating system native threads):
1. Just like with System-Calls `Context Switch` also requires switching between `user mode` to `kernel mode`. Every native Thread's stack is divided into two isolated parts : `user stack` and `kernel stack`: 
   * `User stack` is used during normal user Application execution and is allocated in `user mode` virtual address space. `User stack` holds local variables, function arguments, frame pointer, function return address, etc.
   * `Kernel stack` is used during `Context Switch` in `kernel mode` and is allocated in `kernel mode` address space. `Kernel stack` is intended for saving current values from CPU registers (that is, storing current CPU execution state).     
   
   `User` and `Kernel` stacks are separated for the same security and stability reasons as `mode`'s address spaces.   
   So, the first step that the operating system takes is switching between `User mode` to `Kernel mode`. 
2. In `Kernel mode` OS saves values from CPU registers (Program Counter, Stack Pointer, etc.) to Thread's `Kernel stack` and Thread Control Block (`TCB`). Actually, when Thread crosses into `Kernel mode` the `Kernel Stack` for this Thread is empty, since every time Thread goes back from `Kernel mode` to `User mode` the `Kernel Stack` get cleaned.
3. On the top of the `Kernel stack` there is so-called "interrupt" stack frame in which the value of `User mode` Stack Pointer is stored. This allows the Thread to store the point of user's execution state when it comes back from `Kernel mode` to `User mode`. The figure below depicts the state of stack parts at this point.  
```C
                      W  H  O  L  E      R  A  M
 _______________________________________________________________________
|        user mode address space            | kernel mode address space |
|___________________________________________|___________________________|


               U  S  E  R      M  O  D  E      S  P  A  C  E      
 ________________________________________________________________________
|           |     user stack       |                         |           | 
|  .......  |local vars, args, etc.|                         |  .......  |
|___________|______________________|_________________________|___________| 
                Specific Process/Application virtual space              

         
  K  E  R  N  E  L      M  O  D  E      S  P  A  C  E      
 ______________________________________________________
|          kernel stack          |                     |
| stack pointer| cpu regs values |      .........      |
|______________|_________________|_____________________|
interrupt frame             
```
4.  


// OS Kernel saves `Thread Context` that consists of data stored on CPU registers into the dedicated place in memory (kernel stack).

#### CPU registers and TCB
