file = File.open("/sys/bus/w1/devices/28-00000a9b6404/w1_slave", "r")
  data = file.read
  file.close
  puts data
end
