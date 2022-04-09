# http://www.jython.org/archive/21/docs/zxjdbc.html
from java.lang import *
from java.sql import *

Class.forName("org.teiid.jdbc.TeiidDriver").newInstance()
con = DriverManager.getConnection( 'jdbc:db2:sample','vyang','jythonrocks' )

stmt = con.createStatement()

sql='select firstname,lastname,salary from employee where salary > 20000 order by salary'
rs = stmt.executeQuery(sql)

employeeList=[]
while (rs.next()):
    row={}
    row['firstname']=rs.getString(1)
    row['lastname']=rs.getString(2)
    row['salary']=rs.getDouble(3)
    employeeList.append(row)

rs.close()
stmt.close()
con.close()

print 'employee salary over $20,000'
print '============================'
print 'firstname lastname salary'
print '============================'

# print the result
for e in employeeList:
    print e['firstname'],e['lastname'],'$'+ str(e['salary'])
