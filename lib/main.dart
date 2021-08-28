import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';
import 'dart:math' as math;

import 'bndbox.dart';
import 'camera.dart';

List<CameraDescription>? cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print('Error: $e .code \n Error Message: $e.message');
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(cameras!),
    );
  }
}

class HomePage extends StatefulWidget {
  final List<CameraDescription> cameras;

  HomePage(this.cameras);

  @override
  _HomePageStateState createState() => new _HomePageStateState();
}

class _HomePageStateState extends State<HomePage> {
  List<dynamic> _recognitions = [];
  int _imageHeight = 0;
  int _imageWidth = 0;
  String _model = "";

  Widget _stopCamera() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RaisedButton(
            color: Colors.greenAccent,
            child: Text(
              "작동",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () => onCamera(ssd),
          ),
        ],
      ),
    );
  }

  Widget _runCamera() {
    Size screen = MediaQuery.of(context).size;
    return Stack(
      children: [
        Camera(
          widget.cameras,
          _model,
          setRecognitions,
        ),
        BndBox(
          _recognitions == null ? [] : _recognitions,
          math.max(_imageHeight, _imageWidth),
          math.min(_imageHeight, _imageWidth),
          screen.height,
          screen.width,
        ),
      ],
    );
  }

  loadModel() async {
    String res;
    res = (await Tflite.loadModel(
        model: "assets/ssd_mobilenet_v1_1_metadata_1.tflite",
        labels: "assets/ssd_mobilenet.txt"))!;
    print(res);
  }

  onCamera(model) {
    setState(() {
      _model = model;
    });
    loadModel();
  }

  setRecognitions(recognitions, imageHeight, imageWidth) {
    setState(() {
      _recognitions = recognitions;
      _imageHeight = imageHeight;
      _imageWidth = imageWidth;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.greenAccent,
        title: Text("물체 인식"),
        actions: [
          IconButton(
            icon: Icon(Icons.stop),
            onPressed: () {
              _model = "";
            },
          )
        ],
      ),
      body: _model == "" ? _stopCamera() : _runCamera(),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
