------------------------------------------------------------------------
------------------------------------------------------------------------
--
-- PROCEDURES
--
------------------------------------------------------------------------
------------------------------------------------------------------------


------------------------------------------------------------------------
-- GENERIC TEMPLATE (adapted from L07 PLpgSQL):
------------------------------------------------------------------------
-- CREATE OR REPLACE FUNCTION <name>
--  (<param> <type>, <param> <type>, ...)
-- RETURNS <type> AS $$
-- DECLARE
--  <variable>
--  <variable>
-- BEGIN
--  <code>
-- END
-- $$ LANGUAGE <sql OR plpgsql>;

-- CREATE OR REPLACE PROCEDURE <name>
--  (<param> <type>, <param> <type>, ...)
-- AS $$
--
--
-- <code>
--
--
-- $$ LANGUAGE <sql OR plpgsql>;

-- IF <condition> THEN <action>
-- ELSEIF <condition> THEN <action>
-- ...
-- ELSE <action>
-- END IF;

-- WHILE <condition> LOOP    
--  EXIT WHEN <condition>
--  <action>
-- END LOOP;

-- FOREACH <variable> IN ARRAY <iterable> LOOP
--  <action>
-- END LOOP;
------------------------------------------------------------------------


------------------------------------------------------------------------
-- BASIC (Readapt as necessary.)
------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE add_department
 (<param> <type>, <param> <type>, ...)
AS $$
    -- Tianle
$$ LANGUAGE sql;


CREATE OR REPLACE PROCEDURE remove_department
 (<param> <type>, <param> <type>, ...)
AS $$
    -- Tianle
$$ LANGUAGE sql;


CREATE OR REPLACE PROCEDURE add_room
 (<param> <type>, <param> <type>, ...)
AS $$
    -- Tianle
$$ LANGUAGE sql;


CREATE OR REPLACE PROCEDURE change_capacity
 (<param> <type>, <param> <type>, ...)
AS $$
    -- Tianle
$$ LANGUAGE sql;


CREATE OR REPLACE FUNCTION generate_id(OUT eid INT)
RETURNS INT AS $$
    SELECT MAX(eid)+1 FROM Employees;
$$ LANGUAGE sql;


CREATE OR REPLACE PROCEDURE add_employee
 (IN ename VARCHAR(50), IN contact VARCHAR(50), IN kind VARCHAR(10), IN did INT)
AS $$
 -- Teddy
DECLARE
    email VARCHAR(50);
    eid INT := 0;
BEGIN
    eid := generate_id();   
    raise notice 'Value: %', eid;
    SELECT concat(ename, eid, '@hotmail.com') INTO email;
    INSERT INTO Employees (eid, ename, email, did) VALUES (eid, ename, email, did);
    INSERT INTO Contacts VALUES (contact, eid);
    IF kind = 'junior' THEN INSERT INTO Juniors VALUES (eid);
    ELSIF kind = 'senior' THEN 
        INSERT INTO Bookers VALUES (eid);
        INSERT INTO Seniors VALUES (eid);
    ELSIF kind = 'manager' THEN
        INSERT INTO Bookers VALUES (eid);
        INSERT INTO Managers VALUES (eid);
    END IF;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE PROCEDURE remove_employee
 (<param> <type>, <param> <type>, ...)
AS $$
    -- Petrick
$$ LANGUAGE sql;


------------------------------------------------------------------------
-- CORE (Readapt as necessary.)
------------------------------------------------------------------------


CREATE OR REPLACE FUNCTION search_room
 (<param> <type>, <param> <type>, ...)
RETURNS <type> AS $$
DECLARE
    -- variables here
BEGIN
    -- Tianle
END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE PROCEDURE book_room
 (IN floor_num INT, IN room_num INT, IN dt DATE, IN start_hour INT, IN end_hour INT, IN e_id INT) AS $$
DECLARE
    -- variables here
    e_temperature FLOAT;
    h INT;
    t TIME;
