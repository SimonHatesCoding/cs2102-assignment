-- proc format
------------------------------------------------------------------------
-- BASIC (Readapt as necessary.)
------------------------------------------------------------------------
add_department(IN in_did INT, IN in_dname VARCHAR(50))
remove_department(IN in_did1 INT, IN in_did2 INT)
add_room(IN in_room INT, IN "in_floor" INT, IN in_rname VARCHAR(50), IN in_did INT)
change_capacity(IN in_room INT, IN in_floor INT, IN in_capacity INT, IN in_date DATE, IN in_eid INT)
add_employee(IN in_ename VARCHAR(50), IN in_contact VARCHAR(50), IN kind VARCHAR(10), IN in_did INT)
remove_employee(IN in_eid INT, IN in_date DATE)
------------------------------------------------------------------------
-- CORE (Readapt as necessary.)
------------------------------------------------------------------------
search_room(IN in_capacity INT, IN in_date DATE, IN start_hour INT, IN end_hour INT)
book_room(IN in_floor INT, IN in_room INT, IN in_date DATE, IN start_hour INT, IN end_hour INT, IN in_eid INT)
unbook_room(IN in_floor INT, IN in_room INT, IN in_date DATE, IN start_hour INT, IN end_hour INT, IN in_eid INT)
join_meeting(IN in_floor INT, IN in_room INT, IN in_date DATE, IN start_hour INT, IN end_hour INT, IN in_eid INT)
leave_meeting(IN in_floor INT, IN in_room INT, IN in_date DATE, IN start_hour INT, IN end_hour INT, IN in_eid INT)
approve_meeting(IN in_floor INT, IN in_room INT, IN in_date DATE, IN start_hour INT, IN end_hour INT, IN in_eid INT)
reject_meeting(IN in_floor INT, IN in_room INT, IN in_date DATE, IN start_hour INT, IN end_hour INT, IN in_eid INT)
------------------------------------------------------------------------
-- HEALTH (Readapt as necessary.)
------------------------------------------------------------------------
declare_health(IN eid INT, IN "date" DATE, IN temperature float)
contact_tracing(IN in_eid INT, IN D DATE)
------------------------------------------------------------------------
-- ADMIN (Readapt as necessary.)
------------------------------------------------------------------------
non-compliance(IN in_start DATE, IN in_end DATE, OUT eid INT, OUT "days" INT)
view_booking_report(IN in_start_date DATE, IN in_eid INT, OUT out_floor INT, OUT out_room INT, OUT out_date DATE, OUT out_time TIME, OUT is_approved TEXT)
view_future_meeting(IN in_start_date DATE, IN in_eid INT, OUT out_floor INT, OUT out_room INT, OUT out_date DATE, OUT out_time TIME)
view_manager_report(IN in_start_date DATE, IN in_eid INT)


-- Week 1

-- Big week: 
-- Company decides to set up a new “Secret Department” (42).The new department will have a new room 42 at level 10 with the name “Secret Meeting Room”.
-- Teddy is hired as the manager in the department. 
-- Simon is hired as a senior in the department.
-- Petrick is hired as a manager in the Legal department.
-- Tianle is hired as a junior in the HR department.

DROP TRIGGER IF EXISTS TR_HealthDeclarations_BeforeInsert On HealthDeclarations;

CALL add_department(42, 'Secret Department');
CALL add_room(42, 10, 'Secret Meeting Room', 42);

CALL add_employee('Teddy', '777-777-7777', 'manager', 42); 
--Teddy will have eid=401
CALL add_employee('Simon', '888-888-8888', 'senior', 42); 
--Simon will have eid=402
CALL add_employee('Petrick', '999-999-9999', 'manager', 9); 
--Petrick will have eid=403
CALL add_employee('Tianle', '111-111-1111', 'junior', 4); 
--Tianle will have eid=404

SELECT * FROM non_compliance(CURRENT_DATE, CURRENT_DATE);
-- new employess have not declared health

CALL change_capacity(42, 10, 4, '2021-11-10', 401);
SELECT * FROM Updates WHERE floor = 10;

-- SHOW CHANGES USING:

