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
    INSERT INTO HealthDeclarations VALUES (eid, "date", temperature)
$$ LANGUAGE sql;

CALL declare_health(1, '2021-10-19', 36.8)