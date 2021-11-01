------------------------------------------------------------------------
------------------------------------------------------------------------
--
-- PROCEDURES & TRIGGERS
--
------------------------------------------------------------------------
------------------------------------------------------------------------

------------------------------------------------------------------------
-- HELPERS (for use in other procedures/functions)
------------------------------------------------------------------------
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
        IF found_sessions <> wanted_sessions THEN 
            RAISE NOTICE 'Not all sessions exist in floor: % room: % date: % start: % end: %',
            in_floor, in_room, in_date, in_start, in_end;
            RETURN FALSE;
        END IF;

        RETURN TRUE;
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
        
        IF found_sessions <> 0 THEN
            RAISE NOTICE 'There are already some booked sessions in floor: % room: % date: % start: % end: %',
            in_floor, in_room, in_date, in_start, in_end;
            RETURN TRUE;
        END IF;

        RETURN FALSE;
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

        IF found_sessions <> wanted_sessions THEN
            RAISE NOTICE 'eid: % does not join all the sessions in floor: % room: % date: % start: % end: %', 
            eid, in_floor, in_room, in_date, in_start, in_end;
            RETURN FALSE;
        END IF;

        RETURN TRUE;
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
            IF approver IS NOT NULL THEN 
                RAISE NOTICE 'Some sessions in floor: % room: % date: % start: % end: % have been approved', 
                in_floor, in_room, in_date, in_start, in_end;
                RETURN TRUE;
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

-- is_valid_hour
    CREATE OR REPLACE FUNCTION is_valid_hour(IN start_hour INT, IN end_hour INT)
    RETURNS BOOLEAN AS $$
    BEGIN
        IF (end_hour <= start_hour) OR (start_hour NOT BETWEEN 1 AND 24) OR (end_hour NOT BETWEEN 1 AND 24) THEN 
            RAISE NOTICE 'Invalid start_hour: % and end_hour: %', start_hour, end_hour;
            RETURN FALSE;
        ELSE RETURN TRUE;
        END IF;
    END;
    $$ LANGUAGE plpgsql;

-- is_past
    CREATE OR REPLACE FUNCTION is_past(IN in_date DATE, in_hour INT)
    RETURNS BOOLEAN AS $$
    BEGIN
        IF (in_date < CURRENT_DATE) OR (in_date = CURRENT_DATE AND in_hour < date_part('hour', current_timestamp)) THEN 
            RAISE NOTICE 'The given date and hour is in the past % %', in_date, in_hour;
            RETURN TRUE;
        ELSE RETURN FALSE;
        END IF;
    END;
    $$ LANGUAGE plpgsql;

-- is_valid_room
    CREATE OR REPLACE FUNCTION is_valid_room(IN in_floor INT, IN in_room INT)
    RETURNS BOOLEAN AS $$
    BEGIN
        IF (in_floor, in_room) NOT IN (SELECT room, floor FROM MeetingRooms) THEN 
            RAISE NOTICE 'The given floor: % and room: % is invalid', in_floor, in_room;
            RETURN FALSE;
        ELSE RETURN TRUE;
        END IF;
    END;
    $$ LANGUAGE plpgsql;

-- hour_int_to_time
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
(IN in_did INT, IN in_dname VARCHAR(50)) 
AS $$
    IF (in_did, in_dname) NOT IN (SELECT did, dname FROM Departments) THEN
        INSERT INTO Departments VALUES (in_did, in_dname);
    END IF;
$$ LANGUAGE sql;

CREATE OR REPLACE PROCEDURE remove_department
(IN in_did1 INT, IN in_did2)
AS $$
    IF in_did1 IN (SELECT did FROM Departments) AND 
         in_did2 IN (SELECT did FROM Departments) THEN
    UPDATE Employees SET did = in_did2 WHERE did = in_did1;
    DELETE FROM Departments WHERE did = in_did1;
    END IF;
$$ LANGUAGE sql;

CREATE OR REPLACE PROCEDURE add_room
 (IN in_room INT, IN "in_floor" INT, IN in_rname VARCHAR(50), IN in_did INT)
AS $$
    INSERT INTO MeetingRooms VALUES (in_room, "in_floor", in_rname, in_did);
$$ LANGUAGE sql;