SELECT * FROM Departments WHERE did = 42;
SELECT * FROM MeetingRooms WHERE did = 42;
SELECT * FROM Employees WHERE eid > 400;


-- R&D Department (did 10) is removed → all employees in R&D now belong to the “Secret Department” (did 42).
	
CALL remove_department(10, 42);

SELECT * FROM Updates WHERE floor = 10;

-- SHOW CHANGES USING

SELECT * FROM Departments WHERE did = 10; 
--empty
SELECT * FROM MeetingRooms WHERE did = 10; 
--empty
SELECT * FROM Employees WHERE did = 10; 
--empty

SELECT * FROM Departments WHERE did = 42;
SELECT * FROM MeetingRooms WHERE did = 42;
SELECT * FROM Employees WHERE did = 42;
-- Teddy, the manager, wants to call a meeting for all managers in the “Secret Department”, a total of 5 people. (2pm-4pm on 10 Nov)

-- Teddy tries to search for an available 5pax room for 2pm-4pm on 10 Nov

SELECT search_room(5, '2021-11-10', 14, 16);
--no entry

-- Teddy realizes capacity is capped at 4 due to recent government advisory. Teddy invites only three managers instead.

SELECT search_room(4, '2021-11-10', 14, 16);
--the following entry should exist: (10, 42, 42, 4)
--meaning: 
--room no. 42 @ floor 01 belonging to Secret Department (did:42) can be 
--booked for max 4 ppl

CALL book_room(10, 42, '2021-11-10', 14, 16, 401);
CALL declare_health(401, CURRENT_DATE, 36.8);
CALL book_room(10, 42, '2021-11-10', 14, 16, 401);
    
-- Three managers joined the meeting. 

--in this demo, the managers are 19, 119, 219
CALL join_meeting(10, 42, '2021-11-10', 14, 16, 19);
CALL join_meeting(10, 42, '2021-11-10', 14, 16, 119);
CALL join_meeting(10, 42, '2021-11-10', 14, 16, 219);

-- One realizes he has a dental appointment, and leaves the meeting.

--let's say eid=19 needs to go
CALL leave_meeting(10, 42, '2021-11-10', 14, 16, 19);

-- Teddy wants to make full use of capacity, and asks Simon to join the meeting.

CALL join_meeting(10, 42, '2021-11-10', 14, 16, 402);
CALL declare_health(402, CURRENT_DATE, 36.5);
CALL join_meeting(10, 42, '2021-11-10', 14, 16, 402);

-- Teddy approves his own meeting.

SELECT * FROM view_booking_report('2021-11-10', 401);
SELECT * FROM view_future_meeting('2021-11-10', 401);

CALL approve_meeting(10, 42, '2021-11-10', 14, 16, 401);

-- Simon checks that he has a meeting in the future.

SELECT * FROM view_future_meeting('2021-11-10', 402);



-- Teddy calls a second meeting for Manager in Legal (Petrick), a Manager in Marketing and a Manager in Finance (book_rooms 2pm-4pm on 11 Nov)

-- The other 3 managers join the meeting.

SELECT search_room(4, '2021-11-11', 14, 16);
--the following entry should exist: (10, 42, 42, 4)

CALL book_room(10, 42, '2021-11-11', 14, 16, 401);

CALL join_meeting(10, 42, '2021-11-11', 14, 16, 403); -- Petrick
CALL declare_health(403, CURRENT_DATE, 36.5);
CALL join_meeting(10, 42, '2021-11-11', 14, 16, 403); -- Petrick
CALL join_meeting(10, 42, '2021-11-11', 14, 16, 20); -- Marketing Manager
CALL join_meeting(10, 42, '2021-11-11', 14, 16, 111); -- Finance Manager

-- Teddy realizes he has an appointment with a gym coach during 2-3pm, cancels the booking, makes another booking from 4-5.

SELECT * FROM view_booking_report('2021-11-11', 401);

CALL unbook_room(10, 42, '2021-11-11', 14, 16, 401);
CALL book_room(10, 42, '2021-11-11', 16, 17, 401);

SELECT * FROM view_booking_report('2021-11-11', 401);

-- The other 3 managers rejoin meeting

