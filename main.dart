import 'package:flutter/material.dart';
import 'package:flutter_sensors/flutter_sensors.dart';
import 'package:flutter_barometer_plugin/flutter_barometer.dart';
import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:flutter_sensors/flutter_sensors.dart';
// import 'package:flutter_barometer_plugin/flutter_barometer_plugin.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: BuildingHeightApp(),
  ));
}

class BuildingHeightApp extends StatefulWidget {
  @override
  _BuildingHeightAppState createState() => _BuildingHeightAppState();
}

class _BuildingHeightAppState extends State<BuildingHeightApp> {
  double initialPressure = 0.0;
  double currentPressure = 0.0;
  StreamSubscription<dynamic>? subscription;

  Future<void> startPressureMeasurement() async {
    subscription = SensorManager()
        .sensorUpdates(
      sensorId: Sensors.PRESSURE,
      interval: Sensors.SENSOR_DELAY_NORMAL,
    )
        .listen((event) {
      setState(() {
        if (initialPressure == 0.0) {
          initialPressure = event.data;
        } else {
          currentPressure = event.data;
        }
      });
    });
  }

  void stopPressureMeasurement() {
    subscription?.cancel();
  }

  double calculateBuildingHeight() {
    double pressureDifference = initialPressure - currentPressure;

    if (pressureDifference <= 0) {
      return 0.0;
    }

    double buildingHeight = (pressureDifference * 100) /
        (9.8 *
            1.147); // 1.147 is the density of air, 9.8 is the acceleration due to gravity

    return buildingHeight;
  }

  @override
  void dispose() {
    stopPressureMeasurement();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Building Height Measurement'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: startPressureMeasurement,
              child: Text('Start Pressure Measurement'),
            ),
            SizedBox(height: 16),
            Text(
              'Initial Pressure: ${initialPressure.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 32),
            Text(
              'Current Pressure: ${currentPressure.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                double height = calculateBuildingHeight();
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text('Building Height'),
                    content: Text(
                        'The building height is ${height.toStringAsFixed(2)} meters.'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('OK'),
                      ),
                    ],
                  ),
                );
              },
              child: Text('Calculate Building Height'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: stopPressureMeasurement,
              child: Text('Stop Pressure Measurement'),
            ),
          ],
        ),
      ),
    );
  }
}
