import  os, sys, json
from flask import Flask, render_template

sys.path.append("../client")
from vertica_query import VerticaClientFacade

server = Flask(__name__)

def execute_query(query_identifier, start_date, end_date, response):

	client = VerticaClientFacade()

	(exit_status, message, output) = client.check_and_query(query_identifier, start_date, end_date)

	if ( exit_status != 0 ):

		response['exit_status'] = exit_status
		response['message'] = message
		return

	query_results = {
		'name' : query_identifier,
		'children' : []
	}

	for row in output.rows:

		vm_info = {'size' : 1}
		
		for i in range(0, len(output.column_names)):
		
			vm_info[output.column_names[i]['name']] = {
				'value' : row[i],
				'measurement' : output.column_names[i]['measurement']
			}

		query_results['children'].append(vm_info)

	response['children'].append(query_results)


@server.route('/')
@server.route('/query/<query_identifier>/<start_date>/<end_date>')
def do_query(query_identifier=None, start_date=None, end_date=None):

	if query_identifier == None or start_date == None or end_date == None:
		return render_template("index.html")

	response = { 
		'name' : query_identifier,
		'children' : []
	}

	execute_query(query_identifier, start_date, end_date, response)
	if response['exit_status'] != 0:
		pass #flash

	return render_template("index.html", response=json.dumps(response))

@server.route('/subutilization/<start_date>/<end_date>')
def do_subutilization_queries(start_date=None, end_date=None):

	response = { 
		'name' : 'subutilization',
		'children' : []
	}

	execute_query("vmsOverMemAlloc", start_date, end_date, response)
	if response['exit_status'] != 0:
		pass #flash

	execute_query("lowUsageVMs", start_date, end_date, response)
	if response['exit_status'] != 0:
		pass #flash

	return render_template("index.html", response=json.dumps(response))

if __name__ == "__main__":

	port = int(os.environ.get("PORT", 80))
	server.run(host="150.165.15.173", port=port, debug=True)