CALL join_meeting(10, 42, '2021-11-11', 16, 17, 403); 
CALL join_meeting(10, 42, '2021-11-11', 16, 17, 20); 
CALL join_meeting(10, 42, '2021-11-11', 16, 17, 111); 

-- Teddy approves meeting

SELECT * FROM view_manager_report('2021-11-11', 401);
CALL approve_meeting(10, 42, '2021-11-11', 16, 17, 401);


-- Simon wants to call a meeting with Teddy and the other two managers in 42. (3-5pm 11 Nov)

-- Simon failed booking; he did not check availability for that room.

CALL book_room(10, 42, '2021-11-11', 15, 17, 402);
-- raises exception 'There are already some book sessions…'

-- Check for available room, book 3-5pm 11 Nov

SELECT search_room(4, '2021-11-11', 15, 17);
--the following entry should exist: (10, 01, 42, 4)

CALL book_room(10, 01, '2021-11-11', 15, 17, 402);
SELECT * FROM view_booking_report('2021-11-11', 402);

-- Simon asks Teddy to review, Teddy views his report.

-- view from the date of demo '2021-11-11' onwards.
SELECT * from view_manager_report('2021-11-11', 401);
--the following entry/ies should exist: 
--(10, 01, '2021-11-11', 15, 402)
--(10, 01, '2021-11-11', 16, 402)

-- Teddy says he cannot do 4-5 cuz he has another meeting.
-- Simon unbooks 3-5pm.
-- Simon makes another booking 5-7pm.

CALL unbook_room(10, 01, '2021-11-11', 15, 17, 402);
CALL book_room(10, 01, '2021-11-11', 17, 19, 402);

SELECT * FROM view_booking_report('2021-11-11', 402);

-- Teddy views his report again. He thinks he needs a break between meetings. 
-- He only approves 6-7 but rejects 5-6.

-- view from the date of demo '2021-11-09' onwards.
SELECT * FROM view_manager_report('2021-11-09', 401);
--the following new entry/ies should exist now: 
--(10, 01, '2021-11-11', 16, 402)
--(10, 01, '2021-11-11', 17, 402)

CALL join_meeting(10, 01, '2021-11-11', 18, 19, 401);
CALL join_meeting(10, 01, '2021-11-11', 18, 19, 119);
CALL join_meeting(10, 01, '2021-11-11', 18, 19, 219);

CALL approve_meeting(10, 01, '2021-11-11', 18, 19, 401);
CALL reject_meeting(10, 01, '2021-11-11', 17, 18, 401);

SELECT * FROM view_future_meeting('2021-11-11', 402);
-- Only 1 meeting from 17 to 18
SELECT * FROM view_future_meeting('2021-11-11', 401);
-- Many meetings for manager



-- The manager (13) in HR (4) calls a meeting with a junior employee Tianle (404) (5-6pm 12 Nov)

-- Tianle tries to set up the meeting but fails.

CALL book_room(04, 01, '2021-11-12', 17, 18, 404);
-- raises exception: '404 is not authorized to make bookings'

-- Manager makes the booking.

--skip search_room: data.sql has no meeting booked for 12 Nov, thus safe.
CALL book_room(04, 01, '2021-11-12', 17, 18, 13);
CALL join_meeting(04, 01, '2021-11-12', 17, 18, 404); -- Tianle
CALL declare_health(404, CURRENT_DATE, 36.3);
CALL join_meeting(04, 01, '2021-11-12', 17, 18, 404);

-- The manager forgot to approve the meeting. Tianle, as an eager junior, tried to approve the meeting but realized he had no authority.

CALL approve_meeting(04, 01, '2021-11-12', 17, 18, 404);
-- raises exception: '404 is not authorized to approve the meeting'

-- Tianle asks Petrick to approve the meeting since he is a manager, but Petrick failed since he is stupid in a different department.

CALL approve_meeting(04, 01, '2021-11-12', 17, 18, 403);
-- raises exception: '403 is not in the same department (9) as the booker of 04-01 at 2021-11-12 17h (4)'

-- Petrick notifies the HR Managers, one of whom eventually approves meeting

CALL approve_meeting(04, 01, '2021-11-12', 17, 18, 313);

SELECT * From Joins WHERE floor = 4 AND room = 1 AND date = '2021-11-12';


