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

### Functional dependence
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
_Is denoted as X -> Y._

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
_Functional dependence exists if there is no such tuple where the attribute values are equal to X but not equal to Y._

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
_In another words: if there are tuples with X value duplicates, then Y values should also be duplicated._

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
_However relational algebra doesn't allow tuple duplicates (if R = (X,Y,Z) and X=Y, then Z must be unique)._
