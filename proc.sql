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

-- HELPERS
  -- all_sessions_exist
    CREATE OR REPLACE FUNCTION all_sessions_exist
    (IN in_floor INT, IN in_room INT, IN in_date DATE, IN in_start TIME, IN in_end TIME)
    RETURNS BOOLEAN AS $$
    -- Teddy
    DECLARE
        found_sessions INT;
        wanted_sessions INT;
    BEGIN
        SELECT COUNT(*) INTO found_sessions
        FROM "Sessions"
        WHERE "date" = in_date AND
            room = in_room AND
            "floor" = in_floor AND
            "time" BETWEEN in_start AND (in_end - interval '1 min');
        
        SELECT EXTRACT(epoch FROM in_end - in_time)/3600 INTO wanted_sessions;

        -- trying to join sessions that have not been booked
        RETURN found_sessions == wanted_sessions;
    END
    $$ LANGUAGE plpgsql;

  -- any_session_exist
    CREATE OR REPLACE FUNCTION any_session_exist
    (IN in_floor INT, IN in_room INT, IN in_date DATE, IN in_start TIME, IN in_end TIME)
    RETURNS BOOLEAN AS $$
    -- Teddy
    DECLARE
        found_sessions INT;
    BEGIN
        SELECT COUNT(*) INTO found_sessions
        FROM "Sessions"
        WHERE "date" = in_date AND
            room = in_room AND
            "floor" = in_floor AND
            "time" BETWEEN in_start AND (in_end - interval '1 min');
        
        -- trying to join sessions that have not been booked
        RETURN found_sessions != 0;
    END
    $$ LANGUAGE plpgsql;

  -- eid_in_all_sessions
    CREATE OR REPLACE FUNCTION eid_in_all_sessions
    (IN in_floor INT, IN in_room INT, IN in_date DATE, IN in_start TIME, IN in_end TIME, IN eid INT)
    RETURNS BOOLEAN AS $$
    DECLARE
        found_sessions INT;
        wanted_sessions INT;
    BEGIN
        SELECT COUNT(*) INTO found_sessions
        FROM "Sessions" S
        LEFT JOIN Joins J 
        ON S.time = J.time AND S.date = J.date AND S.room = J.room AND S.floor = J.floor
        WHERE J.date = in_date AND
            J.room = in_room AND
            J.floor = in_floor AND
            J.eid = in_eid AND
            J.time BETWEEN in_start AND (in_end - interval '1 min');
        
        SELECT EXTRACT(epoch FROM in_end - in_time)/3600 INTO wanted_sessions;

        RETURN found_sessions = wanted_sessions;
    END
    $$ LANGUAGE plpgsql;

  -- any_session_approved
    CREATE OR REPLACE FUNCTION any_session_approved
    (IN in_floor INT, IN in_room INT, IN in_date DATE, IN in_start TIME, IN in_end TIME)
    RETURNS BOOLEAN AS $$
    -- Teddy
    DECLARE
        approver INT;
        curr_start TIME := in_start;
    BEGIN
        WHILE curr_start < in_end LOOP
            approver := NULL;
            SELECT approver_id INTO approver
            FROM "Sessions"
            WHERE "time" = curr_start AND
                "date" = in_date AND
                room = in_room AND
                "floor" = in_floor;
            
            -- cannot join approved meeting
            IF approver IS NOT NULL THEN RETURN TRUE;
            END IF;

            curr_start := curr_start + interval '1 hour';
        END LOOP;
        RETURN FALSE;
    END
    $$ LANGUAGE plpgsql;

  -- has_fever
    CREATE OR REPLACE FUNCTION has_fever
    (IN in_eid INT)
    RETURNS BOOLEAN AS $$
    DECLARE
        temp INT;
    BEGIN

        SELECT temperature INTO temp FROM HealthDeclarations HD 
        WHERE HD.eid = in_eid AND HD.eid = CURRENT_DATE;

        IF temp IS NULL THEN
            RAISE NOTICE '% has not declared temperature today, unable to decide whether employee has a fever. 
            Taking a safer approach, employee is assumed to potentially have a fever until the employee declares otherwise', in_eid;
            RETURNS TRUE; 
        ELSIF temp > 37.5 THEN
            RETURNS TRUE;
        ELSE
            RETURNS FALSE;
        END IF;
    END
    $$ LANGUAGE plpgsql;

  --is_valid_hour
    CREATE OR REPLACE FUNCTION is_valid_hour(IN start_hour INT, IN end_hour INT)
    RETURNS BOOLEAN AS $$
    BEGIN
        IF (end_hour <= start_hour) OR (start_hour NOT BETWEEN 1 AND 24) OR (end_hour NOT BETWEEN 1 AND 24) THEN RETURN FALSE;
        ELSE RETURN TRUE;
        END IF;
    END;
    $$ LANGUAGE plpgsql;

  --is_past
    CREATE OR REPLACE FUNCTION is_past(IN in_date DATE, in_hour INT)
    RETURNS BOOLEAN AS $$
    BEGIN
        IF (in_date < CURRENT_DATE) OR (in_date = CURRENT_DATE AND in_hour < date_part('hour', current_timestamp)) THEN RETURN TRUE;
        ELSE RETURN FALSE;
        END IF;
    END;
    $$ LANGUAGE plpgsql;

  --is_valid_room
    CREATE OR REPLACE FUNCTION is_valid_room(IN in_floor INT, IN in_room INT)
    RETURNS BOOLEAN AS $$
    BEGIN
        IF (in_floor, in_room) NOT IN (SELECT room, floor FROM MeetingRooms) THEN RETURN FALSE;
        ELSE RETURN TRUE;
        END IF;
    END;
    $$ LANGUAGE plpgsql;

  --hour_int_to_time
    CREATE OR REPLACE FUNCTION hour_int_to_time(IN in_hour INT)
    RETURNS TIME AS $$
    BEGIN
        IF in_hour >= 10 THEN RETURN CAST(CONCAT(CAST(in_hour AS TEXT), ':00') AS TIME);
        ELSE RETURN CAST(CONCAT('0', CAST(in_hour AS TEXT), ':00') AS TIME);
        END IF;
    END;
    $$ LANGUAGE plpgsql;

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
 (IN in_ename VARCHAR(50), IN in_contact VARCHAR(50), IN kind VARCHAR(10), IN in_did INT)
