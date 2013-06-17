import  os, sys, json, itertools, copy
from flask import Flask, render_template

sys.path.append("../client")
from vertica_query import VerticaClientFacade

server = Flask(__name__)

def execute_query(query_identifier, start_date, end_date, response):

	client = VerticaClientFacade()

	(exit_status, message, output) = client.check_and_query(query_identifier, start_date, end_date)

	response['exit_status'] = exit_status
	response['message'] = message

	if (exit_status != 0):
		return

	# Add the children conditionally just if there is any answer 
	if len(output.rows) > 0:
		query_results = {
			'name' : query_identifier,
			'children' : []
		}

		for row in output.rows:
			# vm_info
			# size: All VMs have equal size
			# name: We assume that the first column is always the VM name
			vm_info = {'size' : 1, 'name' : row[0]}
			
			for i in range(1, len(output.column_names)):
			
				vm_info[output.column_names[i]['name']] = {
					'value' : row[i],
					'measurement' : output.column_names[i]['measurement'],
				}
	
			query_results['children'].append(vm_info)
	
		response['children'].append(query_results)


def aggregate_problems(start_date, end_date, response):
	
	# Get the query_names, vm_names and query_vm_info's
	query_names = []
	query_vms_map = {}
	query_vms_info_map = {}
	for child_query in response['children']:
		query_names.append(child_query['name'])
		
		query_vms = []
		for vm_info in child_query['children']:
			query_vms.append(vm_info['name'])
		query_vms_map[child_query] = query_vms
		
		query_vms_info_map[child_query] = child_query['children']

		response = { 
		'name' : '',  # Remember to add the 'subutilization' then...
		'children' : []
	}
	
	combs = []
	for i in range(len(query_names), 0, -1):
		combs.extend([list(x) for x in itertools.combinations(query_names, i)])
		
	for comb in combs:
		print comb
		vm_comb = []
		
		# Query Intersection 
		for i in xrange(0, len(comb)):
			if len(vm_comb) > 0:
				vm_comb = list(set(vm_comb) & set(query_vms_map[comb[i]]))
			else:
				vm_comb.extend(query_vms_map[comb[i]])


		# Remove the VMs from the initial query map
		for vm in vm_comb:
			for i in xrange(0, len(comb)):
				query_vms_map[comb[i]].remove(vm)
				
		print vm_comb
		
		# Create the new response
		if len(vm_comb) > 0:
			query_results = {
				'name' : ' - '.join(comb),
				'children' : []
			}
	
			for vm in vm_comb:
				for info in query_vms_info_map[comb[0]]:
					if info['name'] == vm:
						query_results['children'].append(info)
						break;
				
			response['children'].append(query_results)
		
		print


@server.route('/')
def index():
	return render_template("index.html")

@server.route('/subutilization/<start_date>/<end_date>')
def do_subutilization_queries(start_date=None, end_date=None):

	response = { 
		'name' : '',  # Remember to add the 'subutilization' then...
		'children' : []
	}

	execute_query("vmsOverMemAlloc", start_date, end_date, response)
	if response['exit_status'] != 0:
		pass  # flash this error

	execute_query("vmsOverCPU", start_date, end_date, response)
	if response['exit_status'] != 0:
		pass  # flash this error
	
	execute_query("lowUsageVMs", start_date, end_date, response)
	if response['exit_status'] != 0:
		pass  # flash this error

	# Aggregate problems
	aggregate_problems(start_date, end_date, response)

	return render_template("index.html", response=json.dumps(response))

@server.route('/superutilization/<start_date>/<end_date>')
def do_superutilization_queries(start_date=None, end_date=None):

	response = { 
		'name' : '',  # Remember to add the 'superutilization' then...
		'children' : []
	}

	execute_query("vmsNetConstrained", start_date, end_date, response)
	if response['exit_status'] != 0:
		pass  # flash this error

	return render_template("index.html", response=json.dumps(response))


if __name__ == "__main__":

	port = int(os.environ.get("PORT", 80))
	server.run(host="150.165.15.173", port=port, debug=True)
