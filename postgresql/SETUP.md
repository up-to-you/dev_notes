### Auth control
###### pg_hba.conf
###### /etc/postgresql/$version/main/pg_hba.conf
###### or /opt/postgres/
###### or /usr/lib/postgresql/$version/*
###### this conf describes client authentication control
###### only for local non-secure access

```bash 
host    all             all             0.0.0.0/0                  trust
```

### Startup debugging 
###### sample for debugging postgresql startup

```bash
/usr/lib/postgresql/9.5/bin/postgres -d 3 -D /var/lib/postgresql/9.5/main -c config_file=/etc/postgresql/9.5/main/postgresql.conf
```
