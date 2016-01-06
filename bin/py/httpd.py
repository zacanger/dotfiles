#!/usr/bin/env python

HOST='127.0.0.1'
PORT=8080

from BaseHTTPServer import HTTPServer, BaseHTTPRequestHandler
from subprocess import Popen, PIPE, STDOUT
import json, traceback

class Handler(BaseHTTPRequestHandler):

	def do_GET(self):
		self.send_response(200)
		self.send_header('Content-Type', 'text/plain')
		self.end_headers()
		self.wfile.write('Nothing!')

	def do_POST(self):
		try:
			json_length = int(self.headers.get('Content-Length'))
			jsondata = self.rfile.read(json_length)
			try:
				data = json.loads(jsondata)
			except:
				raise Exception('invalid json')

			command = data.get('command')

			if command:
				process = Popen(command, stdout=PIPE, stderr=STDOUT)
				output = process.communicate()[0]
				returncode = process.returncode
			else:
				output = 'No command given.'
				returncode = -1

		except Exception, msg:
			self.send_response(500)
			self.send_header('Content-Type', 'application/json')
			self.end_headers()
			self.wfile.write(json.dumps(dict(status='error', error=repr(msg), returncode=None, traceback=traceback.format_exc())))
			return
		self.send_response(200)
		self.send_header('Content-Type', 'application/json')
		self.end_headers()
		self.wfile.write(json.dumps(dict(response=output, returncode=returncode, status='ok')))

httpd = HTTPServer((HOST, PORT), Handler)
httpd.serve_forever()

# curl -vvv -D - -d '{"command":["/bin/echo", "haha"]}' http://localhost:8080/
