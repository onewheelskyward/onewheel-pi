#!/usr/bin/ruby

require 'rest-client'
require 'aws-sdk-dynamodb'

Aws.config.update({
                    region: "us-west-2",
                    credentials: Aws::Credentials.new()
                  })

dynamodb = Aws::DynamoDB::Client.new

timestamp = Time.now.to_i

sensor_id = '28-00000a9b6404'
table_name = 'temp-sensor-01'

  # Write to dynamo
#  begin
    params = {
      table_name: table_name
    }

    loop do
      result = dynamodb.scan(params)

      result.items.each do |elem|
        puts "#{elem['sensor_id']} #{elem['timestamp']} #{elem['temp']}"
        item = {
          sensor_id: elem['sensor_id'],
          unixtime: elem['timestamp'],
          temp: elem['temp']
        }

        p = {
          table_name: 'temp-sensor-02',
          item: item
        }
        result = dynamodb.put_item(p)
      end

      break if result.last_evaluated_key.nil?

      puts "Scanning for more..."
      params[:exclusive_start_key] = result.last_evaluated_key
    end
#  rescue Aws::DynamoDB::Errors::ServiceError => e
#    puts "Error found! #{e.message}"
#  end
  

