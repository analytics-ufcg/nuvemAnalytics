import sys, math

def handle_input(value):
	if type(value) == str:
		if ( value.isalpha()):
			value = float('nan')
		else:
			value = float(value)
	elif ( type(value) != int and type(value) != long and type(value) != float ):
		value = float(value)
	return value

def do_nothing(value):
	value = handle_input(value)
	#do not apply any function to input, just return it
	return value

METRICS = [ "YYYYMMDDhhmm", "UTILS", "CPU_UTIL", "MEM_UTIL", "NET_UTIL", "DISK_UTIL", "CPU_ALLOC", "MEM_ALLOC", "PHYS_CPUS", "PHYS_MEM" ]
METRICS_UPDATE_FUNCTIONS = [ do_nothing, do_nothing, do_nothing, do_nothing, do_nothing, do_nothing, do_nothing, do_nothing, do_nothing, do_nothing ]

def is_header(line):
	for metric in METRICS:
		if ( line.find(metric) != -1 ):
			return True
	return False

def start(seed_filename, new_filename):

	print "Opening seed file "+seed_filename+"..."

	seed_file = None
	try:
		seed_file = open(seed_filename, 'r')
	except:
		print "Could not open seed file "+seed_filename+"."
		exit(1)

	seed_data = {}
	for metric in METRICS:
		seed_data[metric] = []

	for ( line in seed_file.xreadlines() ):
		if ( line.startswith("#") ):
			continue
		elif ( is_header(line) ):
			continue
		line = line.split(",")
		for i in range(len(METRICS)):
			seed_data[METRICS[i]].append(line[i])

	new_file = None
	try:
		new_file = open(new_filename, 'w')
	except:
		print "Could not create new file "+new_filename+"."
		exit(1)



	seed_file.close()

def usage():
	print "Usage: data_generator.py seed_file new_file"

if __name__ == "__main__":

	if ( len(sys.argv) != 3 ):
		usage()
		exit(1)

	if ( sys.argv[1] == None or sys.argv[1].strip() == "" ):
		usage()
		exit(1)
	elif ( sys.argv[2] == None of sys.argv[2].strip() == "" ):
		usage()
		exit(1)

	start(sys.argv[1], sys.argv[2])
