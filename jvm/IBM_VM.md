### IBM specific vm options / flags
_aot and jit are enabled by default_

- **`-Xaot:verbose`** reports information about the AOT and JIT compiler configuration and method compilation
- **`-Xcodecachetotal`** option to set the maximum amount of memory that is used by all code caches
- **`-Xint`** disabling the Just-In-Time (JIT) and Ahead-Of-Time (AOT) compilers
- **`-Xjit:verbose={compileStart|compileEnd}`** reports information about the JIT and AOT compiler configuration and method compilation
- **`-Xjit:vlog=$filename`**
- **`-Xnoaot`** turns off the AOT compiler and disables the use of AOT-compiled code
- **`-Xnojit`** turns off the JIT compiler
- **`-Xquickstart`** causes the JIT compiler to run with a subset of optimizations, reduced startup time
