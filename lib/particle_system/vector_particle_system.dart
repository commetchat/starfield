import 'dart:typed_data';

import 'package:starfield/particle_system/particle_system.dart';
import 'package:vector_math/vector_math.dart';
import 'package:vector_math/vector_math_lists.dart';

class VectorParticleSystem implements ParticleSystem {
  late Vector2List positions;
  late Vector2List velocities;

  @override
  void process(double delta) {
    int len = positions.length;

    for (int i = 0; i < len; i++) {
      var v = velocities[i];
      v = v + Vector2(0.1, 0.1);
      v = v * 0.9;
      velocities[i] = v;
    }

    for (int i = 0; i < len; i++) {
      var p = positions[i];
      p = p + (velocities[i] * delta);
      positions[i] = p;
    }
  }

  @override
  void setSize(int particleCount) {
    positions = Vector2List(particleCount);
    velocities = Vector2List(particleCount);
  }

  @override
  void printParticle() {
    var p = positions[0];
    print("X: ${p.x}, Y: ${p.y}");
  }
}
