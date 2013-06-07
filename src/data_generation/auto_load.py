import shlex, subprocess, os, glob, pyodbc, sys

def executeQuery(sqlQueryFile, isLoad):

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
            if (isLoad):
                dbCursor.execute(sqlCode, OUTPUT_DIR_NAME)
            else:
                dbCursor.execute(sqlCode)
        except pyodbc.DataError:
            print "error: a problem (data error) happened while executing this query" + sqlCode
            exit(5)
        except Exception, e:
            print "error: a problem (" + str(e) + ") happened while executing this query " + sqlCode
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
DATA_DIR = "../../data/"
TRACE_DIR = "../../data/traces/"
PERC_FAIL_COLLECT = 0.01
PERC_FAIL_METRIC = 0.05

'''
    EXECUTION VARIABLES
'''
VMS_PER_LOAD = 1
RECREATE_TABLES = 0
LOAD_TIME_TABLE = 0

if __name__ == '__main__':
    print "================ Auto Loading VMs ================"
    
    # Read input arguments
    if len(sys.argv) != 6:
        print "usage: python auto_load.py <first_vm_id> <last_vm_id> <recreate_tables> <load_time_table> <output_dir_name>"
        exit(1)
    
    FIRST_VM_ID = int(sys.argv[1])
    LAST_VM_ID = int(sys.argv[2])
    RECREATE_TABLES = int(sys.argv[3])
    LOAD_TIME_TABLE = int(sys.argv[4])
    OUTPUT_DIR_NAME = sys.argv[5]
    
    if FIRST_VM_ID > LAST_VM_ID:
        print "error: <first_vm_id> greater than <last_vm_id>"
        exit(1)
    
    if not RECREATE_TABLES in [0, 1]:
        print "error: <recreate_tables> should be 0 or 1"
        exit(1)
   
    if not LOAD_TIME_TABLE in [0, 1]:
        print "error: <load_time_table> should be 0 or 1"
        exit(1)

#     if not os.path.exists(OUTPUT_DIR):
#         print "error: unexistent <output_dir>"
#         exit(1)
    
    # Start the script
    
    if RECREATE_TABLES == 1:
        # Drop the old tables and crete the new ones
        print "DROP old tables from DB..."
        executeQuery(DROP_TABLE_SQL)
        print "CREATE new tables in DB..."
        executeQuery(CREATE_TABLE_SQL)

    initialVmId = FIRST_VM_ID
    loadedTimeTable = False
    outputDir = DATA_DIR + OUTPUT_DIR_NAME + "/"
    
    while True:
        
        finalVmId = min(initialVmId + VMS_PER_LOAD - 1, LAST_VM_ID)
        
        print "\n======== VM Ids from " + str(initialVmId) + " to " + str(finalVmId) + " (up to " + str(LAST_VM_ID) + ") ========"

        if os.path.exists(outputDir + "cpu_1.csv"):
            print "Remove the old vm and fact tables..."
            for f in glob.glob(outputDir + "*.csv"):
                if not f.endswith("time.csv"):
                    os.remove(f)

        # RUN the DATA GENERATOR
        print "Run the data generator..."
        generationCall = "Rscript data_generator.R " + TRACE_DIR + " " + outputDir + " " + \
                          str(initialVmId) + " " + str(finalVmId) + " " + str(PERC_FAIL_COLLECT) + " " + str(PERC_FAIL_METRIC)
        subprocess.call(shlex.split(generationCall))
        
        if LOAD_TIME_TABLE == 1 and not loadedTimeTable:
            print "Load the TIME TABLE into DB..." 
            executeQuery(LOAD_TIME_TABLE_SQL, isLoad=True)
            loadedTimeTable = True
        
        print "Load the VM and FACT TABLEs into DB..."
        executeQuery(LOAD_OTHER_TABLES_SQL, isLoad=True)

        print ""
        sys.stdout.flush()

        if finalVmId == LAST_VM_ID:
            print "=================== We're DONE! =================="
            break
        else:
            initialVmId += VMS_PER_LOAD
    
