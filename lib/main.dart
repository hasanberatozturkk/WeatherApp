import 'package:flutter/material.dart';
import 'package:flutter_weather_app/models/weather_model.dart';
import 'package:flutter_weather_app/constants.dart';
import 'package:flutter_weather_app/services/weather_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_animation/weather_animation.dart';

void main(){
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget{
  const WeatherApp({super.key});
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      debugShowCheckedModeBanner: false, // debug bandını kaldırmak için kullanılır.
      title: 'Weather Application',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch:Colors.blue,
      ),
      home: const WeatherHome(),
    );
  }
}

class WeatherHome extends StatefulWidget{
  const WeatherHome({super.key});
  @override
  State<WeatherHome> createState() => WeatherHomeState();
}

class WeatherHomeState extends State<WeatherHome> {
  final weatherService = WeatherService(ApiConstants.apiKey);
  Weather? weather;
  List<Weather>? forecast; // tahmin listesi

  final TextEditingController cityNameController = TextEditingController();

  // hava durumuna göre ikon belirleme fonksiyonu
  IconData getWeatherIcon(String? mainCondition) {
    if(mainCondition==null) {
      return Icons.wb_sunny;
    }
    switch(mainCondition.toLowerCase()){
      case 'clouds':
        return Icons.cloud;
      case 'rain':
        return Icons.umbrella;
      case 'clear':
        return Icons.wb_sunny;
      case 'snow' :
        return Icons.ac_unit;
      case 'thunderstorm':
        return Icons.flash_on;
      default:
        return Icons.wb_cloudy;
    }
  }

  // veri çekmek için kullanılır.
  Future<void> fetchWeather({String? cityName}) async {
    try {
      Weather weather;
      List<Weather> forecast;

      if(cityName == null || cityName.isEmpty) {
        Position position = await getCurrentLocation();
        weather = await weatherService.getWeatherCoordinat(position.latitude, position.longitude);
        forecast = await weatherService.getForecastCoordinat(position.latitude, position.longitude);
      }else{
        weather=await weatherService.getWeather(cityName);
        forecast=await weatherService.getForecast(cityName);
      }
      setState(() {
        weather=weather;
        forecast=forecast;
      });

    } catch (e) {
      print(e);
    }
  }
  // günlerin isimlerini almak için kullanılır.
  String getDayName(int dayIndex){
    DateTime targetDay=DateTime.now().add(Duration(days: dayIndex));

    List<String> months=['','Ocak','Şubat','Mart','Nisan','Mayıs','Haziran','Temmuz','Ağustos','Eylül','Ekim','Kasım','Aralık'];
    return '${targetDay.day} ${months[targetDay.month]}';
  }
  // saat üretmek için kullanılır.
  String getHour(int hourIndex){
    DateTime targetHour=DateTime.now().add(Duration(hours: hourIndex));
    String hour = targetHour.hour.toString().padLeft(2,'0');
    return '$hour:00';
  }

  // hava durumuna göre animasyon üreten fonksiyon
  Widget getWeatherAnimation(BuildContext context,String? mainCondition) {
    final screenSize=MediaQuery.of(context).size;
    if(mainCondition == null){
      return Container(
        color: Colors.blueGrey[900],);
    }
    switch (mainCondition.toLowerCase()){
      case 'rain':
        return WrapperScene(
          sizeCanvas: screenSize,
          colors: [Color(0xFF2C3E50),Color(0xFF34495E)],
          children: [CloudWidget(),RainWidget()],
        );
      case 'clouds':
        return WrapperScene(
          sizeCanvas: screenSize,
          colors: [Color(0xFF7F7FD5),Color(0xFF86A8E7)],
          children: [CloudWidget()],
        );
      case 'snow':
        return WrapperScene(
          sizeCanvas: screenSize,
          colors: [Color(0xFF83a4d4),Color(0xFFb6fbff)],
          children: [CloudWidget(),SnowWidget()],
        );
      case 'thunderstorm':
        return WrapperScene(
          sizeCanvas: screenSize,
          colors: [Color(0xFF141E30), Color(0xFF243B55)],
          children: [CloudWidget(),ThunderWidget(),RainWidget()],
        );
      case 'clear':
      default:
        return WrapperScene(
          sizeCanvas: screenSize,
          colors: [Color(0xFF2980B9), Color(0xFF6DD5FA)],
          children: [SunWidget()],
        );
    }
  }


