#!/usr/bin/env ruby
require 'json'
require 'net/http'
require 'htmlentities'

if ARGV[1]
  board, query = ARGV[0], ARGV[1]
else
  board, query = "a", /woto|snw/i
end

counter = 0
catalog = JSON.parse(Net::HTTP.get(
  'a.4cdn.org', "/#{board}/catalog.json"))
catalog.each { |page| page['threads'].each do |thread|
  @post = thread['com'] ? thread['com'] : nil
  if not @post.nil? and @post.match(query)
    puts "Thread found:"
    puts "https://boards.4chan.org/#{board}/thread/#{thread['no']}"
    puts HTMLEntities.new.decode(@post)
    counter += 1
  end
end }

puts "No threads found" if counter < 1
