/* Given the start date and end date with quantity as a single record, convert the quantity into rows by day, if day doesn't exist then represent that 
 day with zero quantity */
 
 create volatile table vt_test_recs
(
start_dt date,
end_dt date,
qty int
)
on commit preserve rows;

insert into vt_test_recs values('2019-01-01','2019-01-04', 300);
insert into vt_test_recs values('2019-01-06','2019-01-08', 75);

select * from  vt_test_recs;
	start_dt	end_dt	qty
1	1/1/2019	1/4/2019	300
2	1/6/2019	1/8/2019	75

-- Solution :

with recursive temp(strt_Dt, eddt) as
(
select min(start_dt) strt_Dt, max(end_Dt) eddt from vt_test_recs
union all
select strt_Dt+1 as ed, eddt from temp
where ed <= eddt
)
select temp.strt_dt, case when start_Dt is not null then
                          case when end_dt - start_dt = 0 
			       then qty
			       else qty/(end_dt - start_Dt+1) 
			   end
		    else 0 end Day_Qty
from temp
 left join vt_test_recs
   on temp.strt_dt between vt_test_recs.start_dt and vt_test_recs.end_dt;

-- Result:
	strt_Dt	Day_Qty
1	1/1/2019	75
2	1/2/2019	75
3	1/3/2019	75
4	1/4/2019	75
5	1/5/2019	0
6	1/6/2019	25
7	1/7/2019	25
8	1/8/2019	25

