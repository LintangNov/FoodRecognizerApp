import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:submission/controller/home_controller.dart';
import 'package:submission/controller/result_controller.dart';
import 'package:submission/widget/classification_item.dart';

class ResultPage extends StatelessWidget {
  const ResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Result Page'),
      ),
      body: SafeArea(child: const _ResultBody()),
    );
  }
}

class _ResultBody extends StatefulWidget {
  const _ResultBody();

  @override
  State<_ResultBody> createState() => _ResultBodyState();
}

class _ResultBodyState extends State<_ResultBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final imagePath = context.read<HomeController>().imagePath;
      if (imagePath != null) {
        context.read<ResultController>().analyzeImage(imagePath);
      }
    });
  }

  List<Widget> _buildIngredients(Map<String, dynamic> recipe) {
    List<Widget> ingredients = [];
    for (var i = 0; i < 20; i++) {
      final ingredient = recipe['strIngredient$i'];
      final measure = recipe['strMeasure$i'];
      if (ingredient != null && ingredient.toString().trim().isNotEmpty) {
        ingredients.add(Text("- $ingredient: $measure"));
      }
    }
    return ingredients;
  }

  @override
  Widget build(BuildContext context) {
    final imagePath = context.read<HomeController>().imagePath;

    return Consumer<ResultController>(
      builder: (context, provider, child){
        if(provider.isAnalyzing){
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 15,),
                Text("Menganalisis gambar..."),
              ],
            ),
          );
        }

        if (provider.errorMessage != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  Text(
                    provider.errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.red),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () {
                      if (imagePath != null) {
                        context.read<ResultController>().analyzeImage(imagePath);
                      }
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text("Coba Lagi"),
                  )
                ],
              ),
            ),
          );
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: imagePath != null
                    ? Image.file(File(imagePath), height: 250, fit: BoxFit.cover,)
                    : const Icon(Icons.broken_image, size: 100,),
              ),
              SizedBox(height: 16,),

              ClassificatioinItem(
                item: provider.detectedLabel,
                value: provider.confidenceScore,
              ),
              const Divider(height: 32, thickness: 2,),

              if(provider.recipeData != null) ...[
                Text("Resep dari MealDB", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),)
                ,SizedBox(height: 8,),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: provider.recipeData!['strMealThumb'] != null
                        ? Image.network(provider.recipeData!['strMealThumb'], height: 150, fit: BoxFit.cover,)
                        : const Icon(Icons.fastfood, size: 100, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 16,),
                const Text("Bahan-bahan:", style: TextStyle(fontWeight: FontWeight.bold)),
                ..._buildIngredients(provider.recipeData!),
                const SizedBox(height: 16),
                const Text("Instruksi:", style: TextStyle(fontWeight: FontWeight.bold)),
                Text(provider.recipeData!['strInstructions'] ?? "Tidak ada instruksi."),
                const Divider(height: 32, thickness: 2),
              ] else ...[
                const Text("Resep tidak ditemukan di MealDB database.", style: TextStyle(fontStyle: FontStyle.italic)),
                const Divider(height: 32, thickness: 2),
              ],

              if(provider.nutritionData != null) ...[
                Text("Informasi Nutrisi (Gemini AI)", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsetsGeometry.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Kalori: ${provider.nutritionData!['kalori']}"),
                        Text("Karbohidrat: ${provider.nutritionData!['karbohidrat']}"),
                        Text("Lemak: ${provider.nutritionData!['lemak']}"),
                        Text("Protein: ${provider.nutritionData!['protein']}"),
                        Text("Serat: ${provider.nutritionData!['serat']}"),
                      ],
                    ),
                  ),
                )
              ] else ...[
                const Text("Nutrisi gagal dimuat.", style: TextStyle(fontStyle: FontStyle.italic)),
              ]
            ],
          ),
        );
      },
    );
    
  }
}
