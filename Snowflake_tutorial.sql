Snowflake Tutorial


SQL try_me tutorial:
http://www.mysqltutorial.org/tryit/


Create table 
Ex:
create or replace table count_example(i int, j int);

Clone table
CREATE TABLE PC_FIVETRAN_DB.AURORA_CORE.user_locations CLONE PC_FIVETRAN_DB.PUBLIC.user_locations;

Remove table:
drop table count_example

Rename table:
alter table active_users_info RENAME TO active_users

Modify a table- columns:
1) drop a column
alter table t1 modify c2 drop default;
2) chnage type of the column (only can increase the length)
alter table t1 alter c3 set data type varchar(50);

//used https://docs.snowflake.net/manuals/sql-reference/sql/alter-table-column.html#syntax


Update table:
update t1
  set t1.number_column = t1.number_column + t2.number_column, t1.text_column = 'ASDF'
  from t2
  where t1.key_column = t2.t1_key and t1.number_column < 10;


https://docs.snowflake.net/manuals/sql-reference/sql/create-table.html




Insert values:
Ex1:

insert into count_example values
(11,101), (11,102), (11,null), (12,101), (null,101), (null,102);

 Ex2:

insert into my_table (x2, x5, x7, x10) select x2, x5, x7, x10 from t

3. Altering a table and columns:
https://docs.snowflake.net/manuals/sql-reference/sql/alter-table-column.html

 ALTER TABLE <name> { ALTER | MODIFY } [ ( ]
                                          [ COLUMN ] <col1_name> DROP DEFAULT,
                                          [ COLUMN ] <col1_name> { [ SET ] NOT NULL | DROP NOT NULL },
                                          [ COLUMN ] <col1_name> [ [ SET DATA ] TYPE ] <type>,
                                          [ COLUMN ] <col1_name> COMMENT '<string>',
                                          [ [ COLUMN ] <col2_name> ... ]
                                      [ ) ]

alter table user_locations alter user_ID set data type NUMBER(20,0);

 
4. Copy from the file
copy t (x1, ... , x10) from '/path/to/my_file' with (format csv)


5. Save query as a new table

CREATE TABLE experimental.public.active_users2 (User_ID NUMBER(20,0), resycount NUMBER(20,0)) 
AS

select u.id as "active_user_ID", count(r.id) as "num of res for 90 days"
FROM USER_info AS u
JOIN resy_info r on r.user_id = u.id
where R.DATE_CREATED > '2018-07-20' and R.DATE_CREATED < '2018-11-01'
GROUP BY u.id
order by u.id
;


6. Select
https://docs.snowflake.net/manuals/sql-reference/sql/select.html
Ex:

select * from count_example;
+------+------+
|    I |    J |
|------+------|
|   11 |  101 |
|   11 |  102 |
|   11 | NULL |
|   12 |  101 |
| NULL |  101 |
| NULL |  102 |
+------+------+

7. Subqueries

https://docs.snowflake.net/manuals/sql-reference/operators-subquery.html
                                                                                       
//======WHERE=====
                                                                                       
//Ex.1
//This query shows an uncorrelated subquery in a WHERE clause. The subquery gets the per capita GDP of Brazil, and the outer query selects all the jobs (in any country) that pay less than the per-capita GDP of Brazil. The subquery is uncorrelated because the value that it returns does not depend upon any column of the outer query. The subquery only needs to be called once during the entire execution of the outer query.
select p.name, p.annual_wage, p.country
  from pay as p
  where p.annual_wage < (select per_capita_gdp
                           from international_gdp
                           where name = 'Brazil');
//Ex. 2                                                                                       
This shows a correlated subquery in a WHERE clause. This query lists jobs where the annual pay of the job is less than the per-capita GDP in that country. This subquery is correlated because it is called once for each row in the outer query and is passed a value (p.country (country name)) from that row.
select p.name, p.annual_wage, p.country
  from pay as p
  where p.annual_wage < (select max(per_capita_gdp)
                           from international_gdp i
                           where p.country = i.name);

//Ex.3
select goats.*, n.*, ns.*  
from (select uu.id, uu.date_created  
      from user_user as uu
      inner join user_info as u on u.ID=uu.foreign_ID
      left outer JOIN reservation_bookreservation rr on rr.user_id = uu.id
      where uu.foreign_type='resy_app'
      and rr.user_id is NULL) as goats
inner join "PC_FIVETRAN_DB"."AURORA_CORE"."NOTIFY_AVAIL_CONFIG" as n on n.GLOBAL_user_ID=goats.ID
inner join PC_FIVETRAN_DB.AURORA_CORE.NOTIFY_NOTIFYSTATUS as ns on ns.ID=n.ID;


