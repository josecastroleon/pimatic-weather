module.exports ={
  title: "pimatic-weather device config schemas"
  WeatherDevice: {
    title: "WeatherDevice config options"
    type: "object"
    properties: 
      degreeType:
        description: "Degree type of Temperature"
        format: String
        default: "C"
      timeout:
        description: "Timeout between requests"
        format: Number
        default: "60000"
  }
  WeatherForecastDevice: {
    title: "WeatherForecastDevice config options"
    type: "object"
    properties:
      degreeType:
        description: "Degree type of Temperature"
        format: String
        default: "C"
      timeout:
        description: "Timeout between requests"
        format: Number
        default: "60000"
      day:
        description: "day to retrieve forecast (today+value)"
        format: Number
        default: "1"
  }
}
