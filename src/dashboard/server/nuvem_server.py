import  os, sys, json, itertools
from flask import Flask, render_template, request, flash

sys.path.append("../client")
from vertica_query import VerticaClientFacade

server = Flask(__name__)
server.secret_key = os.urandom(24)

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
			'children' : [],
			'type' : 'vm_set',
			'query_columns' : {},
			'query_names' : []
		}

		query_results['query_names'].append(query_identifier)

		query_results['query_columns'][query_identifier] = []
		for i in range (1, len(output.column_names)):
			query_results['query_columns'][query_identifier].append(output.column_names[i]['name'])

		for row in output.rows:
			# vm_info
			# size: All VMs have equal size
			# name: We assume that the first column is always the VM name
			vm_info = {'size' : 1,
					   'name' : row[0],
					   'type' : 'vm',
					   'values' : list(row[1:len(row)])}
			
			query_results['children'].append(vm_info)

		if 'children' not in response:
			response['children'] = []
		response['children'].append(query_results)


def aggregate_problems(start_date, end_date, response):
	
	if 'children' not in response:
		return response

	# Get the query_names, vm_names and query_vm_info's
	query_names = []
	query_vms_map = {}
	query_col_map = {}
	query_vms_info_map = {}
	for child_query in response['children']:
		query_names.append(child_query['name'])
		
		query_vms = []
		for vm_info in child_query['children']:
			query_vms.append(vm_info['name'])
		query_vms_map[child_query['name']] = query_vms
		
		query_col_map[child_query['name']] = child_query['query_columns'][child_query['name']]
		
		query_vms_info_map[child_query['name']] = child_query['children']

	response_json = { 
		'name' : '',  # Remember to add the 'subutilization' then...
		'children' : []
	}
	
	combs = []
	for i in range(len(query_names), 0, -1):
		combs.extend([list(x) for x in itertools.combinations(query_names, i)])
		
	for comb in combs:
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
		
		# Create the new response
		if len(vm_comb) > 0:
			query_results = {
				'name' : ' - '.join(comb),
				'children' : [],
				'type' : 'vm_set',
				'query_names' : comb,
				'query_columns' : {}
			}
	
			for query in comb:
				query_results['query_columns'][query] = query_col_map[query]
	
			for vm in vm_comb:
				my_vm_info = None
				for query in comb:
					for info in query_vms_info_map[query]:
						if info['name'] == vm:
							# All columns per query are mantained
							if my_vm_info is None:
								my_vm_info = info
							else:
								my_vm_info['values'].extend(info['values'])
				
				query_results['children'].append(my_vm_info)
				
			response_json['children'].append(query_results)
			
	return response_json	
		


@server.route('/')
def index():
	return render_template("index.html")

@server.route('/subutilization')
def do_subutilization_queries():

	start_date = request.args.get("start_date")
	end_date = request.args.get("end_date")

	if (start_date == None or end_date == None):
		flash("Error: start dates or end dates cannot be null!")
		return render_template("index.html")

	aggregate = request.args.get("aggregate")
	if (aggregate != None and aggregate == "yes"):
		aggregate = True
	else:
		aggregate = False

	response = { 
		'name' : '',  # Remember to add the 'subutilization' then...
	}

	execute_query("vmsOverMemAlloc", start_date, end_date, response)
	if response['exit_status'] != 0:
		flash(response['message'].capitalize() + "!")
		return render_template("index.html", start_date=start_date, end_date=end_date)

	execute_query("vmsOverCPU", start_date, end_date, response)
	if response['exit_status'] != 0:
		flash(response['message'].capitalize() + "!")
		return render_template("index.html", start_date=start_date, end_date=end_date)

	execute_query("lowUsageVMs", start_date, end_date, response)
	if response['exit_status'] != 0:
		flash(response['message'].capitalize() + "!")

	# see if query results should be aggregated
	if (aggregate):
		response = aggregate_problems(start_date, end_date, response)

	return render_template("index.html", response=json.dumps(response), start_date=start_date, end_date=end_date, aggregate=aggregate)

