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
        FROM Sessions
        WHERE "date" = in_date AND
            room = in_room AND
            "floor" = in_floor AND
            "time" BETWEEN in_start AND (in_end - interval '1 min');
        
        SELECT EXTRACT(epoch FROM in_end - in_start)/3600 INTO wanted_sessions;

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
        FROM Sessions
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
        FROM Sessions S
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
            FROM Sessions
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
        WHERE HD.eid = in_eid AND HD.date = CURRENT_DATE;

        IF temp IS NULL THEN
            RAISE NOTICE '% has not declared temperature today, unable to decide whether employee has a fever. 
            Taking a safer approach, employee is assumed to potentially have a fever until the employee declares otherwise', in_eid;
            RETURN TRUE; 
        ELSIF temp > 37.5 THEN
            RETURN TRUE;
        ELSE
            RETURN FALSE;
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
        IF (in_room, in_floor) NOT IN (SELECT room, floor FROM MeetingRooms) THEN 
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

-- generate_id
    CREATE OR REPLACE FUNCTION generate_id(OUT eid INT)
    RETURNS INT AS $$
        SELECT 
        CASE 
            WHEN MAX(eid) IS NULL THEN 1
            ELSE MAX(eid) + 1
        END 
        FROM Employees;
    $$ LANGUAGE sql;

-- check_capacity
    CREATE OR REPLACE FUNCTION check_capacity(IN in_room INT, IN in_floor INT, IN in_date DATE)
    RETURNS INT AS $$ 
        SELECT U.capacity
        FROM Updates U
        WHERE U.date <= in_date AND U.room = in_room AND U.floor = in_floor
        ORDER BY U.date DESC
        LIMIT 1;
    $$ LANGUAGE sql;

-- check_same_dpmt
    CREATE OR REPLACE FUNCTION check_same_dpmt(IN in_floor INT, IN in_room INT, IN in_date DATE, IN start_hour INT, IN end_hour INT, IN in_eid INT)
    RETURNS BOOLEAN AS $$
    DECLARE
        did_a INT;
        did_b INT;
        h INT;
    BEGIN
        FOR h in start_hour..end_hour-1 LOOP
            SELECT did INTO did_b FROM Employees
            WHERE eid = (SELECT booker_id FROM Sessions WHERE floor = in_floor AND room = in_room AND date = in_date AND date_part('hour', time) = h);
            SELECT did INTO did_a FROM Employees WHERE eid = in_eid;
            IF did_b <> did_a THEN RAISE NOTICE '% is not in the same department (%) as the booker of %-% at % %h (%)', in_eid, did_a, in_floor, in_room, in_date, h, did_b;
            RETURN FALSE;
            END IF;
        RETURN TRUE;
        END LOOP;
    END;
    $$ LANGUAGE plpgsql;

-- is_resigned
    CREATE OR REPLACE FUNCTION is_resigned(IN in_eid INT)
    RETURNS BOOLEAN AS $$
    BEGIN
        IF (SELECT resigned_date FROM Employees WHERE eid = in_eid) IS NOT NULL
            THEN RAISE NOTICE '% is already resigned', in_eid;
            RETURN TRUE;
        END IF;
        RETURN FALSE;
    END;
    $$ LANGUAGE plpgsql;

------------------------------------------------------------------------
-- BASIC (Readapt as necessary.)
------------------------------------------------------------------------
-- add_department
    CREATE OR REPLACE PROCEDURE add_department
    (IN in_did INT, IN in_dname VARCHAR(50)) 
    AS $$
        INSERT INTO Departments VALUES (in_did, in_dname);
    $$ LANGUAGE sql;

-- remove_department
    CREATE OR REPLACE PROCEDURE remove_department
    (IN in_did1 INT, IN in_did2 INT)
    AS $$
    BEGIN
        IF in_did1 IN (SELECT did FROM Departments) AND 
            in_did2 IN (SELECT did FROM Departments) THEN
        UPDATE Employees SET did = in_did2 WHERE did = in_did1;
        UPDATE MeetingRooms SET did = in_did2 WHERE did = in_did1;
        DELETE FROM Departments WHERE did = in_did1;
        END IF;
    END;
    $$ LANGUAGE plpgsql;

