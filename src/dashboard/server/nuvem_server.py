import  os, sys
from flask import Flask, render_template

sys.path.append("../client")
from vertica_query import VerticaClientFacade

server = Flask(__name__)

@server.route('/')
def index():

	return render_template("index.html")

@server.route('/query/<query_identifier>/<start_date>/<end_date>')
def do_query(query_identifier=None, start_date=None, end_date=None):

	print "query: %s" % query_identifier
	print "start: %s" % start_date
	print "end: %s" % end_date

	client = VerticaClientFacade()
	(exit_status, message, output) = client.check_and_query(query_identifier, start_date, end_date)

	if ( exit_status != 0 ):
		return "too bad(%s): %s" % (exit_status, message)

	return_page = ""

	header = ""
	for i in range(len(output.column_names)):
		header += "%s (%s) \t\t" % (output.column_names[i]['name'], output.column_names[i]['measurement'])
	return_page += header + "\n"

	for row in output.rows:
		formatted_row = ""
		for i in range(len(row)):
			formatted_row += row[i] + "\t\t"
		return_page += formatted_row + "\n"

	return return_page

if __name__ == "__main__":

	port = int(os.environ.get("PORT", 80))
	server.run(host="150.165.15.176", port=port, debug=True)
