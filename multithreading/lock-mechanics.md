### Object header
### Unlocked  &nbsp;&rarr;&nbsp;  Biased lock  &nbsp;&rarr;&nbsp;  Lightweight lock (thin)  &nbsp;&rarr;&nbsp;  Fat lock (inflated).

Every class object or corresponding instance of a class contains object header `share/oops/oop.hpp (oopDesc)`, which consists of two `words`:  
*mark word* `markOop _mark` and  
*class word (describes class object)*.

Most of the time (during Biased, Thin locks and before inflating to heavyweight Fat lock) JVM utilize `CAS` CPU instruction for internal implementation of optimized Locking. 

### Unlocked  &nbsp;&rarr;&nbsp;  Biased lock

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

`src/hotspot/share/runtime/biasedLocking.hpp : `

```C++
// The basic observation is that in HotSpot's current fast locking
// scheme, recursive locking (in the fast path) causes no update to
// the object header. The recursion is described simply by stack
// records containing a specific value (NULL). Only the last unlock by
// a given thread causes an update to the object header.
//
// This observation, coupled with the fact that HotSpot only compiles
// methods for which monitor matching is obeyed (and which therefore
// can not throw IllegalMonitorStateException), implies that we can
// completely eliminate modifications to the object header for
// recursive locking in compiled code, and perform similar recursion
// checks and throwing of IllegalMonitorStateException in the
// interpreter with little or no impact on the performance of the fast
// path.
//
// The basic algorithm is as follows (note, see below for more details
// and information). A pattern in the low three bits is reserved in
// the object header to indicate whether biasing of a given object's
// lock is currently being done or is allowed at all.  If the bias
// pattern is present, the contents of the rest of the header are
// either the JavaThread* of the thread to which the lock is biased,
// or NULL, indicating that the lock is "anonymously biased". The
// first thread which locks an anonymously biased object biases the
// lock toward that thread. If another thread subsequently attempts to
// lock the same object, the bias is revoked.
//
// Because there are no updates to the object header at all during
// recursive locking while the lock is biased, the biased lock entry
// code is simply a test of the object header's value. If this test
// succeeds, the lock has been acquired by the thread. If this test
// fails, a bit test is done to see whether the bias bit is still
// set. If not, we fall back to HotSpot's original CAS-based locking
// scheme. If it is set, we attempt to CAS in a bias toward this
// thread. The latter operation is expected to be the rarest operation
// performed on these locks. We optimistically expect the biased lock
// entry to hit most of the time, and want the CAS-based fallthrough
// to occur quickly in the situations where the bias has been revoked.
```
`fast path` refers to JIT optimized code block, while `slow path` describes native C++ interpreter.

`Fast path is a term used in computer science to describe a path with shorter instruction path length through a program compared to the 'normal'(i.e. slow-path) path.`

*"... Because there are no updates to the object header at all during recursive locking while the lock is biased, the biased lock entry code is simply a test of the object header's value..."*  
&larr; So, for such recursive biased-lock - JVM can do this the easy way - just check header's value in biased thread, moreover - optimizinging it using JIT (fast-path).

*"... the biased lock entry code is simply a test of the object header's value. If this test succeeds, the lock has been acquired by the thread. If this test fails, a bit test is done to see whether the bias bit is still set ..."*   
&larr;  
describes, that second thread, which comes to acquire already biased lock will cause biased thread test (monitor header value check) to fail, such that bias will be revoked and therefore switch to `Lightweight (thin)` lock state  
&rarr;  
*"If another thread subsequently attempts to lock the same object, the bias is revoked"*

**Slow path** source code:  
`share/runtime/biasedLocking.cpp:670`  
CAS whole markWord `share/oops/oop.hpp:59 &rarr; share/oops/markOop.hpp:104` for newer rebiasedPrototype:
```C++
  markOop rebiased_prototype = 
     markOopDesc::encode((JavaThread*) THREAD, mark->age(), prototype_header->bias_epoch());
     markOop res_mark = obj->cas_set_mark(rebiased_prototype, mark);
        if (res_mark == biased_value) {
          return BIAS_REVOKED_AND_REBIASED;
  ```

### Biased lock  &nbsp;&rarr;&nbsp;  Lightweight lock (thin)

` share/runtime/synchronizer.cpp `  

```C++
// Interpreter/Compiler Slow Case
// This routine is used to handle interpreter/compiler slow case
// We don't need to use fast path here, because it must have been
// failed in the interpreter/compiler code.
void ObjectSynchronizer::slow_enter(Handle obj, BasicLock* lock, TRAPS) {
```

*Source code samples:*    
* **For Thin-lock** (lightweight, not biased, contention is not too high) : share/runtime/synchronizer::slow_enter.cpp:347  
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

