#!/usr/bin/python

import os
import sys
import pyodbc

def execute_query(sql_query_file, start_date, end_date):

	sql_code = None

	sql_file = open(sql_query_file, 'r')
	sql_code = sql_file.read()
	sql_file.close()

	sql_code = sql_code[ : sql_code.find("T.date_time >= '") + 16 ] + sql_code[ sql_code.find("'", sql_code.find("T.date_time >= '") + 16) : ]
	sql_code = sql_code[ : sql_code.find("T.date_time <= '") + 16 ] + sql_code[ sql_code.find("'", sql_code.find("T.date_time <= '") + 16) : ]
	
	sql_code = sql_code.replace("T.date_time >= ''", "T.date_time >= '" + start_date + "'")
	sql_code = sql_code.replace("T.date_time <= ''", "T.date_time <= '" + end_date + "'")

	try:
		DB_CURSOR.execute(sql_code)
	except pyodbc.DataError:
		print "error: a problem (data error) happened while executing this query"+sql_query_file
		exit(5)
	except Exception, e:
		print "error: a problem ("+str(e)+") happened while executing this query "+sql_query_file
		exit(5)

#TO ADD NEW QUERIES JUST CREATE ANOTHER FUNCTION DEFINITION AS THE ONES BELOW
#AND THEN ADD A KEY VALUE PAIR (query_name, query_function) INTO THE QUERY_ADAPTERS DICTIONARY

def lowUsageVMs(start_date, end_date):

	print ">: Executing query 'lowUsageVMs'... from "+start_date+" to "+end_date
	print ">: Beware this will take a while..."

	execute_query("LowUsageVMs.sql", start_date, end_date)

	print ">: Query complete. We got the following results:"

	print "VM NAME\t\t90th PERCENTILE CPU (cores)\t90th DISK I/O (MB/s)\t90th PERCENTILE NETWORK I/O (MB/s)"
	rows = DB_CURSOR.fetchall()
	for row in rows:
		print row

def vmsOverMemAlloc(start_date, end_date):

	print ">: Executing query 'vmsOverMemAlloc'... from "+start_date+" to "+end_date

	execute_query("VMsOverMemAlloc.sql", start_date, end_date)

	print ">: Query complete. We got the following results:"

	print "VM NAME\t\tPEAK MEMORY (%)\tMEMORY ALLOCATION (GB)"
	rows = DB_CURSOR.fetchall()
	for row in rows:
		print "%s\t\t%.5f\t\t%.3f" % (row[0], row[1], row[2])


def exampleQuery(start_date, end_date):
	print "executing exampleQuery"
	print "start date is:", start_date
	print "end date is:", end_date
	pass

QUERY_ADAPTERS = {}
QUERY_ADAPTERS['lowUsageVMs'] = lowUsageVMs
QUERY_ADAPTERS['vmsOverMemAlloc'] = vmsOverMemAlloc
QUERY_ADAPTERS['exampleQuery'] = exampleQuery

QUERY_CODES = []
QUERY_CODES.append('lowUsageVMs')
QUERY_CODES.append('vmsOverMemAlloc')
QUERY_CODES.append('exampleQuery')

DATE_FORMAT = "%Y-%m-%d %H-%M-%S" #Accepts only dates in this format YYYY-MM-DD HH:MM:SS e.g. 2002-08-22 13:54:22

RANGES = [] #Ranges are inclusive
RANGES.append((1950, 2013)) 	#YEAR
RANGES.append((1, 12))		#MONTH
RANGES.append((1, 31))		#DAY
RANGES.append((0, 23))		#HOUR
RANGES.append((0, 59))		#MINUTE
RANGES.append((0, 59))		#SECOND

DB_CONNECTION = None
DB_CURSOR = None

def in_range(number, range_index):
	number = int(number)
	return RANGES[range_index][0] <= number <= RANGES[range_index][1]


def valid_date(a_date):
	if a_date.count("-") != 2:
		return False
	elif a_date.count(":") != 2:
		return False
	elif a_date.strip().count(" ") != 1:
		return False

	parts = a_date.split(" ")
	numbers = parts[0].split("-") + parts[1].split(":")

	if len(numbers[0]) != 4:
		return False
	
	for i in range(len(numbers)):
		if ( i != 0 and not len(numbers[i]) == 2 ):
			return False
		if ( not numbers[i].isdigit() or not in_range(numbers[i], i) ):
			return False
	
	return True
	
if __name__ == "__main__":

	if len(sys.argv) != 4:
		print "usage: python vertica_query [<query_name> | <query_code>] <\"start_date\"> <\"end_date\">"
		print "date format: \"YYYY-MM-DD HH:MM:SS\""
		print "codes:"
		for i in range(len(QUERY_CODES)):
			print "\t", i, " - ", QUERY_CODES[i]
		exit(1)
		
	query_code = sys.argv[1]
	query_name = None
	if ( query_code.isdigit() ):
		if ( 0 <= int(query_code) <= len(QUERY_CODES) ):
			query_name = QUERY_CODES[int(query_code)]
		else:
			print "error: invalid query code"
			exit(2)
	else:
		query_name = query_code

	start_date = sys.argv[2]
	end_date = sys.argv[3]
	
	if ( query_name not in QUERY_ADAPTERS ):
		print "error: invalid query name"
		exit(2)
	
	if ( not valid_date(start_date) or not valid_date(end_date) ):
		print "error: both start and end dates must be valid"
		exit(3)

	try:
		DB_CONNECTION = pyodbc.connect("DSN=Vertica")
		DB_CURSOR = DB_CONNECTION.cursor()
	except pyodbc.Error:
		print "error: pyodbc could not connect to Vertica database"
		exit(4)
	except Exception, e:
		print "error: something odd happened while attempting to connect to Vertica database: "+str(e)

	QUERY_ADAPTERS[query_name](start_date, end_date)

	DB_CURSOR.close()
	DB_CONNECTION.close()