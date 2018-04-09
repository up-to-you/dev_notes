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

-- //////////////////////////////////////////////////

CREATE OR REPLACE FUNCTION GET_MIN_MAX(arr INTEGER[])
    RETURNS TABLE(min INTEGER, max INTEGER)
AS
$$
    DECLARE
        result INTEGER[];
    BEGIN
        SELECT ARRAY(
            SELECT DISTINCT unnest(arr) ORDER BY 1
        ) INTO result;

        RETURN QUERY SELECT result[1], result[array_length(result, 1)];
    END;
$$ LANGUAGE plpgsql;

SELECT * FROM GET_MIN_MAX((SELECT array_agg(weight) FROM air_plane));

-- //////////////////////////////////////////////////

CREATE OR REPLACE FUNCTION MIN_MAX(arr INTEGER[], val INTEGER)
    RETURNS INTEGER[]
AS
$$
    BEGIN
        arr = val || arr;
        RAISE NOTICE '%', arr;
        RETURN (SELECT ARRAY[min, max] FROM GET_MIN_MAX(arr));
    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION MID_VALUE(arr INTEGER[])
    RETURNS FLOAT
AS
$$
    BEGIN
        RETURN (arr[2] - arr[1]) / 2;
    END;
$$ LANGUAGE plpgsql;

CREATE AGGREGATE MIDDLE(INTEGER) (
    SFUNC = MIN_MAX,
    STYPE = INTEGER[],
    FINALFUNC = MID_VALUE
);

SELECT MIDDLE(weight) FROM air_plane;

-- //////////////////////////////////////////////////

CREATE OR REPLACE VIEW HIGH_WEIGHTED_AIRPLANES AS
    SELECT * FROM air_plane WHERE weight > 1100
    ORDER BY weight;

CREATE OR REPLACE FUNCTION INSERT_HIGH_WEIGHTED_AIRPLANES()
RETURNS TRIGGER
AS
$function$
    BEGIN
        IF tg_op = 'INSERT' THEN
            INSERT INTO air_plane VALUES (NEW.ID, NEW.producer, NEW.model, NEW.weight, NEW.capacity);
            RETURN NEW;
        END IF;
    END;
$function$ LANGUAGE plpgsql;

CREATE TRIGGER INSERT_HIGH_WEIGHTED_AIRPLANES_VIEW
    INSTEAD OF INSERT ON HIGH_WEIGHTED_AIRPLANES
    FOR EACH ROW EXECUTE PROCEDURE INSERT_HIGH_WEIGHTED_AIRPLANES();

INSERT INTO HIGH_WEIGHTED_AIRPLANES VALUES (20, 'BOEING', '7-7007', 2700, 2300);
COMMIT ;

-- //////////////////////////////////////////////////

CREATE OR REPLACE FUNCTION INSERT_BOEING_AIR_PLANE(model CHARACTER VARYING, weight INTEGER, capacity INTEGER)
    RETURNS VOID
AS
$$
    BEGIN
        EXECUTE format('INSERT INTO AIR_PLANE VALUES ((SELECT MAX(ID) + 1 FROM AIR_PLANE), $1, $2, $3, $4)')
                                                                            USING 'BOEING', model, weight, capacity;
    END;
$$ LANGUAGE plpgsql;

-- //////////////////////////////////////////////////
