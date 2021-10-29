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
 (IN did INT, IN dname VARCHAR(50)) 
 RETURNS void AS $$
    -- Tianle
    INSERT INTO Departments VALUES (did, dname);
$$ LANGUAGE sql;


CREATE OR REPLACE PROCEDURE remove_department
 (IN did INT)
 -- CANNOT DELETE 1,2,4,5,9; Operations will be transffered into HR; R&D is transffered into IT. The rest of departments cannot be deleted. Raise exception if attempts are made.
 RETURNS void AS $$
    -- Tianle
    DELETE FROM Departments WHERE did = OLD.did;
    IF did IN (6, 7, 8) THEN
    DELETE FROM Employees WHERE did = OLD.did;
    ELSIF did = 3 THEN
    UPDATE Employees SET OLD.did = 4 WHERE OLD.did = 4;
    ELSIF did = 10 THEN
    UPDATE Employees SET OLD.did = 5 WHERE OLD.did = 5;
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION core_departments() RETURNS TRIGGER AS $$
BEGIN
    RAISE NOTICE 'Some users are trying to delete or update the core departments';
    RETURN NULL;
END;
$$ LANGUAGE sql;

CREATE OR REPLACE TRIGGER check_core
BEFORE DELETE OR UPDATE ON Departments
FOR EACH ROW WHERE OLD.did IN (1,2,4,5,9) EXECUTE FUNCTION core_departments();


CREATE OR REPLACE PROCEDURE add_room
 (IN room INT, IN "floor" INT, IN rname VARCHAR(50), IN did INT)
RETURN void AS $$
    -- Tianle
    INSERT INTO MeetingRooms VALUES (room, "floor", rname, did);
$$ LANGUAGE sql;

CREATE OR REPLACE PROCEDURE change_capacity
(IN room INT, IN "floor" INT, IN capacity INT, IN DATE )
AS $$
    UPDATE Updates SET cap = capacity wHERE room = OLD.room AND "floor" = OLD.floor;
    UPDATE Updates SET "date" = OLD."date" wHERE room = OLD.room AND "floor" = OLD.floor;
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
 ()
RETURNS AS $$
DECLARE
    -- variables here
BEGIN
    -- Tianle
END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE PROCEDURE book_room
 (IN floor_num INT, IN room_num INT, IN date DATETIME, IN start_hour INT, IN end_hour INT, IN eid INT)
RETURNS VOID AS $$
DECLARE
    -- variables here
    e_temperature FLOAT;
    h INT;
    t VARCHAR(5);
BEGIN
    -- Simon
    SELECT temperature INTO e_temperature FROM HealthDeclarations WHERE eid = eid AND date = CURRENT_DATE
    IF eid NOT IN (SELECT eid FROM Bookers) THEN RAISE EXCEPTION 'Employee % is not authorized to make bookings', eid;
    ELSIF e_temperature IS NOT NULL AND e_temperature > 37.5 THEN RAISE EXCEPTION 'Employee % is having a fever (%C)', eid, e_temperature;
    ELSIF (floor_num, room_num) NOT IN (SELECT room, floor FROM Sessions) THEN RAISE EXCEPTION '%-% is not found', floor_num, room_num;
    ELSIF ((end_hour >= start_hour) OR (start_hour NOT BETWEEN 1 AND 24) OR end_hour NOT BETWEEN 1 AND 24) THEN RAISE EXCEPTION 'Invalid hour input: %, %', start_hour, end_hour;
    ELSIF ((date < CURRENT_DATE) OR (start_hour < date_trunc('hour', current_timestamp))) THEN RAISE EXCEPTION 'Not allowed to make a booking in the past: %, %', date, start_hour;
    ELSE FOR h IN start_hour..end_hour-1 LOOP
        IF h >= 10 THEN t := '%:00', h;
        ELSE t:= '0%:00', h;
        END IF;
        INSERT INTO Sessions VALUES (eid, time, date, room, floor);
END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE PROCEDURE unbook_room
 (IN floor_num INT, IN room_num INT, IN date DATETIME, IN start_hour INT, IN end_hour INT, IN eid INT)
RETURNS VOID AS $$
DECLARE
    -- variables here
BEGIN
    -- Simon
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


CREATE OR REPLACE FUNCTION approve_meeting
 (<param> <type>, <param> <type>, ...)
RETURNS <type> AS $$
DECLARE
    -- variables here
BEGIN
    -- Simon
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

