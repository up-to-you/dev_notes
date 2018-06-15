#### Bubble Sort
Most primitive decision, average time is about `(n^2) / 2` , since avg length of inner loop is about `arr.length / 2`

In a nutshell : every `i` iteration in `f` loop - we push `higher` elements forward. 

Every `f` loop starts from zero to current `i` element, correcting previous `f` loop sort.

```java
class BubbleSort {
    static void sort(int[] target) {
        for(int i = 1; i < target.length; i++) {
            for(int f = 0; f < i; f++) {
                if(target[f] > target[i]) {
                    swap(target, f, i);
                }
            }
        }
    }

    private static void swap(int[] target, int from, int to) {
        int temp = target[from];
        target[from] = target[to];
        target[to] = temp;
    }
}
```

#### Insertion Sort

Logic: Loop `i` -> take `key` that resides on `i` index and check if elements before `key` are higher than `key`, is fo - push those elements one place forward to free up place for `key` element.

Average: `(n^2)/4`, in comparison to `Bubble Sort` - inner loop is not just half of array length, it is `half * half`, since `key` can be placed in the middle of the inner loop index.

```java
class InsertionSort {
    static void sort(int[] target) {
        for(int i = 1; i < target.length; i++) {
            int key = target[i];

            int f = i - 1;
            while (f >= 0 && target[f] > key) {
                // push to one place forward
                target[f + 1] = target[f];
                f--;
            }
            target[f + 1] = key;
        }
    }
}
```
