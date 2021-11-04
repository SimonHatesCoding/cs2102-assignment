CALL declare_health(4, '2021-11-4', 36.8);
CALL declare_health(1, '2021-11-4', 36.5);
CALL declare_health(14, '2021-11-4', 36.5);

DELETE FROM Sessions WHERE date = '2021-11-11';

CALL book_room(4,1,'2021-11-11',10,12,2); --fever cannot book
CALL book_room(4,1,'2021-11-11',10,12,4); --ok
CALL book_room(4,1,'2021-11-11',10,12,1); --others alr booked
CALL book_room(4,1,'2021-11-11',11,13,4); --subset of alr booked
CALL book_room(4,1,'2021-11-11',12,14,4); --ok

SELECT * FROM Sessions WHERE date = '2021-11-11';

CALL unbook_room(4,1,'2021-11-11',11,13,14); --not the same guy :X

SELECT * FROM Sessions WHERE date = '2021-11-11';

CALL unbook_room(4,1,'2021-11-11',11,13,4); --ok

CALL approve_meeting(4,1,'2021-11-11',10,14,14); --some sessions not exist

SELECT * FROM Sessions WHERE date = '2021-11-11';

CALL approve_meeting(4,1,'2021-11-11',10,11,14); --ok
CALL reject_meeting(4,1,'2021-11-11',13,14,14); --ok

SELECT * FROM Sessions WHERE date = '2021-11-11';

CALL book_room(4,1,'2021-11-11',10,11,14); --cannot book since session approved
CALL book_room(4,1,'2021-11-11',13,14,14); --ok

CALL approve_meeting(4,1,'2021-11-11',13,14,4); --no authority to approve
CALL approve_meeting(4,1,'2021-11-11',13,14,15); --not the same dept
CALL approve_meeting(4,1,'2021-11-11',10,11,14); --session alr approved
CALL approve_meeting(4,1,'2021-11-11',13,14,14); --ok

SELECT * FROM Sessions WHERE date = '2021-11-11';