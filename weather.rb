# This file will create methods to:
# read in a text file of locations
# for each location:
#   request latitude/longitude
#   request weather data
# create CSV file with weather data for each location

require "net/http"
require "uri"
require "json"
require "csv"

class Weather

  # Make an http(s) request
  # Using a case statement we can handle various types of responses properly
  # Keeping it simple for this use case
  #
  # @param [String]  uri_str the url string you want to request
  # @param [Integer] limit   the max number of redirects allowed before throwing
  def fetch uri_str, limit = 10
    # This is not the best choice of exceptions
    raise ArgumentError, 'too many HTTP redirects' if limit == 0

    response = Net::HTTP.get_response(URI(uri_str))

    case response
    when Net::HTTPSuccess then
      response.body
    when Net::HTTPRedirection then
      location = response['location']
      warn "redirected to #{location}"
      fetch(location, limit - 1)
    else
      response.value
    end
  end

  # Reads a file of geo locations
  # Stores and returns locations in array
  #
  # @param [String] file_path the path to the file to open
  def get_locations file_path
    locations = []
    File.open(file_path).each do |line|
      locations.push(line.gsub(/\n/, ""))
    end
    locations
  end

  # Uses Google Maps api to get latitude and longitude for given location
  #
  # @param [String] url   the base url to request
  # @param [String] query the query to append to request
  #                 Includes location and API key
  #
  # the request should take the form of 
  # https://maps.googleapis.com/maps/api/geocode/json?address={address}&key={API_KEY}
  def get_lat_lng url, query
    location_data = JSON.parse(fetch(url + query))
    
    lat = location_data['results'][0]['geometry']['location']['lat']
    lng = location_data['results'][0]['geometry']['location']['lng']
    
    data = [lat, lng]
  end

  # Uses Dark Sky api to get weather data for given latitude and longitude
  #
  # @param [String]          url the base url to request
  # @param [String | Number] lat the latitude to append to request
  # @param [String | Number] lng the longitude to append to request                        
  #
  # the request should take the form of 
  # https://api.darksky.net/forecast/{API_KEY}/{lat},{lng}
  def get_weather_data url, lat, lng
      url = "#{url}#{lat},#{lng}"
      weather = JSON.parse(fetch(url))
      
      temperature = weather['currently']["temperature"].round
      time = Time.at(weather['currently']["time"]).to_s
      
      data = [temperature, time]
  end

  # Any normalization to the location data should occur here
  #
  # @param [String] location the location text to normalize
  def normalize_location location
    location = location.gsub(/\s+/, "+")
  end

  # Outputs a CSV file
  #
  # @param [String] file_name      name for the created CSV
  # @param [String] [open_mode=wb] the open mode to pass to File.open
  # @param [String] [arr=[]]       array of data to create CSV for
  def create_csv file_name, open_mode = 'wb', arr = []
    if arr.length > 0
      CSV.open(file_name, open_mode) do |csv|
        arr.each do |location|
          csv << location
        end
      end
      puts "#{file_name} created"
    else 
      puts 'No data supplied. Not creating CSV.'
    end
  end


  # Orchestration. Returns weather data as multidimensional array.
  #
  # @param [String] location_path the filepath to location info
  #
  # [
  #   [Location,Latitude,Longitude,Temperature,Timestamp],
  #   ["Portland, OR",45.5230622,-122.6764816,48,2017-03-26 13:53:48 -0700]
  # ]
  def get_weather location_path
    locations = get_locations(location_path)
    puts 'Getting weather...'
    # build CSV as array, so we only do file IO once
    output = [["Location", "Latitude", "Longitude", "Temperature", "Timestamp"]]
    
    locations.each do |location|
      location_info = []

      # normalize
      location_info.push(location)
      location = normalize_location(location)
      
      #get lat lng
      g_url = 'https://maps.googleapis.com/maps/api/geocode/json'
      g_query = "?address=#{location}&key=#{ENV['G_API_KEY']}"
      lat_lng = get_lat_lng(g_url, g_query)
      lat = lat_lng[0]
      lng = lat_lng[1]
      location_info.push(lat, lng)
      
      # get weather
      sky_url = "https://api.darksky.net/forecast/#{ENV['SKY_API_KEY']}/"
      weather_data = get_weather_data(sky_url, lat, lng)
      location_info.push(weather_data[0], weather_data[1])

      # store info that will be CSV row
      output.push(location_info)
    end
    puts 'Data received.'
    output
  end

end