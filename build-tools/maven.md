## Concepts

```bash
   Lifecycle #1
         Phase #1
               goal #1
               goal #2
               goal #3
               ...
         Phase #2
               goal #1
               goal #2
               ...
         ...
```

   
_E.g. :_

```bash
   Packaging (ear)
         generate-resources
               ear:generate-application-xml
         process-resources
               resources:resources
         package
               ear:ear
         install
               install:install
         deploy
               deploy:deploy
```

###### _Obviously, phase like ```deploy``` may contains multiple goals, not only ```deploy:deploy```_

---

###### Lifecycles : e.g. clean, compile, install, package, test-compile, test, integration-test
###### Phases : e.g.
- ###### Clean phase
   - ###### pre-clean, clean, post-clean
   - ###### clean
   - ###### post-clean

## Multi-Module

_In ***multi-module*** project Maven reactor determines the build order of modules (by modules sorting) and dependencies_

_If A depends on B depends on C, obviously, the build order is C -> B -> A_

## Scopes

***compile*** - default, persists in compile, test, target bundle

***provided*** - doesn't persists in target bundle

***runtime*** - doesn't persists at compile time, but at runtime, including target bundle

***test*** - persists only for test phase, _NOT TRANSITIVE !_

***system*** - available only on local machine at compile/runtime, doesn't persists in target bundle
```xml
         <dependency>
            <groupId>com.ibm</groupId>
            <artifactId>mq</artifactId>
            <version>8.5.0</version>
            <scope>system</scope>
            <systemPath>${project.basedir}/lib/com.ibm.mq.allclient.jar</systemPath>
         </dependency>
```


