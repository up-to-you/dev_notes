### This page contains the layer of abstraction for brevity and understanding

**1.** &nbsp; ***Compilation step***

_source_code &nbsp; ==`javac`=> &nbsp; byte_code_

_Bytecode is an intermediate representation, that can be mapped almost one-to-one into machine opcodes,_

_One of the main benefits of Java bytecode in contrast to other languages is similarity to real machine instructions (opcodes)._

_Thus, it is much easy to interpret bytecode into machine instructions and optimise it for performance gain._

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
_Example of bytecode mapping into Machine Instructions (opcodes) in hexidecimal format:_

| Mnemonic        | Opcode (hex) | Description |
| ------------- |-------------|------|
| aload_0      | 2a | loads a reference onto the stack from local variable 0 |
| invokespecial      | b7      |   invoke instance method on object reference requiring special handling (instance initialization method, a private method, or a superclass method), where the method is identified by method reference index in constant pool |
| areturn | b0      |    returns a reference from a method |
| getfield | b4      |    gets a field value of an object reference, where the field is identified by field reference in the constant pool index |
| putfield | b5      |    `getfield` opposite  |


**2.** &nbsp; ***Interpretation step***

_Virtual Machines are written in C/C++/ASM._

_Sample of machine instructions execution, using C++ :_

```C++
int hex_instructions[] = {0x83ec8b55,0x565340ec,0x0c758b57,0x8b087d8b,
                          0x348d104d,0xcf3c8dce,0x6f0fd9f7,0x6f0fce04,
                          0x0f08ce4c,0x10ce546f,0xce5c6f0f,0x646f0f18,
                          0x6f0f20ce,0x0f28ce6c,0x30ce746f,0xce7c6f0f,
                          0x04e70f38,0x4ce70fcf,0xe70f08cf,0x0f10cf54,
                          0x18cf5ce7,0xcf64e70f,0x6ce70f20,0xe70f28cf,
                          0x0f30cf74,0x38cf7ce7,0x7508c183,0xf8ae0fad,
                          0x5e5f770f,0x5de58b5b,0xccccccc3};

int _tmain(int argc, _TCHAR* argv[])
{
    int *src = new int[64];
    int *dst = new int[64];
    int *dst2 = new int[64];

    for (int i = 0; i < 64; ++i){
        src[i] = i;
    }

    // address reservation
    void* address = NULL;
    address = VirtualAlloc(NULL, sizeof(hex_instructions), MEM_COMMIT|MEM_RESERVE, PAGE_EXECUTE_READWRITE);
    // copying instructions
    memcpy(address,hex_instructions,sizeof(hex_instructions));

    // call instructions from assemble
    __asm {
      push        20h  
      mov         eax,dword ptr [src]  
      push        eax  
      mov         ecx,dword ptr [dst]  
      push        ecx
      mov         ecx, dword ptr [address]
      call        ecx
      add         esp,0Ch 
    }

    for (int i = 0; i < 64; ++i){
        printf("%d ",dst[i]);
    }

    // call instructions from function pointer
    typedef void (*FASTCALL)(void* dst, void* src, int len);
    FASTCALL fastcall;
    fastcall = (FASTCALL)address;
    fastcall(dst2,src,64/2);

    printf("\n");
    for (int i = 0; i < 64; ++i){
        printf("%d ",dst2[i]);
    }
    return 0;
}
```
_Thus, bytecode is interpreted at runtime into machine code. It is worth mentioning, that bytecode is quite similar to machine code, therefore there are many options for performance optimisations._


**3.** &nbsp; ***JIT compilation step***

_There are one more substantial part of performance optimisation at runtime - Just In Time compiler._

_JIT compiles bytecode into native machine code during code execution._

_It continuously analyses the code being executed and compute possible performance gain сompared to the compilation cost._

_If performance gain outweigh compilation cost, JIT starts to work._

_Moreover, JIT performs inlining and pre-optimizes code, by analyzing execution cycles and making predictions._
