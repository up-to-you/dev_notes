
- # Dependency
<img src="assets/Dependency.png" width="70%" height="155px">

Class Manager **use** class Employee as method argument.

Manager also can create an new instance of type Employee inside some factory method (i.e. on stack).

<img src="assets/right_dependency.png" width="55%" height="155px">

_**But it mustn't contain any member of type Employee**_.

<img src="assets/wrong_dependency.png" width="30%" height="100px">

- # Association
<img src="assets/Association.png" width="70%" height="155px">

It is much like **Dependency** , but represents much stronger relationship.

Oposite to previous wrong Dependency example, it is ok for Association to represent relationship as member variable:

<img src="assets/right_association.png" width="30%" height="60px">