//=====WITH========

  <subquery_name1> [ ( <col_list> ) ] AS ( SELECT ...  )
  [ , <subquery_name2> [ ( <col_list> ) ] AS ( SELECT ...  ) [ , ... ] ]
SELECT ...
FROM ...
[ ... ]

//Ex. #1:
with
  albums_1976 as (select * from music_albums where album_year = 1976)
select album_name from albums_1976 order by album_name;


//Ex. #2
with sub1 as (
  select 
    terminalid, 
    first_value(id) over (partition by terminalid order by d desc) id
  from terminal 
),
-- Now, make sure there's only one per terminalid id
sub2 as (
  select 
    terminalid, 
    any_value(id) id
  from sub1
  group by terminalid
)
-- Now use that result
select tr.ID, sub2.id
FROM "Transaction" tr
JOIN sub2 ON tr.terminalid = sub2.terminalid;



8. Aggregates:
//====Count======
https://docs.snowflake.net/manuals/sql-reference/functions/count.html

Ex:
select count(*), count(i), count(distinct i), count(j), count(distinct j) from count_example;

+----------+----------+-------------------+----------+-------------------+
| COUNT(*) | COUNT(I) | COUNT(DISTINCT I) | COUNT(J) | COUNT(DISTINCT J) |
|----------+----------+-------------------+----------+-------------------|
|        6 |        4 |                 2 |        5 |                 2 |
+----------+----------+-------------------+----------+-------------------+

select i, count(*), count(j) from count_example group by i;

+------+----------+----------+
|    I | COUNT(*) | COUNT(J) |
|------+----------+----------|
|   11 |        3 |        2 |
|   12 |        1 |        1 |
| NULL |        2 |        2 |
+------+----------+----------+



//===========Sum=========
//Ex:
select dayname(r.date_booked) string$Day,
    sum(r.num_seats) number$Total_Covers,
    sum(case when r.source_id like 'Airbnb' then r.num_seats end) number$AirBnB_Covers,
    sum(case when r.source_id like 'Instagram' then r.num_seats end) number$Instagram_Covers,
    sum(case when r.source_id like '%facebook'  then r.num_seats end) number$Facebook_Covers,
    sum(case when r.source_id like '%import%'  then r.num_seats end) number$Import_Covers,
    sum(case when r.source_id like 'resy.com' then r.num_seats  end) number$Resycom_Covers,
    sum(case when r.source_id like 'resy_app'  then r.num_seats end) number$Resy_App_Covers,
    sum(case when r.SOURCE_ID not like 'resy_os' and r.source_id not like 'resy_app' and r.source_id not like 'resy.com' and r.source_id not like 'Airbnb' and r.source_id not like 'Instagram' and r.source_id not like '%facebook' and r.source_id not like '%import%' then r.num_seats end) number$Widget_Covers,
    sum(case when r.source_id like 'resy.com' or  r.source_id like 'resy_app' then r.num_seats end)/sum(r.num_seats) percentage$Percent_Resy_Platform
from reservation_bookreservation r
 inner join reservation_bookreservationstatus s on r.id = s.reservation_id and s.status_id != 2
 join venue_info v on v.id=r.venue_id and v.is_active=1
where
r.cancellation_id is null
 and r.venue_id != 1278
 and month(r.date_booked) = 8
 and year(r.date_booked) = 2018
group by 1;

8.Dense_Rank ranking the values from certain field

select state, bushels_produced, dense_rank()
  over (order by bushels_produced desc)
  from corn_production;

+--------+------------------+------------+
|  state | bushels_produced | DENSE_RANK |
+--------+------------------+------------+
| Kansas |              130 |          1 |
| Kansas |              120 |          2 |
| Iowa   |              110 |          3 |
| Iowa   |              100 |          4 |
+--------+------------------+------------+
select state, bushels_produced, dense_rank()
  over (partition by state order by bushels_produced)
  from corn_production;

+--------+------------------+------------+
|  state | bushels_produced | DENSE_RANK |
+--------+------------------+------------+
| Iowa   |              110 |          1 |
| Iowa   |              100 |          2 |
| Kansas |              130 |          1 |
| Kansas |              120 |          2 |
+--------+------------------+------------+


https://docs.snowflake.net/manuals/sql-reference/functions/dense_rank.html

9. Case
https://docs.snowflake.net/manuals/sql-reference/functions/case.html

select
    column1,
    case
        when column1=1 then 'one'
        when column1=2 then 'two'
        else 'other'
    end as result
from (values(1),(2),(3)) v;

---------+--------+
 column1 | result |
---------+--------+
 1       | one    |
 2       | two    |
 3       | other  |
---------+--------+



10. Join
https://docs.snowflake.net/manuals/sql-reference/constructs/join.html

Ex:
select * from t1 order by c1;

