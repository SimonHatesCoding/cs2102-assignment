CALL declare_health(4, '2021-11-4', 36.8);
CALL declare_health(1, '2021-11-4', 36.5);
CALL declare_health(14, '2021-11-4', 36.5);

DELETE FROM Sessions WHERE date = '2021-11-11';

CALL book_room(4,1,'2021-11-11',10,12,4);
CALL book_room(4,1,'2021-11-11',10,12,1);
CALL book_room(4,1,'2021-11-11',11,13,4);
CALL book_room(4,1,'2021-11-11',12,14,4);

SELECT * FROM Sessions WHERE date = '2021-11-11';

CALL unbook_room(4,1,'2021-11-11',11,13,4);

CALL approve_meeting(4,1,'2021-11-11',10,14,14);

SELECT * FROM Sessions WHERE date = '2021-11-11';

CALL approve_meeting(4,1,'2021-11-11',10,11,14);
CALL reject_meeting(4,1,'2021-11-11',13,14,14);

SELECT * FROM Sessions WHERE date = '2021-11-11';

CALL book_room(4,1,'2021-11-11',10,11,14);
CALL book_room(4,1,'2021-11-11',13,14,14);

CALL approve_meeting(4,1,'2021-11-11',13,14,4);
CALL approve_meeting(4,1,'2021-11-11',13,14,15);
CALL approve_meeting(4,1,'2021-11-11',10,11,14);
CALL approve_meeting(4,1,'2021-11-11',13,14,14);

SELECT * FROM Sessions WHERE date = '2021-11-11';