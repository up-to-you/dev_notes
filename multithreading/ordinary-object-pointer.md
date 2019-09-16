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
`oopDesc` is a parent class for all "Java objects", such as `instanceOopDesc`, `markOopDesc`, `arrayOopDesc` etc.      
Since every `***OopDesc` class inherits from `oopDesc` - every `oopDesc` child contains `markWord` and a `Klass*` pointer. 

1. `markOopDesc` - represents header of any object. `markOopDesc` inherits from `oopDesc` (as mentioned in JVM comments - "for historical reasons") and at the same time `oopDesc` contains `markWord` of type `markOopDesc` that is actual object's header.
2. `instanceOopDesc`  - is an instance of a Java Class.
3.  `arrayOopDesc` - abstract baseclass for all arrays (e.g. `typeArrayOopDesc`,`objArrayOopDesc` etc.).

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
