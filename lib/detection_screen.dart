import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:tflite/tflite.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? controller;
  List<CameraDescription>? cameras;
  ScreenshotController screenshotController = ScreenshotController();
  String? emotion;

  @override
  void initState() {
    super.initState();
    loadModel();
    settingCamera();
  }


  @override
  void dispose() {
    controller?.dispose();
    Tflite.close();
    super.dispose();
  }

  Future<void> settingCamera() async{
    cameras = await availableCameras();
    // controller = CameraController(cameras![0], ResolutionPreset.medium);
    for (var camera in cameras!) {
      if (camera.lensDirection == CameraLensDirection.front) {
        controller = CameraController(camera, ResolutionPreset.medium);
        break;
      }
    }
    controller!.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
      startTakingScreenshots();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SizedBox(
          // aspectRatio: controller!.value.aspectRatio,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Screenshot(
            controller: screenshotController,
            child: Column(
              children: [
                Expanded(child: CameraPreview(controller!)),
                if(emotion!=null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 16),
                    child: Text(emotion!,style: const TextStyle(color: Colors.greenAccent,fontSize: 24),),
                  )

              ],
            ),
          ),
        ),
      ),
    );

  }

  Future<void> loadModel() async {
    try {
      String modelPath = "assets/drowsy.tflite"; // Update with your model path
      String labelsPath = "assets/labels.txt"; // Update with your labels path

      String? res = await Tflite.loadModel(
        model: modelPath,
        labels: labelsPath,
        numThreads: 1, // You can adjust the number of threads
        isAsset: true, // Indicates that the model and labels are in the assets
      );

      if (kDebugMode) {
        print("Model loaded: $res");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error loading model: $e");
      }
    }
  }

  void startTakingScreenshots() async {
    Timer.periodic(const Duration(seconds: 5), (Timer t) async {
      screenshotController.capture().then((Uint8List? image) async {
        if (image != null) {
          final directory = (await getApplicationDocumentsDirectory()).path;
          String fileName = DateTime.now().millisecondsSinceEpoch.toString();
          final path = '$directory/$fileName.png';
          await File(path).writeAsBytes(image).then((File file) async {

            try {
              var recognitions = await Tflite.runModelOnImage(
                path: path,
                imageMean: 0.0, // Adjust if needed
                imageStd: 255.0, // Adjust if needed
                numResults: 7, // Number of emotions you want to detect
                threshold: 0.1, // Adjust if needed
                asynch: true,
              );

              if (recognitions != null && recognitions.isNotEmpty) {
                emotion = recognitions[0]['label'];
                setState(() {});
                for (var recognition in recognitions) {
                  String label = recognition["label"];
                  double confidence = recognition["confidence"];
                  print("Emotion: $label, Confidence: $confidence");
                  if (kDebugMode) {
                    print("Emotion: $label, Confidence: $confidence");
                  }
                }
              }
            } catch (e) {
              if (kDebugMode) {
                print("Error running emotion detection: $e");
              }
            }

            // if (kDebugMode) {
            //   print("Screenshot saved to $path");
            // }
            await File(path).delete();
          });
        }
      }).catchError((onError) {
        if (kDebugMode) {
          print(onError);
        }
      });
    });
  }

}