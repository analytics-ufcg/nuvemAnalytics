import sys

#TO ADD NEW QUERIES JUST CREATE ANOTHER FUNCTION DEFINITION AS THE ONES BELOW
#AND THEN ADD A KEY VALUE PAIR (query_name, query_function) INTO THE QUERY_ADAPTERS DICTIONARY

def lowUsageVMs(start_date, end_date):
	print "executing lowUsageVMs"
	print "start date is:", start_date
	print "end date is:", end_date

def vmsOverMemAlloc(start_date, end_date):
	print "executing vmsOverMemAlloc"
	print "start date is:", start_date
	print "end date is:", end_date

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
		print "usage: python vertica_query.py [<query_name> | <query_code>] <\"start_date\"> <\"end_date\">"
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
	
	QUERY_ADAPTERS[query_name](start_date, end_date)
	
