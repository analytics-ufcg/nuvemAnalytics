import shlex, subprocess, shutil, os, glob
import sys, pyodbc

def executeQuery(sqlQueryFile):

    sqlFile = open(sqlQueryFile, 'r')
    sqlCode = sqlFile.read()
    sqlFile.close()
    print sqlCode
# 
#     try:
#         DB_CURSOR.execute(sqlCode)
#     except pyodbc.DataError:
#         print "error: a problem (data error) happened while executing this query" + sql_query_file
#         exit(5)
#     except Exception, e:
#         print "error: a problem (" + str(e) + ") happened while executing this query " + sql_query_file
#         exit(5)
# 
#     try:
#         rows = DB_CURSOR.fetchall()
#         for row in rows:
#             print row
#     except Exception, e:
#         exit(5)
    pass

'''
    RUN: DropTables.sql
    RUN: CreateTables.sql

    LOOP:
        RUN: data generator
        RUN: LoadTimeTable.sql (only once)
        RUN: LoadVmAndFactTables.sql
        
        Delete the generated data
    
'''

'''
    GLOBAL SQL VARIABLES
'''
SQL_DIR = "../sql_scripts"

DROP_TABLE_SQL = SQL_DIR + "/ddl_scripts/DropTables.sql"
CREATE_TABLE_SQL = SQL_DIR + "/ddl_scripts/CreateTables.sql"
LOAD_TIME_TABLE_SQL = SQL_DIR + "/dml_scripts/load_scripts/LoadTimeTable.sql"
LOAD_OTHER_TABLES_SQL = SQL_DIR + "/dml_scripts/load_scripts/LoadVmAndFactTables.sql"

'''
    GLOBAL R VARIABLES
'''
TRACE_DIR = "../../data/traces/"
OUTPUT_DIR = "../../data/output/"
FIRST_VM_ID = 1
LAST_VM_ID = 3
PERC_FAIL_COLLECT = 0.01
PERC_FAIL_METRIC = 0.05

VMS_PER_LOAD = 1

if __name__ == '__main__':
    print "================ Auto Loading VMs ================"
    print "DROP old tables from DB..."
#     executeQuery(DROP_TABLE_SQL)
    print "CREATE new tables in DB...\n"
#     executeQuery(CREATE_TABLE_SQL)
    
    initialVmId = 1
    
    while True:
        
        lastVmId = min(initialVmId + VMS_PER_LOAD - 1, LAST_VM_ID)
        
        print "======== VM Ids from " + str(initialVmId) + " to " + str(lastVmId) + " ========"

        if os.path.exists(OUTPUT_DIR + "cpu_1.csv"):
            print "Remove the old vm and fact tables..."
            for f in glob.glob(OUTPUT_DIR + "*.csv"):
                if not f.endswith("time.csv"):
                    os.remove(f)

        # RUN the DATA GENERATOR
        print "Run the data generator..."
        generationCall = "Rscript data_generator.R " + TRACE_DIR + " " + OUTPUT_DIR + " " + \
                          str(initialVmId) + " " + str(lastVmId) + " " + str(PERC_FAIL_COLLECT) + " " + str(PERC_FAIL_METRIC)
#         print generationCall
        subprocess.call(shlex.split(generationCall))
        
        print "Load generated data into DB..." 
#         executeQuery(LOAD_TIME_TABLE_SQL)
#         executeQuery(LOAD_OTHER_TABLES_SQL)

#     try:
#         DB_CONNECTION = pyodbc.connect("DSN=Vertica")
#         DB_CURSOR = DB_CONNECTION.cursor()
#     except pyodbc.Error:
#         print "error: pyodbc could not connect to Vertica database"
#         exit(4)
#     except Exception, e:
#         print "error: something odd happened while attempting to connect to Vertica database: " + str(e)
# 
#     DB_CURSOR.close()
#     DB_CONNECTION.close()

        print "\n"

        if lastVmId == LAST_VM_ID:
            print "=================== We're DONE! =================="
            break
        else:
            initialVmId += VMS_PER_LOAD
        
