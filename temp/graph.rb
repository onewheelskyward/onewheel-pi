#!/usr/bin/ruby

require 'rest-client'
require 'aws-sdk-dynamodb'
require 'gruff'

Aws.config.update({
                    region: "us-west-2",
                    credentials: Aws::Credentials.new('AKIAIRH2DXHVQTBRSETQ', 'cCQr0nK4dhNOXL+SHhjOOg/zByTxhvqv4/35DH2O')
                  })

dynamodb = Aws::DynamoDB::Client.new

timestamp = Time.now.to_i

sensor_id = '28-00000a9b6404'
table_name = 'temp-sensor-02'

  # Write to dynamo
  begin
    params = {
      table_name: table_name,
#      projection_expression: "#sensor_id, unixtime, temp",
      key_condition_expression:
        "#sensor_id = :sensor_id and unixtime between :start and :stop",
      expression_attribute_names: {
        "#sensor_id" => "sensor_id"
      },
      expression_attribute_values: {
        ":sensor_id" => sensor_id,
        ":start" => 1549734319,
        ":stop" => 1549762593
      }
    }
    result = dynamodb.query(params)
    unixtimes = []
    temps = []
    result.items.each do |item|
      unixtimes.push item['unixtime'].to_i
      temps.push item['temp'].to_f
    end

    # timing labels
    graph_label_points = unixtimes.count - 10
    iterator = unixtimes.count / 5
    labels = []
#    labels.push = Time.at(unixtimes.min).strftime("%H:%M")

    4.times do |time|
      labels.push Time.at(unixtimes[iterator * time]).strftime("%H:%M")
    end
    
    labels.push Time.at(unixtimes.max).strftime("%H:%M")

    g = Gruff::Line.new
    g.title = 'TempSW'
    g.labels = { 0 => labels[0], iterator => labels[1], iterator*2 => labels[2], iterator*3 => labels[3], iterator*4 => labels[4] }
    g.data :sensor, temps
    g.write('exciting.png')

  rescue Aws::DynamoDB::Errors::ServiceError => e
    puts "Error found! #{e.message}"
  end
