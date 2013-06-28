#!/usr/bin/python

import os, sys, pyodbc

class QueryResult:

	def __init__(self, column_names, rows):
		self.column_names = column_names
		self.rows = rows

# TO ADD NEW QUERIES JUST CREATE ANOTHER FUNCTION DEFINITION AS THE ONES BELOW
# AND THEN ADD A KEY VALUE PAIR (query_name, query_function) INTO THE QUERY_ADAPTERS DICTIONARY

def lowUsageVMs(start_date, end_date):

	(exit_status, message, rows) = execute_query(PATH_TO_QUERIES + "LowUsageVMs.sql", start_date, end_date)
	
	if ( exit_status != 0 ):
		return (exit_status, message, NO_OUTPUT)

	column_names = [
	{'name' : 'VM NAME', 'measurement' : ''},
	{'name' : '90th Percentile CPU', 'measurement' : 'cores'},
	{'name' : '90th Percentile DISK I/O', 'measurement' : 'MB/s'},
	{'name' : '90th Percentile NETWORK I/O', 'measurement' : 'Mb/s'}
	]
	
	return (exit_status, message, QueryResult(column_names, rows))	

def vmsOverMemAlloc(start_date, end_date):

	(exit_status, message, rows) = execute_query(PATH_TO_QUERIES + "VMsOverMemAlloc.sql", start_date, end_date)

	if ( exit_status != 0 ):
		return (exit_status, message, NO_OUTPUT)

	column_names = [
	{'name' : 'VM Name', 'measurement' : ''},
	{'name' : 'Peak MEMORY', 'measurement' : '%'},
	{'name' : 'MEMORY Allocation', 'measurement' : 'GB'}
	]

	return (exit_status, message, QueryResult(column_names, rows))

def vmsOverCPU(start_date, end_date):

	(exit_status, message, rows) = execute_query(PATH_TO_QUERIES + "VMsOverCPU.sql", start_date, end_date)

	if ( exit_status != 0 ):
		return (exit_status, message, NO_OUTPUT)

	column_names = [
	{'name' : 'VM Name', 'measurement' : ''},
	{'name' : 'Peak CPU', 'measurement' : '%'},
	{'name' : 'CORE Count', 'measurement' : ''}
	]

	return (exit_status, message, QueryResult(column_names, rows))

def vmsNetConstrained(start_date, end_date):

	(exit_status, message, rows) = execute_query(PATH_TO_QUERIES + "VMsNetConstrained.sql", start_date, end_date)

	if ( exit_status != 0 ):
		return (exit_status, message, NO_OUTPUT)

	column_names = [
	{'name' : 'VM Name', 'measurement' : ''},
	{'name' : '90th Percentile NETWORK I/O', 'measurement' : 'MB/s'}
	]

	return (exit_status, message, QueryResult(column_names, rows))

def highCPUQueueing(start_date, end_date):

        (exit_status, message, rows) = execute_query(PATH_TO_QUERIES + "HighCPUQueueing.sql", start_date, end_date)

        if ( exit_status != 0 ):
                return (exit_status, message, NO_OUTPUT)

        column_names = [
        {'name' : 'VM Name', 'measurement' : ''},
        {'name' : '90th Percentile CPU Queue', 'measurement' : ''},
	{'name' : '90th Percentile CPU', 'measurement' : '%'},
	{'name' : 'Average CPU', 'measurement' : '%'}
        ]

        return (exit_status, message, QueryResult(column_names, rows))

def vmsWithHighPagingRate(start_date, end_date):

        (exit_status, message, rows) = execute_query(PATH_TO_QUERIES + "VMsHighPagingRate.sql", start_date, end_date)

        if ( exit_status != 0 ):
                return (exit_status, message, NO_OUTPUT)

        column_names = [
        {'name' : 'VM Name', 'measurement' : ''},
        {'name' : '90th Percentile Memory Paging', 'measurement' : 'pages/s'},
        {'name' : '90th Percentile Memory', 'measurement' : '%'}
        ]

        return (exit_status, message, QueryResult(column_names, rows))


def metricTimeSeries(start_date, end_date, vm_name, table, metric):

	def autoQueryDefinition(vm_name, table, metric, start_date, end_date):

		select_clause = "select T.date_time, X." + metric
		from_clause = "from vm_dim as V, time_dim as T, " + table + " as X"
		where_clause = "where T.date_time >= '" + start_date + "' and T.date_time <= '" + end_date + \
				"' and V.vm_name = '" + vm_name + "' and X.id_time = T.id_time and X.id_vm = V.id_vm"
		order_clause = "order by T.date_time"

		return select_clause + "\n" + from_clause + "\n" + where_clause + "\n" + order_clause + ";"

	auto_query = autoQueryDefinition(vm_name, table, metric, start_date, end_date)

	print auto_query

        (exit_status, message, rows) = execute_query(sql_query_string = auto_query)

        if ( exit_status != 0 ):
                return (exit_status, message, NO_OUTPUT)

        column_names = [
        {'name' : 'Date Time', 'measurement' : ''},
        {'name' : metric, 'measurement' : ''}
        ]

        return (exit_status, message, QueryResult(column_names, rows))