-- Teddy calls another meeting with his "Secret" Team.

CALL book_room(10, 42, '2021-11-12', 14, 16, 401);

CALL join_meeting(10, 42, '2021-11-12', 14, 16, 402); -- Simon
CALL join_meeting(10, 42, '2021-11-12', 14, 16, 119); -- Manager
CALL join_meeting(10, 42, '2021-11-12', 14, 16, 219); -- Manager

CALL approve_meeting(10, 42, '2021-11-12', 14, 16, 401);

SELECT * FROM view_future_meeting('2021-11-12', 401);
SELECT * FROM view_future_meeting('2021-11-12', 402);
SELECT * FROM view_future_meeting('2021-11-12', 119);
SELECT * FROM view_future_meeting('2021-11-12', 219);


-- Week 2

-- Petrick books regular meeting from 10-11am from 15 to 19 Nov for the three managers in 42 (Teddy), Marketing and Finance.

-- Petrick books session

CALL book_room(9,1,'2021-11-15', 10, 11, 403);
CALL book_room(9,1,'2021-11-16', 10, 11, 403);
CALL book_room(9,1,'2021-11-17', 10, 11, 403);
CALL book_room(9,1,'2021-11-18', 10, 11, 403);
CALL book_room(9,1,'2021-11-19', 10, 11, 403);

SELECT * FROM view_booking_report('2021-11-15', 403);
-- returns Petrick's own 5 bookings

-- Managers join meeting

CALL join_meeting(9,1,'2021-11-15', 10, 11, 401);
CALL join_meeting(9,1,'2021-11-16', 10, 11, 401);
CALL join_meeting(9,1,'2021-11-17', 10, 11, 401);
CALL join_meeting(9,1,'2021-11-18', 10, 11, 401);
CALL join_meeting(9,1,'2021-11-19', 10, 11, 401);

CALL join_meeting(9,1,'2021-11-15', 10, 11, 20);
CALL join_meeting(9,1,'2021-11-16', 10, 11, 20);
CALL join_meeting(9,1,'2021-11-17', 10, 11, 20);
CALL join_meeting(9,1,'2021-11-18', 10, 11, 20);
CALL join_meeting(9,1,'2021-11-19', 10, 11, 20);

CALL join_meeting(9,1,'2021-11-15', 10, 11, 111);
CALL join_meeting(9,1,'2021-11-16', 10, 11, 111);
CALL join_meeting(9,1,'2021-11-17', 10, 11, 111);
CALL join_meeting(9,1,'2021-11-18', 10, 11, 111);
CALL join_meeting(9,1,'2021-11-19', 10, 11, 111);


-- Petrick approves his own session

SELECT * FROM view_manager_report('2021-11-15', 403);
-- returns Petrick's own 5 bookings

CALL approve_meeting(9,1,'2021-11-15', 10, 11, 403);
CALL approve_meeting(9,1,'2021-11-16', 10, 11, 403);
CALL approve_meeting(9,1,'2021-11-17', 10, 11, 403);
CALL approve_meeting(9,1,'2021-11-18', 10, 11, 403);
CALL approve_meeting(9,1,'2021-11-19', 10, 11, 403);

SELECT * FROM view_future_meeting('2021-11-15', 403);
SELECT * FROM view_future_meeting('2021-11-15', 401);
SELECT * FROM view_future_meeting('2021-11-15', 20);
SELECT * FROM view_future_meeting('2021-11-15', 111);
-- all returns same results (regular meeting 10-11)


-- Teddy books regular meeting from 11-12 from 15 to 19 Nov for the three managers in 
-- HR, IT and Logistics.

-- Teddy books session

CALL book_room(10,42,'2021-11-15', 11, 12, 401);
CALL book_room(10,42,'2021-11-16', 11, 12, 401);
CALL book_room(10,42,'2021-11-17', 11, 12, 401);
CALL book_room(10,42,'2021-11-18', 11, 12, 401);
CALL book_room(10,42,'2021-11-19', 11, 12, 401);

SELECT * FROM view_booking_report('2021-11-15', 401);
-- returns Teddy's own 5 bookings

-- Managers join meeting

