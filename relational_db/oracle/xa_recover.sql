SELECT formatid, globalid, branchid FROM SYS.DBA_PENDING_TRANSACTIONS;
select * from pending_trans$;
select * from DBA_2PC_NEIGHBORS;
select * from DBA_2PC_PENDING where STATE <> 'forced commit';
select * from V$CORRUPT_XID_LIST;

select * from LOCALUSER.CURRENT_MESSAGE_NUMBER for update nowait;
select * from sib.sibowner for update nowait;

ROLLBACK FORCE '1.0.999';

COMMIT FORCE '5.20.1097';
COMMIT FORCE '2.21.1060';
COMMIT FORCE '7.9.1052';


grant select on pending_trans$ to public;
grant select on dba_2pc_pending to public;
grant select on dba_pending_transactions to public;

grant execute on dbms_system to localuser;
grant execute on dbms_system to sib;
grant execute on dbms_xa to localuser;
grant execute on dbms_xa to sib;
