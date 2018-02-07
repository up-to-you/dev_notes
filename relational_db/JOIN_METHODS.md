### NESTED LOOP JOIN

_usage conditions :_
- small tables
- join conditions must satisfy such that one table must depends on another 
(join conditions must be far from Cartesian product)

_optimizer logic :_
1. Determination of "driven table" for outer loop
2. Second table assignment for inner loop
3. Execution of physical plan as (pseudocode) :
```sql
SELECT ...
   OUTER LOOP
      INNER LOOP
```
for Cartesian product there are more suitable join methods...

### HASH JOIN

_usage conditions :_
- join condition's are equalities
- large amount of data or large tables need to be joined

_optimizer logic :_
1. Table with smaller selection result is choosen, that will fit to available memory.
2. The hash function is calculated. For example, lets consider h(a) = a mod 10 (where 'a' is a current value of join-column):
   
   multiple rows that has same h(a) result will fall into single "hash bucket".
3. Hash calculation of larger table is produced.
4. If hash-bucket's h(a) value is not equal, then none of records inside bucket are equal.

_It is very important that the smaller table fit in available memory. The cost will be reduced dramatically,_

_because asymptotically it will be equal to a single data read of two tables._

### SORT MERGE JOIN

_usage conditions :_
- join conditions are inequalities (<=, >=, <, >)
- join-columns are allready sorted ***OR*** sorting is required in other query's operations

_optimizer logic :_

_Need to notice, that ***hash join*** is applicable only for equality conditions and in most cases is better then sort merge join._

1. Sorting by join-column is performed.
2. Compare is performed such that:


