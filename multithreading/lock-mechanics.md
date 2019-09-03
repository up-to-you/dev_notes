### Object header
### Unlocked  &nbsp;&rarr;&nbsp;  Biased lock  &nbsp;&rarr;&nbsp;  Lightweight lock (thin)  &nbsp;&rarr;&nbsp;  Fat lock (inflated).

Every class object or corresponding instance of a class contains object header `share/oops/oop.hpp (oopDesc)`, which consists of two `words`:  
*mark word* `markOop _mark` and  
*class word (describes class object)*.

Most of the time (during Biased, Thin locks and before inflating to heavyweight Fat lock) JVM utilize `CAS` CPU instruction for internal implementation of optimized Locking. 

`Contention`- the name is the same as it's meaning, it's a contention between Threads for some resource, in current scope - contention for Object's Monitor lock. 

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
describes, that second thread, which comes to acquire already biased lock will cause biased thread test (monitor header value check) to fail. If it fail and JVM detects (through internal heuristics), that current synchronization between Threads is `Uncontended` - there will be a try to rebias the lock (`BIAS_REVOKED_AND_REBIASED`). If rebiasing fails or there is a `Contention` between Threads - bias will be revoked and therefore switch to `Lightweight (thin)` lock state.

Fast path (i.e. JITed) interpreted piece resides in `share/runtime/synchronizer.cpp:270`:  
if Biased lock was `BIAS_REVOKED_AND_REBIASED` - return and avoid slow_enter (i.e. slow path) invocation:
```C++
// -----------------------------------------------------------------------------
//  Fast Monitor Enter/Exit
// This the fast monitor enter. The interpreter and compiler use
// some assembly copies of this code. Make sure update those code
// if the following function is changed. The implementation is
// extremely sensitive to race condition. Be careful.

void ObjectSynchronizer::fast_enter(Handle obj, BasicLock* lock,
                                    bool attempt_rebias, TRAPS) {
  if (UseBiasedLocking) {
    if (!SafepointSynchronize::is_at_safepoint()) {
      BiasedLocking::Condition cond = BiasedLocking::revoke_and_rebias(obj, attempt_rebias, THREAD);
      if (cond == BiasedLocking::BIAS_REVOKED_AND_REBIASED) {
        return;
      }
    } else {
      assert(!attempt_rebias, "can not rebias toward VM thread");
      BiasedLocking::revoke_at_safepoint(obj);
    }
    assert(!obj->mark()->has_bias_pattern(), "biases should be revoked by now");
  }

  slow_enter(obj, lock, THREAD);
}
```

The attempt to rebias (`revoke_and_rebias`) occurs in `share/runtime/biasedLocking.cpp:670`:
```C++
if (attempt_rebias) {
    assert(THREAD->is_Java_thread(), "");
    markOop biased_value       = mark;
    markOop rebiased_prototype = 
        markOopDesc::encode((JavaThread*) THREAD, mark->age(), prototype_header->bias_epoch());
        markOop res_mark = obj->cas_set_mark(rebiased_prototype, mark);
        if (res_mark == biased_value) {
          return BIAS_REVOKED_AND_REBIASED;
        }
  ```
where current Thread is trying to CAS whole markWord in Monitor's object header (described in `share/oops/oop.hpp:59` and `share/oops/markOop.hpp:104`) for newer `markOop rebiased_prototype`.

### Biased lock  &nbsp;&rarr;&nbsp;  Lightweight lock (thin)

So, the Biased lock keeps alive while fast-path header's value test is passing successfully.

The crucial moment between Biased and Lightweight lock (as described above) occurs, when another Thread performs CAS instruction to acquire this already Biased Lock and if it succeeded - object's header value is changed, therefore leading to test failure in Biased Thread. If JVM detects (through internal heuristics), that current synchronization between Threads is `Uncontended` - there will be attempt to rebiase the lock (`BIAS_REVOKED_AND_REBIASED`), otherwise - Bias Revocation will be performed.

So, if any of conditions in `share/runtime/biasedLocking.cpp:revoke_and_rebias` func results in returning `BIAS_REVOKED`, 
then JVM start to use slow_enter `share/runtime/synchronizer.cpp:279` (i.e. Lightweight / Thin lock).

One of such example `share/runtime/biasedLocking.cpp:647`:
```C++
if (!prototype_header->has_bias_pattern()) {
      // This object has a stale bias from before the bulk revocation
      // for this data type occurred. It's pointless to update the
      // heuristics at this point so simply update the header with a
      // CAS. If we fail this race, the object's bias has been revoked
      // by another thread so we simply return and let the caller deal
      // with it.
      markOop biased_value       = mark;
      markOop res_mark = obj->cas_set_mark(prototype_header, mark);
      assert(!obj->mark()->has_bias_pattern(), "even if we raced, should still be revoked");
      return BIAS_REVOKED;
```


` share/runtime/synchronizer.cpp:339 `  

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

