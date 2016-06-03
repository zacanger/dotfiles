#!/usr/bin/env ruby

# An approximative Wikipedia/Mechanize version of:
# curl -s http://data.iana.org/TLD/tlds-alpha-by-domain.txt | grep -v XN | sed -e 1d -e 's/\(.*\)/\L\1/'
# Vivien Didelot <vivien@didelot.org>

require 'mechanize'

wikipedia_page = "http://en.wikipedia.org/wiki/List_of_Internet_top-level_domains"
agent = Mechanize.new
agent.user_agent = "Mac Safari"
page = agent.get(wikipedia_page)
tlds = page.search("td/a").collect { |a| a.text if a.text[0] == "." && a.text.ascii_only? }.compact.sort.uniq

puts tlds.join("\n")

exit

