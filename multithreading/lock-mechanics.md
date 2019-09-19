### Object header
### Unlocked  &nbsp;&rarr;&nbsp;  Biased lock  &nbsp;&rarr;&nbsp;  Lightweight lock (thin)  &nbsp;&rarr;&nbsp;  Fat lock (inflated).

Initially, for clarification see [Ordinary Object Pointer](ordinary-object-pointer.md)

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

First of all, the Thread is trying to acquire the lock by using CAS instruction on Object's header `markWord`. CAS instruction is trying to set current Thread ID into the `markWord`, if it succeeds - the Object (that represents current Monitor) is biased towards that Thread. Biased fast-path locking is JITted, such that no modifications of Object's header are performed. NULL instead of Thread ID in `markWord` indicates `anonymously biased` object (biased towards NOBODY yet). 
`Anonymously biased` - means, that nobody acquired this Monitor yet, but bias-bit `01` is already set, `share/oops/markOop.hpp:190`:
```C++
  // Indicates that the mark has the bias bit set but that it has not
  // yet been biased toward a particular thread
  bool is_biased_anonymously() const {
    return (has_bias_pattern() && (biased_locker() == NULL));
  }
```
The first thread which locks an anonymously biased object - Biases the lock toward that thread, respectively. Algorithm briefly described in `src/hotspot/share/runtime/biasedLocking.hpp : `.

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
describes, that second thread, which comes to acquire already biased lock will cause biased thread test (monitor header value check) to fail. If it fail and JVM detects (through internal heuristics), that current synchronization between Threads is `Uncontended` - there will be a try to rebias the lock (`BIAS_REVOKED_AND_REBIASED`) towards newcomer Thread. If rebiasing fails or there is a `Contention` between Threads - bias will be revoked and therefore switch to `Lightweight (thin)` lock state.

Lock rebiasing towards newcomer Thread is performed at `share/runtime/biasedLocking.cpp:475`:
```C++
static BiasedLocking::Condition bulk_revoke_or_rebias_at_safepoint(oop o,
                                                                   bool bulk_rebias,
                                                                   bool attempt_rebias_of_object,
                                                                   JavaThread* requesting_thread) {
...
... ...
... ... ...
  if (attempt_rebias_of_object &&
      o->mark()->has_bias_pattern() &&
      klass->prototype_header()->has_bias_pattern()) {
    markOop new_mark = markOopDesc::encode(requesting_thread, o->mark()->age(),
                                           klass->prototype_header()->bias_epoch());
    o->set_mark(new_mark);
    status_code = BiasedLocking::BIAS_REVOKED_AND_REBIASED;
    log_info(biasedlocking)("  Rebiased object toward thread " INTPTR_FORMAT, 
                                                              (intptr_t) requesting_thread);
  }
... ... ...
... ...
...
```

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

Any further monitor acquiring during Lightweight lock state is performing using CAS instruction, since `slow_enter` denotes slow-path without Biased-like fast-path JIT optimizations.
```C++
// Interpreter/Compiler Slow Case
// This routine is used to handle interpreter/compiler slow case
// We don't need to use fast path here, because it must have been
// failed in the interpreter/compiler code.
void ObjectSynchronizer::slow_enter(Handle obj, BasicLock* lock, TRAPS) {
```
`markWord` layouts during transition Biased lock &rarr; Lightweight lock  

| Biased, locked :            | Thread id     | epoch | age   |1   |01  |
| --------------------------- |:-------------:| -----:| -----:|---:|---:|

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &darr; &darr; &darr;

| Thin/Lightweight locked object : | Pointer to original header (markword)  |00 |
| --------------------------- |:-------------:|--------:|

After Biased lock was Revoked - JVM invokes `slow_enter` functon `share/runtime/synchronizer.cpp:279`. JVM copies Monitor's object header (`markWord`) to it's own Stack Slot (within Stack Frame) and then tries to set a pointer in the original Monitor's object `markWord` via CAS instruction, that points to copied `markWord`.   
The copied `markWord`, that resides in Thread's Stack Slot is called `displaced header`.   
```C++
    Unlocked:
    [ original_header | 01 ]    |   Stack frame   |
                                |                 |
    Locked:                     |                 |
    [ stack_pointer | 00 ]      |                 |
         |                      |-----------------|
          --------------------->| original_header |
                                |(displaced copy) |
                                |-----------------|
                                |                 |
                                |                 |
                                 -----------------
```
`Displaced header` and its pointer in the original Monitor's header are necessary for two reasons:   
1) Eventually, when Unlocking of Monitor occurs, current header must be replaced with the `original header`. It can be done easily, since `original header` is reachable via `stack_pointer`. 
2) When thread acquires the lock, besides copying original `markWord` and setting the pointer to Monitor's header, it also modifies last 2 bits of Monitor's header to `00`, which mean `locked` Monitor. However, Lock can be acquired multiple times by the same Thread (i.e. recursive lock), but only the **last** Lock release must trigger the return of the `original header`. Such optimization as storing `original header` via pointer allows not to spam via relatively heavy Lock/Unlock operations during recursive locking.

During Recursive locking, `stack pointer` is replaced with `NULL` (which denotes recursive lock), being that current Thread (Lock owner) already contains copy of `original header` in its Stack Slot.

There are only few positive conditions for further performing of Thin locking in `slow_enter` function (`share/runtime/synchronizer.cpp:339`):  
1. If current object's monitor is free, therefore CAS results in success (`original header` is replaced with `stack_pointer`)
2. If object's monitor is not free, but the owner of the monitor is current Thread (recursive locking, `stack_pointer` is replaced with `NULL`).
3. Otherwise, Monitor becomes inflated and switches to Fat locking, which in turn leverages the OS-based Threads synchronization via system calls.

### Lightweight lock (thin)  &nbsp;&rarr;&nbsp;  Heavyweight (Fat) lock

`markWord` layouts during transition between Lighweight lock &rarr; Heavyweight lock  

| Thin/Lightweight locked object : | Pointer to original header (markword)  |00 |
| --------------------------- |:-------------:|--------:|

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &darr; &darr; &darr;

| Fat/Heavyweight locked object : | Pointer to ObjectMonitor  |10 |
| --------------------------- |:-------------:|--------:|

When CAS-based synchronization during Lightweight Lock cause `Contention` (as described in point 3., since points 1.,2.  failed) - JVM switches to **Inflated Monitor** `share/runtime/synchronizer.cpp:365` (`slow_enter`):
1. In `ObjectSynchronizer::inflate` (`share/runtime/synchronizer.cpp:1387`) function, JVM sets a Pointer to fat `ObjectMonitor` and last two bits to `10` in a `markWord`, using CAS instruction.
2. After atomic `inflate` operation was succeeded, JVM tries to acquire Monitor's fat lock `ObjectMonitor::enter`(`share/runtime/synchronizer.cpp:367`).
3. In `ObjectMonitor::enter` JVM performs several attempts to acquire lock using SPIN-LOOP and CAS. If attempts failed, JVM performs expensive Platform-Specific `os::PlatformEvent::park()` system-call, which involves Platform Thread Scheduler, Context Switching, etc. For Linux `os::PlatformEvent::park()` function located at `os/posix/os_posix.cpp:1827`. 

**OS-based Threads synchronization is slow mostly for 3 reasons:**
1. System-call for Thread parking is expensive, since, for the sake of execution some System/OS function - Processor needs to switch from `user mode` (user application) to `kernel mode` (system scope). In `user mode` Processor has access to dedicated virtual address space specifically for current User Application. `User mode` forbids Processor for any access to kernel virtual address space, since errors in kernel space may lead to OS crash. For the sake of System-call - Processor switches from `user mode` to `kernel mode`, executes System/OS function and switches back to `user mode` again for further execution of Application.
2. `unpark()` time is not deterministic, due to OS Thread Scheduler mechanics. After `unpark()` System-call was invoked, it may take a long time for actual Thread awakening, as there could be other busy Threads in OS, which Scheduler can decide to execute instead of those currently requested for awakening.
3. For switching native Threads OS performs so-called [Context Switch](context-switch.md) and it's fairly expensive procedure.

??? cxq, EntryList, WaitSet

??? need to describe Adaptive Spinning Support

