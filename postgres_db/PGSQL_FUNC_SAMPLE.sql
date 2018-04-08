CREATE TABLE AIR_PLANE
(
	ID INTEGER NOT NULL
      CONSTRAINT AIR_PLANE_PKEY
      PRIMARY KEY,
	PRODUCER VARCHAR(128),
	MODEL VARCHAR(128),
	WEIGHT INTEGER,
	CAPACITY INTEGER
		CONSTRAINT AIR_PLANE_CAPACITY_CHECK
			CHECK (CAPACITY >= 500),
	CONSTRAINT PRODUCER_MODEL
		UNIQUE (PRODUCER, MODEL)
);

-- test data
INSERT INTO AIR_PLANE VALUES (1, 'BOEING', '777', 1000, 500);
INSERT INTO AIR_PLANE VALUES (2, 'AEROBUS', 'A-310', 700, 500);
INSERT INTO AIR_PLANE VALUES (3, 'BOEING', '787', 1700, 600);
INSERT INTO AIR_PLANE VALUES (4, 'BOEING', '797', 1900, 700);
INSERT INTO AIR_PLANE VALUES (5, 'AEROBUS', 'A-410', 1100, 550);
COMMIT ;

CREATE OR REPLACE FUNCTION CONCATENATE_ALL_AIRPLANE_MODELS() RETURNS TEXT AS
$$
    DECLARE
        models CURSOR FOR SELECT DISTINCT model FROM air_plane;
        air_plane_row air_plane%ROWTYPE;
        result TEXT = '';
    BEGIN
        OPEN models;
            LOOP
                FETCH models INTO air_plane_row.model;
                EXIT WHEN NOT FOUND;

                IF (result != '') THEN
                 result = result || ', ';
                END IF ;

                result = result || air_plane_row.model;

                RAISE NOTICE '%', result;
            END LOOP;
        CLOSE models;

        RETURN result;
    END;
$$ LANGUAGE plpgsql;
