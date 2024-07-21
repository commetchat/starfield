import 'dart:math';
import 'dart:typed_data';

import 'package:starfield/particle_system/particle_system.dart';
import 'package:vector_math/vector_math_64.dart';
import 'dart:math' as math;

enum ParticleType {
  point,
  sprite,
}

class EcsParticleSystem implements ParticleSystem {
  ParticleType type;

  EcsParticleSystem(this.type);

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

  void processVelocities(double delta) {
    for (int i = 0; i < numParticles; i++) {
      var rand = (i % 100).toDouble() / 100;
      rand = rand * 0.1;
      int ix = indexToPosXIndex(i);
      int iy = indexToPosYIndex(i);

      var vx = velocities[ix];
      var vy = velocities[iy];

      vy += 9.8;

      vx *= 0.98 - rand;
      vy *= 0.98 - rand;

      velocities[ix] = vx;
      velocities[iy] = vy;
    }
  }

  void processAngularVelocities(double delta) {
    for (int i = 0; i < numParticles; i++) {
      var rand = (i % 100).toDouble() / 100;
      rand = rand * 0.1;
      var v = angularVelocities[i];
      v = v * (0.99 - rand);
      angularVelocities[i] = v;
      rotations[i] = rotations[i] + (v * delta);
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

  void processTransformation(double delta) {
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

      var anchorX = 256.0;
      var anchorY = 256.0;

      var x = positions[pxi];
      var y = positions[pxy];

      final double tx = x + -scos * anchorX + ssin * anchorY;
      final double ty = y + -ssin * anchorX - scos * anchorY;

      rstTransforms[xi] = tx;
      rstTransforms[yi] = ty;
    }
  }

  @override
  void process(double delta) {
    processVelocities(delta);
    processPositions(delta);

    if (type == ParticleType.sprite) {
      processAngularVelocities(delta);
      processTransformation(delta);
    }
  }

  @override
  void setSize(int particleCount) {
    numParticles = particleCount;

    velocities = Float32List(particleCount * 2);
    positions = Float32List(particleCount * 2);
    colors = Int32List(particleCount);

    if (type == ParticleType.sprite) {
      rstTransforms = Float32List(particleCount * 4);
      rotations = Float32List(particleCount);
      angularVelocities = Float32List(particleCount);
      scales = Float32List(particleCount);
      rects = Float32List(particleCount * 4);
    }

    Random r = Random();

    for (int i = 0; i < numParticles; i++) {
      if (type == ParticleType.sprite) {
        rects[i * 4 + 0] = 0;
        rects[i * 4 + 1] = 0.0;
        rects[i * 4 + 2] = 512;
        rects[i * 4 + 3] = 512;

        scales[i] = 0.1;
        rotations[i] = r.nextDouble() * 3.14;
        angularVelocities[i] = r.nextDouble() * 50;

        colors[i] = r.nextInt(0xffffffff) | 0xff000000;
      }

      var initialPos =
          Vector2(r.nextDouble() - 0.5, r.nextDouble() - 0.5).normalized() *
              1280 *
              r.nextDouble();

      positions[indexToPosXIndex(i)] = initialPos.x;
      positions[indexToPosYIndex(i)] = initialPos.y;

      var vel = initialPos * r.nextDouble() * 10;

      velocities[indexToPosXIndex(i)] = vel.x;
      velocities[indexToPosYIndex(i)] = vel.y;
    }
  }

  @override
  void printParticle() {
    var x = positions[indexToPosXIndex(0)];
    var y = positions[indexToPosYIndex(0)];

    print("X: ${x}, Y: ${y}");
  }
}
