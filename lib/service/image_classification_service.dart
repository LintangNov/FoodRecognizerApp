import 'dart:io';
import 'dart:isolate';

import 'package:flutter/services.dart';
import 'package:submission/service/firebase_ml_service.dart';
import 'package:submission/service/isolate_inference.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class ImageClassificationService {
  final FirebaseMlService _mlService;
  late final Interpreter interpreter;
  late final List<String> labels;
  late final IsolateInference isolateInference;
  late Tensor inputTensor;
  late Tensor outputTensor;

  ImageClassificationService(this._mlService);

  Future<void> initHelper() async{
    final labelTxt = await rootBundle.loadString("assets/labels.txt");
    labels = labelTxt.split('\n');

    final File modelFile = await _mlService.loadModel();

    final options = InterpreterOptions()
      ..useNnApiForAndroid = true
      ..useMetalDelegateForIOS = true;

    interpreter = Interpreter.fromFile(modelFile, options: options);

    inputTensor = interpreter.getInputTensors().first;
    outputTensor = interpreter.getOutputTensors().first;

    isolateInference = IsolateInference();
    await isolateInference.start();
  }

  Future<Map<String, dynamic>> inferenceImage(String imagePath)async{
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
    return results;
  }

  Future<void> close() async{
    await isolateInference.close();
    interpreter.close();
  }
}