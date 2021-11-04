
-- true
select all_sessions_exist(3, 1, '2021-10-21', hour_int_to_time(13), hour_int_to_time(16));
-- false
select all_sessions_exist(3, 1, '2021-10-21', hour_int_to_time(13), hour_int_to_time(17));

-- true
select any_session_exist(3, 1, '2021-10-21', hour_int_to_time(13), hour_int_to_time(17));

-- true
select eid_in_all_sessions(3, 1, '2021-10-21', hour_int_to_time(13), hour_int_to_time(16), 283);
-- false
select eid_in_all_sessions(3, 1, '2021-10-21', hour_int_to_time(13), hour_int_to_time(17), 283);

-- true
select any_session_approved(3, 1, '2021-10-21', hour_int_to_time(13), hour_int_to_time(17));
-- false
select any_session_approved(4, 2, '2021-10-23', hour_int_to_time(9), hour_int_to_time(12));

-- have not declared => true
delete from HealthDeclarations where eid = 1 AND "date" = CURRENT_DATE;
select has_fever(1);

-- declared 37.5 => false
call declare_health(1, CURRENT_DATE, 37.5);
select has_fever(1);

-- declared 37.6 => true
call declare_health(2, CURRENT_DATE, 37.6);
select has_fever(2);

-- valid input + junior
call add_employee('John Elton', '234-234-1234', 'junior', 1);
-- valid input + senior
call add_employee('Albert Elton', '234-234-1234', 'senior', 1);
-- valid input + manager
call add_employee('William Elton', '234-234-1234', 'manager', 1);

-- invalid kind
call add_employee('Anna', '234-234-1234', 'janitor', 1);
-- invalid did
call add_employee('Anna', '234-234-1234', 'janitor', 11);


-- Join valid single session
call join_meeting(2, 2, '2021-11-22', 10, 11, 400);

-- Join valid multiple sessions
call join_meeting(4, 2, '2021-11-23', 9, 12, 400);

-- Join partially approved meetings
call join_meeting(5, 2, '2021-11-20', 16, 19, 400);

-- Join partially unavailable sessions
call join_meeting(1, 1, '2021-11-10', 15, 20, 400);

-- leave valid single meeting

-- leave valid multiple meetings

-- leave partially approved meetings

-- leave partially available meetings

-- contact tracing
