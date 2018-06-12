## Java Collections Framework

<img src="assets/collections.png"/>

### EnumSet
Efficient for Enums, since this type of set stores enums as an array of bits. It is possible due to predefined information about available Enum's sizes and order:

`Note that each enum type has a static values method that returns an array containing all of the values of the enum type in the order they are declared.`

Just for illustration: MyEnum {A, B, C, D, E} represents as [1, 1, 1, 1, 1]. To compare it with another EnumSet, which contains MyEnum {A,D,E} [1, 0, 0, 1, 1] – jvm should perform only single bitwise operation. Sure, this `O(1)` is much faster than `hashcode` computation.

### EnumMap
The keys are single Enum type, values - any of available. EnumMap maintain entries in `NATURAL ORDER`, i.e. in `ORDER` of Enum constants, declared in Enum class. Most operations are `O(1)` as for EnumSet.

