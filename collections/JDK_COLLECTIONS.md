Efficient for Enums, since this type of set 
   stores enums as an array of bits.
   For example: MyEnum {A, B, C, D, E}
   represents as [1, 1, 1, 1, 1]. To compare it
   with another EnumSet, which contains
   MyEnum {A,D,E} [1, 0, 0, 1, 1]– jvm should perform only
   single bitwise operation.
