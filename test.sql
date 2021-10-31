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

-- INSERT INTO Departments VALUES
--     -- Tianle
--     (1, 'Marketing'),
--     (2, 'Finance'),
--     (3, 'Operations Management'),
--     (4, 'Human Resource'),
--     (5, 'IT')
-- ;

-- insert into Employees (eid, ename, email, resigned_date, did) values (1, 'Markus Mullan', 'mmullan0@miitbeian.gov.cn', null, 1);

-- CALL add_employee('John', '09876634', 'junior', 1);
-- CALL add_employee('Elton', '89796334', 'senior', 1);
-- CALL add_employee('Mark', '13452345', 'manager', 1);

CREATE OR REPLACE PROCEDURE declare_health
 (IN eid INT, IN "date" DATE, IN temperature float)
AS $$
    INSERT INTO HealthDeclarations (eid, "date", temperature) VALUES (eid, "date", temperature) 
    ON CONFLICT (eid, "date") DO UPDATE
        SET temperature = EXCLUDED.temperature;
$$ LANGUAGE sql;

CALL declare_health(1, '2021-10-19', 37.0);

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

SELECT * FROM non_compliance('2021-09-10'::DATE, '2021-09-20'::DATE);
SELECT * FROM non_compliance('2021-09-10', '2021-09-20');

-- CREATE OR REPLACE PROCEDURE book_room
--  (IN floor_num INT, IN room_num INT, IN dt DATE, IN start_hour INT, IN end_hour INT, IN e_id INT) AS $$
-- DECLARE
--     -- variables here
--     e_temperature FLOAT;
--     h INT;
--     t TIME;
-- BEGIN
--     -- Simon
--     SELECT temperature INTO e_temperature FROM HealthDeclarations WHERE eid = e_id AND dt = CURRENT_DATE;
--     IF e_id NOT IN (SELECT eid FROM Bookers) THEN RAISE EXCEPTION 'Employee % is not authorized to make bookings', e_id;
--     ELSIF e_temperature IS NOT NULL AND e_temperature > 37.5 THEN RAISE EXCEPTION 'Employee % is having a fever (%C)', e_id, e_temperature;
--     ELSIF (floor_num, room_num) NOT IN (SELECT room, floor FROM MeetingRooms) THEN RAISE EXCEPTION '%-% is not found', floor_num, room_num;
--     ELSIF ((end_hour <= start_hour) OR (start_hour NOT BETWEEN 1 AND 24) OR end_hour NOT BETWEEN 1 AND 24) THEN RAISE EXCEPTION 'Invalid hour input: %, %', start_hour, end_hour;
--     ELSIF ((dt < CURRENT_DATE) OR (dt = CURRENT_DATE AND start_hour < date_part('hour', current_timestamp))) THEN RAISE EXCEPTION 'Not allowed to make a booking in the past: %, %', dt, start_hour;

--     ELSE FOR h IN start_hour..end_hour-1 LOOP
--         IF h >= 10 THEN t := CAST(CONCAT(CAST(h AS TEXT), ':00') AS TIME);
--         ELSE t:= CAST(CONCAT('0', CAST(h AS TEXT), ':00') AS TIME);
--         END IF;
--         INSERT INTO Sessions VALUES (t, dt, room_num, floor_num, e_id);
--     END LOOP;

--     END IF;
-- END
-- $$ LANGUAGE plpgsql;

-- CALL book_room(3,1,'2021-10-30',10,12, 4);
-- CALL book_room(3,1,'2021-10-30',10,12, 1);

-- CREATE OR REPLACE PROCEDURE unbook_room
--  (IN floor_num INT, IN room_num INT, IN dt DATE, IN start_hour INT, IN end_hour INT, IN e_id INT) AS $$
-- DECLARE
--     -- variables here
--     h INT;
--     r RECORD;
-- BEGIN
--     -- Simon
--     FOR h IN start_hour..end_hour-1 LOOP
--         IF ((end_hour <= start_hour) OR (start_hour NOT BETWEEN 1 AND 24) OR end_hour NOT BETWEEN 1 AND 24) THEN RAISE EXCEPTION 'Invalid hour input: %, %', start_hour, end_hour;
--         ELSIF ((dt < CURRENT_DATE) OR (dt = CURRENT_DATE AND start_hour < date_part('hour', current_timestamp))) THEN RAISE EXCEPTION 'Not allowed to remove a booking in the past: %, %', dt, start_hour;
--         END IF;

--         SELECT * INTO r FROM Sessions WHERE booker_id = e_id AND floor = floor_num AND room = room_num AND date = dt AND date_part('hour', time) = h;
--         CONTINUE WHEN r IS NULL;

--         DELETE FROM Sessions WHERE booker_id = e_id AND floor = floor_num AND room = room_num AND date = dt AND date_part('hour', time) = h;
--         DELETE FROM Joins WHERE floor = floor_num AND room = room_num AND date = dt AND date_part('hour', time) = h;
--     END LOOP;
-- END
-- $$ LANGUAGE plpgsql;

-- CALL unbook_room(3,1,'2021-10-30',10,12, 4);

-- CREATE OR REPLACE PROCEDURE approve_meeting
--  (IN floor_num INT, IN room_num INT, IN dt DATE, IN start_hour INT, IN end_hour INT, IN e_id INT) AS $$
-- DECLARE
--     -- variables here
--     h INT;
--     dpmt_b INT;
--     dpmt_a INT;
-- BEGIN
--     -- Simon
--     IF e_id NOT IN (SELECT eid FROM Managers) THEN RAISE EXCEPTION '% is not authorized to approve the meeting', e_id;
--     ELSIF ((end_hour <= start_hour) OR (start_hour NOT BETWEEN 1 AND 24) OR end_hour NOT BETWEEN 1 AND 24) THEN RAISE EXCEPTION 'Invalid hour input: %, %', start_hour, end_hour;
--     ELSIF ((dt < CURRENT_DATE) OR (dt = CURRENT_DATE AND start_hour < date_part('hour', current_timestamp))) THEN RAISE EXCEPTION 'Not allowed to remove a booking in the past: %, %', dt, start_hour;

--     ELSE FOR h in start_hour..end_hour-1 LOOP
--         SELECT did INTO dpmt_b FROM Employees WHERE eid = (SELECT booker_id FROM Sessions WHERE floor = floor_num AND room = room_num AND date = dt AND date_part('hour', time) = h);
--         SELECT did INTO dpmt_a FROM Employees WHERE eid = e_id;
--         IF dpmt_b <> dpmt_a THEN RAISE EXCEPTION '% is not in the same department (%) as the booker of %-% at % %h (%)', e_id, dpmt_a, floor_num, room_num, dt, h, dpmt_b;
--         ELSE
--             UPDATE Sessions SET approver_id = e_id WHERE floor = floor_num AND room = room_num AND date = dt AND date_part('hour', time) = h;
--         END IF;
--     END LOOP;

--     END IF;
-- END
-- $$ LANGUAGE plpgsql;