-- add_room
    CREATE OR REPLACE PROCEDURE add_room
    (IN in_room INT, IN "in_floor" INT, IN in_rname VARCHAR(50), IN in_did INT)
    AS $$
        INSERT INTO MeetingRooms VALUES (in_room, "in_floor", in_rname, in_did);
    $$ LANGUAGE sql;

-- change_capacity
    CREATE OR REPLACE PROCEDURE change_capacity
    (IN in_room INT, IN in_floor INT, IN in_capacity INT, IN in_date DATE, IN in_eid INT)
    AS $$
    BEGIN
        IF is_past(in_date, 0) THEN NULL;
        ELSIF NOT in_eid IN (SELECT eid FROM Managers) THEN NULL;
        ELSIF in_date IN (SELECT "date" FROM Updates WHERE room = in_room AND "floor" = "in_floor") THEN 
            UPDATE Updates SET "date" = in_date, capacity = in_capacity 
            WHERE room = in_room AND "floor" = "in_floor";
        ELSE
            INSERT INTO Updates VALUES(in_eid, in_date, in_floor, in_room, in_capacity);  
        END IF; 
    END;
    $$ LANGUAGE plpgsql;

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
        SELECT concat(eid, '@hotmail.com') INTO email;
        INSERT INTO Employees (eid, ename, email, did, contact) 
        VALUES (eid, in_ename, email, in_did, in_contact);
        
        IF kind NOT IN ('junior', 'senior', 'manager') THEN
            RAISE NOTICE 'Invalid type of employee';
        END IF;

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
    BEGIN
        IF in_eid NOT IN (SELECT eid FROM Employees) THEN 
            -- ignore if eid does not exist
            RAISE EXCEPTION 'Employee % does not exist.', in_eid;

        ELSE
            -- employee exists, so:
            -- (1) update their resigned_date
            UPDATE Employees SET resigned_date = in_date WHERE eid = in_eid;

            -- (2) remove them from joined meetings after resigned date
            DELETE FROM Joins WHERE eid = in_eid AND "date" >= in_date;

            IF in_eid IN (SELECT eid FROM Bookers) THEN
                -- Bookers routine: delete Sessions after resigned date
                -- (Joining participants will ON CASCADE DELETE)
                DELETE FROM Sessions WHERE booker_id = in_eid AND "date" >= in_date;
            END IF;
        END IF;
    END;
    $$ LANGUAGE plpgsql;  

------------------------------------------------------------------------
-- CORE (Readapt as necessary.)
------------------------------------------------------------------------
-- search_room
    CREATE OR REPLACE FUNCTION search_room
    (IN in_capacity INT, IN in_date DATE, IN start_hour INT, IN end_hour INT)
    RETURNS TABLE(floor_num INT, room_num INT, department_id INT, capacity INT) AS $$
    BEGIN
        IF NOT is_valid_hour(start_hour, end_hour) THEN RETURN;
        ELSIF is_past(in_date, start_hour) THEN RETURN;
        END IF;

        RETURN QUERY 
        SELECT M.floor, M.room, M.did, check_capacity(M.room, M.floor, in_date)
        FROM MeetingRooms M
        WHERE in_capacity <= check_capacity(M.room, M.floor, in_date) AND
<<<<<<< HEAD
              NOT any_session_exist(M.floor, M.room, in_date, hour_int_to_time(start_hour), hour_int_to_time(end_hour));
=======
              NOT any_session_exist(M.floor, M.room, in_date, hour_int_to_time(start_hour), 
                hour_int_to_time(end_hour));
>>>>>>> edb101d4452d5b509ecec5f94d46d6b28d6210f3
    END;
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
        ELSIF any_session_exist(in_floor, in_room, in_date, hour_int_to_time(start_hour), hour_int_to_time(end_hour)) THEN RETURN; -- check 

        ELSE FOR h IN start_hour..end_hour-1 LOOP -- all or nothing
            t:= hour_int_to_time(h);
            INSERT INTO Sessions (booker_id, "time", "date", room, "floor") VALUES (in_eid, t, in_date, in_room, in_floor);
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
        ELSIF NOT all_sessions_exist(in_floor, in_room, in_date, hour_int_to_time(start_hour), hour_int_to_time(end_hour)) THEN RETURN;
        END IF;

        FOR h IN start_hour..end_hour-1 LOOP
            DELETE FROM Sessions WHERE booker_id = in_eid AND floor = in_floor AND room = in_room AND date = in_date AND date_part('hour', time) = h;
        END LOOP;
    END;
    $$ LANGUAGE plpgsql;

