#!/usr/bin/env ruby
require 'mixpanel_client'
require 'csv'

if ARGV.size < 1
  puts ""
  puts "Usage: mixpanel_export.rb from_date to_date [event_name]"
  puts "  (dates in yyyy-mm-dd format)"
else
  from_date = ARGV[0]
  to_date = ARGV[1]
  event =  ARGV[2]

  client = Mixpanel::Client.new(
    :api_key => ENV['API_KEY'],
    :api_secret => ENV['API_SECRET']
  )

  params = {:from_date => from_date,
            :to_date => to_date}
  params[:event] = %Q(["#{event}"]) if event

  data = client.request('export', params)

  headers = []
  properties = []

  # Do one loop to find all possible headers that we need
  data.each do |datum|
    datum.keys.each do |key|
      headers << key unless headers.include?(key)
    end
    row_props = datum.fetch('properties', {}).keys
    row_props.each do |key|
      properties << key unless properties.include?(key)
    end
  end

  # Now actually export the data
  CSV do |csv|
    csv << headers + properties

    data.each do |datum|
      row = []
      headers.each do |header|
        row << datum[header]
      end
      event_props = datum.fetch('properties', {})

      if headers.include?("$email") && event_props["$email"].to_s.length == 0 && event_props["distinct_id"].to_s.length > 0
        # Look up user details
        user_params = { :distinct_id => event_props["distinct_id"] }
        user_data = client.request('engage', user_params)
        begin
          event_props["$email"] = user_data["results"].first["$properties"]["$email"]
        rescue => e
          # Oh well...
        end
      end

      properties.each do |property|
        row << event_props[property]
      end
      csv << row
    end
  end
end
