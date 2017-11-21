DECLARE

--   you can't declare large string literals in standard sql
--   hence you should use pl/sql
  str VARCHAR2(32767);

--   reference to table column datatype
  some_raw_data SOME_TABLE.BLOB_COLUMN%TYPE;

BEGIN
  
--   blob func requires raw (binary) data
  some_raw_data:= utl_raw.cast_to_raw('LONG_STRING');

  INSERT ALL
    INTO SOME_TABLE VALUES (blobVal)
    INTO NEXT_TABLE VALUES (blobVal)
  SELECT
    TO_BLOB(some_raw_data) blobVal
  FROM dual;
  COMMIT ;

END;
