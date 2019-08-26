### Object header
### Unlocked  &nbsp;=>&nbsp;  Biased lock  &nbsp;=>&nbsp;  Lightweight lock (thin)  &nbsp;=>&nbsp;  Fat lock (inflated).

Every class object or corresponding instance of a class contains object header `share/oops/oop.hpp (oopDesc)`, which consists of two `words`:  
*mark word* `markOop _mark` and  
*class word (describes class object)*.

Most of the time (during Biased, Thin locks and before inflating to heavyweight Fat lock) JVM utilize `CAS` CPU instruction for internal implementation of optimized Locking. 

### Unlocked  &nbsp;=>&nbsp;  Biased lock

Below are layouts of *mark word* during unlocked and biased lock states:


| Unlocked, but biasable :    | 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;| epoch | age   |1   |01  |
| --------------------------- |:-------------:| -----:| -----:|---:|---:|

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;**initial lock**  &nbsp;&darr; &uarr;&nbsp; **rebias**

| Biased, locked/unlocked :   | Thread id     | epoch | age   |1   |01  |
| --------------------------- |:-------------:| -----:| -----:|---:|---:|

* Last two bits `01` in *mark word* denotes current type of Lock mechanism, that depends on `contention` of threads over this object (being a monitor).
* Third bit from the end `1` denotes that object is allowed to be biasable.
* `age` - how many GC did the object survive.
* `epoch` - the number of rebiase operations performed on object.
* `Thread id` - current ID of owner (i.e. Thread).

*Source code samples:*    

* **For Biased-lock** : share/runtime/biasedLocking.cpp:670  
(CAS whole markWord [share/oops/oop.hpp:59 => share/oops/markOop.hpp:104] for newer rebiasedPrototype)
  ```C++
  markOop rebiased_prototype = 
  markOopDesc::encode((JavaThread*) THREAD, mark->age(), prototype_header->bias_epoch());
  ```
* **For Thin-lock** (lightweight, not biased, contention is not too high) : share/runtime/synchronizer.cpp:347  
(CAS mechanics the same as for Biased-lock)

* **For Flat-lock** (Inflated - OS based) : share/runtime/objectMonitor.cpp:270  
(CAS thread pointer, that currently is owning the lock, share/runtime/objectMonitor.hpp:152) 



??? need to describe Adaptive Spinning Support



There is another issue in threads synchronization called `Contention`.  
`Contention` denotes the state, when multiple threads trying to access resource, that currently acquired and locked by another thread.  

Having only **Mutex** on hand, there are only two common ways to achieve multithreaded synchronization:
1. by using `futex` system-calls with `FUTEX_WAIT`, such that `contended` threads will be put to sleep and further thread awakening is costly.
2. by simply spinning threads (Spin-Lock), such that `contended` threads will burn a lot of CPU cycles. Also, simple Spin-Lock may lead to Thread starvation.

??? spin-wait

??? fast-path / slow-path
