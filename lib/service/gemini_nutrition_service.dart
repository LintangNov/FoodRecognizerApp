import 'dart:convert';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:submission/env/env.dart';

class GeminiNutritionService {
  late final GenerativeModel model;

  final Map<String, Map<String, dynamic>> _nutritionCache = {};

  GeminiNutritionService(){
    final apiKey = Env.geminiApiKey;
    model = GenerativeModel(
      model: 'gemini-2.5-flash', 
      apiKey: apiKey,
      systemInstruction: Content.system(
        'Kamu adalah Ahli gizi. Berikan estimasi nutrisi: kalori, karbohidrat, lemak, serat, protein. Satuan kkal/gram. Output JSON.',
      ),
      generationConfig: GenerationConfig(
        temperature: 0,
        responseMimeType: 'application/json',
        responseSchema: Schema(
          SchemaType.object,
          properties: {
            'kalori': Schema(SchemaType.string),
            'karbohidrat': Schema(SchemaType.string),
            'lemak': Schema(SchemaType.string),
            'serat': Schema(SchemaType.string),
            'protein': Schema(SchemaType.string),
          },
        ),
      ),
      );
  }

  Future<Map<String, dynamic>?> getNutritionInfo(String foodName)async{
    final normalizedFoodName = foodName.toLowerCase().trim();
    if (_nutritionCache.containsKey(normalizedFoodName)) {
      print("INFO: Mengambil nutrisi '$normalizedFoodName' dari cache");
      return _nutritionCache[normalizedFoodName];
    }

    final promt = 'Nama makanannya $foodName';
    final content = [Content.text(promt)];

    try{
      final response = await model.generateContent(content);
      final responseText = response.text;

      if (responseText != null && responseText.isNotEmpty){
        final RegExp regex = RegExp(r'\{[\s\S]*\}');
        final match = regex.firstMatch(responseText);

        if (match != null){
          final jsonString = match.group(0)!;
          final Map<String, dynamic> result = jsonDecode(jsonString);
          _nutritionCache[normalizedFoodName] = result;
          return result;
        } else {
          print("ERROR: Gagal menemukan format JSON di respons Gemini");
        }
      }
      return null;
    } catch(e){
      print("ERROR GEMINI NUTRITION SERVICE: $e");
      return null;
    }
  }
}