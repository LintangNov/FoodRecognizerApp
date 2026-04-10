import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:submission/service/image_classification_service.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _cameraController;
  bool _isProcessing = false;
  String _detectedLabel = 'Mendeteksi..';
  String _confidenceScore = "";
  
  @override
  void initState(){
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera()async{
    final cameras =await availableCameras();
    if(cameras.isEmpty) return;

    _cameraController = CameraController(
      cameras.first,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _cameraController!.initialize();
    if(!mounted) return;
    setState(() {});

    _cameraController!.startImageStream((CameraImage image)async{
      if(_isProcessing) return;
      _isProcessing = true;

      try {
        final service = context.read<ImageClassificationService>();
        final result = await service.inferenceCameraFeed(image);

        if(mounted){
          setState(() {
            _detectedLabel =result['label'];
            final score = (result['score'] as double)*100;
            _confidenceScore = "${score.toStringAsFixed(1)}%";
          });
        }
      } catch (e) {
        
      } finally {
        _isProcessing =false;
      }
    });
  }

  @override
  void dispose(){
    _cameraController?.stopImageStream();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized){
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Makanan lewat Kamera'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: CameraPreview(_cameraController!),
          ),

          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Card(
              color: Colors.black87,
              shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(16)),
              child: Padding(
                padding: EdgeInsetsGeometry.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _detectedLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    Text(
                      _confidenceScore,
                      style: const TextStyle(color: Colors.amberAccent, fontSize: 20, fontWeight: FontWeight.w600),

                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}