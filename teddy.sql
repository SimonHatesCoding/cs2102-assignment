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
    (IN in_floor INT, IN in_room INT, IN in_date DATE, IN in_start TIME, IN in_end TIME, IN in_eid INT)
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
        
        SELECT EXTRACT(epoch FROM in_end - in_start)/3600 INTO wanted_sessions;

        IF found_sessions <> wanted_sessions THEN
            RAISE NOTICE 'eid: % does not join all the sessions in floor: % room: % date: % start: % end: %', 
            in_eid, in_floor, in_room, in_date, in_start, in_end;
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
        temp float;
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

-- generate_id
    CREATE OR REPLACE FUNCTION generate_id(OUT eid INT)
    RETURNS INT AS $$
        SELECT MAX(eid)+1 FROM Employees;
    $$ LANGUAGE sql;



-- TEST CASES

-- declare_health
    CREATE OR REPLACE PROCEDURE declare_health
    (IN eid INT, IN temperature float)
    AS $$
        INSERT INTO HealthDeclarations (eid, "date", temperature) VALUES (eid, CURRENT_DATE, temperature) 
        ON CONFLICT (eid, "date") DO UPDATE
            SET temperature = EXCLUDED.temperature;
    $$ LANGUAGE sql;

-- true
select all_sessions_exist(3, 1, '2021-10-21', hour_int_to_time(13), hour_int_to_time(16));
-- false
select all_sessions_exist(3, 1, '2021-10-21', hour_int_to_time(13), hour_int_to_time(17));

-- true
select any_session_exist(3, 1, '2021-10-21', hour_int_to_time(13), hour_int_to_time(17));

-- true
select eid_in_all_sessions(3, 1, '2021-10-21', hour_int_to_time(13), hour_int_to_time(16), 283);
-- false
select eid_in_all_sessions(3, 1, '2021-10-21', hour_int_to_time(13), hour_int_to_time(17), 283);

-- true
select any_session_approved(3, 1, '2021-10-21', hour_int_to_time(13), hour_int_to_time(17));
-- false
select any_session_approved(4, 2, '2021-10-23', hour_int_to_time(9), hour_int_to_time(12));

-- have not declared => true
delete from HealthDeclarations where eid = 1 AND "date" = CURRENT_DATE;
select has_fever(1);

-- declared 37.5 => false
call declare_health(1, 37.5);
select has_fever(1);

-- declared 37.6 => true
call declare_health(2, 37.6);
select has_fever(2);

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

-- valid input + junior
call add_employee('John Elton', '234-234-1234', 'junior', 1);
-- valid input + senior
call add_employee('Albert Elton', '234-234-1234', 'senior', 1);
-- valid input + manager
call add_employee('William Elton', '234-234-1234', 'manager', 1);

-- invalid kind
call add_employee('Anna', '234-234-1234', 'janitor', 1);
-- invalid did
call add_employee('Anna', '234-234-1234', 'janitor', 11);


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
    END;
    $$ LANGUAGE plpgsql;

-- Join valid sessions

-- Join partially approved meetings

-- Join unavailable sessions