-- join_meeting
    CREATE OR REPLACE PROCEDURE join_meeting
    (IN in_floor INT, IN in_room INT, IN in_date DATE, IN start_hour INT, IN end_hour INT, IN in_eid INT)
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
    END;
    $$ LANGUAGE plpgsql;

-- leave_meeting
    CREATE OR REPLACE PROCEDURE leave_meeting
    (IN in_floor INT, IN in_room INT, IN in_date DATE, IN start_hour INT, IN end_hour INT, IN in_eid INT)
    AS $$
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
    END;
    $$ LANGUAGE plpgsql;

-- approve_meeting
    CREATE OR REPLACE PROCEDURE approve_meeting
    (IN in_floor INT, IN in_room INT, IN in_date DATE, IN start_hour INT, IN end_hour INT, IN in_eid INT) AS $$
    DECLARE
    -- variables here
        h INT;
    BEGIN
        -- Simon
        -- Check if the meeting is alr approved
        IF in_eid NOT IN (SELECT eid FROM Managers) THEN RAISE EXCEPTION '% is not authorized to approve the meeting', in_eid;
        ELSIF NOT is_valid_hour(start_hour, end_hour) THEN RETURN;
        ELSIF is_past(in_date, start_hour) THEN RETURN;
        ELSIF NOT all_sessions_exist(in_floor, in_room, in_date, hour_int_to_time(start_hour), hour_int_to_time(end_hour)) THEN RETURN;
        ELSIF any_session_approved(in_floor, in_room, in_date, hour_int_to_time(start_hour), hour_int_to_time(end_hour)) THEN RETURN;
        ELSIF NOT check_same_dpmt(in_floor, in_room, in_date, start_hour, end_hour, in_eid) THEN RETURN;
        END IF;

        FOR h in start_hour..end_hour-1 LOOP
            UPDATE Sessions SET approver_id = in_eid WHERE floor = in_floor AND room = in_room AND date = in_date AND date_part('hour', time) = h;
        END LOOP;

    END;
    $$ LANGUAGE plpgsql;

-- reject_meeting
    CREATE OR REPLACE PROCEDURE reject_meeting
    (IN in_floor INT, IN in_room INT, IN in_date DATE, IN start_hour INT, IN end_hour INT, IN in_eid INT) AS $$
    DECLARE
    -- variables here
        h INT;
        did_b INT;
        did_a INT;
    BEGIN
        -- Simon
        -- Check if the meeting is alr approved
        IF in_eid NOT IN (SELECT eid FROM Managers) THEN RAISE EXCEPTION '% is not authorized to reject the meeting', in_eid;
        ELSIF NOT is_valid_hour(start_hour, end_hour) THEN RETURN;
        ELSIF is_past(in_date, start_hour) THEN RETURN;
        ELSIF NOT all_sessions_exist(in_floor, in_room, in_date, hour_int_to_time(start_hour), hour_int_to_time(end_hour)) THEN RETURN;
        ELSIF any_session_approved(in_floor, in_room, in_date, hour_int_to_time(start_hour), hour_int_to_time(end_hour)) THEN RETURN;
        ELSIF NOT check_same_dpmt(in_floor, in_room, in_date, start_hour, end_hour, in_eid) THEN RETURN;
        END IF;

        FOR h in start_hour..end_hour-1 LOOP
            DELETE FROM Sessions WHERE floor = in_floor AND room = in_room AND date = in_date AND date_part('hour', time) = h;
        END LOOP;

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
    (IN in_eid INT, IN D DATE)
    RETURNS TABLE(out_eid INT) AS $$
    DECLARE
        temp INT;
    BEGIN
        SELECT temperature INTO temp FROM HealthDeclarations HD 
        WHERE HD.eid = in_eid AND HD.date = D;

        IF temp IS NULL THEN
            RAISE EXCEPTION 'eid: % did not declare temperature on date: %', in_eid, D;
        ELSIF temp <= 37.5 THEN
            RAISE NOTICE 'eid: % does not have fever, cancelling contact tracing...', in_eid;
            RETURN;
        END IF;

        -- find close contact
        WITH CloseContacts AS (
            SELECT J2.eid
            FROM Joins J1, Joins J2
            WHERE J1.time = J2.time AND J1.date = J2.date AND J1.room = J2.room AND J1.floor = J2.floor
                  AND J1.eid = in_eid AND J1.date BETWEEN D - interval '3 days' AND D AND J1.eid <> J2.eid 
        ) 
        DELETE FROM Joins J
        WHERE (J.date BETWEEN D AND D + interval '7 days') AND (J.date >= CURRENT_DATE) 
                AND J.eid IN (SELECT * FROM CloseContacts);

        RETURN QUERY 
        SELECT J2.eid
        FROM Joins J1, Joins J2
        WHERE J1.time = J2.time AND J1.date = J2.date AND J1.room = J2.room AND J1.floor = J2.floor
                AND J1.eid = in_eid AND J1.date BETWEEN D - interval '3 days' AND D AND J1.eid <> J2.eid;

    END;
    $$ LANGUAGE plpgsql;

