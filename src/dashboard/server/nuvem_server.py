import  os, sys, json
from flask import Flask, render_template

sys.path.append("../client")
from vertica_query import VerticaClientFacade

server = Flask(__name__)

def execute_query(query_identifier, start_date, end_date, response):

	client = VerticaClientFacade()

	(exit_status, message, output) = client.check_and_query(query_identifier, start_date, end_date)

	response['exit_status'] = exit_status
	response['message'] = message

	if ( exit_status != 0 ):
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


@server.route('/')
def index():
	return render_template("index.html")

@server.route('/subutilization/<start_date>/<end_date>')
def do_subutilization_queries(start_date=None, end_date=None):

	response = { 
		'name' : 'subutilization',
		'children' : []
	}

	execute_query("vmsOverMemAlloc", start_date, end_date, response)
	if response['exit_status'] != 0:
		pass #flash this error

	execute_query("lowUsageVMs", start_date, end_date, response)
	if response['exit_status'] != 0:
		pass #flash this error

	return render_template("index.html", response=json.dumps(response))

if __name__ == "__main__":

	port = int(os.environ.get("PORT", 80))
	server.run(host="150.165.15.173", port=port, debug=True)
