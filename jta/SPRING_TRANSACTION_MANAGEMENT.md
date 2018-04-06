### Spring Transaction Propagation

|Propagation|Description                             |
|-----------|----------------------------------------|
|_REQUIRED_ |Join Current / Create new if none exists [**default**]|
|_MANDATORY_|Join Current / throws Exception if none exists|
|_SUPPORTS_ |non-transactional / Join Current if exists|
|_NOT_SUPPORTED_|non-transactional / suspend outer if exists|
|_NEVER_|non-transactional / throws Exception if exists|
|_REQUIRES_NEW_|Always new + supend outer transaction|
|_NESTED_|Logical new transaction via **savepoints** , outer + nested = single physical in database|

