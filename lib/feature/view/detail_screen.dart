import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class DetailScreen extends StatefulWidget {
  final String imagePath;

  const DetailScreen({Key? key, required this.imagePath}) : super(key: key);

  @override
  DetailScreenState createState() => DetailScreenState();
}

class DetailScreenState extends State<DetailScreen> {
  late final String _imagePath;
  late final TextRecognizer _textDetector;
  RegExp regEx = RegExp(r'[!@#<>?":_`~;[\]\\|=+)(*&^%0-9-]');
  Size? _imageSize;
  final List<TextElement> _elements = [];
  List<String> scannedText = [];
  List<String>? listScannedText;

  Future<void> _getImageSize(File imageFile) async {
    final Completer<Size> completer = Completer<Size>();
    final Image image = Image.file(imageFile);
    image.image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        completer.complete(Size(
          info.image.width.toDouble(),
          info.image.height.toDouble(),
        ));
      }),
    );
    final Size imageSize = await completer.future;
    setState(() {
      _imageSize = imageSize;
    });
  }

  void _recognizeEmails() async {
    _getImageSize(File(_imagePath));
    final inputImage = InputImage.fromFilePath(_imagePath);
    final text = await _textDetector.processImage(inputImage);
    for (TextBlock block in text.blocks) {
      for (TextLine line in block.lines) {
        if (regEx.hasMatch(line.text)) {
          scannedText.add(line.text);
          for (TextElement element in line.elements) {
            _elements.add(element);
          }
        }
        setState(() {
          listScannedText = scannedText;
        });
      }
    }
  }

  @override
  void initState() {
    _imagePath = widget.imagePath;
    _textDetector = GoogleMlKit.vision.textRecognizer();
    _recognizeEmails();
    super.initState();
  }

  @override
  void dispose() {
    _textDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Image Vision"),
      ),
      body: _imageSize != null
          ? Stack(
              children: [
                Container(
                  width: double.maxFinite,
                  color: Colors.black,
                  child: CustomPaint(
                    foregroundPainter: TextDetectorPainter(
                      _imageSize!,
                      _elements,
                    ),
                    child: AspectRatio(
                      aspectRatio: _imageSize!.aspectRatio,
                      child: Image.file(
                        File(_imagePath),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Card(
                    elevation: 8,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Padding(
                            padding: EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              "Scanned Numbers",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 60,
                            child: SingleChildScrollView(
                              child: listScannedText != null
                                  ? ListView.builder(
                                      shrinkWrap: true,
                                      physics: const BouncingScrollPhysics(),
                                      itemCount: listScannedText!.length,
                                      itemBuilder: (context, index) => Text(
                                        listScannedText![index],
                                        style: const TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black),
                                      ),
                                    )
                                  : Container(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )
          : Container(
              color: Colors.white,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
    );
  }
}

class TextDetectorPainter extends CustomPainter {
  TextDetectorPainter(this.absoluteImageSize, this.elements);

  final Size absoluteImageSize;
  final List<TextElement> elements;

  @override
  void paint(Canvas canvas, Size size) {}

  @override
  bool shouldRepaint(TextDetectorPainter oldDelegate) {
    return true;
  }

  Rect scaleRect(TextElement container) {
    return const Rect.fromLTRB(20.0, 100.0, 20.0, 40.0);
  }
}