CREATE OR REPLACE PROCEDURE change_capacity
(IN in_room INT, IN "in_floor" INT, IN in_capacity INT, IN in_date DATE, IN in_eid INT)
AS $$
    IF in_eid IN (SELECT * FROM Managers) THEN
        UPDATE Updates SET capacity = in_cap WHERE room = in_room AND "floor" = "in_floor";
        UPDATE Updates SET "date" = in_date WHERE room = in_room AND "floor" = "in_floor";
        UPDATE Updates SET eid = in_eid WHERE room = in_room AND "floor" = "in_floor";
    END IF;
$$ LANGUAGE sql;

-- generate_id
    CREATE OR REPLACE FUNCTION generate_id(OUT eid INT)
    RETURNS INT AS $$
        SELECT MAX(eid)+1 FROM Employees;
    $$ LANGUAGE sql;

------------------------------------------------------------------------
-- BASIC (Readapt as necessary.)
------------------------------------------------------------------------
-- add_department
    CREATE OR REPLACE PROCEDURE add_department
    (IN in_did INT, IN in_dname VARCHAR(50)) 
    AS $$
        IF (in_did, in_dname) NOT IN (SELECT did, dname FROM Departments) THEN
            INSERT INTO Departments VALUES (in_did, in_dname);
        END IF;
    $$ LANGUAGE sql;

-- remove_department
    CREATE OR REPLACE PROCEDURE remove_department
    (IN in_did1 INT, IN in_did2)
    AS $$
        IF in_did1 IN (SELECT did FROM Departments) AND 
            in_did2 IN (SELECT did FROM Departments) THEN
        UPDATE Employees SET did = in_did2 WHERE did = in_did1;
        DELETE FROM Departments WHERE did = in_did1;
        END IF;
    $$ LANGUAGE sql;

-- add_room
    CREATE OR REPLACE PROCEDURE add_room
    (IN in_room INT, IN "in_floor" INT, IN in_rname VARCHAR(50), IN in_did INT)
    AS $$
        INSERT INTO MeetingRooms VALUES (in_room, "in_floor", in_rname, in_did);
    $$ LANGUAGE sql;

-- change_capacity
    CREATE OR REPLACE PROCEDURE change_capacity
    (IN in_room INT, IN "in_floor" INT, IN in_capacity INT, IN in_date DATE, IN in_eid INT)
    AS $$
        IF in_eid IN (SELECT * FROM Managers) THEN
            UPDATE Updates SET capacity = in_cap WHERE room = in_room AND "floor" = "in_floor";
            UPDATE Updates SET "date" = in_date WHERE room = in_room AND "floor" = "in_floor";
            UPDATE Updates SET eid = in_eid WHERE room = in_room AND "floor" = "in_floor";
        END IF;
    $$ LANGUAGE sql;

-- add_employee
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

-- remove_employee
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
-- search_room
    CREATE OR REPLACE FUNCTION search_room
    (<param> <type>, <param> <type>, ...)
    RETURNS <type> AS $$
    DECLARE
        -- variables here
    BEGIN
        -- Tianle
    END
    $$ LANGUAGE plpgsql;

-- book_room
    CREATE OR REPLACE PROCEDURE book_room
    (IN in_floor INT, IN in_room INT, IN in_date DATE, IN start_hour INT, IN end_hour INT, IN in_eid INT) AS $$
    DECLARE
        -- variables here
        h INT;
        t TIME;
    BEGIN
    -- Simon
        IF in_eid NOT IN (SELECT eid FROM Bookers) THEN RAISE EXCEPTION 'Employee % is not authorized to make bookings', in_eid;
        ELSIF NOT is_valid_room(in_floor, in_room) THEN RETURN;
        ELSIF NOT is_valid_hour(start_hour, end_hour) THEN RETURN;
        ELSIF is_past(in_date, start_hour) THEN RETURN;
        ELSIF any_session_approved(in_floor, in_room, in_date, start_hour, end_hour) THEN RETURN;

        ELSE FOR h IN start_hour..end_hour-1 LOOP -- all or nothing
            IF h >= 10 THEN t := hour_int_to_time(h);
            ELSE t:= hour_int_to_time(h);
            END IF;
            INSERT INTO Sessions (eid, "time", "date", room, "floor") VALUES (in_eid, time, in_date, in_room, in_floor);
        END LOOP;

        END IF;
    END;
    $$ LANGUAGE plpgsql;

