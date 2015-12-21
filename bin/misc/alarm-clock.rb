#!/usr/bin/env ruby

def die(str)
  $stderr.puts str
  exit
end

def usage
  die "Usage: nap { for <float>[<h|m|s>] | until <date(1) parsable datestr> }" +
    "\ne.g.  nap for 3h\n      nap until 10AM"
end

def hourminutes(hours)
  wholes = hours.to_i
  minutes = (hours - hours.to_i) * 60

  "#{ wholes }:#{ ("0" + minutes.to_i.to_s)[-2..-1] }"
end

def kind_for(time)
  aliases = {'m' => 60, 'h' => 3600, 's' => 1}
  prefix  = aliases[(time.match('[hms]$') || ['s'])[0]]

  yield "# date format bogus" unless time.match(/^\d+(\.\d+)?([hms])?$/)

  "-s #{ time.to_f.*(prefix).to_i }"
end

def successfully(args)
  errors, pipe = IO.pipe
  IO.popen(args, err: pipe) do |p| p.read end.tap do
    pipe.close
    die errors.read unless $?.success?
  end
end

def kind_until(time)
  date = successfully(%w{date -d} + [time])
  secs = successfully(%w{date -d} + [time] + %w{+%s}).to_i

  hours = (((secs.to_i - Time.now.to_i) / 36) / 100.0)
  yield "# %s hours" % hourminutes(hours) if (0.40..60).include? hours
  yield "# #{ date }"

  "-t #{ secs }"
end

kind = ARGV[0]
timedescr = ARGV[1]

usage if ARGV.length == 0 || !kind.match(/^(until|for)$/)

cmd = send(:"kind_#{ kind }", timedescr) { |info| $stderr.puts info }

puts "sudo rtcwake -m mem #{ cmd }"
