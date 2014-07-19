module.exports = (env) ->

  convict = env.require "convict"
  Q = env.require 'q'
  assert = env.require 'cassert'
  
  weatherLib = require "weather-js"

  class Weather extends env.plugins.Plugin
    init: (app, @framework, @config) =>
      @location = config.location
      @degreeType = config.degreeType
      @timeout = config.timeout

      @requestForecast()
      setInterval( =>
        @requestForecast()
      , @timeout
      )

    requestForecast: () =>
      weatherLib.find
        search: @location
        degreeType: @degreeType
      , (err, result) =>
        env.logger.error("err") if err
        @receiveForecast(result[0]) if result

    receiveForecast: (forecast) =>
      @emit "weather", forecast

    createDevice: (config) =>
      switch config.class
        when "WeatherTemperature"
          @framework.registerDevice(new WeatherTemperature config)
          return true
        when "WeatherHumidity"
          @framework.registerDevice(new WeatherHumidity config)
          return true
        when "WeatherStatus"
          @framework.registerDevice(new WeatherStatus config)
          return true
        else
          return false

  class WeatherTemperature extends env.devices.TemperatureSensor
    temperature: null

    constructor: (@config) ->
      @id = config.id
      @name = config.name
      super()
      plugin.on "weather", (forecast) =>
        temperature = forecast.current.temperature
        @temperature = temperature
        @emit "temperature", temperature

    getTemperature: -> Q(@temperature)

  class WeatherHumidity extends env.devices.Sensor
    attributes:
      humidity:
        description: "The actual degree of Humidity"
        type: Number
        unit: '%'
        
    humidity: null
        
    constructor: (@config) ->
      @id = config.id
      @name = config.name
      super()
      plugin.on "weather", (forecast) =>
        humidity = forecast.current.humidity
        @humidity = humidity
        @emit "humidity", humidity
      
    getHumidity: -> Q(@humidity)

  class WeatherStatus extends env.devices.Sensor
    attributes:
      status:
        description: "The actual status"
        type: String

    status: null

    constructor: (@config) ->
      @id = config.id
      @name = config.name
      super()
      plugin.on "weather", (forecast) =>
        status = forecast.current.skytext
        @status = status
        @emit "status", status

    getStatus: -> Q(@status)

  plugin = new Weather
  return plugin
