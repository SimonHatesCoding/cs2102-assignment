CREATE OR REPLACE PROCEDURE add_employee
 (IN ename VARCHAR(50), IN contact VARCHAR(50), IN kind VARCHAR(10), IN did INT)
AS $$
 -- Teddy
 -- remove Contacts tables
DECLARE
    email VARCHAR(50);
    eid INT := 0;
BEGIN
    eid := generate_id();   
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

CREATE OR REPLACE FUNCTION has_fever
 (IN in_eid INT, OUT fever BOOLEAN)
RETURNS BOOLEAN AS $$
DECLARE
    declarations INT := 0;
BEGIN
    SELECT COUNT(*) INTO declarations FROM HealthDeclarations WHERE eid = in_eid;

    IF declarations = 0 THEN 
        RAISE EXCEPTION '% has never declared temperature, unable to know whether he/she has fever or not', in_eid;
    END IF;
    
    SELECT CASE WHEN temperature > 37.5 THEN TRUE ELSE FALSE END INTO fever
    FROM HealthDeclarations
    WHERE eid = in_eid
    ORDER BY "date" DESC
    LIMIT 1;
END
$$ LANGUAGE plpgsql;


SELECT has_fever(133);