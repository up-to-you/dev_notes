### Mutex / Lock, Monitor, Semaphore

#### Mutex / Lock
Mutex (or Lock) is just a flag, that resides in memory and can be represented as two bits (according to JVM implementation).
This flag helps to accomplish `mutual exclusion`. `Mutual exclusion` describes the property in concurrent programming, such that, given the two threads T1, T2: T2 will never access critical part of data, while T1 is working on it.

// FIXME
Every class object or corresponding instance of a class in JVM contains specialized two bits reserved for this flag. Hotspot and OpenJDK implementations use optimized `CAS` CPU instruction to update the state of this two bits (flag). 
// FIXME


**For Biased-lock** : share/runtime/biasedLocking.cpp:670  
(CAS whole markWord [share/oops/oop.hpp:59 => share/oops/markOop.hpp:104] for newer rebiasedPrototype)  
```C++
markOop rebiased_prototype = 
markOopDesc::encode((JavaThread*) THREAD, mark->age(), prototype_header->bias_epoch());
```


**For Flat-lock** (Inflated - OS based) : share/runtime/objectMonitor.cpp:270  
(CAS thread pointer, that currently is owning the lock, share/runtime/objectMonitor.hpp:152)  


Every mainstream OS provides such functionality as mutex (called `futex` in Linux), however `system-call` is expensive enough to compete with `CAS`, which can be directly compiled by `intrinsic` (http://javaagile.blogspot.com/2012/07/why-system-calls-are-slow.html).



[lock-mechanics.md](lock-mechanics.md)
--- cooperation, spin-lock, spin-wait

#### Monitor
