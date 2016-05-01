#!/usr/bin/env ruby

require 'webrick'

port = ENV['PORT'] ? ENV['PORT'].to_i : 3000

puts "Server started: http://localhost:#{port}/"

root = File.expand_path './'
server = WEBrick::HTTPServer.new Port: port, DocumentRoot: root

trap('INT') { server.shutdown }

server.start

