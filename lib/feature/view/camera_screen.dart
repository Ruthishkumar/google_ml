import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_ml/feature/view/detail_screen.dart';
import 'package:google_ml/main.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  CameraScreenState createState() => CameraScreenState();
}

class CameraScreenState extends State<CameraScreen> {
  late final CameraController _controller;

  @override
  void initState() {
    _initializeCamera();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _initializeCamera() async {
    final CameraController cameraController = CameraController(
      cameras[0],
      ResolutionPreset.high,
    );
    _controller = cameraController;
    _controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  Future<String?> _takePicture() async {
    if (!_controller.value.isInitialized) {
      print("Controller is not initialized");
      return null;
    }
    String? imagePath;
    if (_controller.value.isTakingPicture) {
      print("Processing is in progress...");

      return null;
    }

    try {
      _controller.setFlashMode(FlashMode.off);
      final XFile file = await _controller.takePicture();
      imagePath = file.path;
    } on CameraException catch (e) {
      print("Camera Exception: $e");
      return null;
    }
    return imagePath;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: _controller.value.isInitialized
            ? Stack(
                children: <Widget>[
                  CameraPreview(_controller),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 50),
                    child: Container(
                      alignment: Alignment.bottomCenter,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.camera),
                        label: const Text("Click"),
                        onPressed: () async {
                          await _takePicture().then((String? path) {
                            if (path != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailScreen(
                                    imagePath: path,
                                  ),
                                ),
                              );
                            } else {
                              print('Image path not found!');
                            }
                          });
                        },
                      ),
                    ),
                  )
                ],
              )
            : Container(
                color: Colors.white,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
      ),
    );
  }
}
