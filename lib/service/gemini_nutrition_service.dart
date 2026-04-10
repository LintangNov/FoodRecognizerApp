import 'dart:convert';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:submission/env/env.dart';

class GeminiNutritionService {
  late final GenerativeModel model;

  GeminiNutritionService(){
    final apiKey = Env.geminiApiKey;
    model = GenerativeModel(
      model: 'gemini-1.5-flash', 
      apiKey: apiKey,
      systemInstruction: Content.system(
        'Saya adalah seorang ahli gizi yang mampu mengidentifikasi nutrisi atau kandungan gizi pada makanan layaknya uji laboratorium makanan. Hal yang bisa saya identifikasi adalah kalori, karbohidrat, lemak, serat, dan protein pada makanan. Satuan dari indikator tersebut berupa gram.',
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
    final promt = 'Nama makanannya yaitu $foodName';
    final content = [Content.text(promt)];

    try{
      final response = await model.generateContent(content);
      final responseText = response.text;

      if (responseText != null && responseText.isNotEmpty){
        final RegExp regex = RegExp(r'\{[\s\S]*\}');
        final match = regex.firstMatch(responseText);

        if (match != null){
          final jsonString = match.group(0)!;
          return jsonDecode(jsonString);
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