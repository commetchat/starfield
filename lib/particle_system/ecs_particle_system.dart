import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:starfield/particle_system/particle_system.dart';
import 'package:starfield/starfield.dart';
import 'dart:math' as math;

enum ParticleType {
  point,
  sprite,
}

class EcsParticleSystem implements ParticleSystem {
  EcsParticleSystem({this.alignment = Alignment.center, this.sprite});
  ParticleSprite? sprite;
  Alignment alignment;
  Random r = Random();
  double time = 0;

  Size? currentSize;

  bool ready = false;

  @override
  Duration processTime = Duration.zero;

  late int numParticles;

  late Float32List positions;
  late Float32List velocities;

  late Float32List rotations;
  late Float32List angularVelocities;

  late Float32List rstTransforms;

  late Float32List rects;

  late Float32List scales;

  late Int32List colors;

  @pragma('vm:prefer-inline')
  int indexToSCosIndex(int index) {
    return index * 4;
  }

  @pragma('vm:prefer-inline')
  int indexToSSinIndex(int index) {
    return (index * 4) + 1;
  }

  @pragma('vm:prefer-inline')
  int indexToTXIndex(int index) {
    return (index * 4) + 2;
  }

  @pragma('vm:prefer-inline')
  int indexToTYIndex(int index) {
    return (index * 4) + 3;
  }

  @pragma('vm:prefer-inline')
  int indexToPosXIndex(int index) {
    return (index * 2);
  }

  @pragma('vm:prefer-inline')
  int indexToPosYIndex(int index) {
    return (index * 2) + 1;
  }

  @pragma('vm:prefer-inline')
  double getPositionX(int index) {
    return positions[indexToPosXIndex(index)];
  }

  @pragma('vm:prefer-inline')
  double getPositionY(int index) {
    return positions[indexToPosYIndex(index)];
  }

  @pragma('vm:prefer-inline')
  void setPositionX(int index, double value) {
    positions[indexToPosXIndex(index)] = value;
  }

  @pragma('vm:prefer-inline')
  void setPositionY(int index, double value) {
    positions[indexToPosYIndex(index)] = value;
  }

  @pragma('vm:prefer-inline')
  double getVelocityX(int index) {
    return velocities[indexToPosXIndex(index)];
  }

  @pragma('vm:prefer-inline')
  double getVelocityY(int index) {
    return velocities[indexToPosYIndex(index)];
  }

  @pragma('vm:prefer-inline')
  void setVelocityX(int index, double value) {
    velocities[indexToPosXIndex(index)] = value;
  }

  @pragma('vm:prefer-inline')
  void setVelocityY(int index, double value) {
    velocities[indexToPosYIndex(index)] = value;
  }

  @pragma('vm:prefer-inline')
  void setColor(int index, int value) {
    colors[index] = value;
  }

  @pragma('vm:prefer-inline')
  int getColor(int index) {
    return colors[index];
  }

  @pragma('vm:prefer-inline')
  void setScale(int index, double value) {
    scales[index] = value;
  }

  @pragma('vm:prefer-inline')
  void setFrame(int index, int frame) {
    double width = sprite?.spritesheet?.frameWidth.toDouble() ??
        sprite?.width.toDouble() ??
        0.0;
    double height = sprite?.spritesheet?.frameHeight.toDouble() ??
        sprite?.height.toDouble() ??
        0.0;

    double offset = frame.toDouble() * width;

    for (int i = 0; i < numParticles; i++) {
      rects[i * 4 + 0] = offset;
      rects[i * 4 + 1] = 0.0;
      rects[i * 4 + 2] = offset + width;
      rects[i * 4 + 3] = height;
    }
  }

  @pragma('vm:prefer-inline')
  double getScale(int index) {
    return scales[index];
  }

  @pragma('vm:prefer-inline')
  void setRotation(int index, double value) {
    rotations[index] = value;
  }

  @pragma('vm:prefer-inline')
  double getRotation(int index) {
    return rotations[index];
  }

  @pragma('vm:prefer-inline')
  void setAngularVelocity(int index, double value) {
    angularVelocities[index] = value;
  }

  @pragma('vm:prefer-inline')
  double getAngularVelocity(int index) {
    return angularVelocities[index];
  }

  void processVelocities(double delta) {
    for (int i = 0; i < numParticles; i++) {
      int ix = indexToPosXIndex(i);
      int iy = indexToPosYIndex(i);

      var vx = velocities[ix];
      var vy = velocities[iy];

      vy += 50;

      vx *= 0.98;
      vy *= 0.98;

      velocities[ix] = vx;
      velocities[iy] = vy;
    }
  }

  void processAngularVelocities(double delta) {
    for (int i = 0; i < numParticles; i++) {
      var v = angularVelocities[i];
      v = v * (0.99);
      angularVelocities[i] = v;
    }
  }

  void processPositions(double delta) {
    for (int i = 0; i < numParticles; i++) {
      var pxi = indexToPosXIndex(i);
      var pxy = indexToPosYIndex(i);

      var x = positions[pxi];
      var y = positions[pxy];

      x = x + (velocities[pxi] * delta);
      y = y + (velocities[pxy] * delta);

      positions[pxi] = x;
      positions[pxy] = y;
    }
  }

