import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:submission/controller/home_controller.dart';
import 'package:submission/controller/result_controller.dart';
import 'package:submission/service/firebase_ml_service.dart';
import 'package:submission/service/gemini_nutrition_service.dart';
import 'package:submission/service/image_classification_service.dart';
import 'package:submission/service/meal_db_service.dart';
import 'package:submission/ui/home_page.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(
    MultiProvider(
      providers: [
        Provider(create: (context) => FirebaseMlService()),
        Provider(
          create: (context)=> ImageClassificationService(
            context.read<FirebaseMlService>(),
          )..initHelper(),
        ),
        Provider(create: (context)=> MealDbService()),
        Provider(create: (context)=> GeminiNutritionService()),
        ChangeNotifierProvider(create: (context) => HomeController()),
        ChangeNotifierProvider(
          create: (context)=> ResultController(
            context.read<ImageClassificationService>(),
            context.read<MealDbService>(),
            context.read<GeminiNutritionService>(),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
