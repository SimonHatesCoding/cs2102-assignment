CALL declare_health(4, '2021-11-3', 36.8);
CALL declare_health(1, '2021-11-3', 36.5);

CALL book_room(4,1,'2021-11-11',10,12,4);
CALL book_room(4,1,'2021-11-11',10,12,1);
CALL book_room(4,1,'2021-11-11',11,13,4);
CALL book_room(4,1,'2021-11-11',12,14,4);

CALL unbook_room(4,1,'2021-11-11',11,13,4);

CALL approve_meeting(4,1,'2021-11-11',10,14,14);
CALL approve_meeting(4,1,'2021-11-11',10,11,14);
CALL reject_meeting(4,1,'2021-11-11',13,14,14);