@server.route('/superutilization')
def do_superutilization_queries():

	start_date = request.args.get("start_date")
	end_date = request.args.get("end_date")

	if (start_date == None or end_date == None):
		flash("Error: start dates or end dates cannot be null!")
		return render_template("index.html")

	aggregate = request.args.get("aggregate")
	if (aggregate != None and aggregate == "yes"):
		aggregate = True
	else:
		aggregate = False

	response = { 
		'name' : '',  # Remember to add the 'superutilization' then...
	}

	execute_query("vmsNetConstrained", start_date, end_date, response)
	if response['exit_status'] != 0:
		flash(response['message'].capitalize() + "!")
		return render_template("index.html", start_date=start_date, end_date=end_date)

#        execute_query("highCPUQueueing", start_date, end_date, response)
#        if response['exit_status'] != 0:
#                flash(response['message'].capitalize() + "!")
#                return render_template("index.html", start_date=start_date, end_date=end_date)


#        execute_query("vmsWithHighPagingRate", start_date, end_date, response)
#        if response['exit_status'] != 0:
#                flash(response['message'].capitalize() + "!")
#                return render_template("index.html", start_date=start_date, end_date=end_date)


	# see if query results should be aggregated
	if (aggregate):
		response = aggregate_problems(start_date, end_date, response)

	return render_template("index.html", response=json.dumps(response), start_date=start_date, end_date=end_date, aggregate=aggregate)

query_metrics = {}
query_metrics['lowUsageVMs'] = {'tables' : ["cpu", "disk", "network"], 
				'metrics' : [ 'cpu_alloc', 'ios_per_sec', 'pkt_per_sec' ]}
query_metrics['vmsOverMemAlloc'] = {'tables' : ["memory", "memory"], 
				    'metrics' : [ 'mem_util', 'mem_alloc' ]}
query_metrics['vmsOverCPU'] = {'tables' : ["cpu", "cpu"], 
				'metrics' : [ 'cpu_util', 'cpu_alloc' ]}
query_metrics['vmsNetConstrained'] = {'tables' : ["network"], 
				      'metrics' : [ 'pkt_per_sec' ]}
query_metrics['vmsWithHighPagingRate'] = {'tables' : ["memory", "memory"],
                                          'metrics' : [ 'mem_util', 'pages_per_sec' ]}
query_metrics['highCPUQueueing'] = {'tables' : ["cpu", "cpu", "cpu"],
                                          'metrics' : [ "cpu_util", "cpu_alloc", "cpu_queue"]}

@server.route('/query_metrics')
def get_query_metrics():

        query_string_list = request.args.get("query_list")

        if ( query_string_list == None):
                return "null";
        else:
		query_list = query_string_list.split(" - ")
		response = {'tables' : [],
			    'metrics' : []}
		for query in query_list:
			print query
			metrics = query_metrics[query]['metrics']
			tables = query_metrics[query]['tables']
			for i in range(len(metrics)):
				if metrics[i] not in response['metrics']:
					response['metrics'].append(metrics[i])
					response['tables'].append(tables[i])
		print response
                return json.dumps(response)

@server.route('/metric_time_series')
def do_metric_time_series_query():
	
	vm_name = request.args.get("vm_name")
	metric_name = request.args.get("metric")
	table_name = request.args.get("table")
	start_date = request.args.get("start_date")
        end_date = request.args.get("end_date")

        if (vm_name == None or metric_name == None or table_name == None or 
	    start_date == None or end_date == None):
                return "error: any parameter is missing"
	else:
		client = VerticaClientFacade()
		(exit_status, message, output) = client.check_and_query("metricTimeSeries", start_date, end_date, vm_name, table_name, metric_name)
		if exit_status == 0:
			# Prepare the json response object
			response = {'date_time' : [], 
				    'value' : []}
			for row in output.rows:
				response['date_time'].append(str(row[0]))
				response['value'].append(row[1])

			return json.dumps (response)
		else:
			return message
	
	

if __name__ == "__main__":

	port = int(os.environ.get("PORT", 80))
	server.run(host="150.165.15.173", port=port, debug=True)
