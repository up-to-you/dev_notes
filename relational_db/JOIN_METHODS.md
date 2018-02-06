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
for Cartesian product...


### HASH JOIN

_usage conditions :_

_logic :_

### SORT MERGE JOIN

_usage conditions :_

_logic :_

