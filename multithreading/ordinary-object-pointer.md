#### Ordinary Object Pointer

Behind the scene - the core class, that represents Java classes and instances is `oopDesc`, described in `share/oops/oop.hpp` (ordinary object pointer):
```C++
// oopDesc is the top baseclass for objects classes. The {name}Desc classes describe
// the format of Java objects so the fields can be accessed from C++.
// oopDesc is abstract.
class oopDesc {
  friend class VMStructs;
  friend class JVMCIVMStructs;
 private:
  volatile markOop _mark;
  union _metadata {
    Klass*      _klass;
    narrowKlass _compressed_klass;
  } _metadata;
```
Ordinary Object Pointer serves as a simple C++ Pointer, that points to Java object/instance in memory.   
`oopDesc` is a parent class for all "Java objects" (`instanceOopDesc`) and other `***OopDesc` classes: `markOopDesc`, `arrayOopDesc` etc.    
Since every `***OopDesc` class inherits from `oopDesc` - every `oopDesc` child contains `markWord` and a `Klass*` pointer. 

1. `markOopDesc` - represents header of any object. `markOopDesc` inherits from `oopDesc` (as mentioned in JVM comments - "for historical reasons") and at the same time `oopDesc` contains `markWord` of type `markOopDesc` that is actual object's header.
2. `instanceOopDesc`  - is an instance of a Java Class.
3.  `arrayOopDesc` - abstract baseclass for all arrays (e.g. `typeArrayOopDesc`,`objArrayOopDesc` etc.).


`markWord` is not a real oop but just a word (64 bits). Layout of bits in `markWord` depends on current **lock mechanics** (biased / lightweight / heavyweight), i.e. when object serves as a Monitor for Threads synchronization. For simple unlocked state, `markWord` laid out as:

|  unused   |   Identity hashcode |unused| age   | biased-lock flag | lock state |
|-----------|---------------------|------|-------|------------------|------------|
|  25 bits  |   31 bits           |1 bit | 4 bits|  1 bit           |   2 bits   |

1. Identity hashcode - `System.identityHashCode(x)`
2. Age - how many GC iterations does object survived
3. Biased-lock flag - if biased-locking is enabled (enabled by default since java 7+)
4. Lock state - current **lock mechanics**   

`Klass*` points to struct, which represents *Class Object* (resides in metaspace), on the basis of which the *Class Instance* is instantiated. Some simple `***Oop`'s dispatch calls of virtual functions to their corresponding `Klass`. Therefore no need to store C++ virtual table Pointer in every Java Object.
```C++
// A Klass provides:
//  1: language level class object (method dictionary etc.)
//  2: provide vm dispatch behavior for the object
// Both functions are combined into one C++ class.

// One reason for the oop/klass dichotomy in the implementation is
// that we don't want a C++ vtbl pointer in every object.  Thus,
// normal oops don't have any virtual functions.  Instead, they
// forward all "virtual" functions to their klass, which does have
// a vtbl and does the C++ dispatch depending on the object's
// actual type.  (See oop.inline.hpp for some of the forwarding code.)
class Klass : public Metadata {
```

For the purpose of Java memory management, `oopDesc` is handled via `Handle` class (parent class for type-specific `Handles`, e.g. `instanceHandle`,`arrayHandle`,`objArrayHandle`,`typeArrayHandle`).
OOP `Handle` is just another layer of indirection for managing and updating OOP pointer during GC.
```C++
// In order to preserve oops during garbage collection, they should be
// allocated and passed around via Handles within the VM. A handle is
// simply an extra indirection allocated in a thread local handle area.
//
// A handle is a value object, so it can be passed around as a value, can
// be used as a parameter w/o using &-passing, and can be returned as a
// return value.
//
// Handles are specialized for different oop types to provide extra type
// information and avoid unnecessary casting. For each oop type xxxOop
// there is a corresponding handle called xxxHandle.
//
// Base class for all handles. Provides overloading of frequently
// used operators for ease of use.
class Handle {
 private:
  oop* _handle;

 protected:
  oop     obj() const          { return _handle == NULL ? (oop)NULL : *_handle; }
  oop     non_null_obj() const { assert(_handle != NULL, "resolving NULL handle"); return *_handle; }
```