------------------------------------------------------------------------
-- ADMIN (Readapt as necessary.)
------------------------------------------------------------------------
-- non-compliance
    CREATE OR REPLACE FUNCTION non_compliance
    (IN in_start DATE, IN in_end DATE, OUT eid INT, OUT "days" INT)
    RETURNS  SETOF RECORD  AS $$
        -- Teddy
        WITH Declared AS (
            SELECT eid, COUNT(temperature) AS counts
            FROM HealthDeclarations
            WHERE "date" BETWEEN in_start AND in_end
            GROUP BY eid
        )
        SELECT E.eid AS eid, in_end - in_start + 1 - COALESCE(D.counts,0) AS "days"
        FROM Employees E
        LEFT JOIN Declared D ON E.eid = D.eid
        WHERE in_end - in_start + 1 - COALESCE(D.counts,0) > 0;
    $$ LANGUAGE sql;

-- view_booking_report
    CREATE OR REPLACE FUNCTION view_booking_report
    (IN in_start_date DATE, IN in_eid INT, OUT out_floor INT, OUT out_room INT, OUT out_date DATE, OUT out_time TIME, OUT is_approved TEXT)
    RETURNS SETOF RECORD AS $$
        --Petrick
        SELECT "floor", room, "date", "time", 
        CASE 
            WHEN approver_id IS NOT NULL THEN 'Yes'  -- is approved
            ELSE 'No (Pending)'                      -- waiting for approval
        END AS is_approved
        FROM Sessions
        WHERE "date" >= in_start_date AND booker_id = in_eid
        ORDER BY "date" ASC, "time" ASC;
    $$ LANGUAGE sql;

-- view_future_meeting
    CREATE OR REPLACE FUNCTION view_future_meeting
    (IN in_start_date DATE, IN in_eid INT, OUT out_floor INT, OUT out_room INT, OUT out_date DATE, OUT out_time TIME)
    RETURNS SETOF RECORD AS $$
        --Petrick
        SELECT J.floor, J.room, J.date, J.time
        FROM Sessions S LEFT JOIN Joins J 
            ON S.time = J.time AND S.date = J.date AND S.room = J.room AND S.floor = J.floor
        WHERE J.date >= in_start_date AND J.eid = in_eid AND S.approver_id IS NOT NULL
        ORDER BY J.date ASC, J.time ASC;
    $$ LANGUAGE sql;

-- view_manager_report
    CREATE OR REPLACE FUNCTION view_manager_report
    (IN in_start_date DATE, IN in_eid INT)
    RETURNS TABLE("floor" INT, room INT, "date" DATE, "time" TIME, eid INT) AS $$
        --Petrick
    BEGIN
        RETURN QUERY
        SELECT S.floor, S.room, S.date, S.time, S.booker_id
        FROM Sessions S
        WHERE in_eid in (SELECT M.eid FROM Managers M)
        AND S.date >= in_start_date AND S.approver_id IS NULL
        AND (SELECT did FROM Employees E WHERE E.eid = in_eid) = (SELECT did FROM MeetingRooms R WHERE S.floor = R.floor AND S.room = R.room)
        ORDER BY S.date ASC, S.time ASC;
    END;
    $$ LANGUAGE plpgsql;

