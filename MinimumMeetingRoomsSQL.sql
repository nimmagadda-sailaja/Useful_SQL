drop table vt_meetings;
create volatile table vt_meetings (
id int,
start_time varchar(8),
end_time varchar(8)
)on commit preserve rows;

delete from vt_meetings;
-- Test 1 
/* INSERT INTO vt_Meetings VALUES (1,'08:00','09:00');
INSERT INTO vt_Meetings VALUES (2,'08:00','10:00');
INSERT INTO vt_Meetings VALUES (3,'10:00','11:00');
INSERT INTO vt_Meetings VALUES (4,'11:00','12:00');
INSERT INTO vt_Meetings VALUES (5,'11:00','13:00');
INSERT INTO vt_Meetings VALUES (6,'13:00','14:00');
INSERT INTO vt_Meetings VALUES (7,'13:00','15:00');
*/

-- Test 2
INSERT INTO vt_meetings values (1,'08:00','14:00');
INSERT INTO vt_meetings values (2,'09:00','10:30');
INSERT INTO vt_meetings values (3,'11:00','12:00');
INSERT INTO vt_meetings values (4,'12:00','13:00');
INSERT INTO vt_meetings values (5,'10:15','11:00');
INSERT INTO vt_meetings values (6,'12:00','13:00');
INSERT INTO vt_meetings values (7,'10:00','10:30');
INSERT INTO vt_meetings values (8,'11:00','13:00');
INSERT INTO vt_meetings values (9,'11:00','14:00');
INSERT INTO vt_meetings values (10,'12:00','14:00');
INSERT INTO vt_meetings values (11,'10:00','14:00');
INSERT INTO vt_meetings values (12,'12:00','14:00');
INSERT INTO vt_meetings values (13,'10:00','14:00');
INSERT INTO vt_meetings values (14,'13:00','14:00');
*/
/* Expected to return 4 rooms */
/*
INSERT INTO vt_meetings VALUES(1, '07:00:00', '11:00:00');
INSERT INTO vt_meetings VALUES(2, '12:30:00', '17:00:00');
INSERT INTO vt_meetings VALUES(3, '11:30:00', '14:00:00');
INSERT INTO vt_meetings VALUES(4, '09:30:00', '11:30:00');
INSERT INTO vt_meetings VALUES(5, '10:00:00', '15:00:00');
INSERT INTO vt_meetings VALUES(6, '09:00:00', '13:30:00');
*/

/* My solution */
/* Works for all cases */
select max(rollover)
from 
(
SELECT  t, sum(num) over(partition by 1 order by t rows unbounded preceding)  rollover from (
select t, sum(num) as num
from
(
select start_time t, 's' event, 1 num from vt_meetings
union all 
select end_time t, 'e' event, -1 num from vt_meetings
)i group by t)
a
)b;

/* Breaks due to format */ /* Stack overflow solution which is incorrect */
with mod_meetings as (select id, to_timestamp(start_time, 'HH24:MI') as start_time,
to_timestamp(end_time, 'HH24:MI') as end_time from vt_meetings)
select CASE when max(a_cnt)>1 then max(a_cnt)+1 
            when max(a_cnt)=1 and max(b_cnt)=1 then 2 else 1 end as rooms 
from
(select count(*) as a_cnt, a.id, count(b.id) as b_cnt from mod_meetings a left join mod_meetings b 
on a.start_time>b.start_time and a.start_time<b.end_time group by a.id) join_table;


delete from vt_meetings;
INSERT INTO vt_meetings VALUES
(1, '09:00:00', '17:00:00');
INSERT INTO vt_meetings VALUES(2, '09:00:00', '10:00:00');
INSERT INTO vt_meetings VALUES(3, '10:00:00', '11:00:00');
INSERT INTO vt_meetings VALUES(4, '11:00:00', '12:00:00');
INSERT INTO vt_meetings VALUES(5, '12:00:00', '13:00:00');
INSERT INTO vt_meetings VALUES(6, '13:00:00', '14:00:00');
INSERT INTO vt_meetings VALUES(7, '14:00:00', '15:00:00');
INSERT INTO vt_meetings VALUES(8, '15:00:00', '16:00:00');
INSERT INTO vt_meetings VALUES(9, '16:00:00', '17:00:00');

/* Validate theryxcommar solution*/
/* Works for all cases */
SELECT MAX(overlap) as solution FROM (
    SELECT COUNT(t) as overlap FROM (
        SELECT * FROM (
            SELECT start_time AS t
            FROM vt_meetings
            UNION SELECT end_time AS t
            FROM vt_meetings
        ) as times
        JOIN vt_meetings AS m
        ON times.t >= m.start_time AND times.t < m.end_time
    )a
    GROUP BY t
)a;
