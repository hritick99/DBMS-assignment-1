use hritick;
create table depts(deptcode char(3) primary key,deptname char(30) not null);
desc depts;
insert into depts(deptcode ,deptname)
value
/*('CSE','Computer_science'),
('ETC','Electronic and tele'),
('MEC','Mechanical'),
('EE','ELectrical'),
('MM','Metallurgy'),*/
('CE','Civil');

select *from depts;
insert into depts(deptcode ,deptname)
value
('004',NULL);/*Null as the deptname cannot be put since it is assigned as "not num"*/
select *from depts;
create table students(rollno numeric(8) primary key,name char(30),bdate date check(bdate < '2001-01-01'), deptcode char(3)references depts(deptcode)on delete cascade ,hostel numeric check(hostel<10),parent_inc numeric(8,1));
alter table students
add constraint Fk_empid foreign key(deptcode)
references depts(deptcode);
desc students;
insert into students(rollno,name,bdate,deptcode,hostel,parent_inc)
value
(17,'Arnab','1982-01-09','EE',8,500);/*the deptcode EE is not added in dept table so the following input violates the constraints*/
select deptcode
from students
where deptcode='002';
update students
set deptcode='ETC'
where deptcode='002';
select * from students;
select count(*) from students;
select count(*) from students
where deptcode='CSE';/*to count the number of CSE students*/
select hostel,rollno,parent_inc
from students
where parent_inc=(select max(parent_inc) from students );/*to display the data for the student whose parent income is maximum in hostel*/

delete from students where deptcode='CSE';/*Deletion of data whose deptcode was CSE*/
delete from students where name='hritick';/*deletion of hritick data from the table students */

create table faculty(fac_code char(8) primary key ,fac_name char(30) not null, fac_dept char(3) references depts(deptcode));
insert into faculty (fac_code,fac_name,fac_dept)
value
('000010','SRM','Seng');

select *from faculty;

create table crs_offrd(crs_code char(5) primary key,crs_name char(35) not null,crs_credits numeric(2,1),crs_fac_cd char(8) references faculty(fac_code));
insert into crs_offrd(crs_code,crs_name,crs_credits,crs_fac_cd)
value
('CS101','Computer',4,'000008');
update crs_offrd
set crs_code='PH106'
where crs_code='5201';
select *from crs_offrd;

create table crs_regd(crs_rollno numeric(8) references students(rollno),crs_cd char(5) references crs_offrd(crs_code),marks numeric(5,2),primary key(crs_rollno,crs_cd));
insert into crs_regd(crs_rollno,crs_cd,marks)
value
(92005010,'CS101',84);

select *from crs_regd;
select *from crs_offrd
natural join
crs_regd
where crs_code=crs_cd and marks=(select max(marks)from crs_regd where crs_code=crs_cd )
group by crs_code;/*maximum marks of each course*/
select *from crs_offrd
natural join
crs_regd
where crs_code=crs_cd and marks=(select min(marks)from crs_regd where crs_code=crs_cd )/*minimum marks of each course*/
group by crs_code;
SELECT	crs_cd,	crs_name,	avg(marks)
	FROM
	crs_regd,crs_offrd
WHERE crs_regd.crs_cd = crs_offrd.crs_code
GROUP BY (crs_cd) /*average marks of each courses.*/
ORDER BY crs_cd;
SELECT 
	crs_regd.crs_rollno as roll_no,
	sum(crs_offrd.crs_credits * crs_regd.marks/100) as total_credits
FROM crs_regd, crs_offrd
WHERE crs_regd.crs_cd = crs_offrd.crs_code
GROUP BY crs_regd.crs_rollno
ORDER BY crs_regd.crs_rollno;/* the total credits of the courses registered by a student.*/

select * from faculty
natural join
crs_offrd
where fac_code=crs_fac_cd and fac_name='DBP';/*the course offered by dbp*/

select *from faculty
natural join 
crs_offrd
where fac_code=crs_fac_cd and fac_name='NLS';/*the course offered by nls*/
select *from crs_offrd where crs_credits>=4 AND crs_credits<=6;/*the courses having credits between 4 and 6 */
select *from crs_offrd where crs_credits>6.5;/*the course which has credit> 6.5*/
select name,parent_inc
from students
where parent_inc >= (select parent_inc from students where rollno='92005010');
select * from students
natural join 
crs_regd
where rollno=crs_rollno and crs_cd='CH103' and marks>(select marks from crs_regd where crs_cd='CH103' and crs_rollno='92005010');/*the marks of the student who have scored more than student 92005010 in CH103*/
 select * from students
natural join 
crs_regd
where rollno=crs_rollno and crs_cd='PH106' and marks>(select marks from crs_regd where crs_cd='PH106' and crs_rollno='92005010');/*the marks of the student who have scored more than student 92005010 in PH106*/
select name,rollno,deptcode,crs_cd from students
natural join 
crs_regd
where rollno=crs_rollno and  crs_cd='EE101';/*List students (rollno,name,deptcode) registered for course EE101.*/
select name,rollno from students
natural join 
crs_regd
where rollno=crs_rollno and deptcode='EE' and crs_cd='EE101' ;/*List students (rollno,name) in ELE dept registered for course EE101.*/
select rollno, name 
from students inner join crs_regd
where rollno not in (select crs_rollno from crs_regd where crs_cd = 'EE101')
and deptcode = 'EE'
group by rollno;/* List students (rollno,name) in ELE dept not registered for course EE101.*/
select rollno, name
from students, crs_regd, crs_offrd
where (rollno in (select crs_rollno from crs_regd inner join crs_offrd on crs_code = crs_cd 
where crs_name = 'DBMS'))
and
(rollno in (select crs_rollno from crs_regd inner join crs_offrd on crs_code = crs_cd 
where crs_name = 'OS'))
group by rollno;/*List the names of the students who have registered for both the courses 'DBMS' and 'OS'.*/
select fac_name ,fac_code,crs_name from faculty
natural join 
 crs_offrd
where (fac_code=crs_fac_cd and crs_name='MIS') or (fac_code=crs_fac_cd and crs_name='soft_engg') ;/* the names of the faculty members who have offered either 'MIS' or 'Software Engg.'*/
select fac_code, fac_name, crs_name
from faculty, crs_offrd
where fac_code = crs_fac_cd
and
(crs_name = 'MIS' and
crs_name != 'Soft_engg');/* Find the names of the faculty members who have offered 'MIS' but not offered 'Software Engg.'*/
select name,rollno,hostel from students
natural join 
crs_regd
where rollno=crs_rollno and  crs_cd='';/* Find out the students in each hostel who are not registered for any course.*/
select rollno,name,deptcode,crs_cd from students
natural join 
crs_regd
where (rollno=crs_rollno and crs_cd='CS101' or deptcode ='EE' ) /* the students who are in ELE dept or who have registered for course CS101.*/
group by rollno;
select rollno, name
from students, crs_regd
where rollno = crs_rollno group by name having count(*) = (select count(*) from crs_offrd);/*Display the students who have registered to all the courses.*/

update crs_regd, crs_offrd
set
marks = marks+5
where marks < 50 and crs_name = 'DBMS' and crs_cd = crs_code;/* Give Grace Marks 5 in subject ‘DBMS’to the students who have scored less than 50 in that subject.*/




