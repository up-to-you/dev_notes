### This page contains the layer of abstraction for brevity and understanding

**1.** &nbsp; ***Comilation step***

_source_code &nbsp; ==`javac`=> &nbsp; byte_code_

_One of the main benefits of Java bytecode in contrast to other languages is similarity to real machine instructions (opcodes)._

_Thus, it is much easy to interpret bytecode into machine instructions and optimise it for performance gain._

_Bytecode is an intermediate representation, that can be mapped almost one-to-one into machine opcodes,_

_which allows to implement cross-platform code, by using platform-specific interpreter for concrete OS._

_In a nutshell, Virtual Machine simulates Physical Machine behavior and execution of instructions, therefore called ***Virtual***._

```java
public class Foo {
    private String bar;
    public String getBar(){ 
      return bar; 
    }
    public void setBar(String bar) {
      this.bar = bar;
    }
  }
```
_Foo.**java** &nbsp; ==`javac Foo.java`=> &nbsp; Foo.**class**_

`javap -c Foo`:
```java
public class Foo extends java.lang.Object {
public Foo();
  Code:
   0:   aload_0
   1:   invokespecial   #1; //Method java/lang/Object."<init>":()V
   4:   return
public java.lang.String getBar();
  Code:
   0:   aload_0
   1:   getfield        #2; //Field bar:Ljava/lang/String;
   4:   areturn
public void setBar(java.lang.String);
  Code:
   0:   aload_0
   1:   aload_1
   2:   putfield        #2; //Field bar:Ljava/lang/String;
   5:   return
}
```
Example of bytecode mapping into Machine Instructions (opcodes) in hexidecimal format:

| Mnemonic        | Opcode (hex) | Description |
| ------------- |-------------|------|
| aload_0      | 2a | loads a reference onto the stack from local variable 0 |
| invokespecial      | b7      |   invoke instance method on object reference requiring special handling (instance initialization method, a private method, or a superclass method), where the method is identified by method reference index in constant pool |
| areturn | b0      |    returns a reference from a method |
| getfield | b4      |    gets a field value of an object reference, where the field is identified by field reference in the constant pool index |
| putfield | b5      |    `getfield` opposite  |


