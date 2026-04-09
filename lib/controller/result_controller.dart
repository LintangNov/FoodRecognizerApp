import 'package:flutter/material.dart';
import 'package:submission/service/image_classification_service.dart';

class ResultController extends ChangeNotifier {
  final ImageClassificationService _service;

  ResultController(this._service);

  bool isAnalyzing = false;
  String detectedLabel = "";
  String confidenceScore = "";

  Future<void> analyzeImage(String imagePath)async{
    isAnalyzing = true;
    notifyListeners();

    try{
      final result = await _service.inferenceImage(imagePath);

      detectedLabel = result['label'];

      final score = (result['score']as double) * 100;
      confidenceScore = "${score.toStringAsFixed(2)}%";
    } catch (e){
      detectedLabel = "Gagal menganalisis gambar";
      confidenceScore = "0%";
    }

    isAnalyzing = false;
    notifyListeners();
  }
}