CALL join_meeting(10,42,'2021-11-15', 11, 12, 13);
CALL join_meeting(10,42,'2021-11-16', 11, 12, 13);
CALL join_meeting(10,42,'2021-11-17', 11, 12, 13);
CALL join_meeting(10,42,'2021-11-18', 11, 12, 13);
CALL join_meeting(10,42,'2021-11-19', 11, 12, 13);

CALL join_meeting(10,42,'2021-11-15', 11, 12, 14);
CALL join_meeting(10,42,'2021-11-16', 11, 12, 14);
CALL join_meeting(10,42,'2021-11-17', 11, 12, 14);
CALL join_meeting(10,42,'2021-11-18', 11, 12, 14);
CALL join_meeting(10,42,'2021-11-19', 11, 12, 14);

CALL join_meeting(10,42,'2021-11-15', 11, 12, 17);
CALL join_meeting(10,42,'2021-11-16', 11, 12, 17);
CALL join_meeting(10,42,'2021-11-17', 11, 12, 17);
CALL join_meeting(10,42,'2021-11-18', 11, 12, 17);
CALL join_meeting(10,42,'2021-11-19', 11, 12, 17);


-- Teddy approves his own session

SELECT * FROM view_manager_report('2021-11-15', 401);
-- returns Teddy's own 5 bookings

CALL approve_meeting(10,42,'2021-11-15', 11, 12, 401);
CALL approve_meeting(10,42,'2021-11-16', 11, 12, 401);
CALL approve_meeting(10,42,'2021-11-17', 11, 12, 401);
CALL approve_meeting(10,42,'2021-11-18', 11, 12, 401);
CALL approve_meeting(10,42,'2021-11-19', 11, 12, 401);

SELECT * FROM view_future_meeting('2021-11-15', 401);
-- Teddy now have 2 regular meetings, 10-11 and 11-12
SELECT * FROM view_future_meeting('2021-11-15', 13);
SELECT * FROM view_future_meeting('2021-11-15', 14);
SELECT * FROM view_future_meeting('2021-11-15', 17);
-- all returns same results (regular meetings 11-12)
-- Simon books regular meeting from 2-4pm from 15 to 19 Nov for the team in 42.

-- Simon books session

CALL book_room(10,42,'2021-11-15', 14, 16, 402);
CALL book_room(10,42,'2021-11-16', 14, 16, 402);
CALL book_room(10,42,'2021-11-17', 14, 16, 402);
CALL book_room(10,42,'2021-11-18', 14, 16, 402);
CALL book_room(10,42,'2021-11-19', 14, 16, 402);

SELECT * FROM view_booking_report('2021-11-15', 402);
-- returns Simon's 5 bookings

-- Team in 42 join meeting

CALL join_meeting(10,42,'2021-11-15', 14, 16, 401);
CALL join_meeting(10,42,'2021-11-16', 14, 16, 401);
CALL join_meeting(10,42,'2021-11-17', 14, 16, 401);
CALL join_meeting(10,42,'2021-11-18', 14, 16, 401);
CALL join_meeting(10,42,'2021-11-19', 14, 16, 401);

CALL join_meeting(10,42,'2021-11-15', 14, 16, 119);
CALL join_meeting(10,42,'2021-11-16', 14, 16, 119);
CALL join_meeting(10,42,'2021-11-17', 14, 16, 119);
CALL join_meeting(10,42,'2021-11-18', 14, 16, 119);
CALL join_meeting(10,42,'2021-11-19', 14, 16, 119);

CALL join_meeting(10,42,'2021-11-15', 14, 16, 219);
CALL join_meeting(10,42,'2021-11-16', 14, 16, 219);
CALL join_meeting(10,42,'2021-11-17', 14, 16, 219);
CALL join_meeting(10,42,'2021-11-18', 14, 16, 219);
CALL join_meeting(10,42,'2021-11-19', 14, 16, 219);

SELECT * FROM view_future_meeting('2021-11-15', 401);
-- Teddy now have 2 regular meetings, 10-11 and 11-12
SELECT * FROM view_future_meeting('2021-11-15', 402);
SELECT * FROM view_future_meeting('2021-11-15', 119);
SELECT * FROM view_future_meeting('2021-11-15', 219);
-- all returns same results (no meeting as not approved yet)


