# This file wil create a CSV file with weather data

require_relative 'weather'

weather = Weather. new

# kick it all off
weather.create_csv('weather.csv', 'wb', weather.get_weather('locations.txt'))


