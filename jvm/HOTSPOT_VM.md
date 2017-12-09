### HotSpot common options / flags / tools

### [jlink](https://docs.oracle.com/javase/9/tools/jlink.htm#JSWOR-GUID-CECAC52B-CFEE-46CB-8166-F17A8E9280E9)
Example cmd for bundling (including jvm) javafx application :

**`~/jdk-9/bin/jlink --module-path ~/jdk-9/jmods:. --add-modules fx.desktop --output ~/fx-out --launcher start=fx.desktop/fx.desktop.formula.repair.model.Desktop --strip-debug --compress=2`**

`--strip-debug --compress=2` - for minimizing bundle size (`compress=2` - max level of compression)

### [javapackager](https://docs.oracle.com/javase/9/tools/javapackager.htm#JSWOR719)

for jdk >= 9 uses jlink under the hood for stripping runtime bundle

**`javapackager -deploy -native image -outdir packages -outfile DesktopBootstrap --module-path ./libs -srcfiles DesktopBootstrap.jar --module fx.desktop/desktop.math.repair.model.DesktopBootstrap -name DesktopBootstrap -title DesktopBootstrap -verbose
`**

`--module-path` - *directory with your modular jar*

`-srcfiles` - *the modular jar itself*

`--module` - *[module-name to add]/[main-class]*

`-native` - *type of bundle*

###### `-BshortcutHint=true` - desktop-icon creation for -native msi/exe
