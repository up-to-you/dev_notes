_There is no way to define real database nested transaction using jdbc, currently._
_Real physical nested transactions can be achived on database level, using such SQL extensions as PL/SQL (however, the real application of physical database nested transactions is an another story)._
_JDBC 3.0 savepoints only allow to divide single physical transaction to dedicated atomic parts._

_To remind, without savepoints considiration, there are only two ways to start and commit transaction via connection object._

_Multiple queries in a single physical transaction:_
```java
try(Connection connection = DriverManager.getConnection(url, "username", "password")) {
         connection.setAutoCommit(false);
         try(var statement = connection.createStatement()){
             statement.executeUpdate("INSERT INTO ...");
             statement.closeOnCompletion();
         }

         try(var statement = connection.createStatement()){
             statement.executeUpdate("INSERT INTO ...");
             statement.closeOnCompletion();
         }

         connection.commit();
}
```
_And multiple sequential physical transactions on each query :_
```java
try(Connection connection = DriverManager.getConnection(url, "username", "password")) {
         connection.setAutoCommit(true);
         try(var statement = connection.createStatement()){
             statement.executeUpdate("INSERT INTO ...");
             // First transaction got commited, since autocommit = true
             statement.closeOnCompletion();
         }

         try(var statement = connection.createStatement()){
             statement.executeUpdate("INSERT INTO ...");
             // Second transaction got commited
             statement.closeOnCompletion();
         }
}
```
_In other words: JDBC api bounds every `unit of work` to a single Connection object._