----+
 C1 |
----+
 2  |
 3  |
 4  |
----+

select * from t2 order by c2;

----+
 C2 |
----+
 1  |
 2  |
 2  |
 3  |
----+


Inner join:
select c1, c2 from t1 inner join t2 on c1 = c2 order by 1,2;

----+----+
 c1 | c2 |
----+----+
 2  | 2  |
 2  | 2  |
 3  | 3  |
----+----+
Left outer join:
select c1, c2 from t1 left outer join t2 on c1 = c2 order by 1,2;

----+--------+
 c1 |   c2   |
----+--------+
 2  | 2      |
 2  | 2      |
 3  | 3      |
 4  | [NULL] |
----+--------+


Right outer join:
select c1, c2 from t1 right outer join t2 on c1 = c2 order by 1,2;

--------+----+
   c1   | c2 |
--------+----+
 2      | 2  |
 2      | 2  |
 3      | 3  |
 [NULL] | 1  |
--------+----+
Here is an example of a cross join, which will produce the cartesian product:
create or replace table d1 (
  id number,
  name string
  );
insert into d1 (id, name) values
  (1,'a'),
  (2,'b'),
  (4,'c');

create or replace table d2 (
  id number,
  value string
  );
insert into d2 (id, value) values
  (1,'xx'),
  (2,'yy'),
  (5,'zz');

select d1.*, d2.*
from d1 cross join d2;

+----+------+----+-------+
| ID | NAME | ID | VALUE |
|----+------+----+-------|
|  1 | a    |  1 | xx    |
|  1 | a    |  2 | yy    |
|  1 | a    |  5 | zz    |
|  2 | b    |  1 | xx    |
|  2 | b    |  2 | yy    |
|  2 | b    |  5 | zz    |
|  4 | c    |  1 | xx    |
|  4 | c    |  2 | yy    |
|  4 | c    |  5 | zz    |
+----+------+----+-------+
A cross join can be filtered by a WHERE clause, as shown in the example below:
select d1.*, d2.*
from d1 cross join d2
where d1.id = d2.id;

+----+------+----+-------+
| ID | NAME | ID | VALUE |
|----+------+----+-------|
|  1 | a    |  1 | xx    |
|  2 | b    |  2 | yy    |
+----+------+----+-------+


This is an example of a natural join:
select d1.*, d2.*
from d1 natural inner join d2;
The output is:
+----+------+----+-------+
| ID | NAME | ID | VALUE |
|----+------+----+-------|
|  1 | a    |  1 | xx    |
|  2 | b    |  2 | yy    |
+----+------+----+-------+
The natural join is equivalent to a join that explicitly joins on each column that the two tables have in common:
select d1.*, d2.*
from d1 inner join d2
  on d2.id=d1.id;


The output of this explicit join is the same as the output of the equivalent natural join, i.e.:
+----+------+----+-------+
| ID | NAME | ID | VALUE |
|----+------+----+-------|
|  1 | a    |  1 | xx    |
|  2 | b    |  2 | yy    |
+----+------+----+-------+






Other Examples:

 select last_name from employee_table where employee_id = 101;

select department_name, last_name, first_name
  from employee_table inner join department_table
    on employee_table.department_id = department_table.department_id
  order by department_name, last_name, first_name;

select 2.0 * pi() * pi() as area_of_circle;
select department_name, last_name, first_name
  from employee_table inner join department_table
    on employee_table.department_id = department_table.department_id
  order by department_name, last_name, first_name;
Full outer join:
create or replace table employees (
employeeid number
, lastname string
, firstname string
, email string
, workphone string
, cellphone string
, homeaddress string
, locationid number
);

insert into employees (employeeid,lastname,firstname,email,workphone,cellphone,homeaddress,locationid)
values
(1, 'Reed', 'Riley', 'RRiley@mycompany.com', '1-650-766-3283', '1-650-247-9094', '5274 Tempus St Sacramento CA 95838', 1)
,(2, 'Harlan', 'Harrison', 'HHarrison@mycompany.com', '1-650-443-4754', '1-650-998-4302', '1562 Sed St Rio Linda CA 95673', 1)
,(3, 'Caldwell', 'Wise', 'CWise@mycompany.com', '1-650-380-9433', '1-650-952-8492', '270-3798 Suspendisse St Elk Grove CA 95624', 4)
,(4, 'Barry', 'Thompson', 'BThompson@mmycompany.com', '1-617-681-5370', '1-617-164-6624', '933 Semper Rd Belmont MA 81900', 2)
,(5, 'Octavia', 'Jackson', 'OJackson@mycompany.com', '1-617-867-8027', '1-617-110-9862', '114 Lerwick Rd Lexington MA 59222', 2);