################## END OF QUERY DEFINITIONS #####################

PATH_TO_QUERIES = "../../sql_scripts/dml_scripts/queries/"

QUERY_ADAPTERS = {}
QUERY_ADAPTERS['lowUsageVMs'] = lowUsageVMs
QUERY_ADAPTERS['vmsOverMemAlloc'] = vmsOverMemAlloc
QUERY_ADAPTERS['vmsOverCPU'] = vmsOverCPU
QUERY_ADAPTERS['vmsNetConstrained'] = vmsNetConstrained
QUERY_ADAPTERS['highCPUQueueing'] = highCPUQueueing
QUERY_ADAPTERS['vmsWithHighPagingRate'] = vmsWithHighPagingRate
QUERY_ADAPTERS['metricTimeSeries'] = metricTimeSeries

QUERY_CODES = []
QUERY_CODES.append('lowUsageVMs')
QUERY_CODES.append('vmsOverMemAlloc')
QUERY_CODES.append('vmsOverCPU')
QUERY_CODES.append('vmsNetConstrained')
QUERY_CODES.append('metricTimeSeries')
QUERY_CODES.append('highCPUQueueing')
QUERY_CODES.append('vmsWithHighPagingRate')

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

def filter_out(text, pattern):

	actual_find = text.find(pattern)
	while (actual_find != -1):

		next_find = text.find("'", actual_find+16)
		text = text[:actual_find+16] + text[next_find:]
		actual_find = text.find(pattern, next_find)

	return text

def execute_query(sql_query_file = None, start_date = None, end_date = None, sql_query_string = None):

	sql_code = ""

	if sql_query_file != None and start_date != None and end_date != None:
	        sql_file = open(os.path.join("..", "client", sql_query_file), 'r')
        	sql_code = sql_file.read()
	        sql_file.close()

        	sql_code = filter_out(sql_code, "T.date_time >= '")
	        sql_code = sql_code.replace("T.date_time >= ''", "T.date_time >= '" + start_date + "'")

        	sql_code = filter_out(sql_code, "T.date_time <= '")
	        sql_code = sql_code.replace("T.date_time <= ''", "T.date_time <= '" + end_date + "'")
	elif sql_query_string != None:
		sql_code = sql_query_string
	else:
		exit_status = 4
		message = "error: both the sql_query_file and the sql_query_string are null"		
		return (exit_status, message, NO_OUTPUT)

	try:
		DB_CURSOR.execute(sql_code)
	except pyodbc.DataError:
		exit_status = 5
		message = "error: a problem (data error) happened while executing this query " + sql_code
		return (exit_status, message, NO_OUTPUT)
	except Exception, e:
		exit_status = 5
		message = "error: a problem (" + str(e) + ") happened while executing this query " + sql_code
		return (exit_status, message, NO_OUTPUT)

	rows = DB_CURSOR.fetchall()
	exit_status = 0
	message = "Query completed succesfully!"
	return (exit_status, message, rows)


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

	def check_and_query(self, query_identifier, start_date, end_date, vm_name = None, table_name = None, metric_name = None):

		global DB_CURSOR
		global DB_CONNECTION

		if (query_identifier == None):
		
			exit_status = 2
			message = "error: query identifier cannot be null"
			return (exit_status, message, NO_OUTPUT)
		
		elif (start_date == None or end_date == None):
		
			exit_status = 3
			message = "error: both start and end dates cannot be null"
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
			if __name__ == "__main__":
				print ">: Connecting to Vertica..."
			DB_CONNECTION = pyodbc.connect("DSN=TestVertica")
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
			print ">: Connection successful!"
			print ">: Executing query '" + query_name + "'... from " + start_date + " to " + end_date

		if vm_name != None and table_name != None and metric_name != None:
			(exit_status, message, output) = metricTimeSeries(start_date, end_date, vm_name, table_name, metric_name)
		else:
			(exit_status, message, output) = QUERY_ADAPTERS[query_identifier](start_date, end_date)

		if __name__ == "__main__":
			print ">: Query complete. We got the following results:"

			if exit_status == 0:
	
				header = ""
				for i in range(len(output.column_names)):
					header += "%s (%s) \t\t" % (output.column_names[i]['name'], output.column_names[i]['measurement'])
				print header
	
				for row in output.rows:
					formatted_row = ""
					for i in range(len(row)):
						formatted_row += str(row[i]) + "\t\t"
					print formatted_row
			else:
				print ">: No results..."

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