AS $$
 -- Teddy
DECLARE
    email VARCHAR(50);
    eid INT := 0;
BEGIN
    eid := generate_id();   
    SELECT concat(ename, eid, '@hotmail.com') INTO email;
    INSERT INTO Employees (eid, ename, email, did, contact) 
    VALUES (eid, in_ename, email, in_did, in_contact);
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
 (IN in_eid INT, IN in_date DATE)
AS $$
DECLARE
    emp_id INT;
BEGIN
    SELECT eid INTO emp_id FROM Employees WHERE eid = in_eid;
    IF eid NOT IN (SELECT eid FROM Bookers) THEN RAISE EXCEPTION 'Employee % does not exist', e_id;
    ELSE 
    -- edit resigned date for employee
    -- remove employee from all related records
    ---- Joins
    ---- Sessions (check if booker resigns -> delete sessions)
END;
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

CREATE OR REPLACE FUNCTION is_valid_eid(IN eid INT)
RETURNS BOOLEAN AS $$

$$ LANGUAGE plpgsql;

-- make a hour function

CREATE OR REPLACE PROCEDURE book_room
 (IN in_floor INT, IN in_room INT, IN in_date DATE, IN start_hour INT, IN end_hour INT, IN in_eid INT) AS $$
DECLARE
    -- variables here
    e_temperature FLOAT;
    h INT;
    t TIME;
