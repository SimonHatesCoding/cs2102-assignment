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
);


CREATE TABLE Seniors (
    -- Simon
);


CREATE TABLE Managers (
    -- Simon
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

