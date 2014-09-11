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
}
