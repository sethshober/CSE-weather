require 'pry'
require 'minitest/autorun'
require_relative 'weather'

class WeatherTest < Minitest::Test

  Minitest.after_run do
    if File.file? 'test.csv'
      File.delete 'test.csv'
    end
  end

  describe "weather" do
    before do
      @weather = Weather.new
    end

    # this is not a great test
    it "will successfully make an http request" do
      data = @weather.fetch('https://www.google.com/')
      success = data.include? 'google'
      assert_equal true, success
    end

    # this might be better done by stubbing so IO doesn't have to happen
    it "will parse the locations text properly" do
      assert_equal ["Portland, OR", "San Francisco, CA"],
                    @weather.get_locations('locations.test.txt')
    end

    it "should return latitude and longitude" do
      #stub fetch to avoid external call
      def @weather.fetch url
        '{"results":[{"geometry":{"location":{"lat":45.5230622,"lng":-122.6764816}}}]}'
      end
      assert_equal [45.5230622, -122.6764816], @weather.get_lat_lng('url', 'query')
    end

    it "should return weather data" do
       #stub fetch to avoid external call
      def @weather.fetch url
        '{"currently": { "time":1490585906,"temperature":48.1}}'
      end
      assert_equal [48, '2017-03-26 20:38:26 -0700'], @weather.get_weather_data('url', 'lat', 'lng')
    end

    it "will convert spaces to '+' in location text" do
      assert_equal 'Portland,+OR', @weather.normalize_location('Portland, OR')
    end

    it "should create a CSV file when passed data array" do
      if File.file? 'test.csv' 
        File.delete 'test.csv'
      end
      isCSV = File.file? 'test.csv' 
      assert_equal false, isCSV
      arr = [["Location", "Latitude", "Longitude", "Temperature", "Timestamp"]]
      @weather.create_csv 'test.csv', 'wb', arr
      isCSV = File.file? 'test.csv'
      assert true, isCSV 
    end

    it "should not create a CSV file when not passed data array" do
      if File.file? 'test.csv' 
        File.delete 'test.csv'
      end
      isCSV = File.file? 'test.csv' 
      assert_equal false, isCSV
      @weather.create_csv 'test.csv'
      isCSV = File.file? 'test.csv'
      assert_equal false, isCSV 
    end

    it "should return weather info to be passsed to CSV" do
      # stubs to avoid external calls
      def @weather.get_lat_lng url, query
        [45.5230622, -122.6764816]
      end
      def @weather.get_weather_data url, lat, lng
        [48, '2017-03-26 20:38:26 -0700']
      end
      data = @weather.get_weather 'locations.test.txt'
      expected = [["Location", "Latitude", "Longitude", "Temperature", "Timestamp"],
                  ["Portland, OR", 45.5230622, -122.6764816, 48, '2017-03-26 20:38:26 -0700'],
                  ["San Francisco, CA", 45.5230622, -122.6764816, 48, '2017-03-26 20:38:26 -0700']]
      assert_equal expected, data
    end
  end
end


