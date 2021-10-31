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
Departments,
Employees,
HealthDeclarations,
Juniors,
Bookers,
Seniors,
Managers,
Sessions,
MeetingRooms,

-- RELATIONS (Insert/Delete table names here)
Joins,
Updates
-- LocatedIn,   (merged with MeetingRooms)
-- Books,       (merged with Sessions)
-- Approves,    (merged with Sessions)
-- WorksIn      (merged with Employees)

CASCADE;


------------------------------------------------------------------------
-- ENTITIES (Add trigger functions and triggers as you deem fit.)
------------------------------------------------------------------------

CREATE TABLE Departments (
    -- Tianle
    did INT PRIMARY KEY,
    dname VARCHAR(50) NOT NULL
); --before Employees since latter need fk

CREATE TABLE Employees (
    -- Teddy
    eid             INT             PRIMARY KEY,
    ename           VARCHAR(50),
    email           VARCHAR(50),
    resigned_date   DATE,
    did             INT             REFERENCES Departments(did),
    contact         VARCHAR
);

CREATE TABLE HealthDeclarations (
    -- Teddy 
    eid         INT     REFERENCES Employees(eid),
    "date"      DATE,
    temperature float   NOT NULL,
    PRIMARY KEY ("date", eid)
);

CREATE TABLE Juniors (
    -- Teddy
    eid     INT     PRIMARY KEY REFERENCES Employees(eid)
);


CREATE TABLE Bookers (
    -- Simon
    eid     INT     PRIMARY KEY REFERENCES Employees(eid)
);


CREATE TABLE Seniors (
    -- Simon
    eid     INT     PRIMARY KEY REFERENCES Bookers(eid)
);


CREATE TABLE Managers (
    -- Simon
    eid     INT     PRIMARY KEY REFERENCES Bookers(eid)
);

CREATE TABLE MeetingRooms (
    room        INT,
    "floor"     INT,
    rname       VARCHAR(50),
    did         INT,
    PRIMARY KEY (room, "floor"),
    FOREIGN KEY (did) REFERENCES Departments(did)
);

CREATE TABLE Sessions (
    -- Petrick
    "time"          TIME,
    "date"          DATE,
    room            INT,
    "floor"         INT,
    booker_id       INT     NOT NULL,
    approver_id     INT,
    PRIMARY KEY ("time", "date", room, "floor"),
    FOREIGN KEY (booker_id) REFERENCES Bookers(eid),
    FOREIGN KEY (approver_id) REFERENCES Managers(eid),
    FOREIGN KEY (room, "floor") REFERENCES MeetingRooms(room, "floor") ON DELETE CASCADE
);

------------------------------------------------------------------------
-- RELATIONSHIPS (Modify and merge relations, add triggers as needed.)
------------------------------------------------------------------------

CREATE TABLE Joins (
    -- Teddy 
    eid     INT     REFERENCES Employees(eid),
    "time"  TIME,
    "date"  DATE,
    room    INT,
    "floor" INT,
    PRIMARY KEY (eid, "time", "date", room, "floor"),
    FOREIGN KEY (room, "floor") REFERENCES MeetingRooms(room, "floor")
);


CREATE TABLE Updates (
    -- Simon
    eid         INT     REFERENCES Managers(eid),
    "date"      DATE,
    "floor"     INT,
    room        INT,
    capacity    INT     NOT NULL,
    PRIMARY KEY (eid, "date", "floor", room)
    FOREIGN KEY ("floor", room) REFERENCES MeetingRooms("floor", room)
);

