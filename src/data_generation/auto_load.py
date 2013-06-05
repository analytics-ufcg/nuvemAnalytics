import shlex, subprocess, os, glob, pyodbc, sys

def executeQuery(sqlQueryFile):

    sqlFile = open(sqlQueryFile, 'r')
    sqlScript = sqlFile.read()
    sqlFile.close()

    dbConnection = None
    dbCursor = None

    # Create the cursor and the connection
    try:
        dbConnection = pyodbc.connect("DSN=Vertica")
        dbCursor = dbConnection.cursor()
    except pyodbc.Error:
        print "error: pyodbc could not connect to Vertica database"
        exit(4)
    except Exception, e:
        print "error: something odd happened while attempting to connect to Vertica database: " + str(e)
	exit(4)
 
    # Execute the DDL queries
    for sqlCode in sqlScript.split(";"):
        sqlCode = sqlCode.rstrip().lstrip() + ";"
        try:
            dbCursor.execute(sqlCode)
        except pyodbc.DataError:
            print "error: a problem (data error) happened while executing this query" + sqlQueryFile
            exit(5)
        except Exception, e:
            print "error: a problem (" + str(e) + ") happened while executing this query " + sqlQueryFile
            exit(5)

        if dbCursor.rowcount != -1:
            print "  " + str(dbCursor.rowcount) + " rows affected"

    # Commit all changes
    dbCursor.commit()

    # Close the cursor and the connection
    dbCursor.close()
    dbConnection.close()
   
'''
    SQL VARIABLES
'''
SQL_DIR = "../sql_scripts"

DROP_TABLE_SQL = SQL_DIR + "/ddl_scripts/DropTables.sql"
CREATE_TABLE_SQL = SQL_DIR + "/ddl_scripts/CreateTables.sql"
LOAD_TIME_TABLE_SQL = SQL_DIR + "/dml_scripts/load_scripts/LoadTimeTable.sql"
LOAD_OTHER_TABLES_SQL = SQL_DIR + "/dml_scripts/load_scripts/LoadVmAndFactTables.sql"

'''
    R VARIABLES
'''
TRACE_DIR = "../../data/traces/"
OUTPUT_DIR = "../../data/output/"
PERC_FAIL_COLLECT = 0.01
PERC_FAIL_METRIC = 0.05
FIRST_VM_ID = -1  # Default only (not used)
LAST_VM_ID = 0  # Default only (not used)

'''
    EXECUTION VARIABLES
'''
VMS_PER_LOAD = 1
RECREATE_TABLES = 0

if __name__ == '__main__':
    print "================ Auto Loading VMs ================"
    
    # Read input arguments
    if len(sys.argv) != 4:
        print "usage: python auto_load.py <first_vm_id> <last_vm_id> <recreate_tables>"
        exit(1)
    
    FIRST_VM_ID = int(sys.argv[1])
    LAST_VM_ID = int(sys.argv[2])
    RECREATE_TABLES = int(sys.argv[3])
    
    if FIRST_VM_ID > LAST_VM_ID:
        print "error: <first_vm_id> greater than <last_vm_id>"
        exit(1)
    
    if RECREATE_TABLES == 1:
        # Drop the old tables and crete the new ones
        print "DROP old tables from DB..."
        executeQuery(DROP_TABLE_SQL)
        print "CREATE new tables in DB..."
        executeQuery(CREATE_TABLE_SQL)

    initialVmId = 1
    loadedTimeTable = False
    
    while True:
        
        finalVmId = min(initialVmId + VMS_PER_LOAD - 1, LAST_VM_ID)
        
        print "\n======== VM Ids from " + str(initialVmId) + " to " + str(finalVmId) + " (up to " + str(LAST_VM_ID) + ") ========"

        if os.path.exists(OUTPUT_DIR + "cpu_1.csv"):
            print "Remove the old vm and fact tables..."
            for f in glob.glob(OUTPUT_DIR + "*.csv"):
                if not f.endswith("time.csv"):
                    os.remove(f)

        # RUN the DATA GENERATOR
        print "Run the data generator..."
        generationCall = "Rscript data_generator.R " + TRACE_DIR + " " + OUTPUT_DIR + " " + \
                          str(initialVmId) + " " + str(finalVmId) + " " + str(PERC_FAIL_COLLECT) + " " + str(PERC_FAIL_METRIC)
        subprocess.call(shlex.split(generationCall))
        
        if not loadedTimeTable:
            print "Load the TIME TABLE into DB..." 
            executeQuery(LOAD_TIME_TABLE_SQL)
            loadedTimeTable = True
        
        print "Load the VM and FACT TABLEs into DB..."
        executeQuery(LOAD_OTHER_TABLES_SQL)

        print

        if finalVmId == LAST_VM_ID:
            print "=================== We're DONE! =================="
            break
        else:
            initialVmId += VMS_PER_LOAD
    
