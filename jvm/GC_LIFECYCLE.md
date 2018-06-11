## HotSpot Garbage Collection Lifecycle

#### GC types:

1. **Minor GC** - covers Eden and Survivor's spaces
2. **Major GC** - covers Tenured space
3. **Full GC** - covers Tenured and Metaspace areas

```java
  if(Eden space is full)
      Minor GC, move to Survivor
      if(Threshold is reached)
          move to Tenured
          if(Tenured is full)
              Major GC, evict Tenured
              if(Heap is over)
                  Full GC, evict entire Heap, Metaspace
```

#### Minor GC

Once `Eden` space is filled, minor GC marks reachable objects for further transfer to `S0`.

<img src="assets/gc_1.png">

`Eden` space is filled again and now minor GC scans `Eden` and `S0` as contigious area, marking reachable objects from both spaces for further transfer to `S1`.
After transfer completed, GC can easely throw out entire area of unreachable objects.

<img src="assets/gc_2.png">

Now, all reachable objects are located at `S1` and Survivor's spaces should be swapped for the next `Minor GC` iteration, i.e. aftewards,`Minor GC` will scan `Eden` and `S1` for reachable objects.

`Eden` space will be filled again and the previous step will be repeated. 

<img src="assets/gc_3.png">

