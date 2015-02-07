module.exports = (env) ->

  Promise = env.require 'bluebird'
  convict = env.require "convict"
  assert = env.require 'cassert'
  
  weatherLib = require "weather-js"
  Promise.promisifyAll(weatherLib)

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

    status: "Unknown"
    windspeed: 0.0
    temperature: 0.0
    humidity: 0

    constructor: (@config) ->
      @id = config.id
      @name = config.name
      @location = config.location
      @degreeType = config.degreeType
      @timeout = config.timeout
      super()

      @requestForecast()
      setInterval(@requestForecast, @timeout)

    requestForecast: () =>
      weatherLib.findAsync(
        search: @location
        degreeType: @degreeType
      ).then( (results) =>
        @emit "temperature", Number results[0].current.temperature
        @emit "humidity", Number results[0].current.humidity 
        @emit "status", results[0].current.skytext
        @emit "windspeed", Number results[0].current.windspeed
        return results[0]
      ).catch( (err) =>
        env.logger.error(err.message)
        env.logger.debug(err)
      )

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

    forecast: "Unknown"
    low: 0.0
    high: 0.0
    precipitation: 0

    constructor: (@config) ->
      @id = config.id
      @name = config.name
      @location = config.location
      @degreeType = config.degreeType
      @timeout = config.timeout
      @day = config.day
      super()

      @requestForecast()
      setInterval(@requestForecast, @timeout)

    requestForecast: () =>
      weatherLib.findAsync(
        search: @location
        degreeType: @degreeType
      ).then( (results) =>
        @emit "low", Number results[0].forecast[@day].low
        @emit "high", Number results[0].forecast[@day].high
        @emit "forecast", results[0].forecast[@day].skytextday
        @emit "precipitation", Number results[0].forecast[@day].precip
        return results[0]
      ).catch( (err) =>
        env.logger.error(err.message)
        env.logger.debug(err) 
      )

    getLow: -> Promise.resolve @low
    getHigh: -> Promise.resolve @high
    getForecast: -> Promise.resolve @forecast
    getPrecipitation : -> Promise.resolve @precipitation

  plugin = new Weather
  return plugin
