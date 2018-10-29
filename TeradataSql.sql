
Suggested text time works for meConversation opened. 1 read message.

Skip to content
Using Gmail with screen readers
with recursive 

13 of 43
Teradata.txt

Sivaram.nelluri@gmail.com <sivaram.nelluri@gmail.com>
Attachments
Thu, Aug 20, 2015, 5:13 PM
to durgatubati







Attachments area

.begin import mload tables <tablename> sessions 15;
.layout <layoutname>;
.field field1*varchar(50);
.field fieldn*varchar(50);
.dml label insertlabel1;
insert into <tablename>
(columnname1,
columnnamen)
values(
:field1,
:fieldn
);
.dml label deletelabel;
delete from <tablename> where columname1=:field1;
.import infile <filelocation> format <TEXT|VARTEXT|FASTLOAD>
layout <lauoutname>
apply <deletelabel>
apply <insertlabel>
;
.END MLOAD;

.logoff;


===============================
==Now write the fastload =====
==============================
SET RECORD VARTEXT '|';
DEFINE
fieldname1 (varchar(10)), --No need of FIELD keyword in the beginning and data
types should be in paranthesis (VARCHAR(10))
fieldnamen (varchar(10))
file=<filelocation>;


BEGIN LOADING <targettable>
ERRORFILES ET_<targettable1>, ET_<targettable2>
CHECKPOINT <number>
SESSIONS <sessions>;
insert into <targettable>
(column1,
columnn
)
values(
:fieldname1,
:fieldname2)
;
.END LOADING;
.logoff;


=====================================
==Fastload again=====================
=====================================
drop table ET_<targettable1>;
drop table ET_<targettable2>;
set RECORD VARTEXT '|';
DEFINE 
fieldname1 (varchar(10)),
fieldnamen (varchar(10))
file=<filelocation>;
BEGIN LOADING <targettable>
ERRORFILES ET_<targettable1>, ET_<targettable2> --, (comma) should be a must
between two error table names.
CHECKPOINT 100000
SESSIONS 15;
insert into <targettable>
(column1,
columnn
)
values(
:fieldname1,
fieldnamen
);
END LOADING;
.logoff;
 
 
================================================
===Write fast export =========================
===============================================
.logon <systemname>/<userid>,<password>;
.logtable <logtablename>;
.BEGIN EXPORT
SESSIONS 15;
.EXPORT OUTFILE <filename> MODE RECORD FORMAT <TEXT|FASTLOAD> mlscript
<scriptname>;
select * from <tablename>;
.END EXPORT;


====================================================
========Bteq export ================================
====================================================
.export report file=<filelocation>,open/close; (open or close is for
indicating the status of the file if there is any system restart).
.set separator '|';
.set width 3000;
.set titledashes off;
select 

====================Bteq Import ========================
========================================================
.set maxerror 1;
.set width 2000;
.set quiet on;
        .import vartext ',' file=<filename> ,
skip=1
        .repeat *
        using fieldname (VARCHAR(12)),
              fieldname2 (VARCHAR(12)),
              fieldname3 (VARCHAR(12)),
              fieldname4 (VARCHAR(12))
        insert into tablename ( fieldname1,
                fieldname2,
                fieldname3,
                fieldname4
                )
        values(:fieldname,
                :fieldname2,
                :fieldname3,
                :fieldname4
)
                ;


==============================================================
==========with recursive query ===============================
==============================================================
create table ${APP_WORKDB}.tmp_estd_loads as
(
with recursive date_ranges (yyyymm_BEG,yyyymm_END)
                           as
                           ( select (((min_mexced_ld_cyc_dt /100)*100 +1 )
(date)) yyyymm_BEG,
                         add_months((((min_mexced_ld_cyc_dt /100)*100 +1 )
(date)) ,${LOAD_INCR_INT})  yyyymm_END
                         from vt_min_max_mexced_dt a
                         union all
                         select d.yyyymm_END+1 as yyyymm_beg,
add_months(d.yyyymm_end,${LOAD_INCR_INT}) yyyymm_end
                         from  date_ranges d, vt_min_max_mexced_dt a
                         where yyyymm_end <=a.max_mexced_ld_cyc_dt
                         )
                         select yyyymm_beg,
                        yyyymm_end,
                        Null (char(1)) ld_status_cd,
                        row_number() over(order by yyyymm_BEG) est_load_id
                        from date_ranges
)with data primary index(yyyymm_beg);

===========================================================================
=================Bi temporal table =======================================
===========================================================================
This bitemporal table is easy to specify in Teradata.s SQL (note the
new keywords VALIDTIME and TRANSACTIONTIME).
CREATE MULTISET TABLE Prop_Owner (
customer_number INTEGER,
property_number INTEGER,
property_VT PERIOD(DATE) NOT NULL AS VALIDTIME,
property_TT PERIOD (TIMESTAMP(6) WITH TIME ZONE)
NOT NULL AS TRANSACTIONTIME)
PRIMARY INDEX(property_number);

===========================================================================
=================Unix system error ========================================
===========================================================================
#!/usr/sbin/ksh -u
perl -le 'print $!+0, "\t", $!++ for 0..127'
============================================================================