create or replace table locations (
locationid number
, locationname string
, locationphone string
, locationaddress string
);

insert into locations (locationid, locationname, locationphone, locationaddress)
values
(1, 'San Diego', '1-619-265-4050', '6986 Morbi Ave San Diego CA 92093')
,(2, 'Boston', '1-617-448-3992', '628 Aliquet Rd Boston MA 02108')
,(3, 'New York', '1-201-448-3992', '628 Aliquet Bvd New York NY 10001');

select e.lastname, e.firstname, l.locationname
from employees e
full outer join locations l
on e.locationid=l.locationid
order by e.lastname;

+----------+-----------+--------------+
| LASTNAME | FIRSTNAME | LOCATIONNAME |
|----------+-----------+--------------|
| Barry    | Thompson  | Boston       |
| Caldwell | Wise      | NULL         |
| Harlan   | Harrison  | San Diego    |
| Octavia  | Jackson   | Boston       |
| Reed     | Riley     | San Diego    |
| NULL     | NULL      | New York     |
+----------+-----------+--------------+
Common command used in SQL and Snowflake:
https://docs.snowflake.net/manuals/sql-reference/intro-summary-sql.html



                     
                     
11. View
                     
//This shows how to use views to reduce the complexity of the previous example (as in the previous example, this does not use a WITH clause):

 -- We can reduce duplicate code in the preceding query by creating a view(s):
create or replace view view_musicians_in_bands as
select distinct musicians.musician_id, musician_name, band_name
 from musicians inner join musicians_and_albums inner join music_albums inner join music_bands
 where musicians.musician_id = musicians_and_albums.musician_id
   and musicians_and_albums.album_id = music_albums.album_id
   and music_albums.band_id = music_bands.band_id
order by musician_id
  ;

-- With this view, we can re-write our original query as:
select musician_id, musician_name
from view_musicians_in_bands where band_name = 'Santana'
intersect
select musician_id, musician_name
from view_musicians_in_bands where band_name = 'Journey'
order by musician_id;
The output of the previous query is:

+-------------+---------------+
| MUSICIAN_ID | MUSICIAN_NAME |
+=============+===============+
|         305 | Greg Rollie   |
+-------------+---------------+
|         306 | Neil Schon    |
+-------------+---------------+
                     
       
                     
12. Pivot (and nested query)
                     
//new reservations by month by city(?)
select *
from   (select month(r.date_created) Month, year(r.date_created) Year, date_from_parts(Year, Month, 1) Month_Year, li.name City, count(distinct r.user_id) Total_Users
        from reservation_bookreservation r
        inner join reservation_bookreservationstatus s on r.id = s.reservation_id and s.status_id != 2
        join venue_info v on v.id=r.venue_id and v.is_active=1
        join location_info li on li.id=v.location_id
        where r.cancellation_id is null
        and r.venue_id != 1278
        and City in ('New York','Los Angeles', 'San Francisco','Washington D.C.','Austin', 'London')
        group by Month, Year, City
        order by Month_Year) g
pivot (sum(g.Total_Users) for City in ('New York','Los Angeles', 'San Francisco','Washington D.C.','Austin', 'London')) piv
order by Month_Year desc
;
                     
                     
13. Listagg
//Ex. (doesnt work:( but see application of listagg)             
SELECT uu.id as "user ID", v.location_id as "Location", count(r.id) as "resyCount", listagg("resyCount", ',') within group (order by ri.day desc)  as "venueLocations", listagg(ri.day, ', ') within group (order by ri.day desc) as date_of_booking 
//sum(case when r.source_id like '%facebook'  then r.num_seats end) number$Facebook_Covers,

 //sum(case when r.source_id like '%facebook'  then r.num_seats end) number$Facebook_Covers,

FROM USER_user AS uu
JOIN reservation_bookreservation r on r.user_id = uu.id
left outer JOIN venue_info v on v.id = r.venue_id
//where ri.day > '2017-01-01'
//and ri.day >= u.date_created 
GROUP BY uu.id, v.location_id
//having "user ID" <= 1000000
// "venueLocations" RLIKE'.*[^0-9]1[^0-9].*'
ORDER BY uu.id, "resyCount" desc
;             
             
//===================================================================================================================

Tricky differences between Snowflake and Querious:

Snowflake sometimes won't display a quantity unless it's added in the groupby list. 
Actual example that runs on Querious but not on Snowflake: 
select li.id "location_info.id", li.name "location_info.name", count(distinct v.id) "venue_info.id", count(r.id) "res..bookres..id"
from reservation_bookreservation r
join venue_info v on v.id=r.venue_id and v.is_active=1
inner join location_info li on li.id=v.location_id
group by li.id
order by li.id
;
To make it work, change group by li.id to group by li.id, li.name.




