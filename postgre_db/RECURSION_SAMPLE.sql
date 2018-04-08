-- sample
CREATE TABLE ROUTE (
    ID INTEGER,
    FROM_P VARCHAR(256),
    TO_P VARCHAR(256),
    LENGTH INTEGER,
    AVIA_COMPANY VARCHAR(256)
);

-- test data
INSERT INTO ROUTE VALUES (1, 'MOSCOW', 'BERLIN', 1100, 'AIR_BNB');
INSERT INTO ROUTE VALUES (2, 'BERLIN', 'LENINGRAD', 1400, 'TRANSFER_AIR');
INSERT INTO ROUTE VALUES (3, 'LENINGRAD', 'ROME', 1700, 'FLIFHT_MASTER');
INSERT INTO ROUTE VALUES (4, 'ROME', 'OMSK', 2100, 'AIR_SPEC');
COMMIT ;

-- TASK:
--
-- DECLARE A FUNCTION THAT TAKES THE CITY OF DEPARTURE AND THE CITY OF DESTINATION.
-- FUNCTION MUST BUILD ROUTE REGARDLESS OF THE AVAILABILITY OF DIRECT FLIGHTS AND CALCULATE THE INTERMEDIATE LENGTH.
--

CREATE OR REPLACE FUNCTION GET_ROUTE_RECURSIVE(from_city text, to_city text)
    RETURNS
        TABLE(from_city text, to_city text, sum_length integer)
    AS
$$
    WITH RECURSIVE GET_ROUTE(from_r, to_r, idx, curr_sum_length, stop_flag) AS (
--         initial first row, that doesn't involves into recursion
        select FROM_P, TO_P, ID, length,
--         if row with from_city already has target destination, then stop_flag = true
            CASE WHEN TO_P = to_city THEN TRUE ELSE FALSE END
        from ROUTE where FROM_P = from_city
        UNION ALL
--         start the recursion with computation of length sum
        SELECT FROM_P, TO_P, id, length + curr_sum_length,
--         if current row contains destination city, then stop_flag = true
            CASE WHEN TO_P = to_city THEN TRUE ELSE FALSE END
            FROM GET_ROUTE, ROUTE
--         synchronize recursive walk, using GET_ROUTE and ROUTE id (start with next row after initial select)
                        where id = idx + 1
                            AND FROM_P != from_city
--              the previous destination(to_r) must be equal to current departure point(FROM_P)
--              this line allows to build composite route, that doesn't have direct flight
                            AND FROM_P = to_r
                            AND stop_flag = FALSE
    )
    SELECT from_r, to_r, curr_sum_length FROM GET_ROUTE;
$$
LANGUAGE SQL;

-- sample of use
select *
from GET_ROUTE_RECURSIVE('BERLIN', 'ROME');
