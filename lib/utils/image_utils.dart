import 'package:camera/camera.dart';
import 'package:image/image.dart' as image_lib;

class ImageUtils {
  static image_lib.Image? convertCameraImage(CameraImage cameraImage){
    if (cameraImage.format.group == ImageFormatGroup.yuv420){
      return _convertYUV420(cameraImage);
    } else if (cameraImage.format.group == ImageFormatGroup.bgra8888){
      return _convertBGRA8888(cameraImage);
    }

    return _convertBGRA8888(cameraImage);
  }

  static image_lib.Image _convertBGRA8888(CameraImage cameraImage){
    return image_lib.Image.fromBytes(width: 
    cameraImage.width, height: cameraImage.height, bytes: cameraImage.planes[0].bytes.buffer,
    order: image_lib.ChannelOrder.bgra,
    );
  }

  static image_lib.Image _convertYUV420(CameraImage cameraImage){
    final int width = cameraImage.width;
    final int height = cameraImage.height;
    final int uvRowStride = cameraImage.planes[1].bytesPerRow;
    final int uvPixelStride = cameraImage.planes[1].bytesPerPixel!;
    final image = image_lib.Image(width: width, height: height);

    for (var w = 0; w < width; w++) {
      for (var h = 0; h < height; h++) {
        final int uvIndex = uvPixelStride * (w/2).floor() + uvRowStride * (h/2).floor();
        final int index = h*width+w;

        final y = cameraImage.planes[0].bytes[index];
        final u = cameraImage.planes[1].bytes[uvIndex];
        final v = cameraImage.planes[2].bytes[uvIndex];

        int r = (y +v * 1436 / 1024 - 179).round();
        int g = (y - u * 46549 / 131072 + 44 - v * 93604 / 131072 + 91).round();
        int b = (y + u * 1814 / 1024 - 227).round();

        image.setPixelRgb(w, h, r.clamp(0, 255), g.clamp(0, 255), b.clamp(0, 255));
      }
    }
    return image;
  }
}