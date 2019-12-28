## Websphere apps caching
#### Some problems may refer to jit / aot :

###### cached apps
```bash
rm -r ~/profiles/$yourNode/temp/wscache/*
```

###### installed apps

```bash
rm -r ~/profiles/$yourNode/installedApps/$yourCell/*
```
#### _there are a lot of another shit within temp dir, that might be deleted_

## WAS Transaction logs
_if Websphere opposes to restore uncommited XA transactions, you can kick her ass out_
_(hope uncommited transaction's doesn't mater) !_

###### stop server, then truncate XA transaction logs, for dmgr
```bash
cd ~/profiles/dmgr/tranlog/$yourCell/$yourNode/dmgr/transaction
rm -r partnerlog/* && rm -r tranlog/*
```
###### for node
```bash
cd ~/profiles/$yourNode/tranlog/$yourCell/$yourNode/npsServer/transaction
rm -r partnerlog/* && rm -r tranlog/*
```
###### start server

## Start / Stop cli

###### auto-startup node/server example :
```bash
locate wasservice.sh

./wasservice.sh -add nodeagent -serverName nodeagent -profilePath "../../../profiles/mngd" -logRoot "/u01/IBM/profiles/mngd/logs/nodeagent" -restart true -startType automatic
```

###### start sequence sample
```bash
/u01/IBM/profiles/dmgr/bin/startManager.sh && /u01/IBM/profiles/npsNode/bin/startNode.sh && /u01/IBM/profiles/npsNode/bin/startServer.sh npsServer
```

###### stop sequence sample
```bash
/u01/IBM/profiles/npsNode/bin/stopServer.sh npsServer && /u01/IBM/profiles/npsNode/bin/stopNode.sh && /u01/IBM/profiles/dmgr/bin/stopManager.sh
```


## J2C Authentication

*To get Authentication data entry (UserID/Password) via LoginContext,*

*by performing lookup of J2C Authentication data ALIAS **across different nodes** -*

*it's safer to prefix ALIAS name by corresponding Node name, i.e. yourNode/YOUR_J2C_ALIAS_NAME.*

*And specify alias in code the same way yourNode/YOUR_J2C_ALIAS_NAME.*

