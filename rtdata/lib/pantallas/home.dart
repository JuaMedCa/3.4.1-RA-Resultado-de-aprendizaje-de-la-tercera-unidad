import 'dart:async';

import 'package:flutter/material.dart';
import 'package:after_layout/after_layout.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:rtdata/pantallas/GTemp.dart';
import 'package:rtdata/pantallas/GHume.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with AfterLayoutMixin<Home> {
  double humidity = 0, temperature = 0;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gauge"),
        actions: [
          IconButton(
            icon: Icon(Icons.egg),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: GTemp(temperature: temperature)),
              const Divider(height: 5),
              Expanded(child: GHume(humidity: humidity)),
              const Divider(height: 5),
              Row(
                children: [
                  Expanded(child: Text("Temperatura: $temperature °C")),
                  Expanded(child: Text("Humedad: $humidity %")),
                ],
              ),
              _buildTemperatureMessage(),
              _buildHumidityMessage(),
            ],
          ),
          if (isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  Widget _buildTemperatureMessage() {
    String message;
    Color color;

    if (temperature < 0) {
      message = 'Hace frío';
      color = Colors.blue;
    } else if (temperature <= 30) {
      message = 'Temperatura agradable';
      color = Colors.green;
    } else {
      message = 'Temperatura muy alta';
      color = Colors.red;
    }

    return Container(
      padding: EdgeInsets.all(8.0),
      color: color,
      child: Text(
        message,
        style: TextStyle(color: Colors.black),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildHumidityMessage() {
    String message;
    Color color;

    if (humidity < 0) {
      message = 'Tiempo seco';
      color = Colors.brown;
    } else if (humidity < 50) {
      message = 'Humedad media';
      color = Colors.yellow;
    } else {
      message = 'Humedad alta';
      color = Colors.purple;
    }

    return Container(
      padding: EdgeInsets.all(8.0),
      color: color,
      child: Text(
        message,
        style: TextStyle(color: Colors.black),
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  FutureOr<void> afterFirstLayout(BuildContext context) async {
    Timer.periodic(
      const Duration(seconds: 30),
          (timer) async {
        await _refreshData();
      },
    );
  }


  Future<void> _refreshData() async {
    final snackBar = SnackBar(
      content: Text('Cargando los datos espere...'),
      duration: Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    setState(() {
      isLoading = true;
    });

    await Future.delayed(Duration(seconds: 3));
    await getData();

    setState(() {
      isLoading = false;
    });
  }

  Future<void> getData() async {
    final ref = FirebaseDatabase.instance.ref();
    final temp = await ref.child("Living Room/temperature/value").get();
    final humi = await ref.child("Living Room/humidity/value").get();
    if (temp.exists && humi.exists) {
      setState(() {
        temperature = double.parse(temp.value.toString());
        humidity = double.parse(humi.value.toString());
      });
    } else {
      setState(() {
        temperature = -1;
        humidity = -1;
      });
    }
  }
}
