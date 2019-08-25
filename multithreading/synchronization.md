### Mutex / Lock, Monitor, Semaphore

#### Mutex / Lock
Mutex (or Lock) is an OS-specific structure, that helps to implement basic primitive synchronization across Threads and even Processes. Mutex can be represented simply as flag (single bit, which takes values: 0, 1).  

This flag helps to achieve `mutual exclusion`. `Mutual exclusion` describes the property in concurrent programming, such that, given the two threads T1, T2: T2 will never access critical part of data, while T1 is working on it. 

Safe flag value modification is achieved by CPU instructions, such as `LOCK`.  
`LOCK` is a prefix feature (e.g. `LOCK CMPXCHG`, `CMPXCHG` - compare and exchange) which protects a single instruction while holding other threads for the duration of that single instruction.


Every mainstream OS provides such functionality as mutex (called `futex` in Linux, however `futex` itself provides much more functionality than simple mutex). To use such OS-specific synchronization primitives, out application need to perform `system-call`, which is expensive (http://javaagile.blogspot.com/2012/07/why-system-calls-are-slow.html).  
Most modern multithreading libraries rely on `CAS` CPU instruction for implementing mutex-like feature. 


**Mutex** as a term, doesn't provide any functionality like threads cooperation or mechanism that tells other threads to wait until certain condition is met.


More on that how lock is implemented in JVM along with Adaptive Spinning:  
[lock-mechanics.md](lock-mechanics.md)

#### Monitor

Monitor provides both: locking and cooperation mechanics.  
Cooperation mechanics are implementation specific (e.g. using `futex` with `FUTEX_WAIT` on Threads, that are currently trying to acquire already locked mutex).


#### Semaphore