============================================================================
===================Disk space used by the db and available free space=======
============================================================================
select databasename,maxpermspace*1.00000/(1024*1024*1024)
maxpermspace_gb,currentpermspace*1.00000/(1024*1024*1024)
currentpermspace_gb, (maxpermspace_gb-currentpermspace_gb) as
available_space_gb from ( select databasename,sum(maxperm)
maxpermspace,sum(currentperm) currentpermspace from dbc.diskspace  where
databasename='CFNC02C' group by 1)a;

============================================================================
===================Disk space used at table level ==========================
============================================================================
select databasename,tablename,maxpermspace maxpermspace_b,currentpermspace
currentpermspace_b, (maxpermspace_b-currentpermspace_b) as
available_space_b from ( select databasename,tablename,sum(maxperm)
maxpermspace,sum(currentperm) currentpermspace from dbc.allspace  where
databasename='CFNW02C' group by 1,2)a;

===========================================================================
=================find the perm, spool and temp space =====================
==========================================================================
select * from dbc.users;

==========================================================================
=================Getting together in one line by combing multiple lines==
==========================================================================
select id,sum(case when exp_type='travel' then amt else 0 end)
travel_expenses,
sum(case when exp_type='food' then amt end) food_expenses,
sum(case when exp_type='mis' then amt end) mis_expenses
from vt_test_employee group by 1
=============================================================================

============================================================================
===============Multiple rows in to one column SQL ==========================
============================================================================
drop table vt_mbr_proc;
create volatile table vt_mbr_proc
(
sur_mbr_id integer,
proc_cd char(5),
seq_no int,
proc_mod varchar(20)
)on commit preserve rows;
delete from vt_mbr_proc;
insert into vt_mbr_proc values(1,'1234', 0,'');
insert into vt_mbr_proc values(1,'2345', 0,'');
insert into vt_mbr_proc values(1,'4567', 0,'');

select * from vt_mbr_proc;

create volatile table proc_mods 
(
proc_cd char(5),
proc_md char(2)
) on commit preserve rows;

insert into proc_mods values('1234','DO');
insert into proc_mods values('2345','DO');
insert into proc_mods values('2345','XO');
insert into proc_mods values('2345','45');
insert into proc_mods values('2345','56');

create volatile table vt_temp_mbr_procs as
(
select a.*, row_number() over(partition by sur_mbr_id,proc_cd order by
proc_md) seq_no
from
(
select v.sur_mbr_id,v.proc_cd, p.proc_md
from vt_mbr_proc v
left join proc_mods p 
on v.proc_cd=p.proc_cd
group by 1,2,3
)a
)with data primary index(sur_mbr_id) on commit preserve rows;

select * from vt_temp_mbr_procs;

Bring all in one line.
update vt_mbr_proc a
set proc_mod=(case when proc_mod='' then trim(vt_temp_mbr_procs.proc_md)
else trim(proc_mod)||','||trim(vt_temp_mbr_procs.proc_md) end)
,seq_no=vt_temp_mbr_procs.seq_no
where a.seq_no+1=vt_temp_mbr_procs.seq_no
and a.proc_cd=vt_temp_mbr_procs.proc_cd
and a.sur_mbr_id=vt_temp_mbr_procs.sur_mbr_id
and a.seq_no=(select max(seq_no) from  vt_mbr_proc);

select * from vt_mbr_proc
===================================================================================
========Fastexport access module error 34 pmbUxWrite byte count error System
=======Error 4 resolution
===================================================================================
Copy fexpcfg.dat to an accesible location and says STATUS=OFF and initialize
the FEXPLIB variable to the corresponding accesible directory before calling
the fast export script.

===================================================================================

Generated mload from Fastexport by Teradata:

.LOGTABLE LOGTABLE151229;

.LOGON teramed1/lid2rme;

.SET DBASE_TARGETTABLE TO 'CFND02A';
.SET DBASE_WORKTABLE   TO 'CFND02A';
.SET DBASE_ETTABLE     TO 'CFND02A';
.SET DBASE_UVTABLE     TO 'CFND02A';
.SET TARGETTABLE       TO 'TABLE151229';

.BEGIN IMPORT MLOAD
       TABLES &DBASE_TARGETTABLE..&TARGETTABLE
   WORKTABLES &DBASE_WORKTABLE..WT_&TARGETTABLE
  ERRORTABLES &DBASE_ETTABLE..ET_&TARGETTABLE
              &DBASE_UVTABLE..UV_&TARGETTABLE;

.LAYOUT DATAIN_LAYOUT;
.FIELD insert_ts 1 CHAR(32);
.FIELD DataBaseName 33 CHAR(30);
.FIELD TableName 63 CHAR(30);
.FIELD currentperm 93 FLOAT;
.FIELD rn 101 INTEGER;

.DML LABEL INSERT_DML;
INSERT INTO &DBASE_TARGETTABLE..&TARGETTABLE (
 insert_ts = :insert_ts
,DataBaseName = :DataBaseName
,TableName = :TableName
,currentperm = :currentperm
,rn = :rn
);

.IMPORT INFILE /home/lid2rme/table_sizes2
  FORMAT FASTLOAD
  LAYOUT DATAIN_LAYOUT
  APPLY INSERT_DML;

.END MLOAD;

.LOGOFF &SYSRC;


Teradata.txt
Displaying Teradata.txt.
