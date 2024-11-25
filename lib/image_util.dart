import 'dart:typed_data';

import 'package:image/image.dart';

class ImageUtil {
  static bool isValidImage(List<int> image) {
    try {
      Image? i = decodeImage(Uint8List.fromList(image));
      return i != null;
    } catch(e) {
      return false;
    }
  }
}