-- unbook_room
    CREATE OR REPLACE PROCEDURE unbook_room
    (IN in_floor INT, IN in_room INT, IN in_date DATE, IN start_hour INT, IN end_hour INT, IN in_eid INT) AS $$
    DECLARE
        -- variables here
        h INT;
        r RECORD;
    BEGIN
        -- Simon
        IF NOT is_valid_hour(start_hour, end_hour) THEN RETURN;
        ELSIF is_past(in_date, start_hour) THEN RETURN;
        ELSIF NOT all_sessions_exist(in_floor, in_room, in_date, start_hour, end_hour) THEN RETURN;

        ELSE FOR h IN start_hour..end_hour-1 LOOP
            SELECT * INTO r FROM Sessions WHERE booker_id = in_eid AND floor = in_floor AND room = in_room AND date = in_date AND date_part('hour', time) = h;
            CONTINUE WHEN r IS NULL;
            DELETE FROM Sessions WHERE booker_id = in_eid AND floor = in_floor AND room = in_room AND date = in_date AND date_part('hour', time) = h;
            DELETE FROM Joins WHERE floor = in_floor AND room = in_room AND date = in_date AND date_part('hour', time) = h;
        END LOOP;

        END IF;
    END
    $$ LANGUAGE plpgsql;

-- join_meeting
    CREATE OR REPLACE PROCEDURE join_meeting
    (IN in_floor INT, IN in_room INT, IN in_date DATE, IN start_hour TIME, IN end_hour TIME, IN in_eid INT)
    AS $$
    -- Teddy
    DECLARE
        in_start TIME;
        in_end TIME;
        curr_start TIME;
    BEGIN
        in_start := hour_int_to_time(start_hour);
        in_end := hour_int_to_time(end_hour);

        IF NOT is_valid_hour(start_hour, end_hour) OR 
           is_past(in_date, start_hour) OR
           NOT is_valid_room(in_floor, in_room) OR
           NOT all_sessions_exist(in_floor, in_room, in_date, in_start, in_end) OR
           any_session_approved(in_floor, in_room, in_date, in_start, in_end) THEN RETURN;
        END IF;

    -- if everything is valid,
        curr_start := in_start;
        WHILE curr_start < in_end LOOP
            INSERT INTO Joins (eid, "time", "date", room, "floor")
            VALUES (in_eid, curr_start, in_date, in_room, in_floor);

            curr_start := curr_start + interval '1 hour';
        END LOOP;
    END
    $$ LANGUAGE plpgsql;

-- leave_meeting
    CREATE OR REPLACE FUNCTION leave_meeting
    (IN in_floor INT, IN in_room INT, IN in_date DATE, IN start_hour INT, IN end_hour INT, IN in_eid INT)
    RETURNS <type> AS $$
        -- Teddy
    DECLARE
        in_start TIME;
        in_end TIME;
    BEGIN 
        in_start := hour_int_to_time(start_hour);
        in_end := hour_int_to_time(end_hour);

        IF NOT is_valid_hour(start_hour, end_hour) OR 
           is_past(in_date, start_hour) OR
           NOT is_valid_room(in_floor, in_room) OR
           NOT all_sessions_exist(in_floor, in_room, in_date, in_start, in_end) OR
           any_session_approved(in_floor, in_room, in_date, in_start, in_end) THEN RETURN;
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

-- approve_meeting
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
        ELSIF NOT is_valid_hour(start_hour, end_hour) THEN RETURN;
        ELSIF is_past(in_date, start_hour) THEN RETURN;
        ELSIF any_session_approved(in_floor, in_room, in_date, start_hour, end_hour) THEN RETURN;

        ELSE FOR h in start_hour..end_hour-1 LOOP
            SELECT did INTO dpmt_b FROM Employees WHERE eid = (SELECT booker_id FROM Sessions WHERE floor = in_floor AND room = in_room AND date = in_date AND date_part('hour', time) = h);
            SELECT did INTO dpmt_a FROM Employees WHERE eid = in_eid;
            IF dpmt_b <> dpmt_a THEN RAISE EXCEPTION '% is not in the same department (%) as the booker of %-% at % %h (%)', in_eid, dpmt_a, in_floor, in_room, in_date, h, dpmt_b;
            ELSE
                UPDATE Sessions SET approver_id = in_eid WHERE floor = in_floor AND room = in_room AND date = in_date AND date_part('hour', time) = h;
            END IF;
        END LOOP;

        END IF;
    END;
    $$ LANGUAGE plpgsql;

