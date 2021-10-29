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

DROP FUNCTION contact_tracing;

CREATE OR REPLACE FUNCTION contact_tracing
(IN in_eid INT, IN D DATE)
RETURNS void AS $$
DECLARE
    temp INT;
BEGIN
    -- use the latest health declaration
    SELECT HD.temperature INTO temp
    FROM HealthDeclarations HD
    WHERE HD.eid = in_eid
    ORDER BY "date" DESC
    LIMIT 1;

    IF temp IS NULL THEN 
        raise notice 'Employee with % have never declared temperature' in_eid;
        RETURN;
    END IF

    IF temp <= 37.5 THEN RETURN;
    END IF;

    -- find approved sessions in the past 3 days


    -- get all the eid that join these sessions
    -- remove these eid from sessions in the next 7 days

END;

$$ LANGUAGE plpgsql;

SELECT contact_tracing(1);
