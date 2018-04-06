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

#### all tests got performed using Spring 5 / Hibernate 5

By default, Spring @Transactional method propagates same Session and same Physical transaction to nested inner methods, for which @Transactional annotation is not mandatory. 

```java
@RequestMapping(value = "/transaction")
public void performTransaction() {
    service.invokeTransaction();
}
@Transactional
void invokeTransaction() {
    invokeInner();
}   
void invokeInner() {
    // Same Hiber SessionID, Thread, Connection, TransactionID
}
```

It's worth to mention, that there is no way to invoke new "_nested_" physical transaction inside Spring/Hiber managed transaction. Hibernate will check allready active transaction bounded to current thread and will throw Exception if any exists.

```java
@RequestMapping(value = "/transaction")
public void performTransaction() {
    service.invokeTransaction();
}
@Transactional
void invokeTransaction() {
    var session = (Session) entityManager.getDelegate();
    // Exception !
    session.beginTransaction();
}

/*** OR ***/

@Transactional
void invokeTransaction() {
    invokeInner();
}
@Transactional(Propagation.NOT_SUPPORTED)
void invokeInner() {
    var session = (Session) entityManager.getDelegate();
    // Anything is ok, since there is Propagation.NOT_SUPPORTED, that suspends outer transaction
    session.beginTransaction();
    // Exception, since there is allready active transaction !
    session.beginTransaction();
}
```

Spring follows the pattern **session-per-request**, such that two sequential Spring Transactions will be performed in a single Hibernate Session, however on database level - every Spring Transaction represents separated Physical DB Transaction, that uses its own connection:

```java
@RequestMapping(value = "/transaction")
public void performTransaction() {
    // single hiber session and thread for both
    firstService.invokeFirstTransaction();
    secondService.invokeSecondTransaction();
}
@Transactional
void invokeFirstTransaction() {
    // Hiber SessionID = 1
    // Current Thread = 1
    
    // DB Connection = 1
    // DB Transaction ID = 1
}   
@Transactional
void invokeSecondTransaction() {
    // Hiber SessionID = 1
    // Current Thread = 1
    
    // DB Connection = 2
    // DB Transaction ID = 2
}
```
**REQUIRES_NEW** - is a logical separation of two transactions. Outer transaction got suspended, while Inner transaction creates new Session and correspondingly gets new Connection from pool. Both invokes in a single thread.

```java
@RequestMapping(value = "/transaction")
public void performTransaction() {
    service.invokeOuterTransaction();
}
@Transactional
void invokeOuterTransaction() {
    // Hiber SessionID = 1
    // Current Thread = 1
    
    // DB Connection = 1
    // DB Transaction ID = 1
    invokeInnerTransaction();
}   
@Transactional(Propagation.REQUIRES_NEW)
void invokeInnerTransaction() {
    // Hiber SessionID = 2
    // Current Thread = 1
    
    // DB Connection = 2
    // DB Transaction ID = 2
}
```

**NESTED** - invokes "_nested_" logical transaction via **savepoints** (in fact is single DB Physical Transaction). Requires JDBC 3.0+. Hibernate doesn't support nested transaction, due to lack of **savepoints** transaction management implementation. However its available via configuration below, that brings Spring-tx implementation:
```java
    @Bean
    public PlatformTransactionManager setDataSource(DataSource dataSource) {
        return new DataSourceTransactionManager(dataSource);
    }
```
SavePoints allow to rollback part of single transaction to specific savepoint, thus rollback of it part doesn't affects whole transaction.

```java
@RequestMapping(value = "/transaction")
public void performTransaction() {
    service.invokeOuterTransaction();
}
@Transactional
void invokeOuterTransaction() {
    // Hiber SessionID = 1
    // Current Thread = 1
    
    // DB Connection = 1
    // DB Transaction ID = 1
    invokeInnerTransaction();
}   
@Transactional(Propagation.NESTED)
void invokeInnerTransaction() {
    // Hiber SessionID = 1
    // Current Thread = 1
    
    // DB Connection = 1 (but performs separated query for SavePoint) 
    // DB Transaction ID = 1
}
```
