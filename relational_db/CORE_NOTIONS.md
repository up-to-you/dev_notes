### Attribute 
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
_table column (e.g property of business entity)_

### Tuple 
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
_table row in relational database_

### Relationship
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
_set of unique attributes that represent table in rdb_

### Relationship Scheme
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
_set of unique attributes that represent whole rdb scheme with multiple tables_

### Functional dependency
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
_Is denoted as X -> Y._

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
_Functional dependence exists if there is no such tuple where the attribute values are equal to X but not equal to Y._

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
_In another words: if there are tuples with X value duplicates, then Y values should also be duplicated._

- _However, need to pay attention to:_ 
    - _relational algebra doesn't allow tuple duplicates (if R = (X,Y,Z) and X=Y, then Z must be unique)._
    - _following example is a valid FD = X -> Y:_
    
      |X|Y|
      |-|-|
      |A|C|
      |B|C|

    - _following example is an **INVALID** FD = X -> Y:_
    
      |X|Y|
      |-|-|
      |A|B|
      |A|C|

### Irreducible Functional dependency
_X -> Y is **Irreducible Functional dependency** if for every subset of X :_

            if Z ⊂ X then Z !-> Y

### Armstrong's axioms
- **Reflexivity**
                  
                  if (X -> Y && Z ⊆ Y) then X -> Z
- **Augmentation**

                  if (X -> Y) then XZ -> YZ
- **Transitivity**

                  if (X -> Y && Y -> Z) then X -> Z

### Anomalies
      dummy table:
|vendor|product|address|
|------|-------|--------|
|A_prov|A_prod|A_addr|
|A_prov|B_prod|A_addr|
|B_prov|C_prod|C_addr|

- **Redundancy anomaly**

    _redundant repetition of address for single vendor_
- **Anomaly of potential contradictions :**

     _changing the address of single vendor entails update of every tuple where this vendor occur_
- **Insertion anomaly**

     _If vendor and product attributes represents composite key  =>  it is not possible to insert new vendor without products_
- **Deletion anomaly**

     _If vendor stopped supplying any product  =>  information about vendor will be erased too, during deletion of all his products_
