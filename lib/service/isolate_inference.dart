import 'dart:isolate';

import 'package:camera/camera.dart';
import 'package:image/image.dart' as image_lib;
import 'package:tflite_flutter/tflite_flutter.dart';

class InferenceModel {
  CameraImage? cameraImage;
  String? imagePath;
  int interpreterAddress;
  List<String> labels;
  List<int> inputShape;
  List<int> outputShape;
  late SendPort responsePort;

  InferenceModel({
    this.cameraImage,
    this.imagePath,
    required this.interpreterAddress,
    required this.labels,
    required this.inputShape,
    required this.outputShape,
  });
}

class IsolateInference {
  static const String _debugName = "TFLITE_INFERENCE";

  final ReceivePort _receivePort = ReceivePort();
  late Isolate _isolate;
  late SendPort _sendPort;

  SendPort get sendPort => _sendPort;

  Future<void> start() async {
    _isolate = await Isolate.spawn<SendPort>(
      entryPoint,
      _receivePort.sendPort,
      debugName: _debugName,
    );
  }

  Future<void> close() async {
    _isolate.kill();
    _receivePort.close();
  }

  static void entryPoint(SendPort sendPort) async {
    final port = ReceivePort();
    sendPort.send(port.sendPort);

    await for (final InferenceModel isolateModel in port) {
      image_lib.Image? img;

      if (isolateModel.imagePath != null) {
        img = await image_lib.decodeImageFile(isolateModel.imagePath!);
      } else if (isolateModel.cameraImage != null) {
        // TODO: bikin konversi camera feed
      }

      if (img == null) {
        continue;
      }

      image_lib.Image imageInput = image_lib.copyResize(
        img,
        width: isolateModel.inputShape[1],
        height: isolateModel.inputShape[2],
      );

      final imageMatrix = List.generate(
        imageInput.height,
        (y) => List.generate(imageInput.width, (x) {
          final pixel = imageInput.getPixel(x, y);
          return [pixel.r, pixel.g, pixel.b];
        }),
      );

      final input = [imageMatrix];
      final output = [List<double>.filled(isolateModel.outputShape[1],0)];

      Interpreter interpreter = Interpreter.fromAddress(isolateModel.interpreterAddress);
      interpreter.run(input, output);

      final result = output.first;

      double maxScore = 0;
      int maxIndex = 0;
      for (var i = 0; i < result.length; i++) {
        if (result[i] > maxScore){
          maxScore = result[i];
          maxIndex = i;
        }
      }

      String detectedLabel = isolateModel.labels[maxIndex];

      isolateModel.responsePort.send({
        "label": detectedLabel,
        "score": maxScore
      });
    }
  }
}