BEGIN
    -- Simon
    IF in_eid NOT IN (SELECT eid FROM Bookers) THEN RAISE EXCEPTION 'Employee % is not authorized to make bookings', in_eid;
    ELSIF NOT is_valid_room(in_floor, in_room) THEN RAISE EXCEPTION '%-% is not found', in_floor, in_room;
    ELSIF NOT is_valid_hour(start_hour, end_hour) THEN RAISE EXCEPTION 'Invalid hour input: %, %', start_hour, end_hour;
    ELSIF is_past(in_date, start_hour) THEN RAISE EXCEPTION 'Not allowed to make a booking in the past: %, %', in_date, start_hour;
    ELSIF any_session_approved(in_floor, in_room, in_date, start_hour, end_hour) THEN RAISE EXCEPTION 'Some session(s) are already booked and approved for your specified period and room';

    ELSE FOR h IN start_hour..end_hour-1 LOOP -- all or nothing
        IF h >= 10 THEN t := CAST(CONCAT(CAST(h AS TEXT), ':00') AS TIME);
        ELSE t:= CAST(CONCAT('0', CAST(h AS TEXT), ':00') AS TIME);
        END IF;
        INSERT INTO Sessions (eid, "time", "date", room, "floor") VALUES (in_eid, time, in_date, in_room, in_floor);
    END LOOP;

    CALL join_meeting(in_floor, in_room, in_date, start_hour, end_hour, in_eid);

    END IF;
END
$$ LANGUAGE plpgsql;



CREATE OR REPLACE PROCEDURE unbook_room
 (IN in_floor INT, IN in_room INT, IN in_date DATE, IN start_hour INT, IN end_hour INT, IN in_eid INT) AS $$
DECLARE
    -- variables here
    h INT;
    r RECORD;
BEGIN
    -- Simon
    IF NOT is_valid_hour(start_hour, end_hour) THEN RAISE EXCEPTION 'Invalid hour input: %, %', start_hour, end_hour;
    ELSIF is_past(in_date, start_hour) THEN RAISE EXCEPTION 'Not allowed to remove a booking in the past: %, %', in_date, start_hour;
    ELSIF NOT all_sessions_exist(in_floor, in_room, in_date, start_hour, end_hour) THEN RAISE EXCEPTION 'Some session(s) in the query are not present in Sessions';

    ELSE FOR h IN start_hour..end_hour-1 LOOP
        SELECT * INTO r FROM Sessions WHERE booker_id = in_eid AND floor = in_floor AND room = in_room AND date = in_date AND date_part('hour', time) = h;
        CONTINUE WHEN r IS NULL;
        DELETE FROM Sessions WHERE booker_id = in_eid AND floor = in_floor AND room = in_room AND date = in_date AND date_part('hour', time) = h;
        DELETE FROM Joins WHERE floor = in_floor AND room = in_room AND date = in_date AND date_part('hour', time) = h;
    END LOOP;

    END IF;
END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE PROCEDURE join_meeting
 (IN in_floor INT, IN in_room INT, IN in_date DATE, IN in_start TIME, IN in_end TIME, IN in_eid INT)
AS $$
  -- Teddy
DECLARE
    temp INT;
    curr_start TIME := in_start;
BEGIN
  -- check that sessions from in_start to in_end exist
    IF NOT all_sessions_exist(in_floor, in_room, in_date, in_start, in_end) THEN RETURN;
  -- find the sessions and check whether it's approved
    ELSIF any_session_approved(in_floor, in_room, in_date, in_start, in_end) THEN RETURN;
    END IF;

  -- if everything is valid,
    curr_start := in_start;
    WHILE curr_start < in_end
        INSERT INTO Joins (eid, "time", "date", room, "floor")
        VALUES (in_eid, curr_start, in_date, in_room, in_floor);

        curr_start := curr_start + interval '1 hour';
    END LOOP;
END

$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION leave_meeting
 (IN in_floor INT, IN in_room INT, IN in_date DATE, IN in_start TIME, IN in_end TIME, IN in_eid INT)
RETURNS <type> AS $$
    -- Teddy
BEGIN 
  -- check that sessions from in_start to in_end exist
    IF NOT all_sessions_exist(in_floor, in_room, in_date, in_start, in_end) THEN RETURN;
  -- find the sessions and check whether it's approved
    ELSIF any_session_approved(in_floor, in_room, in_date, in_start, in_end) THEN RETURN;
    END IF;

  -- delete the eid from the joins
    DELETE FROM Joins
    WHERE eid = in_eid AND
          "date" = in_date AND
          room = in_room AND
          "floor" = in_floor AND
          "time" BETWEEN in_start AND (in_end - interval '1 min');

