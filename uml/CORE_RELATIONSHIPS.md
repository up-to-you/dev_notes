## Class relationships
- ### Dependency
<img src="assets/Dependency.png" width="100%" height="170px">
Class Manager **use** class Employee as method argument. 
Manager also can create an new instance of type Employee inside some factory method (i.e. on stack),
but it mustn't contain any member of type Employee.
