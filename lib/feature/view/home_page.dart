import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
     bool textScanning = false;
     RegExp regEx =
     RegExp(r'[!@#<>?":_`~;[\]\\|=+)(*&^%0-9-]');

     XFile? imageFile;
     String scannedText = "";



     @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
          leading: const Icon(Icons.keyboard_arrow_left_outlined),
          title: const Text('Google Ml')),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (textScanning) const CircularProgressIndicator(),
              if (!textScanning && imageFile == null)
              Container(
                height: 300,
                width: 300,
                decoration:  BoxDecoration(
                    color: Colors.grey[300],
                  borderRadius: const BorderRadius.all(Radius.circular(20))
                ),
              ),
              const SizedBox(height: 30),
              if (imageFile != null)
                Image.file(File(imageFile!.path)),
              Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  padding: const EdgeInsets.only(top: 10),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.white,
                      onPrimary: Colors.grey,
                      shadowColor: Colors.grey[400],
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0)),
                    ),
                    onPressed: () {
                      getImage(ImageSource.camera);
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 5),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.camera_alt,
                            size: 30,
                          ),
                          Text(
                            "Camera",
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey[600]),
                          )
                        ],
                      ),
                    ),
                  )),
              const SizedBox(
                height: 20
              ),
              Text(
                scannedText,
                style: const TextStyle(
                    color: Colors.black,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    fontSize: 20),
              )

            ],
          ),
        ),
      ),
    );
  }


  void getImage(ImageSource source) async {
    try {
      final pickedImage = await ImagePicker().pickImage(source: source);
      if (pickedImage != null) {
        textScanning = true;
        imageFile = pickedImage;
        setState(() {});
        getRecognisedText(pickedImage);
      }
    } catch (e) {
      textScanning = false;
      imageFile = null;
      scannedText = "Error occured while scanning";
      setState(() {});
    }
  }

     void getRecognisedText(XFile image) async {
       final inputImage = InputImage.fromFilePath(image.path);
       final textDetector = GoogleMlKit.vision.textRecognizer();
       RecognizedText recognisedText = await textDetector.processImage(inputImage);
       await textDetector.close();
       scannedText = "";
       for (TextBlock block in recognisedText.blocks) {
         for (TextLine line in block.lines) {
           if (regEx.hasMatch(line.text)) {
             scannedText = "$scannedText${line.text}";

           }
         }
       }
       textScanning = false;
       setState(() {});
     }
}
