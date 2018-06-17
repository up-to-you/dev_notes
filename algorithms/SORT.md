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

Logic: Loop `i` -> take `key` that resides on `i` index and check if elements before `key` are higher than `key`, if so - push those elements one place forward to free up place for `key` element.

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

Average time is `n*log(n)`. `Merge Sort` has a huge benefit compared to `Quick Sort` - it's worst time is `n*log(n)`.
While `Quick Sort` can produce unbalanced tree (during selection of worst pivot every time, leading to `n^2`), the `Merge Sort` worst case just increase constant factor in the asymptotic estimate.

Worst case is achieved by producing the maximum number of comparisons between `left` and `right` parts (i.e. `tmp[lPoint] < tmp[rPoint]`).


```java
class MergeSort {
    /* During merge operations we produce inserts into target array,
       therefore it is necessary to have a separate array,
       that will contains numbers from current level of recursive tree
       for further comparisons. Merge op can't be done using single array,
       since during inserts it is easy to lose an item from the current insert index. */
    private static int[] tmp;

    static void sort(int[] target) {
        tmp = new int[target.length];
        mergeSort(target, 0, target.length - 1);
    }

    private static void mergeSort(int[] target, int left, int right) {
        if(left < right) {
            int middle = left + (right - left) / 2;

            mergeSort(target, left, middle);
            mergeSort(target, middle + 1, right);

            merge(target, left, middle, right);
        }
    }

    private static void merge(int[] target, int left, int middle, int right) {
        copy(target, left, right);

        int targetPoint = left;

        int lPoint = left;
        int rPoint = middle + 1;

        while (lPoint <= middle && rPoint <= right) {
            target[targetPoint++] =
                    tmp[lPoint] < tmp[rPoint] ?
                            tmp[lPoint++] :
                            tmp[rPoint++];
        }

        /* if all elements from right side are smaller than element at current lPoint,
            then all elements from lPoint to middle (inclusive) are greater,
            and we should push them sequentially to target array */
        while (lPoint <= middle) {
            target[targetPoint++] = tmp[lPoint++];
        }
        /* same as above, only vice versa */
        while (rPoint <= right) {
            target[targetPoint++] = tmp[rPoint++];
        }
    }

    /* copy elements to the tmp array from the current level of tree */
    private static void copy(int[] target, int from, int to) {
         int length = to - from + 1;
         System.arraycopy(target, from, tmp, from, length);
    }
}
```