BEGIN
    -- Simon
    SELECT temperature INTO e_temperature FROM HealthDeclarations WHERE eid = e_id AND dt = CURRENT_DATE;
    IF e_id NOT IN (SELECT eid FROM Bookers) THEN RAISE EXCEPTION 'Employee % is not authorized to make bookings', e_id;
    ELSIF e_temperature IS NOT NULL AND e_temperature > 37.5 THEN RAISE EXCEPTION 'Employee % is having a fever (%C)', e_id, e_temperature;
    ELSIF (floor_num, room_num) NOT IN (SELECT room, floor FROM MeetingRooms) THEN RAISE EXCEPTION '%-% is not found', floor_num, room_num;
    ELSIF ((end_hour <= start_hour) OR (start_hour NOT BETWEEN 1 AND 24) OR end_hour NOT BETWEEN 1 AND 24) THEN RAISE EXCEPTION 'Invalid hour input: %, %', start_hour, end_hour;
    ELSIF ((dt < CURRENT_DATE) OR (dt = CURRENT_DATE AND start_hour < date_part('hour', current_timestamp))) THEN RAISE EXCEPTION 'Not allowed to make a booking in the past: %, %', dt, start_hour;

    ELSE FOR h IN start_hour..end_hour-1 LOOP
        IF h >= 10 THEN t := CAST(CONCAT(CAST(h AS TEXT), ':00') AS TIME);
        ELSE t:= CAST(CONCAT('0', CAST(h AS TEXT), ':00') AS TIME);
        END IF;
        INSERT INTO Sessions VALUES (t, dt, room_num, floor_num, e_id);
    END LOOP;

    END IF;
END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE PROCEDURE unbook_room
 (IN floor_num INT, IN room_num INT, IN dt DATE, IN start_hour INT, IN end_hour INT, IN e_id INT) AS $$
DECLARE
    -- variables here
    h INT;
    r RECORD;
BEGIN
    -- Simon
    FOR h IN start_hour..end_hour-1 LOOP
        IF ((end_hour <= start_hour) OR (start_hour NOT BETWEEN 1 AND 24) OR end_hour NOT BETWEEN 1 AND 24) THEN RAISE EXCEPTION 'Invalid hour input: %, %', start_hour, end_hour;
        ELSIF ((dt < CURRENT_DATE) OR (dt = CURRENT_DATE AND start_hour < date_part('hour', current_timestamp))) THEN RAISE EXCEPTION 'Not allowed to remove a booking in the past: %, %', dt, start_hour;
        END IF;

        SELECT * INTO r FROM Sessions WHERE booker_id = e_id AND floor = floor_num AND room = room_num AND date = dt AND date_part('hour', time) = h;
        CONTINUE WHEN r IS NULL;

        DELETE FROM Sessions WHERE booker_id = e_id AND floor = floor_num AND room = room_num AND date = dt AND date_part('hour', time) = h;
        DELETE FROM Joins WHERE floor = floor_num AND room = room_num AND date = dt AND date_part('hour', time) = h;
    END LOOP;
END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION join_meeting
 (<param> <type>, <param> <type>, ...)
RETURNS <type> AS $$
DECLARE
    -- variables here
BEGIN
    -- Teddy
END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION leave_meeting
 (<param> <type>, <param> <type>, ...)
RETURNS <type> AS $$
DECLARE
    -- variables here
BEGIN
    -- Teddy
END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE PROCEDURE approve_meeting
 (IN floor_num INT, IN room_num INT, IN dt DATE, IN start_hour INT, IN end_hour INT, IN e_id INT) AS $$
DECLARE
    -- variables here
    h INT;
    dpmt_b INT;
    dpmt_a INT;