------------------------------------------------------------------------
-- HEALTH (Readapt as necessary.)
------------------------------------------------------------------------
-- declare_health
    CREATE OR REPLACE PROCEDURE declare_health
    (IN eid INT, IN "date" DATE, IN temperature float)
    AS $$
        INSERT INTO HealthDeclarations (eid, "date", temperature) VALUES (eid, "date", temperature) 
        ON CONFLICT (eid, "date") DO UPDATE
            SET temperature = EXCLUDED.temperature;
    $$ LANGUAGE sql;

-- contact_tracing
    CREATE OR REPLACE FUNCTION contact_tracing
    (IN in_eid INT, IN D DATE, OUT close_contacts_eid)
    RETURNS SETOF RECORD AS $$
    DECLARE
        temp INT;
    BEGIN
    /*
    REMOVE THEM FROM D+7 BUT ONLY THE ONES IN THE FUTURE
    */
        SELECT temperature INTO temp FROM HealthDeclarations HD 
        WHERE HD.eid = in_eid AND HD.eid = D;

        IF temp IS NULL THEN
            RAISE EXCEPTION 'eid: % did not declare temperature on date: %', in_eid, D;
        ELSIF temp <= 37.5 THEN
            RAISE NOTICE 'eid: % does not have fever, cancelling contact tracing...', in_eid;
            RETURN;
        END IF;

        -- find close contact
        WITH AffectedSessions AS (
            SELECT S.time, S.date, S.room, S.floor
            FROM "Sessions" S
            LEFT JOIN Joins J 
            ON S.time = J.time AND S.date = J.date AND S.room = J.room AND S.floor = J.floor
            WHERE J.eid = in_eid AND S.date BETWEEN D - interval '3 days' AND D;           
        )
        SELECT DISTINCT(J.eid) AS close_contacts_eid
        FROM AffectedSessions S
        LEFT JOIN Joins J
        ON S.time = J.time AND S.date = J.date AND S.room = J.room AND S.floor = J.floor AND J.eid <> in_eid;

        -- remove from D to D+7
        DELETE FROM Joins J
        WHERE J.date BETWEEN D AND D + interval '7 days' AND J.date AFTER CURRENT_DATE AND J.eid IN close_contacts_eid;

    END;
    $$ LANGUAGE plpgsql;

------------------------------------------------------------------------
-- ADMIN (Readapt as necessary.)
------------------------------------------------------------------------
-- non-compliance
    CREATE OR REPLACE FUNCTION non_compliance
    (IN "start" DATE, IN "end" DATE, OUT eid INT, OUT "days" INT)
    RETURNS  SETOF RECORD  AS $$
        -- Teddy
        WITH Declared AS (
            SELECT eid, COUNT(temperature) AS counts
            FROM HealthDeclarations
            WHERE "date" BETWEEN "start" AND "end"
            GROUP BY eid
        )
        SELECT E.eid AS eid, in_end - in_start + 1 - COALESCE(D.counts,0) AS "days"
        FROM Employees E
        LEFT JOIN Declared D ON E.eid = D.eid
        WHERE in_end - in_start + 1 - COALESCE(D.counts,0) > 0;
    $$ LANGUAGE sql;

-- view_booking_report
    CREATE OR REPLACE FUNCTION view_booking_report
    (IN in_start_date DATE, IN in_eid INT)
    RETURNS SETOF RECORD AS $$
        --Petrick
        SELECT "floor", room, "date", "time", 
        CASE 
            WHEN approver_id IS NOT NULL THEN TRUE
            ELSE FALSE
        END AS is_approved
        FROM Sessions
        WHERE "date" > in_start_date AND booker_id = in_eid
        ORDER BY "date" ASC, "time" ASC
    $$ LANGUAGE sql;

-- view_future_meeting
    CREATE OR REPLACE FUNCTION view_future_meeting
    (IN in_start_date DATE, IN in_eid INT)
    RETURNS SETOF RECORD AS $$
        --Petrick
        SELECT "floor", room, "date", "time", 
        FROM Joins
        WHERE "date" > in_start_date AND eid = in_eid
        ORDER BY "date" ASC, "time" ASC
    END
    $$ LANGUAGE sql;