------------------------------------------------------------------------
-- TRIGGERS
------------------------------------------------------------------------
-- Sessions
  -- TR_Sessions_BeforeInsert
    CREATE OR REPLACE FUNCTION cannot_book()
    RETURNS TRIGGER AS $$
    BEGIN
        IF has_fever(NEW.booker_id) THEN RETURN NULL;
        ELSIF is_resigned(NEW.booker_id) THEN RETURN NULL;
        ELSIF NEW.booker_id NOT IN (SELECT eid FROM Bookers) THEN RAISE NOTICE 'Employee % is not authorized to make bookings', in_eid;
        RETURN NULL;
        ELSE RETURN NEW;
        END IF;
    END;
    $$ LANGUAGE plpgsql;

    DROP TRIGGER IF EXISTS TR_Sessions_BeforeInsert ON Sessions;
    CREATE TRIGGER TR_Sessions_BeforeInsert
    BEFORE INSERT ON Sessions
    FOR EACH ROW EXECUTE FUNCTION cannot_book();


  -- TR_Sessions_AfterInsert
    CREATE OR REPLACE FUNCTION booker_join_meeting()
    RETURNS TRIGGER AS $$
    BEGIN
        INSERT INTO Joins (eid, "time", "date", room, "floor")
        VALUES (NEW.booker_id, NEW.time, NEW.date, NEW.room, NEW.floor);
        RETURN NULL;
    END;
    $$ LANGUAGE plpgsql;

    DROP TRIGGER IF EXISTS TR_Sessions_AfterInsert ON Sessions;
    CREATE TRIGGER TR_Sessions_AfterInsert
    AFTER INSERT ON Sessions
    FOR EACH ROW EXECUTE FUNCTION booker_join_meeting();

  -- TR_Sessions_BeforeUpdate
    CREATE OR REPLACE FUNCTION cannot_approve()
    RETURNS TRIGGER AS $$
    DECLARE
        booker_did INT;
        approver_did INT;
    BEGIN
        IF NEW.approver_id NOT IN (SELECT eid FROM Managers) THEN 
            RAISE EXCEPTION '% is not authorized to approve the meeting', in_eid;
            RETURN OLD;
        ELSIF is_resigned(NEW.approver_id) THEN RETURN NULL;
        END IF;

        SELECT did INTO booker_did FROM Employees
        WHERE eid = NEW.booker_id;
        SELECT did INTO approver_did FROM Employees 
        WHERE eid = NEW.approver_id;

        IF booker_did <> approver_did THEN 
            RAISE EXCEPTION '% is not in the same department (%) as the booker of %-% at % %h (%)', 
                in_eid, did_a, in_floor, in_room, in_date, h, did_b;
            RETURN OLD;
        END IF;
        
        RETURN NEW;
    END;
    $$ LANGUAGE plpgsql;

    DROP TRIGGER IF EXISTS TR_Sessions_BeforeUpdate ON Sessions;
    CREATE TRIGGER TR_Sessions_BeforeUpdate
    BEFORE UPDATE ON Sessions
    FOR EACH ROW EXECUTE FUNCTION cannot_approve();

-- HealthDeclarations
  -- TR_HealthDeclarations_AfterInsert
    CREATE OR REPLACE FUNCTION check_fever()
    RETURNS TRIGGER AS $$
    BEGIN
        -- no fever
        IF NEW.temperature <= 37.5 THEN RETURN NULL;
        END IF;

        -- if the employee is the booker -> cancel future sessions
        IF NEW.eid IN (SELECT * FROM Bookers) THEN
            DELETE FROM Sessions WHERE booker_id = NEW.eid AND "date" >= NEW.date;
        END IF;

        -- remove employee from future sessions
        DELETE FROM Joins WHERE eid = NEW.eid AND "date" >= NEW.date;

        -- call contact tracing
        PERFORM contact_tracing(NEW.eid, NEW.date);
        RETURN NULL;
    END;
    $$ LANGUAGE plpgsql;

  -- TR_HealthDeclarations_BeforeInsert
    DROP TRIGGER IF EXISTS TR_HealthDeclarations_AfterInsert On HealthDeclarations;
    CREATE TRIGGER TR_HealthDeclarations_AfterInsert
    AFTER INSERT OR UPDATE ON HealthDeclarations
    FOR EACH ROW EXECUTE FUNCTION check_fever();

    CREATE OR REPLACE FUNCTION validate_date()
    RETURNS TRIGGER AS $$
    BEGIN
        IF NEW.date > CURRENT_DATE THEN RETURN NULL;
        END IF;

        RETURN NEW;
    END;
    $$ LANGUAGE plpgsql;

    DROP TRIGGER IF EXISTS TR_HealthDeclarations_BeforeInsert On HealthDeclarations;
    CREATE TRIGGER TR_HealthDeclarations_BeforeInsert
    BEFORE INSERT ON HealthDeclarations
    FOR EACH ROW EXECUTE FUNCTION validate_date();

