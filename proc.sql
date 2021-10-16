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


CREATE OR REPLACE PROCEDURE add_employee
 (<param> <type>, <param> <type>, ...)
AS $$
    -- Teddy
$$ LANGUAGE sql;


CREATE OR REPLACE PROCEDURE remove_employee
 (<param> <type>, <param> <type>, ...)
AS $$
    -- Petrick
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


CREATE OR REPLACE FUNCTION book_room
 (<param> <type>, <param> <type>, ...)
RETURNS <type> AS $$
DECLARE
    -- variables here
BEGIN
    -- Simon
END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION unbook_room
 (<param> <type>, <param> <type>, ...)
RETURNS <type> AS $$
DECLARE
    -- variables here
BEGIN
    -- Simon
END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION join_meeting
 (<param> <type>, <param> <type>, ...)
RETURNS <type> AS $$
DECLARE
    -- variables here
BEGIN
    -- Teddy
END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION leave_meeting
 (<param> <type>, <param> <type>, ...)
RETURNS <type> AS $$
DECLARE
    -- variables here
BEGIN
    -- Teddy
END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION approve_meeting
 (<param> <type>, <param> <type>, ...)
RETURNS <type> AS $$
DECLARE
    -- variables here
BEGIN
    -- Simon
END
$$ LANGUAGE plpgsql;


------------------------------------------------------------------------
-- HEALTH (Readapt as necessary.)
------------------------------------------------------------------------


CREATE OR REPLACE FUNCTION declare_health
 (<param> <type>, <param> <type>, ...)
RETURNS <type> AS $$
DECLARE
    -- variables here
BEGIN
    -- Teddy
END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION book_room
 (<param> <type>, <param> <type>, ...)
RETURNS <type> AS $$
DECLARE
    -- variables here
BEGIN
    -- Teddy
END
$$ LANGUAGE plpgsql;


------------------------------------------------------------------------
-- ADMIN (Readapt as necessary.)
------------------------------------------------------------------------


CREATE OR REPLACE FUNCTION non_compliance
 (<param> <type>, <param> <type>, ...)
RETURNS <type> AS $$
DECLARE
    -- variables here
BEGIN
    -- Teddy
END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION view_booking_report
 (<param> <type>, <param> <type>, ...)
RETURNS <type> AS $$
DECLARE
    -- variables here
BEGIN
    -- Petrick
END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION view_future_meeting
 (<param> <type>, <param> <type>, ...)
RETURNS <type> AS $$
DECLARE
    -- variables here
BEGIN
    -- Petrick
END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION view_manager_report
 (<param> <type>, <param> <type>, ...)
RETURNS <type> AS $$
DECLARE
    -- variables here
BEGIN
    -- Petrick
END
$$ LANGUAGE plpgsql;

