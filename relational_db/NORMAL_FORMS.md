## 1NF
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
###### 3NF + :
  
  
