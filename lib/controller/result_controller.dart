import 'package:flutter/material.dart';
import 'package:submission/service/gemini_nutrition_service.dart';
import 'package:submission/service/image_classification_service.dart';
import 'package:submission/service/meal_db_service.dart';

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

  Map<String, dynamic>? recipeData;
  Map<String, dynamic>? nutritionData;

  Future<void> analyzeImage(String imagePath)async{
    isAnalyzing = true;
    recipeData = null;
    nutritionData = null;
    notifyListeners();

    try{
      final result = await _classificationService.inferenceImage(imagePath);

      detectedLabel = result['label'];

      final score = (result['score']as double) * 100;
      confidenceScore = "${score.toStringAsFixed(2)}%";

      recipeData = await _mealDbService.searchFoodRecipe(detectedLabel);
      nutritionData = await _geminiNutritionService.getNutritionInfo(detectedLabel);
    } catch (e){
      detectedLabel = "Gagal menganalisis gambar";
      confidenceScore = "0%";
    }

    isAnalyzing = false;
    notifyListeners();
  }
}