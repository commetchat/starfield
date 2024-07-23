import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

class ParticleSprite {
  ui.Codec? imageCodec;
  ui.Image? currentImage;

  int get width => currentImage!.width;
  int get height => currentImage!.height;

  double frameTime = -1;

  ParticleSprite();

  Future<void> init({ui.Codec? codec, ui.Image? image}) async {
    assert(image != null || codec != null);

    if (codec != null) {
      imageCodec = codec;
      await decodeNextFrame();
    } else {
      currentImage = image;
    }
  }

  ui.Image getCurrentFrame() {
    return currentImage!;
  }

  void process(double delta) {
    if (frameTime == -1) {
      return;
    }

    frameTime -= delta;
    if (frameTime <= 0) {
      frameTime = -1;
      decodeNextFrame();
    }
  }

  Future<void> decodeNextFrame() async {
    var image = await imageCodec!.getNextFrame();
    if (image.duration != Duration.zero) {
      frameTime = image.duration.inMilliseconds.toDouble() / 1000;
    }
    currentImage = image.image;
  }
}
