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


CREATE OR REPLACE PROCEDURE add_department (IN did INT, IN dname VARCHAR(50)) 
AS $$
    INSERT INTO Departments (did, dname) VALUES (did, dname);
$$ LANGUAGE sql;

CALL add_department(6, 'Safety');


CREATE OR REPLACE PROCEDURE remove_department(IN in_did INT， IN in_transfer_did INT)
 -- CANNOT DELETE 1,2,4,5,9; Operations will be transffered into HR; R&D is transffered into IT. 
 -- The rest of departments cannot be deleted. Raise exception if attempts are made.
AS $$
    IF in_did IN (6,7,8) THEN
        DELETE FROM Employees WHERE in_did = .did;
    ELSIF in_did = 3 THEN
        UPDATE Employees SET did = 4 WHERE did = 3;
    ELSIF in_did = 10 THEN
        UPDATE Employees SET did = 5 WHERE did = 10;
    END IF;
    DELETE FROM Departments WHERE did = in_did;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION core_departments() RETURNS TRIGGER AS $$
BEGIN
    RAISE EXCEPTION 'Some users are trying to delete or update the core departments';
    RETURN NULL;
END;
$$ LANGUAGE sql;

CREATE OR REPLACE TRIGGER check_core
BEFORE DELETE OR UPDATE ON Departments
FOR EACH ROW WHERE OLD.did IN (1,2,4,5,9) EXECUTE FUNCTION core_departments();


CREATE OR REPLACE PROCEDURE add_room
 (IN room INT, IN "floor" INT, IN rname VARCHAR(50), IN did INT)
AS $$
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
-- Check whether the manager changes the cap