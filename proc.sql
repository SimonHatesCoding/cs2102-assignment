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


CREATE OR REPLACE FUNCTION book_room
 (<param> <type>, <param> <type>, ...)
RETURNS <type> AS $$
DECLARE
    -- variables here
BEGIN
    -- Simon
END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION unbook_room
 (<param> <type>, <param> <type>, ...)
RETURNS <type> AS $$
DECLARE
    -- variables here
BEGIN
    -- Simon
END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION join_meeting
 (IN in_floor INT, IN in_room INT, IN in_date DATE, IN in_start TIME, IN in_end TIME, IN eid INT)
RETURNS <type> AS $$
-- cannot join approved meeting
-- cannot join if got fever

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

    -- call contact tracing
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER TR_HealthDeclarations_AfterInsert
AFTER INSERT OR UPDATE ON HealthDeclarations
FOR EACH ROW EXECUTE FUNCTION check_fever();


CREATE OR REPLACE FUNCTION contact_tracing
(IN IN_eid INT, IN D DATE)
AS $$
DECLARE
    temp INT;
BEGIN
    -- use the latest health declaration
    SELECT temperature INTO temp
    FROM HealthDeclarations
    WHERE eid = eid
    ORDER BY "date" DESC
    LIMIT 1;

    raise notice 'Value: %', temp;
END;

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

