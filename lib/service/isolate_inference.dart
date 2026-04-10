import 'dart:isolate';

import 'package:camera/camera.dart';
import 'package:image/image.dart' as image_lib;
import 'package:submission/utils/image_utils.dart';
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
    _sendPort = await _receivePort.first;
  }

  Future<void> close() async {
    _isolate.kill();
    _receivePort.close();
  }

  static void entryPoint(SendPort sendPort) async {
    final port = ReceivePort();
    sendPort.send(port.sendPort);

    Interpreter? interpreter;

    await for (final InferenceModel isolateModel in port) {
      try {
        image_lib.Image? img;

        if (isolateModel.imagePath != null) {
          img = await image_lib.decodeImageFile(isolateModel.imagePath!);
        } else if (isolateModel.cameraImage != null) {
          img = ImageUtils.convertCameraImage(isolateModel.cameraImage!);
        }

        if (img == null) {
          isolateModel.responsePort.send({"error": "Gagal membaca atau memproses gambar."});
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
            return [pixel.r.toInt(), pixel.g.toInt(), pixel.b.toInt()];
          }),
        );

        final input = [imageMatrix];
        final output = [List<int>.filled(isolateModel.outputShape[1],0)];

        interpreter ??= Interpreter.fromAddress(isolateModel.interpreterAddress);
        interpreter.run(input, output);

        final result = output.first;

        double maxScore = 0;
        int maxIndex = 0;
        for (var i = 0; i < result.length; i++) {
          if (result[i] > maxScore){
            maxScore = result[i].toDouble();
            maxIndex = i;
          }
        }

        maxScore = maxScore / 255.0;

        String detectedLabel = isolateModel.labels[maxIndex];

        isolateModel.responsePort.send({
          "label": detectedLabel,
          "score": maxScore
        });

      } catch (e) {
        isolateModel.responsePort.send({
          "error": "Isolate Error: ${e.toString()}"
        });
      }
    }
  }
}
