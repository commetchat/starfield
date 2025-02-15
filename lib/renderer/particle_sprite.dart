import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

class SpriteSheetInfo {
  int frames;
  int frameWidth;
  int frameHeight;
  int framesPerSecond;

  SpriteSheetInfo({
    required this.frames,
    required this.frameWidth,
    required this.frameHeight,
    required this.framesPerSecond,
  });
}

class ParticleSprite {
  ui.Codec? imageCodec;
  ui.Image? currentImage;

  int get width => spritesheet?.frameWidth ?? currentImage!.width;
  int get height => spritesheet?.frameHeight ?? currentImage!.height;

  double frameTime = -1;

  SpriteSheetInfo? spritesheet;

  bool get isSpriteSheet => spritesheet != null;

  ParticleSprite();

  Future<void> init(
      {ui.Codec? codec, ui.Image? image, SpriteSheetInfo? spriteSheet}) async {
    assert(image != null || codec != null);

    spritesheet = spriteSheet;

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
