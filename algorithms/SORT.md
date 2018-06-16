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

Average: `(n^2) / 4`, in comparison to `Bubble Sort` - inner loop is not just half of array length, it is `half * half`, since `key` can be placed in the middle of the inner loop index.

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
#### Selection Sort
Selection Sort is a simplest algorithm: average time is equal to `(n^2) / 2` , but there are less memory modification operations in comparison to `Insertion Sort`.

Every inner `f` loop is seeking for minimal element in the entire array and puts it at the first index,
then it seeking for the next minimal element in the rest of the array `(array.length - current i)` and puts it in the second index from the start of the array, and so on...


```java
class SelectionSort {
    static void sort(int[] target) {
        for(int i = 0; i < target.length; i++) {
            int minIdx = i;

            for(int f = i + 1; f < target.length; f++) {
                if(target[f] < target[minIdx]) {
                    minIdx = f;
                }
            }

            if(minIdx != i) {
                swap(target, i, minIdx);
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
#### Quick Sort

Average time is `n*log(n)`, since on the average - the tree (which forms from the recursive calls) is near balanced, therefore it's depth is about `log(n)` , however, on every level of the tree we iterate over every element of array (no matter it is `2 * arr/2` or `4 * arr/4` , the sum is `n` - iterations), thus the complexity is `log(n) * n`.

```java
class QuickSort {

    static void sort(int[] target) {
        quickSort(target, 0, target.length - 1);
    }

    private static void quickSort(int[] target, int start, int end) {
        /* stop signal for recursion, that there are at least 2 elements to sort */
        if(start < end) {
            int pivotIdx = partSort(target, start, end);

            /* sort left side from pivot */
            quickSort(target, start, pivotIdx - 1);
            /* sort right side from pivot */
            quickSort(target, pivotIdx, end);
        }
    }

    private static int partSort(int[] target, int start, int end) {
        int pivotIdx = (start + end) / 2;

        while (start < end) {
            while (target[start] < target[pivotIdx]) {
                start++;
            }
            while (target[end] > target[pivotIdx]) {
                end--;
            }

            swap(target, start, end);
            start++;
            end--;
        }

        return start;
    }

    private static void swap(int[] target, int from, int to) {
        int temp = target[from];
        target[from] = target[to];
        target[to] = temp;
    }
}
```

#### Merge Sort

