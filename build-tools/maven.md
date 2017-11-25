## CONCEPTS

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
   
_E.g._

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

---

_In ***multi-module*** project Maven reactor determines the build order of modules (by modules sorting) and dependencies_

_If A depends on B depends on C, obviously, the build order is C -> B -> A_
