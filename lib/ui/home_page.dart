import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:submission/controller/home_controller.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Food Recognizer App'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: const _HomeBody(),
        ),
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Center(
            child: Consumer<HomeController>(
              builder: (context, provider, child) {
                return GestureDetector(
                  onTap: () => _showImageSourceActionSheet(context),
                  child:
                      provider.imagePath != null
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(
                              File(provider.imagePath!),
                              fit: BoxFit.cover,
                            ),
                          )
                          : Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.grey.shade400,
                                width: 2,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.add_a_photo,
                                  size: 80,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text('Tekan untuk memilih gambar'),
                              ],
                            ),
                          ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        Consumer<HomeController>(
          builder: (context, provider, child) {
            if (provider.imagePath != null) {
              return TextButton.icon(
                onPressed: provider.clearImage,
                icon: const Icon(Icons.delete, color: Colors.red),
                label: const Text(
                  "Hapus Gambar",
                  style: TextStyle(color: Colors.red),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        const SizedBox(height: 16),
        FilledButton.tonal(
          onPressed: () {
            context.read<HomeController>().goToResultPage(context);
          },
          child: const Text("Analyze"),
        ),
      ],
    );
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bottomSheetContext) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Galeri"),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  context.read<HomeController>().pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Kamera'),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  context.read<HomeController>().pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
