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

