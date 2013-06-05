#!/usr/bin/python

import sys
import pyodbc

class QueryResult:

	def __init__(self, column_names, rows):
		self.column_names = column_names
		self.rows = rows

# TO ADD NEW QUERIES JUST CREATE ANOTHER FUNCTION DEFINITION AS THE ONES BELOW
# AND THEN ADD A KEY VALUE PAIR (query_name, query_function) INTO THE QUERY_ADAPTERS DICTIONARY

def lowUsageVMs(start_date, end_date):

	(exit_status, message, output) = execute_query("LowUsageVMs.sql", start_date, end_date)
	
	if ( exit_status != 0 ):
		return (exit_status, message, NO_OUTPUT)

	column_names = [
	{'name' : 'VM NAME', 'measurement' : ''},
	{'name' : '90th PERCENTILE CPU', 'measurement' : 'cores'},
	{'name' : '90th PERCENTILE NETWORK I/O', 'measurement' : 'MB/s'}
	]
	
	rows = DB_CURSOR.fetchall()
	
	return (exit_status, message, QueryResult(column_names, rows))	

def vmsOverMemAlloc(start_date, end_date):

	(exit_status, message, output) = execute_query("VMsOverMemAlloc.sql", start_date, end_date)

	if ( exit_status != 0 ):
		return (exit_status, message, NO_OUTPUT)

	column_names = [
	{'name' : 'VM NAME', 'measurement' : ''},
	{'name' : 'PEAK MEMORY', 'measurement' : '%'},
	{'name' : 'MEMORY ALLOCATION', 'measurement' : 'GB'}
	]

	rows = DB_CURSOR.fetchall()

	return (exit_status, message, QueryResult(column_names, rows))

################## END OF QUERY DEFINITIONS #####################

QUERY_ADAPTERS = {}
QUERY_ADAPTERS['lowUsageVMs'] = lowUsageVMs
QUERY_ADAPTERS['vmsOverMemAlloc'] = vmsOverMemAlloc

QUERY_CODES = []
QUERY_CODES.append('lowUsageVMs')
QUERY_CODES.append('vmsOverMemAlloc')

DATE_FORMAT = "%Y-%m-%d %H-%M-%S"  # Accepts only dates in this format YYYY-MM-DD HH:MM:SS e.g. 2002-08-22 13:54:22

RANGES = []  # Ranges are inclusive
RANGES.append((1950, 2013))  # YEAR
RANGES.append((1, 12))  # MONTH
RANGES.append((1, 31))  # DAY
RANGES.append((0, 23))  # HOUR
RANGES.append((0, 59))  # MINUTE
RANGES.append((0, 59))  # SECOND

DB_CONNECTION = None
DB_CURSOR = None

NO_OUTPUT = None


def execute_query(sql_query_file, start_date, end_date):

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

		exit_status = 5
		message = "error: a problem (data error) happened while executing this query" + sql_query_file
		return (exit_status, message, NO_OUTPUT)

	except Exception, e:

		exit_status = 5
		message = "error: a problem (" + str(e) + ") happened while executing this query " + sql_query_file
		return (exit_status, message, NO_OUTPUT)



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
		if (i != 0 and not len(numbers[i]) == 2):
			return False
		if (not numbers[i].isdigit() or not in_range(numbers[i], i)):
			return False
	
	return True

class VerticaClientFacade:

	def check_and_query(self, query_identifier, start_date, end_date):

		if (query_identifier == None):
		
			exit_status = 2
			message = "error: query identifier cannot be null"
			return (exit_status, message, NO_OUTPUT)
		
		elif (start_date == None or end_date == None):
		
			exit_status = 3
			message = "error: both start and end ates cannot be null"
			return (exit_status, message, NO_OUTPUT)

		query_code = query_identifier
		query_name = None
		if (query_code.isdigit()):
			if (0 <= int(query_code) <= len(QUERY_CODES)):
				query_name = QUERY_CODES[int(query_code)]
			else:
				exit_status = 2
				message = "error: invalid query code"
				return (exit_status, message, NO_OUTPUT)
		else:
			query_name = query_code

		if (query_name not in QUERY_ADAPTERS):
			exit_status = 2
			message = "error: invalid query name"
			return (exit_status, message, NO_OUTPUT)
		
		if (not valid_date(start_date) or not valid_date(end_date)):
			exit_status = 3
			message = "error: both start and end dates must be valid"
			return (exit_status, message, NO_OUTPUT)

		try:
			DB_CONNECTION = pyodbc.connect("DSN=Vertica")
			DB_CURSOR = DB_CONNECTION.cursor()
		except pyodbc.Error:
			exit_status = 4
			message = "error: pyodbc could not connect to Vertica database"
			return (exit_status, message, NO_OUTPUT)
		except Exception, e:
			exit_status = 5
			message = "error: something odd happened while attempting to connect to Vertica database: " + str(e)
			return (exit_status, message, NO_OUTPUT)

		if __name__ == "__main__":
			print ">: Executing query '" + query_name + "'... from " + start_date + " to " + end_date

		(exit_status, message, output) = QUERY_ADAPTERS[query_name](start_date, end_date)

		if __name__ == "__main__":
			print ">: Query complete. We got the following results:"

		header = ""
		for i in range(len(output.column_names)):
			header += "%s (%s) \t\t" % (output.column_names[i]['name'], output.column_names[i]['measurement'])
		print header

		for row in output.rows:
			formatted_row = ""
			for i in range(len(row)):
				formatted_row += row[i] + "\t\t"
			print formatted_row

		DB_CURSOR.close()
		DB_CONNECTION.close()

		return (exit_status, message, output)

if __name__ == "__main__":

	if len(sys.argv) != 4:
		print "usage: python vertica_query [<query_name> | <query_code>] <\"start_date\"> <\"end_date\">"
		print "date format: \"YYYY-MM-DD HH:MM:SS\""
		print "codes:"
		for i in range(len(QUERY_CODES)):
			print "\t", i, " - ", QUERY_CODES[i]
		exit(1)


	client = VerticaClientFacade()
	(exit_status, message, output) = client.check_and_query(sys.argv[1], sys.argv[2], sys.argv[3])
	if ( exit_status != 0 ):
		print message
		exit(exit_status)
