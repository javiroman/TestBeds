/*
 * JBoss, Home of Professional Open Source.
 * See the COPYRIGHT.txt file distributed with this work for information
 * regarding copyright ownership.  Some portions may be licensed
 * to Red Hat, Inc. under one or more contributor license agreements.
 * 
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 * 
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
 * 02110-1301 USA.
 */
import java.sql.Connection;
import java.sql.DriverManager; // Driver Class JDBC method connection.
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Statement;

import org.teiid.jdbc.TeiidDataSource;
import org.teiid.jdbc.TeiidStatement;

@SuppressWarnings("nls")
public class JDBCClient {
	
	public static final String USERNAME = "username";
	public static final String PASSWORD = "password";
	
	public static final String USERNAME_DEFAULT = "user";
	public static final String PASSWORD_DEFAULT = "user";
	
	public static void main(String[] args) throws Exception {
		if (args.length < 4) {
			System.out.println("usage: JDBCClient <host> <port> <vdb> <sql-command>");
			System.exit(-1);
		}

		System.out.println("Executing using the TeiidDriver");
		boolean isSelect = execute(getDriverConnection(args[0], args[1], args[2]), args[3]);

        	// only if its a Select will the SQL be performed again using TeiidDataSource
		if (isSelect) {
			System.out.println("-----------------------------------");
			System.out.println("Executing using the TeiidDataSource");
			// this is showing how to make a Data Source connection. 
			execute(getDataSourceConnection(args[0], args[1], args[2]), args[3]);
		}
	}
	
	/*
	 * Creating the Driver Class JDBC connection using DriverManager.getConnection) method.
	 */
	static Connection getDriverConnection(String host, String port, String vdb) throws Exception {
		/*
		 * The Driver Connection URL format:
		 *
		 * jdbc:teiid:VDB-NAME@ mm[s]://HOSTNAME:PORT;[prop-name=prop-value;]*
		 *
		 * VDB-NAME - The name of the virtual database (VD B) to which the application is connected.
		 * mm[s] - The JBoss Data Virtualization JDBC protocol. mm is the default for normal
		 * connections. mms uses SSL for encryption and is the default for the AdminAPI tools.
		 * HOSTNAME - The server where JBoss Data Virtualization is installed.
		 * PORT - The port on which JBoss D ata Virtualization is listening for incoming JDBC connections.
		 * [prop-name=prop-value] - Any number of additional name-value pairs can be supplied in the URL,
		 * separated by semi-colons. Property values must be URL encoded if they
		 * contain reserved characters, for example, ?, = , and ; A list of connection
		 * properties here: Red_Hat_JBoss_Data_Virtualization->Development_Guide_Volume_1_Client_Development->
		 * Connection_Properties_for_the_Driver_and_Data_Source_Classes documentation.
		 *
		 * For example "showplan=on" returns the query plan of the VDB Teiid query.
		 */
		String url = "jdbc:teiid:"+vdb+"@mm://"+host+":"+port+";showplan=on"; //note showplan setting
		Class.forName("org.teiid.jdbc.TeiidDriver");
		
		return DriverManager.getConnection(url,getUserName(), getPassword());		
	}
	
	static Connection getDataSourceConnection(String host, String port, String vdb) throws Exception {
		TeiidDataSource ds = new TeiidDataSource();
		ds.setDatabaseName(vdb);
		ds.setUser(getUserName());
		ds.setPassword(getPassword());
		ds.setServerName(host);
		ds.setPortNumber(Integer.valueOf(port));
		
		ds.setShowPlan("on"); //turn show plan on
		
		return ds.getConnection();
	}
	
	static String getUserName() {
		return (System.getProperties().getProperty(USERNAME) != null ? System.getProperties().getProperty(USERNAME) : USERNAME_DEFAULT );
	}
	
	static String getPassword() {
		return (System.getProperties().getProperty(PASSWORD) != null ? System.getProperties().getProperty(PASSWORD) : PASSWORD_DEFAULT );
	}
	
	/*
	 * Take a look to "Processing SQL Statements with JDBC":
	 * https://docs.oracle.com/javase/tutorial/jdbc/basics/processingsqlstatements.html#executing_queries
	 */
	public static boolean execute(Connection connection, String sql) throws Exception {
        
		boolean hasRs = true;
			try {
				Statement statement = connection.createStatement();
				
				hasRs = statement.execute(sql);
				
				if (!hasRs) {
					int cnt = statement.getUpdateCount();
					System.out.println("----------------\r");
					System.out.println("Updated #rows: " + cnt);
					System.out.println("----------------\r");
				} else {
					ResultSet results = statement.getResultSet();
					ResultSetMetaData metadata = results.getMetaData();
					int columns = metadata.getColumnCount();
					System.out.println("Results");
					for (int row = 1; results.next(); row++) {
						System.out.print(row + ": ");
						for (int i = 0; i < columns; i++) {
							if (i > 0) {
								System.out.print(",");
							}
							System.out.print(results.getString(i+1));
						}
						System.out.println();
					}
					results.close();
				}
				System.out.println("Query Plan");
				System.out.println(statement.unwrap(TeiidStatement.class).getPlanDescription());
				
				statement.close();
			} catch (SQLException e) {
				e.printStackTrace();
			} finally {
				if (connection != null) {
					connection.close();
				}
			}
			return hasRs;
		}

}
