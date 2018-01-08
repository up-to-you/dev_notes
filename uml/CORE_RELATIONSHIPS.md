## Class relationships
- ### Dependency
<img src="assets/Dependency.png" width="70%" height="155px">

Class Manager **use** class Employee as method argument.

Manager also can create an new instance of type Employee inside some factory method (i.e. on stack).

<img src="assets/right_dependency.png" width="50%" height="140px">

_**But it mustn't contain any member of type Employee**_.

<img src="assets/wrong_dependency.png" width="50%" height="140px">

