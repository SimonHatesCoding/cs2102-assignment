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
    eid     INT,
    temp    float   NOT NULL,
    `date`  DATE,
    PRIMARY KEY (`date`, eid)
    FOREIGN KEY eid REFERENCES Employees(eid)
);


CREATE TABLE Employees (
    -- Teddy
    eid             INT             PRIMARY KEY,
    ename           VARCHAR(50),
    email           VARCHAR(50),
    resigned_date   DATE,
    did             INT,
    FOREIGN KEY did REFERENCES Departments(did)
);

CREATE TABLE Contacts (
    contact_number  VARCHAR(50),
    eid             INT,
    PRIMARY KEY (eid, contact_number)
    FOREIGN KEY eid REFERENCES Employees(eid)
)

CREATE TABLE Juniors (
    -- Teddy
    eid     INT     PRIMARY KEY,
    FOREIGN KEY eid REFERENCES Employees(eid)
);


CREATE TABLE Bookers (
    -- Simon
    eid     INT     REFERENCES Employees(eid)
);


CREATE TABLE Seniors (
    -- Simon
    eid     INT     REFERENCES Booker(eid)
);


CREATE TABLE Managers (
    -- Simon
    eid     INT     REFERENCES Booker(eid)
);


CREATE TABLE Sessions (
    -- Petrick
);


CREATE TABLE Departments (
    -- Tianle
    did     INT     PRIMARY KEY
    dname   VARCHAR(50)
);


CREATE TABLE MeetingRooms (
    -- Tianle
    room    INT     PRIMARY KEY
    floor   INT     PRIMARY KEY
    rname   VARCHAR(50)
    did     INT,
    FOREIGN KEY did REFERENCES Departments(did)
);


------------------------------------------------------------------------
-- RELATIONSHIPS (Modify and merge relations, add triggers as needed.)
------------------------------------------------------------------------

CREATE TABLE Joins (
    -- Teddy 
    eid     INT
    `time`  TIME
    `date`  DATE
    room    INT
    `floor` INT
    PRIMARY KEY (eid, `time`, `date`, room, `floor`)
    FOREIGN KEY eid REFERENCES Employees(eid)
    FOREIGN KEY (room, `floor`) REFERENCES MeetingRooms(room, `floor`)
);


CREATE TABLE Updates (
    -- Simon
    eid     INT     REFERENCES Managers(eid),
    `date`  DATE,
    floor   INT,
    room    INT,
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