-- Joins
  -- TR_Joins_BeforeInsert
    CREATE OR REPLACE FUNCTION cannot_join()
    RETURNS TRIGGER AS $$
    DECLARE
        capacity INT;
        joined INT;
        approver_id INT;
    BEGIN
        IF has_fever(NEW.eid) THEN RETURN NULL;
        ELSIF is_resigned(NEW.eid) THEN RETURN NULL;
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
        FROM Sessions S
        WHERE S.room = NEW.room AND
              S.floor = NEW.floor AND
              S.date = NEW.date AND
              S.time = NEW.time;
        
        IF approver_id IS NOT NULL THEN RETURN NULL;
        END IF;

        RETURN NEW;
    END;
    $$ LANGUAGE plpgsql;

    DROP TRIGGER IF EXISTS TR_Joins_BeforeInsert ON Joins;
    CREATE TRIGGER TR_Joins_BeforeInsert
    BEFORE INSERT ON Joins
    FOR EACH ROW EXECUTE FUNCTION cannot_join();

  -- TR_Joins_AfterDelete
    CREATE OR REPLACE FUNCTION booker_leave_meeting()
    RETURNS TRIGGER AS $$
    -- if booker leave a meeting, cancel the meeting
    BEGIN
        IF NEW.eid NOT IN (SELECT * FROM Bookers) THEN RETURN NULL;
        END IF;

        DELETE FROM Sessions S
        WHERE S.booker_id = NEW.eid AND
              S.date = NEW.date AND
              S.time = NEW.time AND
              S.floor = NEW.floor AND
              S.room = NEW.room;
        
        RETURN NULL;
    END;
    $$ LANGUAGE plpgsql;

    DROP TRIGGER IF EXISTS TR_Joins_AfterDelete ON Joins;
    CREATE TRIGGER TR_Joins_AfterDelete
    AFTER DELETE ON Joins
    FOR EACH ROW EXECUTE FUNCTION booker_leave_meeting();

-- Updates
  -- TR_Updates_AfterInsert
    CREATE OR REPLACE FUNCTION remove_exceeding_capacity()
    RETURNS TRIGGER AS $$
    BEGIN
        WITH D AS (
            SELECT S.date AS "date", S.time AS "time"
            FROM Sessions S
            LEFT JOIN Joins J
            ON S.time = J.time AND S.date = J.date AND S.room = J.room AND S.floor = J.floor
            WHERE S.date >= NEW.date AND S.room = NEW.room AND S.floor = NEW.floor
            GROUP BY (S.date, S.time)
            HAVING COUNT(J.eid) > NEW.capacity
        )
        DELETE FROM Sessions S
        WHERE S.room = NEW.room AND S.floor = NEW.floor AND
              (S.date, S.time) IN (SELECT * FROM D);
        RETURN NULL;
    END;
    $$ LANGUAGE plpgsql;

    DROP TRIGGER IF EXISTS TR_Updates_AfterInsert ON Updates;
    CREATE TRIGGER TR_Updates_AfterInsert
    AFTER INSERT ON Updates
    FOR EACH ROW EXECUTE FUNCTION remove_exceeding_capacity();

    CREATE OR REPLACE FUNCTION cannot_update()
    RETURNS TRIGGER AS $$
    BEGIN
        IF is_resigned(NEW.approver_id) THEN RETURN NULL;
        END IF;
    END;
    $$ LANGUAGE plpgsql;
    
    DROP TRIGGER IF EXISTS TR_Updates_BeforeUpdate ON Updates;
    CREATE TRIGGER TR_Updates_BeforeUpdate
    BEFORE UPDATE ON Updates
    FOR EACH ROW EXECUTE FUNCTION cannot_update();