import  os, sys, json
from flask import Flask, render_template

sys.path.append("../client")
from vertica_query import VerticaClientFacade

server = Flask(__name__)

@server.route('/')
def index():

	return render_template("index.html")

@server.route('/query/<query_identifier>/<start_date>/<end_date>')
def do_query(query_identifier=None, start_date=None, end_date=None):

	client = VerticaClientFacade()
	(exit_status, message, output) = client.check_and_query(query_identifier, start_date, end_date)

	response = { 
		'name' : 'subutilization',
		'children' : [],
		'exit_status' : exit_status,
		'message' : message
	}

	if ( exit_status != 0 ):

		return render_template("index.html", response=json.dumps(response))

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

	response['response'].append(query_results)
	return render_template("index.html", response=json.dumps(response))

if __name__ == "__main__":

	port = int(os.environ.get("PORT", 80))
	server.run(host="150.165.15.173", port=port, debug=True)
