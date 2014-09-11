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

  class WeatherDevice extends env.devices.Device
    attributes:
      temperature:
        description: "the messured temperature"
        type: "number"
        unit: '°C'
      humidity:
        description: "The actual degree of Humidity"
        type: "number"
        unit: '%'
      status:
        description: "The actual status"
        type: "string"

    temperature: 0.0
    humidity: 0.0
    status: ''

    constructor: (@config) ->
      @id = config.id
      @name = config.name
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
        search: @name
        degreeType: @degreeType
      , (err, result) =>
        env.logger.error("err") if err
        if result
          @emit "temperature", Number result[0].current.temperature
          @emit "humidity", Number result[0].current.humidity 
          @emit "status", result[0].current.skytext

    getTemperature: -> Promise.resolve @temperature
    getHumidity: -> Promise.resolve @humidity
    getStatus: -> Promise.resolve @status

  plugin = new Weather
  return plugin