  void processRotations(double delta) {
    for (int i = 0; i < numParticles; i++) {
      var v = angularVelocities[i];
      rotations[i] = rotations[i] + (v * delta);
    }
  }

  void processRects(double delta) {
    double rectW = sprite!.spritesheet!.frameWidth.toDouble();
    double rectH = sprite!.spritesheet!.frameWidth.toDouble();

    for (int i = 0; i < numParticles; i++) {
      int frame = ((time * sprite!.spritesheet!.framesPerSecond).toInt() + i) %
          sprite!.spritesheet!.frames;
      double offset = frame.toDouble() * rectW;
      rects[i * 4 + 0] = offset;
      rects[i * 4 + 1] = 0.0;
      rects[i * 4 + 2] = offset + rectW;
      rects[i * 4 + 3] = rectH;
    }
  }

  void processTransformation(double delta) {
    double anchorX =
        (sprite?.spritesheet?.frameWidth ?? sprite?.width ?? 0) / 2;
    double anchorY =
        (sprite?.spritesheet?.frameHeight ?? sprite?.height ?? 0) / 2;
    // update transforms
    for (int i = 0; i < numParticles; i++) {
      var scosi = indexToSCosIndex(i);
      var ssini = indexToSSinIndex(i);
      var xi = indexToTXIndex(i);
      var yi = indexToTYIndex(i);
      var pxi = indexToPosXIndex(i);
      var pxy = indexToPosYIndex(i);

      var rotation = rotations[i];
      var scale = scales[i];

      final double scos = math.cos(rotation) * scale;
      final double ssin = math.sin(rotation) * scale;

      rstTransforms[scosi] = scos;
      rstTransforms[ssini] = ssin;

      var x = positions[pxi];
      var y = positions[pxy];

      final double tx = x + -scos * anchorX + ssin * anchorY;
      final double ty = y + -ssin * anchorX - scos * anchorY;

      rstTransforms[xi] = tx;
      rstTransforms[yi] = ty;
    }
  }

  bool shouldStop() {
    if (currentSize == null) {
      return false;
    }

    var offset = (-alignment).alongSize(currentSize!);
    var bottomBound = offset.dy;

    if (sprite != null) {
      bottomBound += sprite!.height.toDouble();
    }

    for (int i = 0; i < numParticles; i++) {
      var h = positions[indexToPosYIndex(i)];
      if (h < bottomBound) {
        return false;
      }
    }

    return true;
  }

  @override
  void process(double delta) {
    time += delta;
    var s = Stopwatch()..start();
    processVelocities(delta);
    processPositions(delta);

    if (sprite != null) {
      processAngularVelocities(delta);
      processRotations(delta);
      processTransformation(delta);
      sprite!.process(delta);
      if (sprite!.isSpriteSheet) {
        processRects(delta);
      }
    }

    if (shouldStop()) {
      setSize(numParticles);
    }

    processTime = s.elapsed;
  }

  @override
  void setSize(int particleCount) {
    numParticles = particleCount;

    velocities = Float32List(particleCount * 2);
    positions = Float32List(particleCount * 2);
    colors = Int32List(particleCount);

    if (sprite != null) {
      rstTransforms = Float32List(particleCount * 4);
      rotations = Float32List(particleCount);
      angularVelocities = Float32List(particleCount);
      scales = Float32List(particleCount);
      rects = Float32List(particleCount * 4);
    }

    ready = false;
  }

  void init() {
    for (int i = 0; i < numParticles; i++) {
      if (sprite != null) {
        setDefaultSpriteProperties(i);
      }

      setDefaultProperties(i);
    }

    ready = true;
  }

  @override
  void printParticle() {
    var x = positions[indexToPosXIndex(0)];
    var y = positions[indexToPosYIndex(0)];

    print("X: ${x}, Y: ${y}");
  }

  void setDefaultProperties(int index) {
    positions[indexToPosXIndex(index)] = r.nextDouble() * 100;
    positions[indexToPosYIndex(index)] = r.nextDouble() * 100;

    velocities[indexToPosXIndex(index)] = r.nextDouble() * 100;
    velocities[indexToPosYIndex(index)] = r.nextDouble() * 100;
  }

  void setDefaultSpriteProperties(int index) {
    scales[index] = 100.0;
    rotations[index] = r.nextDouble() * 0.5;
    angularVelocities[index] = r.nextDouble() * 2;
    colors[index] = 0xffffffff;

    double? rectW = sprite?.width.toDouble();
    double? rectH = sprite?.height.toDouble();

    if (sprite?.isSpriteSheet == true) {
      rectW = sprite!.spritesheet!.frameWidth.toDouble();
      rectH = sprite!.spritesheet!.frameHeight.toDouble();
    }

    rects[index * 4 + 0] = 0;
    rects[index * 4 + 1] = 0.0;
    rects[index * 4 + 2] = rectW!;
    rects[index * 4 + 3] = rectH!;
  }
}
