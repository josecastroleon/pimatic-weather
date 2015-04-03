pimatic-weather
===============

Pimatic Plugin that retrieves the forecast on several devices

Configuration
-------------
Add the plugin to the plugin section:

    {
      "plugin": "weather"
    },

Then add the device with the location into the devices section:

    {
      "id": "weather",
      "class": "WeatherDevice",
      "name": "Weather Geneva",
      "location": "Geneva, Switzerland",
      "lang": "en-US",
      "degreeType": "C",
      "timeout": 300000
    }

If you need a forecast you can use the following device:

    {
      "id": "forecast",
      "class": "WeatherForecastDevice",
      "name": "Forecast 1 day for Geneva",
      "location": "Geneva, Switzerland",
      "lang": "en-US",
      "degreeType": "C",
      "timeout": 300000,
      "day": 1
    }

Then you can add the items into the mobile frontend
