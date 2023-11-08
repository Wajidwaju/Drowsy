import 'dart:async';

import 'package:camera/camera.dart';
import 'package:drowsy/login.dart';
import 'package:drowsy/model/user.dart';
import 'package:flutter/material.dart';
import 'package:volume_control/volume_control.dart';

import 'detection_screen.dart'; // Import the volume_control package

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Flutter App',
      home: LoginScreen(),
    );
  }
}

class Home extends StatefulWidget {
  final User model;
  const Home({super.key, required this.model});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Drowsy'),
        automaticallyImplyLeading: false,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // ElevatedButton(
              //   onPressed: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (context) => VolumeAdjustmentScreen(),
              //       ),
              //     );
              //   },
              //   child: const Text('Adjustment'),
              // ),
              // const SizedBox(height: 80),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ElevatedButton(
                  onPressed: () async {
                    final cameras = await availableCameras();

                    Future.delayed(const Duration(milliseconds: 100), () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CameraScreen()
                          //     CameraView(
                          //   cameras: cameras,
                          // ),
                        ),
                      );
                    });
                  },
                  child: const Text('Start'),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class VolumeAdjustmentScreen extends StatefulWidget {
  @override
  _VolumeAdjustmentScreenState createState() => _VolumeAdjustmentScreenState();
}

class _VolumeAdjustmentScreenState extends State<VolumeAdjustmentScreen> {
  double? _currentVolume = null; // Initial slider value (0.5 for mid-volume)
  Timer timer = Timer(Duration(seconds: 1), () {});

  @override
  void initState() {
    super.initState();
    _getCurrentVolume(); // Get the initial volume level of the device
  }

  void refreshVolume() {
    timer = Timer.periodic(Duration(milliseconds: 500), (timer) async {
      double currentVolume = await VolumeControl.volume;
      if (currentVolume != _currentVolume) {
        setState(() {
          _currentVolume = currentVolume;
        });
      }
    });
  }

  void _getCurrentVolume() async {
    double currentVolume = await VolumeControl.volume;
    setState(() {
      _currentVolume = currentVolume;
    });
    refreshVolume();
  }

  void _setDeviceVolume(double value) async {
    await VolumeControl.setVolume(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Volume Adjustment'),
      ),
      body: Center(
        child: _currentVolume == null
            ? CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Adjust Volume',
                    style: TextStyle(fontSize: 20.0),
                  ),
                  Slider(
                    value: _currentVolume!,
                    onChanged: (value) {
                      setState(() {
                        _currentVolume = value;
                      });
                      _setDeviceVolume(value); // Change the device's volume
                    },
                    min: 0.0,
                    max: 1.0,
                    divisions: 100,
                    label: 'Volume',
                  ),
                ],
              ),
      ),
    );
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }
}

// Screen which is scaffold and contains camera view
class CameraView extends StatefulWidget {
  const CameraView({super.key, required this.cameras});

  final List<CameraDescription> cameras;
  @override
  _CameraViewState createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  CameraController cameraController = CameraController(
    CameraDescription(
      name: '0',
      lensDirection: CameraLensDirection.front,
      sensorOrientation: 0,
    ),
    // widget.cameras[1],
    ResolutionPreset.medium,
  );
  @override
  void initState() {
    cameraController =
        CameraController(widget.cameras[1], ResolutionPreset.medium);

    cameraController.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera View'),
      ),
      body: CameraPreview(cameraController),
    );
  }
}
