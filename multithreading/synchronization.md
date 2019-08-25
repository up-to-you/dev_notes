### Mutex / Lock, Monitor, Semaphore

#### Mutex / Lock
Mutex (or Lock) is an OS-specific structure, that helps to implement basic primitive synchronization across Threads and even Processes. Mutex can be represented simply as flag (single bit, which takes values: 0, 1).  

This flag helps to accomplish `mutual exclusion`. `Mutual exclusion` describes the property in concurrent programming, such that, given the two threads T1, T2: T2 will never access critical part of data, while T1 is working on it. 

Safe flag value modification is achieved by CPU instructions, such as `LOCK`.  
`LOCK` is a prefix feature (e.g. `LOCK CMPXCHG`, `CMPXCHG` - compare and exchange) which protects a single instruction while holding other threads for the duration of that single instruction.


Every mainstream OS provides such functionality as mutex (called `futex` in Linux), however `system-call` is expensive enough to compete with `CAS`, which can be directly compiled by `intrinsic` (http://javaagile.blogspot.com/2012/07/why-system-calls-are-slow.html).


There is another issue in threads synchronization called `Contention`.  
`Contention` denotes the state, when multiple threads trying to access resource, that currently acquired and locked by another thread.  
Having only **Mutex** on hand, there are only two common ways to achieve multithreaded synchronization:
1. by using `futex` system-calls with `FUTEX_WAIT`, such that `contended` threads will be put to sleep and further thread awakening is costly.
2. by simply spinning threads, such that `contended` threads will burn a lot of CPU cycles.

Bare Mutex is not enough for complete synchronization. Spinning
Thread contention

FUTEX_WAIT
More on that how lock is implemented in JVM:  
[lock-mechanics.md](lock-mechanics.md)

#### Monitor
--- cooperation, (spin-lock, spin-wait as common approaches)
