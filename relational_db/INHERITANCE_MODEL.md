#### RDB INHERITANCE OPTIONS

## USING SINGLE TABLE
_most simple, unfriendly and inconvenience_

|ID|WIDTH|HEIGHT|TYPE|ROUNDNESS|POLYGONAL|TRANSPARENT|
|--|-----|------|----|---------|---------|-----------|
|1 |100  |200   |TYPE_1|50%      |null|null|
|2 |150..|250...|TYPE_2|null     |7|null|

(ID, WIDTH, HEIGHT) - _parent fields_

(TYPE) - _child type_

(ROUNDNESS, POLYGONAL, TRANSPARENT) - _every attribute belongs to specific child_



## DECOMPOSITION OF SINGLE TABLE BY TYPE
_depends on quantity of shared attributes_

|ID|WIDTH|HEIGHT|ROUNDNESS|
|--|-----|------|---------|
|1 |100  |200   |50%      |

|ID|WIDTH|HEIGHT|POLYGONAL|
|--|-----|------|---------|
|1 |150  |250   |7        |

|ID|WIDTH|HEIGHT|TRANSPARENT|
|--|-----|------|---------|
|1 |300  |100   |10%      |




## TABLE PER CLASS
_most sensible solution_

|ID|WIDTH|HEIGHT|
|--|-----|------|
|10|100  |200   |
|20|150  |250   |
|30|100  |300   |

|ID|ROUNDNESS|
|--|---------|
|10|50%      |

|ID|POLYGONAL|
|--|---------|
|20|7        |

|ID|TRANSPARENT|
|--|---------|
|30|10%      |


_child's ID is a foreign key of parent primary key._