  // konum isteme ve alma fonksiyonu
  Future<Position> getCurrentLocation() async {
    LocationPermission permission =await Geolocator.checkPermission();
    if(permission==LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if(permission==LocationPermission.denied) {
        return Future.error('Konum izni reddedildi.');
      }
    }
    return await Geolocator.getCurrentPosition();
  }

  @override
  void initState() {
    super.initState();
    // uygulama açılır açılmaz veriyi çekmek için kullanılır.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchWeather();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.blueGrey[900],
        body: weather == null || forecast == null
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : Stack(
          children: [
            Positioned.fill(
              child: getWeatherAnimation(context, weather?.mainCondition),
            ),
            Container(
              color: Colors.black38,
            ),
            SafeArea(
                child: SingleChildScrollView(
                  child:Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                          child:TextField(
                              controller: cityNameController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Şehir Ara',
                                hintStyle: const TextStyle(color: Colors.white54),
                                filled: true, // arka planın doldurulması
                                fillColor: Colors.white10, // arka plan rengi
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.search, color: Colors.white),
                                  onPressed: () {
                                    fetchWeather(cityName: cityNameController.text);
                                    FocusScope.of(context).unfocus(); // klavyeyi kapatmaya yarar.
                                  },
                                ),
                              ),
                              onSubmitted: (value) {
                                fetchWeather(cityName: value); // enter tuşuna basıldığında arama yapar.Sadece arama butonunun tetkilenmesini beklemez.
                              }
                          ),
                        ),
                        const SizedBox(height: 100),
                        Text(
                          "${weather?.temperature.round()}°C",
                          style: const TextStyle(color: Colors.white70,
                              fontSize: 64,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          weather?.cityName ?? "Yükleniyor...",
                          style: const TextStyle(color: Colors.white70, fontSize: 24),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          weather?.mainCondition ?? "",
                          style: const TextStyle(color: Colors.white54, fontSize: 20),
                        ),
                        const SizedBox(height: 40),
                        ElevatedButton(
                          onPressed: () {
                            fetchWeather();
                          },
                          child: const Text(
                            'Güncelle',
                          ),
                        ),
                        const SizedBox(height: 15),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child:Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Bugün',style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.bold),),
                          ),
                        ),
                        const SizedBox(height: 15),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal, // yatay kaydırma
                          child: Row(
                            children: [
                              for(int i=0;i< (forecast!.length>8?8:forecast!.length);i++)
                                hoursCard(
                                  i==0 ? 'Şimdi' : getHour(i*3),
                                  "${forecast![i].temperature.round()}°C",
                                  forecast![i].mainCondition,
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 50),

                        const Text('Gelecek Günler',
                            style: TextStyle(color: Colors.white, fontSize: 18)),
                        const SizedBox(height: 20),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal, // yatay kaydırma
                          child: Row(
                            children: [
                              for (int i = 0; i < forecast!.length; i++)
                                _forecastCard(
                                  i==0 ? 'Yarın' : getDayName(i+1),
                                  "${forecast![i].temperature.round()}°C",
                                  forecast![i].mainCondition,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
            )
          ],
        )
    );
  }
  Widget hoursCard(String hour,String temp,String condition){
    return Container(
      margin: EdgeInsets.only(right: 15),
      padding: EdgeInsets.symmetric(horizontal: 15,vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(20),
        border:Border.all(color:Colors.white24,width: 1),
      ),
      child: Column(
        children: [
          Text(hour,style: TextStyle(color: Colors.white70,fontSize: 14)),
          SizedBox(height: 10),
          Icon(getWeatherIcon(condition),color: Colors.orange,size: 24),
          SizedBox(height: 10),
          Text(temp,style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _forecastCard(String day, String temp,String condition) {
    return Container(
      margin: const EdgeInsets.only(right: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(day, style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 10),
          Icon(getWeatherIcon(condition), color: Colors.orange, size: 30),
          const SizedBox(height: 10),
          Text(temp, style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
  @override
  void dispose(){
    cityNameController.dispose();
    super.dispose();
  }
}
