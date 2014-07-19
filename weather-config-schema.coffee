module.exports = {
  title: "Weather"
  type: "object"
  properties:
    location:
      description: "Location"
      format: String
      default: "Geneva, Switzerland"
    degreeType:
      description: "Degree type of Temperature"
      format: String
      default: "C"
    timeout:
      description: "Timeout between requests"
      format: Number
      default: "60000"
}