BEGIN
    -- Simon
    IF e_id NOT IN (SELECT eid FROM Managers) THEN RAISE EXCEPTION '% is not authorized to approve the meeting', e_id;
    ELSIF ((end_hour <= start_hour) OR (start_hour NOT BETWEEN 1 AND 24) OR end_hour NOT BETWEEN 1 AND 24) THEN RAISE EXCEPTION 'Invalid hour input: %, %', start_hour, end_hour;
    ELSIF ((dt < CURRENT_DATE) OR (dt = CURRENT_DATE AND start_hour < date_part('hour', current_timestamp))) THEN RAISE EXCEPTION 'Not allowed to remove a booking in the past: %, %', dt, start_hour;

    ELSE FOR h in start_hour..end_hour-1 LOOP
        SELECT did INTO dpmt_b FROM Employees WHERE eid = (SELECT booker_id FROM Sessions WHERE floor = floor_num AND room = room_num AND date = dt AND date_part('hour', time) = h);
        SELECT did INTO dpmt_a FROM Employees WHERE eid = e_id;
        IF dpmt_b <> dpmt_a THEN RAISE EXCEPTION '% is not in the same department (%) as the booker of %-% at % %h (%)', e_id, dpmt_a, floor_num, room_num, dt, h, dpmt_b;
        ELSE
            UPDATE Sessions SET approver_id = e_id WHERE floor = floor_num AND room = room_num AND date = dt AND date_part('hour', time) = h;
        END IF;
    END LOOP;

    END IF;
END
$$ LANGUAGE plpgsql;


------------------------------------------------------------------------
-- HEALTH (Readapt as necessary.)
------------------------------------------------------------------------


CREATE OR REPLACE PROCEDURE declare_health
 (IN eid INT, IN "date" DATE, IN temperature float)
AS $$
    INSERT INTO HealthDeclarations (eid, "date", temperature) VALUES (eid, "date", temperature) 
    ON CONFLICT (eid, "date") DO UPDATE
        SET temperature = EXCLUDED.temperature;
$$ LANGUAGE sql;

CALL declare_health(1, '2021-10-19', 37.0);

CREATE OR REPLACE FUNCTION check_fever()
RETURNS TRIGGER AS $$
BEGIN
    -- no fever
    IF NEW.temperature <= 37.5 THEN RETURN NULL;
    END IF;

    -- if the employee is the booker -> cancel future sessions
    IF NEW.eid IN (SELECT * FROM Bookers) THEN
        DELETE FROM "Sessions" WHERE booker_id = NEW.eid AND "date" >= NEW.date;
    END IF;

    -- remove employee from future sessions
    DELETE FROM Joins WHERE eid = NEW.eid AND "date" >= NEW.date;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER TR_HealthDeclarations_AfterInsert
AFTER INSERT OR UPDATE ON HealthDeclarations
FOR EACH ROW EXECUTE FUNCTION check_fever();


CREATE OR REPLACE FUNCTION contact_tracing
(IN eid INT)
AS $$


$$ LANGUAGE plpgsql;

------------------------------------------------------------------------
-- ADMIN (Readapt as necessary.)
------------------------------------------------------------------------


CREATE OR REPLACE FUNCTION non_compliance
 (IN "start" DATE, IN "end" DATE, OUT eid INT, OUT "days" INT)
RETURNS  SETOF RECORD  AS $$
    WITH Declared AS (
        SELECT eid, COUNT(temperature) AS counts
        FROM HealthDeclarations
        WHERE "date" BETWEEN "start" AND "end"
        GROUP BY eid
    )
    SELECT E.eid AS eid, "end"::DATE - "start"::DATE + 1 - COALESCE(D.counts,0) AS "days"
    FROM Employees E
    LEFT JOIN Declared D ON E.eid = D.eid
    WHERE "end"::DATE - "start"::DATE + 1 - COALESCE(D.counts,0) > 0;
$$ LANGUAGE sql;


CREATE OR REPLACE FUNCTION view_booking_report
 (<param> <type>, <param> <type>, ...)
RETURNS <type> AS $$
DECLARE
    -- variables here
BEGIN
    -- Petrick
END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION view_future_meeting
 (<param> <type>, <param> <type>, ...)
RETURNS <type> AS $$
DECLARE
    -- variables here
BEGIN
    -- Petrick
END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION view_manager_report
 (<param> <type>, <param> <type>, ...)
RETURNS <type> AS $$
DECLARE
    -- variables here
BEGIN
    -- Petrick
END
$$ LANGUAGE plpgsql;
