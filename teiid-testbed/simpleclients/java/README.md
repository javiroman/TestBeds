Simple Java Client for Teiid server
===================================

This is a derivated work from 
Source: <https://github.com/teiid/teiid-quickstarts>

What is it?
-----------

Simpleclient quickstart demonstrates how to make a connection to Teiid using both a Driver
and a DataSource.

The JDBCClient.java is the example code that shows a developer the basic connection logic that
can be used to connect to a Teiid instance running in a JBoss AS server.

The program expects four arguments <host> <port> <vdb> <sql-command>.  The pom.xml defines these arguments in
the pom.xml:

....
			<mainClass>JDBCClient</mainClass>
			<arguments>
				<argument>localhost</argument>  <!-- host -->
				<argument>31000</argument>   <!--  port -->
				<argument>${vdb}</argument>
				<argument>${sql}</argument>
			</arguments>
....

Notice that the <host> and <port> are preset. To point to a different server and/or port, 
change "localhost" and/or "31000" arguments, respectively, in the pom.xml.

#############
#  Build
#############
This project can be build using:

	mvn clean install

Notes: If you installed Red Hat JBoss Datavirtualization using the installer, the
maven repositories are well set up using the properly option in the installation 
process.

Notes: If you are using the ZIP file with Teiid Server from upstream project, you
have to properly set up the Maven repositories. The most esasy way is download
the setting.xml file from:

cd $HOME/.m2/
wget https://raw.githubusercontent.com/teiid/teiid/master/settings.xml

#############
#  Execution
#############
To execute a sql query using the simpleclient, use the following format:

   mvn install -Dvdb="<vdb>" -Dsql="<sql>"

Example:   
   mvn install -Dvdb="twitter" -Dsql="select * from tweet where query= 'jboss'" -Dusername="teiidUser" -Dpassword="pwd"

Note that the query is in quotes so that it is understood as a single argument.

You can see an execution example in "run.sh" helper.




