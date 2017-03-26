# CSE challenge:

Input: attached text file with list of locations

Output: .csv file with fields:
Location
Longitude
Latitude
Temperature
Timestamp

Restrictions:
Use only Ruby Standard Library
Use HTTP calls to get Lat/Lng and Weather data - separate data sources for each

Suggestions:

Location Info: http://www.geonames.org/export/web-services.html
Weather Info: https://darksky.net/dev/
In separate description or comments, explain decisions made when building tool.

---

*You'll need to export or run ruby with an API key from Google Maps and Dark Sky.*

**Run Program:** `G_API_KEY='{API_KEY}' SKY_API_KEY='{API_KEY}' ruby index.rb`

`minitest` and `pry` are part of the test suite. If you do not have those installed globally, you'll need to run `bundle install`. The tests don't make any external calls, so the keys are not needed.

**Run Tests:** `ruby weather_test.rb`
