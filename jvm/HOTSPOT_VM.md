### HotSpot common options / flags / tools

### [jlink](https://docs.oracle.com/javase/9/tools/jlink.htm#JSWOR-GUID-CECAC52B-CFEE-46CB-8166-F17A8E9280E9)
Example cmd for bundling (including jvm) javafx application :

**`~/jdk-9/bin/jlink --module-path ~/jdk-9/jmods:. --add-modules fx.desktop --output ~/fx-out --launcher start=fx.desktop/fx.desktop.formula.repair.model.Desktop --strip-debug --compress=2`**

`--strip-debug --compress=2` - for minimizing bundle size (`compress=2` - max level of compression)
