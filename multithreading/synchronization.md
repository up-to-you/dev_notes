### Mutex / Lock, Monitor, Semaphore

#### Mutex / Lock
Mutex (or Lock) is an OS-specific structure (https://github.com/torvalds/linux/blob/master/include/linux/mutex.h), that helps to implement basic primitive synchronization across Threads and even Processes. In general, mutex can be represented simply as a flag (single bit, which takes values: 0, 1).  

This flag helps to achieve `mutual exclusion`. `Mutual exclusion` describes the property in concurrent programming, such that, given the two threads T1, T2: T2 will never access critical part of data, while T1 is working on it. 

Safe flag value modification is achieved by CPU instructions, such as `LOCK`.  
`LOCK` is a prefix feature (e.g. `LOCK CMPXCHG`, `CMPXCHG` - compare and exchange) which protects a single instruction while holding other threads for the duration of that single instruction.


Every mainstream OS provides such functionality as mutex (called `futex` in Linux, however `futex` itself provides much more functionality than simple mutex). To use such OS-specific synchronization primitives, our application need to perform `system-call`, which is expensive (http://javaagile.blogspot.com/2012/07/why-system-calls-are-slow.html).  
Most modern multithreading libraries rely on `CAS` CPU instruction for implementing mutex-like feature. 


Mutex as a term, doesn't provide any functionality like threads cooperation or mechanism that tells other threads to wait until certain condition is met.


#### Monitor

Monitor provides both: locking and cooperation mechanics.  
Cooperation mechanics are implementation specific (e.g. using `futex` with `FUTEX_WAIT` on Threads, that are currently trying to acquire already locked mutex).


#### Semaphore

Semaphore is more like a Monitor with a counter.  
Binary-Semaphore acts like a Monitor itself, since it allows only a single thread to work with resource simultaneously.  
More common Semaphore contains counter and a limit - when some thread acquires the lock - semaphore increments the counter.  
If the counter reaches the limit - semaphore will forbid any access for another threads, until some of the already working threads release the lock and decrements the counter.  


*More on that how lock is implemented in JVM along with Adaptive Spinning:  [lock-mechanics.md](lock-mechanics.md)*
