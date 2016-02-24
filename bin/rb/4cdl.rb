#!/usr/bin/env ruby
require 'json'
require 'net/http'

if ARGV[1].nil?
  puts "Usage: 4cdl [board] [thread id]"
  exit
end

board, thread_id = ARGV[0], ARGV[1]
url = "/#{board}/thread/#{thread_id}.json"
thread = JSON.parse(Net::HTTP.get('a.4cdn.org', url))["posts"]
dir = thread[0]["sub"] ? thread[0]["sub"] : thread_id.to_s
Dir.mkdir(dir) ; Dir.chdir(dir)
thread.each do |post|
  if post["filename"]
    @filename = "#{post["tim"]}-#{post["filename"]}#{post["ext"]}"
    print "Saving #{@filename}..."
    @file = Net::HTTP.get('i.4cdn.org',
                          "/#{board}/#{post["tim"]}#{post["ext"]}")
    File.write(@filename, @file)
    puts " Done"
  end
end
