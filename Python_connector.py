
-------------------------------------Installing snowflake python connector
https://docs.snowflake.net/manuals/user-guide/python-connector-install.html

Establish secure snowflake connection
From any text editor, create a file named validate.py with contents: (replace password)
#!/usr/bin/env python
import snowflake.connector

# Gets the version
ctx = snowflake.connector.connect(
   user='resyanalytics',
   password='yourSnowflakePassword',
   account='yk58234.us-east-1'
   )
cs = ctx.cursor()
try:
   cs.execute("SELECT current_version()")
   one_row = cs.fetchone()
   print(one_row[0])
finally:
   cs.close()
ctx.close()

From Terminal, run 
>> python validate.py

#----------Methods and attributes in the connector package--------
https://docs.snowflake.net/manuals/user-guide/python-connector-example.html#connecting-to-snowflake
http://initd.org/psycopg/docs/cursor.html


#--------------------------------------------Beautiful py file:

#!/usr/bin/env python
import snowflake.connector

#creating a connection
ctx = snowflake.connector.connect(
    user='inna',
    password='...',
    account='yk58234.us-east-1'
    )
#creating a cursor of the current connection
cs=ctx.cursor()

# =============================================================================
#fetching the current version of the python
try:
    cs.execute("SELECT current_version()")
    one_row = cs.fetchone()
    print(one_row[0])
finally:
    cs.close()
cs=ctx.cursor()
# =============================================================================
#Use specific WH, DB
ctx.cursor().execute("USE warehouse PC_FIVETRAN_WH")
ctx.cursor().execute("USE PC_FIVETRAN_DB.AURORA_CORE")
# =============================================================================
#create table
ctx.cursor().execute(
    "CREATE OR REPLACE TABLE "
    "testtable(col1 integer, col2 string)")
#insert test data into new table
ctx.cursor().execute(
    "INSERT INTO testtable(col1, col2) "
    "VALUES(123, 'test string1'),(456, 'test string2')") 
# =============================================================================
 # Querying Data

#method #1
query1 = ctx.execute_string("SELECT USER_ID,LOC_PRIMARY FROM USER_LOCATIONS WHERE LOC_primary = '2';")
query2 = ctx.execute_string(
        "select u.ID from user_info as u order by u.ID;")
query3 = ctx.execute_string(
        "SELECT * FROM USER_LOCATIONS WHERE USER_ID = '8';"    
        "SELECT * FROM USER_LOCATIONS WHERE USER_ID = '100';")
query4 = ctx.execute_string ("SELECT uu.id, uu.foreign_id, count(uu.ID) FROM USER_user AS uu inner join user_info as u on u.ID=uu.foreign_id inner JOIN reservation_bookreservation rr on rr.user_id = uu.id where uu.foreign_type='resy_app' and rr.CANCELLATION_ID is null GROUP BY uu.id, uu.foreign_id  ORDER BY uu.id asc;")

#displaying content
for cursor in query4:
    for row in cursor: 
       print(row[0:10])
# =============================================================================
#method #2
cs=ctx.cursor()
try:
    cs.execute("SELECT col1, col2 FROM testtable")
    for (col1, col2) in cs:
        print('{0}, {1}'.format(col1, col2))
finally:
    cs.close()      
# =============================================================================    
ctx.close()
