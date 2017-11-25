## Concepts

- #### Lifecycle 
   - _Phase #1_
      - _goal #1_
      - _goal #2_
      - _goal #3_
      - ...
   - _Phase #2_
      - _goal #1_
      - _goal #2_
      - ...
   - ...
   
_E.g. :_

- #### Packaging (ear)
   - _generate-resources_
      - _ear:generate-application-xml_
   - _process-resources_
      - _resources:resources_ 
   - _package_
      - _ear:ear_ 
   - _install_
      - _install:install_ 
   - _deploy_
      - _deploy:deploy_ 

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

***system*** - available only on local machine at comile/runtime, doesn't persists in target bundle
```xml
         <dependency>
            <groupId>com.ibm</groupId>
            <artifactId>mq</artifactId>
            <version>8.5.0</version>
            <scope>system</scope>
            <systemPath>${project.basedir}/lib/com.ibm.mq.allclient.jar</systemPath>
         </dependency>
```


