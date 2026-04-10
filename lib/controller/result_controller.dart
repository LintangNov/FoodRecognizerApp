import 'package:flutter/material.dart';
import 'package:submission/service/gemini_nutrition_service.dart';
import 'package:submission/service/image_classification_service.dart';
import 'package:submission/service/meal_db_service.dart';
import 'dart:async';

class ResultController extends ChangeNotifier {
  final ImageClassificationService _classificationService;
  final MealDbService _mealDbService;
  final GeminiNutritionService _geminiNutritionService;

  ResultController(
    this._classificationService,
    this._mealDbService,
    this._geminiNutritionService,
    );

  bool isAnalyzing = false;
  String detectedLabel = "";
  String confidenceScore = "";
  
  String? errorMessage; 

  Map<String, dynamic>? recipeData;
  Map<String, dynamic>? nutritionData;

  Future<void> analyzeImage(String imagePath)async{
    isAnalyzing = true;
    errorMessage = null;
    recipeData = null;
    nutritionData = null;
    notifyListeners();

    try{
      final result = await _classificationService.inferenceImage(imagePath);

      if (result.containsKey('error')){
        throw Exception(result['error']);
      }

      detectedLabel = result['label']?.toString().trim() ?? "Tidak diketahui";

      final score = (result['score']as double?? 0.0) * 100;
      confidenceScore = "${score.toStringAsFixed(2)}%";

      recipeData = await _mealDbService.searchFoodRecipe(detectedLabel);
      nutritionData = await _geminiNutritionService.getNutritionInfo(detectedLabel);
      
    } catch (e){
      print("ERROR SAAT ANALISIS: $e");
      detectedLabel = "Gagal menganalisis";
      confidenceScore = "0%";
      
      if (e is TimeoutException) {
        errorMessage = "Gagal mengunduh model. Periksa koneksi internetmu.";
      } else {
        errorMessage = "Terjadi kesalahan: ${e.toString()}";
      }
    } finally {
      isAnalyzing = false;
      notifyListeners();
    }
  }
}