### Sample for unit-testing JEE modules

```java
    @Resource
    private ConnectionFactory connectionFactory;
    
    private static Context initialContext;
    private static Connection connection;
    private static Session session;

    @BeforeClass
    public static void setupEnvironment() throws Exception {
        Properties p = new Properties();
        
        // core JMS
        p.put("MyJmsResourceAdapter", "new://Resource?type=ActiveMQResourceAdapter");
        p.put("MyJmsResourceAdapter.ServerUrl", "vm://localhost?async=false");
        
        // for concurrent tests executions
        String port = getProperty("os.name").toLowerCase().contains("window") ? "7" + (portPostFix.nextInt(877) + 100) : "61616";

        p.put("MyJmsResourceAdapter.BrokerXmlConfig", "broker:(tcp://localhost:" + port + ")?persistent=false");
        p.put("MyJmsResourceAdapter.maximumRedeliveries", "1");

        // Persistence settings
        p.put("storage", "new://Resource?type=DataSource");
        p.put("storage.JdbcDriver", "org.hsqldb.jdbcDriver");
        p.put("storage.JdbcUrl", "jdbc:hsqldb:mem:storage");
        
        // Represents persistence unit
        p.put("NPSPersistenceUnit.openjpa.jdbc.SynchronizeMappings", "buildSchema(ForeignKeys=true)");
        p.put("NPSPersistenceUnit.openjpa.jdbc.DBDictionary", "hsql(SimulateLocking=true)");
        p.put("NPSPersistenceUnit.openjpa.Log", "DefaultLevel=INFO, Tool=INFO, SQL=INFO");
        p.put("NPSPersistenceUnit.openjpa.RuntimeUnenhancedClasses", "supported");
        p.put("NPSPersistenceUnit.openjpa.ConnectionFactoryProperties", "PrettyPrint=true, PrettyPrintLineLength=80, PrintParameters=True");
        
        // must have for weird environment
        p.put("openejb.jndiname.failoncollision", "false");
        
        // for readability
        p.put("openejb.log.color", "true");
        p.put("openejb.log.color.info", "BLUE");
        p.put("openejb.log.color.warn", "RED");
        p.put("openejb.log.color.error", "RED");
        p.put("openejb.log.color.debug", "MAGENTA");
        p.put("openejb.log.color.fatal", "CYAN");

        // deployment JNDI options
        p.put("openejb.deploymentId.format", "{moduleId}/{ejbName}");
        p.put("openejb.jndiname.format", "{deploymentId}");

        p.put("jndi/QueueConnectionFactory", "new://Resource?type=javax.jms.ConnectionFactory");
        p.put("jndi/QueueConnectionFactory.ResourceAdapter", "MyJmsResourceAdapter");
      
        // Message-Driven beans container
        p.put("MyJmsMdbContainer", "new://Container?type=MESSAGE");
        p.put("MyJmsMdbContainer.ResourceAdapter", "MyJmsResourceAdapter");
        p.put("MyJmsMdbContainer.ActivationSpecClass", "org.apache.activemq.ra.ActiveMQActivationSpec");
        p.put("MyJmsMdbContainer.MessageListenerInterface", "javax.jms.MessageListener");

        p.put("openejb.validation.output.level", "VERBOSE");
        p.put("openejb.jndiname.failoncollision", "false");

        /*
        example for JTA manual setup
        p.put("myTransactionManager", "new://TransactionManager?type=TransactionManager");
        p.put("myTransactionManager.adler32Checksum", "true");
        p.put("myTransactionManager.bufferSizeKb", "32");
        p.put("myTransactionManager.checksumEnabled", "true");
        p.put("myTransactionManager.defaultTransactionTimeout", "10 minutes");
        p.put("myTransactionManager.flushSleepTime", "50 Milliseconds");
        p.put("myTransactionManager.logFileDir", "txlog");
        p.put("myTransactionManager.logFileExt", "log");
        p.put("myTransactionManager.logFileName", "howl");
        p.put("myTransactionManager.maxBlocksPerFile", "-1");
        p.put("myTransactionManager.maxBuffers", "0");
        p.put("myTransactionManager.maxLogFiles", "2");
        p.put("myTransactionManager.minBuffers", "4");
        p.put("myTransactionManager.threadsWaitingForceThreshold", "-1");
        p.put("myTransactionManager.txRecovery", "false");
        */

        p.put("openejb.embedded.remotable", "true");
        p.put(WsService.WS_ADDRESS_FORMAT, "/{ejbName}");

        ejbContainer = EJBContainer.createEJBContainer(p);
        initialContext = ejbContainer.getContext();
        
        startConnection();
     }
     
     private static void startConnection() {
        try {
            initialContext.bind("inject", this);
            if (connection == null) {
                connection = connectionFactory.createConnection();
                session = connection.createSession(false, Session.AUTO_ACKNOWLEDGE);
                connection.start();
            }
        } catch (Exception e) {
            log.error("Error", e);
        }
     }
```