END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE PROCEDURE approve_meeting
 (IN in_floor INT, IN in_room INT, IN in_date DATE, IN start_hour INT, IN end_hour INT, IN in_eid INT) AS $$
DECLARE
    -- variables here
    h INT;
    dpmt_b INT;
    dpmt_a INT;
BEGIN
    -- Simon
    -- Check if the meeting is alr approved
    IF in_eid NOT IN (SELECT eid FROM Managers) THEN RAISE EXCEPTION '% is not authorized to approve the meeting', in_eid;
    ELSIF NOT is_valid_hour(start_hour, end_hour) THEN RAISE EXCEPTION 'Invalid hour input: %, %', start_hour, end_hour;
    ELSIF is_past(in_date, start_hour) THEN RAISE EXCEPTION 'Not allowed to remove a booking in the past: %, %', in_date, start_hour;
    ELSIF any_session_approved(in_floor, in_room, in_date, start_hour, end_hour) THEN RAISE EXCEPTION 'Some sessions are already approved by other manager(s)';

    ELSE FOR h in start_hour..end_hour-1 LOOP
        SELECT did INTO dpmt_b FROM Employees WHERE eid = (SELECT booker_id FROM Sessions WHERE floor = in_floor AND room = in_room AND date = in_date AND date_part('hour', time) = h);
        SELECT did INTO dpmt_a FROM Employees WHERE eid = in_eid;
        IF dpmt_b <> dpmt_a THEN RAISE EXCEPTION '% is not in the same department (%) as the booker of %-% at % %h (%)', in_eid, dpmt_a, in_floor, in_room, in_date, h, dpmt_b;
        ELSE
            UPDATE Sessions SET approver_id = in_eid WHERE floor = in_floor AND room = in_room AND date = in_date AND date_part('hour', time) = h;
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




CREATE OR REPLACE FUNCTION contact_tracing
(IN IN_eid INT, IN D DATE)
AS $$
DECLARE
    temp INT;
BEGIN
/*
IF eid DOESNT DECLARE ON D -> IGNORE
FIND CLOSE CONTACT
REMOVE THEM FROM D+7 BUT ONLY THE ONES IN THE FUTURE
*/
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
-- teddy
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
 (IN in_date DATE, IN eid INT)
RETURNS SETOF RECORD AS $$
    SELECT 
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION view_future_meeting
 (IN in_date DATE, IN eid INT)
RETURNS  SETOF RECORD  AS $$
    SELECT *
    FROM Sessions
    WHERE 
END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION view_manager_report
 (IN in_date DATE, IN eid INT)
RETURNS <type> AS $$
DECLARE
    -- variables here
BEGIN
    -- Petrick
END
$$ LANGUAGE plpgsql;


-- TRIGGERS
  -- Sessions
    CREATE OR REPLACE FUNCTION fever_cannot_book()
    RETURNS TRIGGER AS $$
    BEGIN
        IF has_fever(NEW.booker_id) THEN RETURN NULL;
        ELSE RETURN NEW;
    END
    $$ LANGUAGE plpgsql;

    CREATE TRIGGER TR_Sessions_BeforeInsert
    BEFORE INSERT ON "Sessions"
    FOR EACH ROW EXECUTE FUNCTION fever_cannot_book();

  -- HealthDeclarations
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

  -- Joins
    CREATE OR REPLACE FUNCTION fever_cannot_join()
    RETURNS TRIGGER AS $$
    BEGIN
        IF has_fever(NEW.eid) THEN RETURN NULL;
        ELSE RETURN NEW;
    END
    $$ LANGUAGE plpgsql;

    CREATE TRIGGER TR_Joins_BeforeInsert
    BEFORE INSERT ON Joins
    FOR EACH ROW EXECUTE FUNCTION fever_cannot_join();
