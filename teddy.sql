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