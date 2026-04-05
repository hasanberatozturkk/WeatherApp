class Weather{
  String cityName;
  double temperature;
  String mainCondition;

  Weather({
    required this.cityName,
    required this.temperature,
    required this.mainCondition,
  });

  // json verisini weather nesnesine dönüştürme
  factory Weather.fromJson(Map<String,dynamic>json){
    return Weather(cityName: json['name'] ?? "", temperature: (json['main']['temp']as num).toDouble(), mainCondition: json['weather'][0]['main']);
  }
}