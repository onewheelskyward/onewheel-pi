#!/usr/bin/ruby

require 'rest-client'

system("cat /sys/bus/w1/devices/28-00000a9b6404/w1_slave >> ~/temps.txt")

output = `tail -1 ~/temps.txt`

if (m = output.match /t=([-\d]+)/)
  #puts m[1]
  temp = m[1].to_i.to_f / 1000
  RestClient.get "http://slack.jstal.in:8182/owsensor/#{temp}"
end
