#### BASED ON ORACLE MODEL

3 main transactions behavior:

* **DIRTY READ**
  
  another transaction has access to dirty data, even those, which were not written down definitively. 
  It allows such cases, as reading part of the data during writing.

* **NON-REPEATABLE READ**
  
  sequential read operations doesn't guarantee that the same data will return, 
  since another transaction could update those records, which were returned from the first SELECT.

* **PHANTOM READ**

  sequential read operations guarantee, that rows and values will be identical during multiple read operations.
  Exception - subsequent read operations can return more rows, than previous, due to insertions of second transaction.
  
  
| isolation levels  | acceptable behavior |
| ------------- | ------------- |
| UNCOMMITED_READ  | **PHANTOM READ**, **NON-REPEATABLE READ** , **DIRTY READ** |
| COMMITED_READ  | **PHANTOM READ**, **NON-REPEATABLE READ** |
| REPEATABLE_READ  | **PHANTOM READ**  |
| SERIALIZABLE  | -------  |
