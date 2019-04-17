import 'dart:convert';

import 'package:flutter/material.dart';
import 'Utils/utils.dart' as util;
import 'dart:async';
import 'package:http/http.dart' as http;

void main() {
  runApp(new MaterialApp(
    title: 'Weather App',
    home: new Home(),
    debugShowCheckedModeBanner: false,
  ));
}

double farTocel(double far) {
  var cel = (far - 32) * 5 / 9;
  return cel;
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Weather(),
    );
  }
}

class Weather extends StatefulWidget {
  @override
  _WeatherState createState() => _WeatherState();
}

class _WeatherState extends State<Weather> {
  String changedCity;
  Future _goToNextScreen(BuildContext context) async {
    Map results = await Navigator.of(context)
        .push(new MaterialPageRoute<Map>(builder: (BuildContext context) {
      return new ChangedCity();
    }));
    if (results != null && results.containsKey('city')) {
      debugPrint(results["city"].toString());
      changedCity = results["city"].toString();
    } else {
      debugPrint('Nothing is there');
    }
  }

  void showStuff() async {
    Map data = await getWeather(util.appId, util.defaultCity);
    debugPrint(data.toString());
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(
          'Weathery',
          style: new TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.red,
        actions: <Widget>[
          new IconButton(
            onPressed: () {
              _goToNextScreen(context);
            },
            icon: new Icon(
              Icons.menu,
              color: Colors.white70,
            ),
          )
        ],
      ),
      body: new Stack(
        children: <Widget>[
          new Center(
            child: new Image.asset(
              'images/umbrella.png',
              height: 1000.0,
              width: 490.0,
              fit: BoxFit.fill,
            ),
          ),
          new Container(
            alignment: Alignment.topRight,
            margin: EdgeInsets.fromLTRB(0.0, 10.9, 10.9, 0.0),
            child: changedCity == null
                ? new Text(util.defaultCity, style: CityStyle())
                : new Text(
                    changedCity,
                    style: CityStyle(),
                  ),
          ),
          new Container(
            alignment: Alignment.center,
            child: new Image.asset('images/light_rain.png'),
          ),
          //Container which will have the weather data
          new Container(
            margin: const EdgeInsets.fromLTRB(30.0, 350.0, 0, 0.0),
            child: changedCity == null
                ? updateWeather(util.defaultCity)
                : updateWeather(changedCity),
          ),
        ],
      ),
    );
  }

  Future<Map> getWeather(String appID, String City) async {
    String apiUrl =
        'https://api.openweathermap.org/data/2.5/weather?q=$City&appid=${appID}&units=imperial';
    http.Response response = await http.get(apiUrl);
    return json.decode(response.body);
  }

  Widget updateWeather(String city) {
    return new FutureBuilder(
        future: getWeather(util.appId, city),
        builder: (BuildContext context, AsyncSnapshot<Map> snapschot) {
          if (snapschot.hasData) {
            Map content = snapschot.data;
            return new Container(
              child: new Column(
                children: <Widget>[
                  new ListTile(
                    title: new Text(
                      '${content["main"]["temp"].toString()} F',
                      style: TempStyle(),
                    ),
                  )
                ],
              ),
            );
          } else {
            return new Container();
          }
        });
  }
}

TextStyle CityStyle() {
  return new TextStyle(
      fontSize: 20.0, color: Colors.white70, fontStyle: FontStyle.italic);
}

TextStyle TempStyle() {
  return new TextStyle(
      color: Colors.white,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.w500,
      fontSize: 49.9);
}

class ChangedCity extends StatelessWidget {
  var _changedCityController = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text('Change City'),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      body: new Stack(
        children: <Widget>[
          new Center(
            child: new Image.asset(
              'images/white_snow.png',
              height: 1200.0,
              width: 490.0,
              fit: BoxFit.fill,
            ),
          ),
          new ListView(
            children: <Widget>[
              new ListTile(
                title: new TextField(
                  controller: _changedCityController,
                  decoration:
                      new InputDecoration(labelText: 'Enter a City Name'),
                ),
              ),
              new ListTile(
                title: new FlatButton(
                  onPressed: () {
                    Navigator.pop(
                        context, {"city": _changedCityController.text});
                  },
                  child: new Text('Submit'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
