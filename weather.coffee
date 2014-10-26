module.exports = (env) ->

  Promise = env.require 'bluebird'
  convict = env.require "convict"
  assert = env.require 'cassert'
  
  weatherLib = require "weather-js"

  class Weather extends env.plugins.Plugin
    init: (app, @framework, @config) =>
      deviceConfigDef = require("./device-config-schema")

      @framework.deviceManager.registerDeviceClass("WeatherDevice", {
        configDef: deviceConfigDef.WeatherDevice, 
        createCallback: (config) => new WeatherDevice(config)
      })
      @framework.deviceManager.registerDeviceClass("WeatherForecastDevice", {
        configDef: deviceConfigDef.WeatherForecastDevice,
        createCallback: (config) => new WeatherForecastDevice(config)
      })

  class WeatherDevice extends env.devices.Device
    attributes:
      status:
        description: "The actual status"
        type: "string"
      windspeed:
        description: "The wind speed"
        type: "number"
        unit: 'km/h'
      temperature:
        description: "The messured temperature"
        type: "number"
        unit: '°C'
      humidity:
        description: "The actual degree of Humidity"
        type: "number"
        unit: '%'


    temperature: 0.0
    humidity: 0.0
    status: ''
    windspeed: 0.0

    constructor: (@config) ->
      @id = config.id
      @name = config.name
      @location = config.location
      @degreeType = config.degreeType
      @timeout = config.timeout
      super()

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
        if result
          @emit "temperature", Number result[0].current.temperature
          @emit "humidity", Number result[0].current.humidity 
          @emit "status", result[0].current.skytext
          @emit "windspeed", Number result[0].current.windspeed

    getTemperature: -> Promise.resolve @temperature
    getHumidity: -> Promise.resolve @humidity
    getStatus: -> Promise.resolve @status
    getWindspeed : -> Promise.resolve @windspeed

  class WeatherForecastDevice extends env.devices.Device
    attributes:
      forecast:
        description: "The expected forecast"
        type: "string"
      low:
        description: "The minimum temperature"
        type: "number"
        unit: '°C'
      high:
        description: "The maximum temperature"
        type: "number"
        unit: '°C'
      precipitation:
        description: "The expected degree of precipitation"
        type: "number"
        unit: '%'


    low: 0.0
    high: 0.0
    forecast: ''
    precipitation: 0.0

    constructor: (@config) ->
      @id = config.id
      @name = config.name
      @location = config.location
      @degreeType = config.degreeType
      @timeout = config.timeout
      @day = config.day
      super()

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
        if result
          @emit "low", Number result[0].forecast[@day].low
          @emit "high", Number result[0].forecast[@day].high
          @emit "forecast", result[0].forecast[@day].skytextday
          @emit "precipitation", Number result[0].forecast[@day].precip

    getLow: -> Promise.resolve @low
    getHigh: -> Promise.resolve @high
    getForecast: -> Promise.resolve @forecast
    getPrecipitation : -> Promise.resolve @precipitation

  plugin = new Weather
  return plugin
