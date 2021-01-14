#!/usr/bin/ruby

require 'rest-client'
require 'aws-sdk-dynamodb'

Aws.config.update({
                    region: "us-west-2",
                    credentials: Aws::Credentials.new('AKIAIRH2DXHVQTBRSETQ', 'cCQr0nK4dhNOXL+SHhjOOg/zByTxhvqv4/35DH2O')
                  })

dynamodb = Aws::DynamoDB::Client.new

timestamp = Time.now.to_i

system("cat /sys/bus/w1/devices/28-00000a9b6404/w1_slave >> ~/temps.txt")

output = `tail -1 ~/temps.txt`
sensor_id = '28-00000a9b6404'

if (m = output.match /t=([-\d]+)/)
  #puts m[1]
  temp = m[1].to_i.to_f / 1000
  RestClient.get "http://slack.jstal.in:8182/owsensor/#{temp}"

  # Write to dynamo
  begin
    item = {
      sensor_id: sensor_id,
      unixtime: timestamp,
      temp: temp
    }

    params = {
      table_name: 'temp-sensor-02',
      item: item
    }

    puts "Dynamo item: #{params}"
    result = dynamodb.put_item(params)

  rescue Aws::DynamoDB::Errors::ServiceError => e
    puts "Error found! #{e.message}"
  end
  
end
