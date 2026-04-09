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
    WidgetsBinding.instance.addPostFrameCallback((_){
      if (!mounted) return;
      final imagePath = context.read<HomeController>().imagePath;
      if(imagePath != null){
        context.read<ResultController>().analyzeImage(imagePath);
      }

    });
    Future.microtask(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    final imagePath = context.read<HomeController>().imagePath;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        Expanded(
          child: Center(
            child: imagePath != null
                ? Image.file(File(imagePath), fit: BoxFit.cover,)
                : const Icon(Icons.broken_image, size: 100),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          
          child: Consumer<ResultController>(
            builder: (context, provider, child){
              if (provider.isAnalyzing){
                return const ClassificatioinItemShimmer();
              }

              return ClassificatioinItem(
                item: provider.detectedLabel,
                value: provider.confidenceScore,
              );
            },
          )
        ),
      ],
    );
  }
}
