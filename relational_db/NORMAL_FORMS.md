- **[1NF](#1NF)**
- **[2NF](#2NF)**
- **[3NF](#3NF)**
- **[BCNF](#BCNF)**
- **[4NF](#4NF)**
- **[5NF](#5NF)**

## 1NF

<a name="1NF"/>

All values must be _"atomic"_ (i.e. cell should contains single, not multivalued structures).


```diff
- Failed 1NF:
```
|Generation|Model|        
|----------|-----|
|7-gen     |7700hq,7820hq,7700k|
|8-gen     |8550u|
```diff
+ Right 1NF:
```
|Generation|Model|        
|----------|-----|
|7-gen     |7700hq|
|7-gen     |7820hq|
|7-gen     |7700k|
|8-gen     |8550u|

## 2NF

<a name="2NF"/>

###### 1NF + :
- ***Strict definition:***

  _relationship scheme is in **2NF** if there is no attributes set X,Y,H such that:_
  
  _[X = key],  [**Y ⊂ X**],  [H != Y && H = non-key attribute]_
  
  - _X -> Y_
  - _Y -> H_
  - _Y !-> X_
  
- ***Logical definition:***
  - _each non-key attribute depends on key (i.e. key X -> non-key Y && key X -> non-key Z && ...)_
  
    _and every such Function dependency is **irreducible** (i.e. if (X->Y) && (Z ⊂ X) then Z !-> Y)_

  - _example:_
  
  |Producer|Model|Price|Phone|
  |--------|----------|-----|-----|
  |Intel   |7700hq    |1000 |89...   |
  |Intel   |7820hq    |1500 |89...   |
  |Intel   |8550u     |1400 |89...   |
  |AMD     |Ryzen-7   |900  |97...   |
  
  _Suppose (Producer, Model) is a Composite Key and (Producer, Model) -> (Price), where Price is non-key attribute._
  _(note that theoretically Intel and AMD may have same name for CPU Model, but different price, thus Model -> Price can lead to ambigious relationship)_ 
  
  _(Producer) -> (Phone) - this is a **failure for 2NF**! (Producer, Model) -> (Phone) is **reducible** to (Producer) -> (Phone) !_
  
  _Phone attribute should be allocated into another table **to achive Second Normal Form**:_
  
  |Producer|Phone|
  |--------|-----|
  |Intel   |89...   |
  |Intel   |89...   |
  |Intel   |89...   |
  |AMD     |97...   |
  
## 3NF

<a name="3NF"/>

###### 2NF + :
- ***Strict definition***

  _relationship scheme is in **3NF** if there is no attributes set X,Y,H such that:_
  
  _[X = key],  [**Y ⊂ R**],  [H != Y && H = non-key attribute]_
  
  - _X -> Y_
  - _Y -> H_
  - _Y !-> X_
  
- ***Logical definition***

  _every non-key attribute must depends on key attribute in **non-transitive** way._
  
  |Model|L2_Cache|Performance_Gain|
  |----------|-----|-----|
  |7700hq    |6    |4%   |
  |7820hq    |4    |2%   |
  |8550u     |4    |2%   |
  |Ryzen-7   |6    |4%   |
  
  _(Model) -> (L2_Cache) and (L2_Cache) -> (Performance_Gain), therefore using third Armstrong's axiom we have (Model) -> (Performance_Gain)._
  
  _This is a **transitive** FD!_
  
  _We should use the same approach as for 2NF normalization: Performance_Gain attribute should be allocated into another table **to achive Third Normal Form**._
  
## 3NF+ (Boyce–Codd NF) 

<a name="BCNF"/>

###### 3NF + :

  _There is one condition, when 3NF scheme has several anomalies:_
  
  _If there are **2 and more Composite keys** and they have at least **one shared attribute**._
  
  _In such situation scheme has: Redundancy anomaly, Anomaly of potential contradictions, Insertion anomaly, Deletion anomaly._
  
  _3NF without anomalies known as Boyce–Codd NF._
  
  _Relationship scheme is in **Boyce–Codd NF** if every irreducible FD X -> Y from F satisfies following condition:_
  
      X -> Y ∈ F and X - is a key!
      
- ***Example:***
  
  |MODEL_SERIES|L2_CACHE  |PERFORMANCE_GAIN|POWER_CONSUMPTION|
  |------------|----------|----------------|----------------|
  |7-series    |6MB       |6%              |40W             |
  |7-series    |4MB       |4%              |40W             |
  |6-series    |2MB       |2%              |45W             |
  |5-series    |4MB       |3%              |50W             |
  |4-series    |1MB       |1%              |35W             |
  
  - _Potential **composite** key pairs :_
      - _X = (MODEL_SERIES, L2_CACHE); X -> PERFORMANCE_GAIN, POWER_CONSUMPTION_
      - _X = (L2_CACHE, POWER_CONSUMPTION); X -> MODEL_SERIES, PERFORMANCE_GAIN_
  - _PERFORMANCE_GAIN has unique values, so it can define any other attribute, according to FD definition_
  - _KEY (MODEL_SERIES, POWER_CONSUMPTION) out of consideration, since this FD doesn't define anything (moreover if it could - this FD is **reducible**)_ 

  ***The main problem is POWER_CONSUMPTION :***
  
  _which fall under non-key attribute and POWER_CONSUMPTION -> MODEL_SERIES occurs. This FD breaks BCNF._
  
  ***The solution is the same as for 2NF and 3NF - allocation of POWER_CONSUMPTION -> MODEL_SERIES into another table.***
  
  |MODEL_SERIES|POWER_CONSUMPTION|
  |----------------|----------------|
  |7-series    |40W             |
  |6-series    |45W             |
  |5-series    |50W             |
  |4-series    |35W             |
  
  |MODEL_SERIES|L2_CACHE  |PERFORMANCE_GAIN|
  |------------|----------|----------------|
  |7-series    |6MB       |6%              |
  |7-series    |4MB       |4%              |
  |6-series    |2MB       |2%              |
  |5-series    |4MB       |3%              |
  |4-series    |1MB       |1%              |
  
## 4NF

<a name="4NF"/>

###### BCNF + :         

- _Table souldn't have multivalued dependencies._
  
  |CPU_PRODUCER|MODEL|LAPTOPS|
  |--------|-----|-----------------|
  |Intel   |7700 |Acer|
  |Intel   |7820 |Acer|
  |Intel   |7700 |Lenovo|
  |Intel   |7820 |Lenovo|
  
  _Suppose (CPU_PRODUCER, MODEL, LAPTOPS) is a primary key._
  
  _If intel releases new cpu model 7920, we should insert 2 new tuples (Intel, 7920, Acer) and (Intel, 7920, Lenovo) to keep data consistent (because both, Acer and Lenovo can be equipped with Intel processors)._
  
  _**The solution is simple:** decomposition into 2 separated tables :_
  - [MODEL -> CPU_PRODUCER] and 
  - [LAPTOPS -> CPU_PRODUCER]

## 5NF

<a name="5NF"/>

###### 4NF + :  

_Table is in 5NF if it can be decomposed into smaller tables without join loss_

_i.e. :_
  
  **R0**

  |CPU_PRODUCER|SERIES|L2_CACHE|
  |--------|-----|-----------------|
  |Intel   |7-series|4MB|
  |Intel   |8-series|4MB|
  |Intel   |8-series|6MB|
  |AMD     |R-series|4MB|

        R0 decomposition into (R1, R2, R3) :

  **R1**
  
  |CPU_PRODUCER|MODEL|
  |------------|-----|
  |Intel       |7-series|
  |Intel       |8-series|
  |AMD         |R-series|
  
  **R2**
  
  |SERIES|L2_CACHE|
  |--------|--------|
  |7-series|4MB     |
  |8-series|4MB     |
  |8-series|6MB     |
  |R-series|4MB     |
  
  **R3**
  
  |CPU_PRODUCER|L2_CACHE|
  |--------|-----|
  |Intel   |4MB  |
  |Intel   |6MB  |
  |AMD     |4MB  |

        Checking join loss :

  _R2 ⋈ R3 = R4_
  
  **R4**
  
  |SERIES|L2_CACHE|CPU_PRODUCER|
  |------|--------|------------|
  |7-series| 4mb |INTEL |
  |7-series| 4mb |AMD |
  |8-series| 4mb |INTEL | 
  |8-series| 4mb |AMD |
  |8-series| 6mb |INTEL |
  |r-series| 4mb |INTEL | 
  |r-series| 4mb |AMD | 
  
  _R1 ⋈ R4 = R5_

  ***R5 = R0 (Q.E.D.)***

  |CPU_PRODUCER|SERIES|L2_CACHE|
  |--------|-----|-----------------|
  |Intel   |7-series|4MB|
  |Intel   |8-series|4MB|
  |Intel   |8-series|6MB|
  |AMD     |R-series|4MB|
  