-- Teddy approves Simon's booking

SELECT * FROM view_manager_report('2021-11-15', 401);
-- returns Simon's 5 bookings

CALL approve_meeting(10,42,'2021-11-15', 14, 16, 401);
CALL approve_meeting(10,42,'2021-11-16', 14, 16, 401);
CALL approve_meeting(10,42,'2021-11-17', 14, 16, 401);
CALL approve_meeting(10,42,'2021-11-18', 14, 16, 401);
CALL approve_meeting(10,42,'2021-11-19', 14, 16, 401);

SELECT * FROM view_future_meeting('2021-11-15', 403);
SELECT * FROM view_future_meeting('2021-11-15', 401);
SELECT * FROM view_future_meeting('2021-11-15', 119);
SELECT * FROM view_future_meeting('2021-11-15', 219);

SELECT * FROM view_booking_report('2021-11-15', 402);
-- returns Simon's 5 bookings, now the approver_id should be 401



-- Teddy declares health, has a fever

-- Contract tracing initiated (12 Nov: HR, IT, Logistics Manager, team in 42)

CALL declare_health(401, '2021-11-15', 38.6);
-- contact tracing is triggered

-- Teddy is removed from 1 & 3

SELECT * FROM view_future_meeting('2021-11-15', 401);
-- should be no records

SELECT * FROM view_future_meeting('2021-11-15', 402);
SELECT * FROM view_future_meeting('2021-11-15', 119);
SELECT * FROM view_future_meeting('2021-11-15', 219);
-- should be no records (Team 42 in close contacts on 12 Nov)

SELECT * FROM view_future_meeting('2021-11-15', 403);
SELECT * FROM view_future_meeting('2021-11-15', 20);
SELECT * FROM view_future_meeting('2021-11-15', 11);
-- returns 10-11 regular meeting (Legal, Marketing, Finance not affected)

-- Sessions of 2 is cancelled
SELECT * FROM view_future_meeting('2021-11-15', 13);
SELECT * FROM view_future_meeting('2021-11-15', 14);
SELECT * FROM view_future_meeting('2021-11-15', 17);
-- all returns no records


-- Petrick updates the capacity of a meeting room in Legal to 10 as he reads the latest news.

CALL change_capacity(1,9,10,'2021-11-16', 403);
SELECT * FROM search_room(10, '2021-11-16', 14, 15);
-- should return (9, 1, 9, 10)

-- Petrick calls a meeting with 3 other managers in Legal (2-3pm 16 Nov).

-- Petrick books session

CALL book_room(9,1,'2021-11-16', 14, 15, 403);
SELECT * FROM view_booking_report('2021-11-16', 403);
-- returns the booking 14-15

-- 3 managers join meeting

CALL join_meeting(9,1,'2021-11-16', 14, 15, 18);
CALL join_meeting(9,1,'2021-11-16', 14, 15, 218);
CALL join_meeting(9,1,'2021-11-16', 14, 16, 308);
-- oops he joined more than required, notice message
CALL join_meeting(9,1,'2021-11-16', 14, 15, 308);

-- Tianle is curious about the meeting, also joins the meeting

CALL join_meeting(9,1,'2021-11-16', 14, 15, 404);
SELECT * FROM view_future_meeting('2021-11-16', 404);
-- returns the meeting 14-15

-- Petrick, not knowing an HR junior is joining the meeting, approves the meeting

SELECT * FROM view_manager_report('2021-11-16', 403);
-- returns the booking 14-15
CALL approve_meeting(9, 1, '2021-11-16', 14, 15, 403);

SELECT * FROM view_future_meeting('2021-11-16', 404);

-- Petrick is surprised to see Tianle at the meeting.

-- Tianle is fired

CALL remove_employee(404, '2021-11-16');

-- Another HR manager calls a meeting (2-3pm 17 Nov)

-- Manager books session

CALL book_room(4, 1, '2021-11-17', 14, 15, 13);

-- Tianle still wants to join and ask for forgiveness, but to no avail.

CALL join_meeting(4, 1, '2021-11-17', 14, 15, 404);
-- Resigned employees cannot join meeting

SELECT * FROM non_compliance('2021-11-5', CURRENT_DATE);