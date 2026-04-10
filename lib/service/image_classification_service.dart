import 'dart:io';
import 'dart:isolate';
import 'dart:async'; 

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:submission/service/firebase_ml_service.dart';
import 'package:submission/service/isolate_inference.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class ImageClassificationService {
  final FirebaseMlService _mlService;
  
  late Interpreter interpreter;
  late List<String> labels;
  late IsolateInference isolateInference;
  late Tensor inputTensor;
  late Tensor outputTensor;

  bool isInitialized = false;
  Completer<void>? _initCompleter;

  ImageClassificationService(this._mlService);

  Future<void> initHelper() async {
    if (isInitialized) return;

    if (_initCompleter != null){
      return _initCompleter!.future;
    }
    _initCompleter = Completer<void>();


    try {
      final labelTxt = await rootBundle.loadString("assets/labels.txt");
      labels = labelTxt.split('\n');

      final File modelFile = await _mlService.loadModel().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw TimeoutException("Gagal mengunduh model dari Firebase.");
        },
      );

      final options = InterpreterOptions()
        ..useMetalDelegateForIOS = true;

      interpreter = Interpreter.fromFile(modelFile, options: options);

      inputTensor = interpreter.getInputTensors().first;
      outputTensor = interpreter.getOutputTensors().first;

      isolateInference = IsolateInference();
      await isolateInference.start();

      isInitialized = true;
      _initCompleter!.complete();
    } catch (e) {
      _initCompleter!.completeError(e);
      _initCompleter = null;
      print("ERROR INIT HELPER: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> inferenceImage(String imagePath) async {
    if (!isInitialized) {
      await initHelper();
    }

    var isolateModel = InferenceModel(
      imagePath: imagePath,
      interpreterAddress: interpreter.address,
      labels: labels,
      inputShape: inputTensor.shape,
      outputShape: outputTensor.shape,
    );

    ReceivePort responsePort = ReceivePort();
    isolateModel.responsePort = responsePort.sendPort;

    isolateInference.sendPort.send(isolateModel);

    var results = await responsePort.first as Map<String, dynamic>;

    if (results.containsKey("error")) {
      throw Exception(results["error"]);
    }

    return results;
  }

  Future<Map<String, dynamic>> inferenceCameraFeed(CameraImage cameraImage) async {
    if (!isInitialized) {
      await initHelper();
    }

    var isolateModel = InferenceModel(
      cameraImage: cameraImage,
      interpreterAddress: interpreter.address,
      labels: labels,
      inputShape: inputTensor.shape,
      outputShape: outputTensor.shape,
    );

    ReceivePort responsePort = ReceivePort();
    isolateModel.responsePort = responsePort.sendPort;

    isolateInference.sendPort.send(isolateModel);

    var results = await responsePort.first as Map<String, dynamic>;
    return results;
  }

  Future<void> close() async {
    if (isInitialized) {
      await isolateInference.close();
      interpreter.close();
    }
  }
}