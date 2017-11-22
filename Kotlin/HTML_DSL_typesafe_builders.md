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

*Obviosly **kotlinx/html-builder** uses not only this approach, 
since there are tags like DIV, that can be applied to almost any reciever.*

*The brief overview of source code shows* :

```java
    fun <T, C : TagConsumer<T>> C.html(block : HTML.() -> Unit = {}) : T = HTML(emptyMap, this).visitAndFinalize(this, block)
    
    fun HTML.head(block : HEAD.() -> Unit = {}) : Unit = HEAD(emptyMap, consumer).visit(block)
    fun HTML.body(classes : String? = null, block : BODY.() -> Unit = {}) : Unit = BODY(attributesMapOf("class", classes), consumer).visit(block)

    createHTMLDocument().html {
        head {

        }
        body {

        }
    }
```
*Place to pay attention is html function lambda's reciever ```block : HTML.() -> Unit = {}```*

*and corresponding extension functions same type "recievers"*

```
fun HTML.head(
fun HTML.body(
```

_this way compiler let you omit explicit declarations of extension functions "recievers"_



