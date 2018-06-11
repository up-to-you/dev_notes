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

