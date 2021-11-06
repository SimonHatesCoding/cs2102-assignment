a = """
    insert into Sessions ("time", "date", room, "floor", booker_id, approver_id) values ('09:00', '2021-11-19', 01, 01, 110, 20);
    insert into Sessions ("time", "date", room, "floor", booker_id, approver_id) values ('10:00', '2021-11-19', 02, 02, 1, 111);
    insert into Sessions ("time", "date", room, "floor", booker_id, approver_id) values ('11:00', '2021-11-19', 03, 03, 102, 112);
    insert into Sessions ("time", "date", room, "floor", booker_id, approver_id) values ('12:00', '2021-11-20', 04, 04, 203, 313);
    insert into Sessions ("time", "date", room, "floor", booker_id, approver_id) values ('13:00', '2021-11-20', 05, 05, 304, 314); 
    insert into Sessions ("time", "date", room, "floor", booker_id, approver_id) values ('14:00', '2021-11-20', 01, 06, 205, 315); 
    insert into Sessions ("time", "date", room, "floor", booker_id, approver_id) values ('15:00', '2021-11-20', 02, 07, 206, 216);
    insert into Sessions ("time", "date", room, "floor", booker_id, approver_id) values ('16:00', '2021-11-21', 03, 08, 207, 17);
    insert into Sessions ("time", "date", room, "floor", booker_id, approver_id) values ('17:00', '2021-11-21', 04, 09, 8, 218);
    insert into Sessions ("time", "date", room, "floor", booker_id, approver_id) values ('18:00', '2021-11-21', 05, 10, 109, 219);

    -- to demo contact_tracing
    insert into Sessions ("time", "date", room, "floor", booker_id, approver_id) values ('14:00', '2021-11-05', 05, 10, 109, 219);  -- D-4   Participants of this Sessions ARE NOT considered contacted by 109
    insert into Sessions ("time", "date", room, "floor", booker_id, approver_id) values ('14:00', '2021-11-06', 05, 10, 109, 219);  -- D-3   Participants of this Sessions ARE considered contacted by 109   
    insert into Sessions ("time", "date", room, "floor", booker_id, approver_id) values ('14:00', '2021-11-08', 05, 10, 109, 219);  -- D-1   Participants of this Sessions ARE considered contacted by 109     
    insert into Sessions ("time", "date", room, "floor", booker_id, approver_id) values ('14:00', '2021-11-09', 05, 10, 109, 219);  -- D     109 has fever on this date
    insert into Sessions ("time", "date", room, "floor", booker_id, approver_id) values ('14:00', '2021-11-10', 05, 10, 109, 219);  -- D+1   109 books room and ALREADY APPROVED; cancelled due to fever.
    insert into Sessions ("time", "date", room, "floor", booker_id, approver_id) values ('14:00', '2021-11-11', 05, 10, 109, null); -- D+2   109 books room and NOT YET APPROVED; cancelled due to fever.
    insert into Sessions ("time", "date", room, "floor", booker_id, approver_id) values ('14:00', '2021-11-13', 03, 03, 102, 112);  -- D+4   102 books room and ALREADY APPROVED; cancelled due to contact.
    insert into Sessions ("time", "date", room, "floor", booker_id, approver_id) values ('14:00', '2021-11-16', 03, 08, 207, 17);   -- D+7   Participants at D-3 and/or D-4 are in this meeting; must be removed
    insert into Sessions ("time", "date", room, "floor", booker_id, approver_id) values ('14:00', '2021-11-17', 03, 08, 207, 17);   -- D+8   Participants at D-3 and/or D-4 are in this meeting; need not remove
    insert into Sessions ("time", "date", room, "floor", booker_id, approver_id) values ('14:00', '2021-11-18', 03, 03, 102, 112);  -- D+9   102 books room and ALREADY APPROVED; not cancelled since > D+7. 


    -- CASE B (10): approved meeting AND approver_id == booker_id AND session == 1hr
    insert into Sessions ("time", "date", room, "floor", booker_id, approver_id) values ('09:00', '2021-11-21', 01, 02, 111, 111);
    insert into Sessions ("time", "date", room, "floor", booker_id, approver_id) values ('10:00', '2021-11-20', 02, 04, 313, 313);
    insert into Sessions ("time", "date", room, "floor", booker_id, approver_id) values ('11:00', '2021-11-20', 03, 06, 215, 215);
    insert into Sessions ("time", "date", room, "floor", booker_id, approver_id) values ('12:00', '2021-11-19', 04, 08, 17, 17);
    insert into Sessions ("time", "date", room, "floor", booker_id, approver_id) values ('13:00', '2021-11-19', 05, 10, 19, 19);

    -- CASE C (10): approved meeting AND approver_id <> booker_id AND session > 1hr
    ---- Meeting C1: 2021/10/21 13:00-16:00 at (01, 03)
    insert into Sessions ("time", "date", room, "floor", booker_id, approver_id) values ('13:00', '2021-11-21', 01, 03, 2, 212);
    insert into Sessions ("time", "date", room, "floor", booker_id, approver_id) values ('14:00', '2021-11-21', 01, 03, 2, 212);
    insert into Sessions ("time", "date", room, "floor", booker_id, approver_id) values ('15:00', '2021-11-21', 01, 03, 2, 212);
    ---- Meeting C2: 2021/10/20 16:00-19:00 at (02, 05) ** PARTIALLY APPROVED **
    insert into Sessions ("time", "date", room, "floor", booker_id, approver_id) values ('16:00', '2021-11-20', 02, 05, 104, 114);
    insert into Sessions ("time", "date", room, "floor", booker_id, approver_id) values ('17:00', '2021-11-20', 02, 05, 104, 114);
    insert into Sessions ("time", "date", room, "floor", booker_id, approver_id) values ('18:00', '2021-11-20', 02, 05, 104, null);
    ---- Meeting C3: 2021/10/19 14:00-16:00 at (03, 09) 
    insert into Sessions ("time", "date", room, "floor", booker_id, approver_id) values ('14:00', '2021-11-19', 03, 09, 308, 218);
    insert into Sessions ("time", "date", room, "floor", booker_id, approver_id) values ('15:00', '2021-11-19', 03, 09, 308, 218);
    ---- Meeting C4: 2021/10/19 16:00-18:00 at (04, 06)
    insert into Sessions ("time", "date", room, "floor", booker_id, approver_id) values ('16:00', '2021-11-19', 04, 06, 205, 15);
    insert into Sessions ("time", "date", room, "floor", booker_id, approver_id) values ('17:00', '2021-11-19', 04, 06, 205, 15);

    -- CASE D (5) unapproved meeting AND session == 1hr
    insert into Sessions ("time", "date", room, "floor", booker_id, approver_id) values ('09:00', '2021-11-22', 01, 01, 110, null);
    insert into Sessions ("time", "date", room, "floor", booker_id, approver_id) values ('10:00', '2021-11-22', 02, 02, 1, null);
    insert into Sessions ("time", "date", room, "floor", booker_id, approver_id) values ('11:00', '2021-11-22', 03, 03, 102, null);
    insert into Sessions ("time", "date", room, "floor", booker_id, approver_id) values ('12:00', '2021-11-22', 04, 04, 203, null);
    insert into Sessions ("time", "date", room, "floor", booker_id, approver_id) values ('13:00', '2021-11-22', 05, 05, 304, null);
    
    -- CASE E (5) unapproved meeting AND session >= 1hr
    insert into Sessions ("time", "date", room, "floor", booker_id, approver_id) values ('09:00', '2021-11-23', 02, 04, 303, null);
    insert into Sessions ("time", "date", room, "floor", booker_id, approver_id) values ('10:00', '2021-11-23', 02, 04, 303, null);
    insert into Sessions ("time", "date", room, "floor", booker_id, approver_id) values ('11:00', '2021-11-23', 02, 04, 303, null);
    insert into Sessions ("time", "date", room, "floor", booker_id, approver_id) values ('14:00', '2021-11-23', 04, 01, 110, null);
    insert into Sessions ("time", "date", room, "floor", booker_id, approver_id) values ('15:00', '2021-11-23', 05, 01, 110, null);     
"""

'''
    CREATE OR REPLACE PROCEDURE approve_meeting
    (IN in_floor INT, IN in_room INT, IN in_date DATE, IN start_hour INT, IN end_hour INT, IN in_eid INT) AS $$

CALL approve_meeting(floor, room, date, start_hour, end_hour, eid)
'''

def approve(line):
    if "null" in line: return
    end = line.index(";")
    line = line[:end]
    values_idx = line.index("values")
    values = line[values_idx + 8 :-1]
    t, d, r, f, _, approver = values.split(", ")
    out = 'UPDATE Sessions SET approver_id = {} WHERE "floor" = {} AND "room" = {} AND "date" = {} AND "time" = {};'.format(approver, f, r, d, t)
    print(out)

def booker_joins(line):
    end = line.index(";")
    line = line[:end]
    values_idx = line.index("values")
    values = line[values_idx + 8 :-1]
    t, d, r, f, booker, _ = values.split(", ")
    out = '    insert into Joins (eid, "time", "date", room, "floor") values ({},  {}, {}, {}, {});'.format(booker, t, d, r, f)
    print(out)


for line in a.splitlines():
    line = line.strip()
    if "insert into Sessions" not in line: continue
    booker_joins(line)