-- view_manager_report
    CREATE OR REPLACE FUNCTION view_manager_report
    (IN in_start_date DATE, IN in_eid INT)
    RETURNS SETOF RECORD AS $$
        --Petrick
        SELECT S."floor", S.room, S."date", S."time", S.booker_id
        FROM Sessions S, MeetingRooms R, Managers M, Employees E
        WHERE in_eid in (SELECT eid FROM M)
        AND "date" > in_start_date
        AND (SELECT did FROM E WHERE eid = in_eid) = (SELECT did FROM R WHERE S."floor" = R."floor" AND S."room" = R."room")
        ORDER BY "date" ASC, "time" ASC
    $$ LANGUAGE sql;

------------------------------------------------------------------------
-- TRIGGERS
------------------------------------------------------------------------
-- Departments
    CREATE OR REPLACE FUNCTION core_departments() RETURNS TRIGGER AS $$
    BEGIN
        RAISE NOTICE 'Some users are trying to delete or update the core departments';
        RETURN NULL;
    END;
    $$ LANGUAGE sql;

    DROP TRIGGER IF EXISTS check_core ON Departments;
    CREATE TRIGGER check_core
    BEFORE DELETE OR UPDATE ON Departments
    FOR EACH ROW WHERE OLD.did IN (1,2,4,5,9) EXECUTE FUNCTION core_departments();

-- Sessions
    CREATE OR REPLACE FUNCTION fever_cannot_book()
    RETURNS TRIGGER AS $$
    BEGIN
        IF has_fever(NEW.booker_id) THEN RETURN NULL;
        ELSE RETURN NEW;
        END IF;
    END;
    $$ LANGUAGE plpgsql;

    DROP TRIGGER IF EXISTS TR_Sessions_BeforeInsert ON Sessions;
    CREATE TRIGGER TR_Sessions_BeforeInsert
    BEFORE INSERT ON Sessions
    FOR EACH ROW EXECUTE FUNCTION fever_cannot_book();


    CREATE OR REPLACE FUNCTION booker_join_meeting()
    RETURNS TRIGGER AS $$
    BEGIN
        INSERT INTO Joins (eid, "time", "date", room, "floor")
        VALUES (NEW.booker_id, NEW.time, NEW.date, NEW.room, NEW.floor);
    END;
    $$ LANGUAGE plpgsql;

    DROP TRIGGER IF EXISTS TR_Sessions_AfterInsert ON Sessions;
    CREATE TRIGGER TR_Sessions_AfterInsert
    AFTER INSERT ON Sessions
    FOR EACH ROW EXECUTE FUNCTION booker_join_meeting();

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

    DROP TRIGGER IF EXISTS TR_HealthDeclarations_AfterInsert On HealthDeclarations;
    CREATE TRIGGER TR_HealthDeclarations_AfterInsert
    AFTER INSERT OR UPDATE ON HealthDeclarations
    FOR EACH ROW EXECUTE FUNCTION check_fever();

-- Joins
    CREATE OR REPLACE FUNCTION capacity_and_fever_check()
    RETURNS TRIGGER AS $$
    DECLARE
        capacity INT;
        joined INT;
        approver_id INT;
    BEGIN
        IF has_fever(NEW.eid) THEN RETURN NULL;
        END IF;

        -- find out the capacity of the room for that day
        SELECT U.capacity INTO capacity
        FROM Updates U
        WHERE U.room = NEW.room AND
              U.floor = NEW.floor AND
              U.date <= NEW.date
        ORDER BY U.date DESC
        LIMIT 1;

        -- find out how many employees have already joined
        SELECT COUNT(*) INTO joined
        FROM Joins J
        WHERE J.time = NEW.time AND
              J.date = NEW.date AND
              J.room = NEW.room AND
              J.floor = NEW.floor;
        
        IF joined = capacity THEN RETURN NULL;
        END IF;

        -- cannot joined approved session
        SELECT S.approver_id INTO approver_id
        FROM "Sessions" S
        WHERE S.room = NEW.room AND
              S.floor = NEW.floor AND
              S.date = NEW.date AND
              S.time = NEW.time;
        
        IF approver_id IS NOT NULL THEN RETURN NULL;
        END IF;

        RETURN NEW;
    END;
    $$ LANGUAGE sql;

    DROP TRIGGER IF EXISTS TR_Joins_BeforeInsert ON Joins;
    CREATE TRIGGER TR_Joins_BeforeInsert
    BEFORE INSERT ON Joins
    FOR EACH ROW EXECUTE FUNCTION capacity_and_fever_check();
