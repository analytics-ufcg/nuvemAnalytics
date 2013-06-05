import  os
from flask import Flask, render_template

server = Flask(__name__)

@server.route('/')
def index():
	return render_template("index.html")

if __name__ == "__main__":

	port = int(os.environ.get("PORT", 80))
	server.run(host="150.165.15.176", port=port, debug=True)
