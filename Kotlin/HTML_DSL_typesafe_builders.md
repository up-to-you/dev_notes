_From JetBrain's article_ :

_Typesafe html tags is just a function's, that takes lambda's with HTML type reciever_ 

```Java
fun html(init: HTML.() -> Unit): HTML {
    val html = HTML()
    html.init()
    return html
}
```
_invocation (preceding ```this``` is omited)_

```Java
html {
    head { /* ... */ }
    body { /* ... */ }
}
```
*the explanation describes it as invocation's of ```head``` and ```body``` functions that owned by HTML reciever.*

*Obviosly **kotlinx/html-builder** doesn't use this approach, 
since there are tags like DIV, that can be applied to almost any reciever.*

*The brief overview of source code shows* :

```diff
+ TODO :
```
