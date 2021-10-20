------------------------------------------------------------------------
------------------------------------------------------------------------
--
-- SCHEMA
--
------------------------------------------------------------------------
------------------------------------------------------------------------


------------------------------------------------------------------------
-- GENERIC TEMPLATE (from L09 Announcements):
------------------------------------------------------------------------
-- (put table name in DROP TABLE below)
-- CREATE TABLE ...;
-- CREATE OR REPLACE FUNCTIONS ...;
-- CREATE TRIGGERS ...;
-- INSERT INTO ... VALUES ...; (in data.sql (?))
------------------------------------------------------------------------


DROP TABLE IF EXISTS

-- ENTITIES (Insert/Delete table names here)
HealthDeclarations,
Employees,
Juniors,
Bookers,
Seniors,
Managers,
Sessions,
Departments,
MeetingRooms,

-- RELATIONS (Insert/Delete table names here)
Books,
Joins,
LocatedIn,
Updates,
Approves,
WorksIn,

CASCADE;


------------------------------------------------------------------------
-- ENTITIES (Add trigger functions and triggers as you deem fit.)
------------------------------------------------------------------------

CREATE TABLE HealthDeclarations (
    -- Teddy 
);


CREATE TABLE Employees (
    -- Teddy
);


CREATE TABLE Juniors (
    -- Teddy
);


CREATE TABLE Bookers (
    -- Simon
    eid INT REFERENCES Employees(eid)
);


CREATE TABLE Seniors (
    -- Simon
    eid INT REFERENCES Booker(eid)
);


CREATE TABLE Managers (
    -- Simon
    eid INT REFERENCES Booker(eid)
);


CREATE TABLE Sessions (
    -- Petrick
);


CREATE TABLE Departments (
    -- Tianle
);


CREATE TABLE MeetingRooms (
    -- Tianle
);


------------------------------------------------------------------------
-- RELATIONSHIPS (Modify and merge relations, add triggers as needed.)
------------------------------------------------------------------------

CREATE TABLE Joins (
    -- Teddy 
);


CREATE TABLE WorksIn (
    -- Teddy
    -- REMARK: Merge into Employees?
);


CREATE TABLE Updates (
    -- Simon
    eid INT REFERENCES Managers(eid),
    `date` DATE,
    floor INT,
    room INT,
    FOREIGN KEY (floor, room) REFERENCES MeetingRooms(floor, room)
);


CREATE TABLE Books (
    -- Petrick
    -- REMARK: Merge into Sessions?
);


CREATE TABLE Approves (
    -- Petrick
    -- REMARK: Merge into Sessions?
);


CREATE TABLE LocatedIn (
    -- Tianle
    -- REMARK: Merge into MeetingRooms?
);

