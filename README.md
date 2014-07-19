pimatic-weather
===============

Pimatic Plugin that retrieves the forecast on several devices

Configuration
-------------
Add the plugin to the plugin section:

    {
      "plugin": "weather",
      "location": "Geneva, Switzerland",
      "degreeType": "C",
      "timeout": 60000
    },

Then add several sensors for your device to the devices section:

    {
      "id": "weather-temperature",
      "class": "WeatherTemperature",
      "name": "Temperature"
    },
    {
      "id": "weather-humidity",
      "class": "WeatherHumidity",
      "name": "Humidity"
    },
    {
      "id": "weather-status",
      "class": "WeatherStatus",
      "name": "Status"
    },

Then you can add the items into the mobile frontend
