import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:submission/ui/result_page.dart';

class HomeController extends ChangeNotifier {
  String? imagePath;

  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile =  await picker.pickImage(source: source);

    if(pickedFile != null) {
      await _cropImage(pickedFile.path);
    }
  }

  Future<void> _cropImage(String path) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Gambar',
          toolbarColor: Colors.deepPurpleAccent,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: 'Crop Gambar',

        ),
      ],
    );

    if(croppedFile != null) {
      imagePath = croppedFile.path;
      notifyListeners();
    }
  }

  void clearImage(){
    imagePath = null;
    notifyListeners();
  }

  void goToResultPage(BuildContext context) {
    if(imagePath == null){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih gambar terlebih dulu')),
      );
      return;
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ResultPage()),
    );
  }
}
