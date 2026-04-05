import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class WeatherService {
  final String apiKey;

  WeatherService(this.apiKey);

  // gelecek tahminler için bu yapıyı kullanırız.
  Future<List<Weather>> getForecastCoordinat(double lat,double lon) async {
    final response = await http.get(
      Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List list = data['list'];

      return list.where((item) => list.indexOf(item) % 8 == 0).map((item) {
        final weather = Weather.fromJson(item);
        weather.cityName=data['city']['name'];
        return weather;
      }).toList();
    } else {
      throw Exception('Hava durumu alınamadı.');
    }
  }
// koordinatsiz gelecek tahminleri için bu yapıyı kullanırız.
  Future<List<Weather>> getForecast(String cityName) async {
    final response = await http.get(
      Uri.parse('https://api.openweathermap.org/data/2.5/forecast?q=$cityName&appid=$apiKey&units=metric'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List list = data['list'];

      return list.where((item) => list.indexOf(item) % 8 == 0).map((item) {
        final weather = Weather.fromJson(item);
        weather.cityName=data['city']['name'];
        return weather;
      }).toList();
    } else {
      throw Exception('Hava durumu alınamadı.');
    }
  }

  // anlık tahmin için bu yapıyı kullanırız.
  Future<Weather> getWeatherCoordinat(double lat,double lon) async{
    final response = await http.get(
      Uri.parse('https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric'),
    );
    if (response.statusCode == 200) {
      return Weather.fromJson(jsonDecode(response.body));
    }else{
      throw Exception('Hava durumu alınamadı.');
    }
  }
  // koordinatsız şehir seçerek anlık tahmin için bu yapıyı kullanırız.
  Future<Weather> getWeather(String cityName) async{
    final response = await http.get(
      Uri.parse('https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$apiKey&units=metric'),
    );
    if (response.statusCode == 200) {
      return Weather.fromJson(jsonDecode(response.body));
    }else{
      throw Exception('Hava durumu alınamadı.');
    }
  }
}
