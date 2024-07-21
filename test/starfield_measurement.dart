import 'dart:math';

import 'package:starfield/particle_system/ecs_particle_system.dart';
import 'package:starfield/particle_system/object_particle_system.dart';
import 'package:starfield/particle_system/particle_system.dart';
import 'package:starfield/particle_system/vector_particle_system.dart';

void main() {
  for (int i = 0; i < 10; i++) {
    int numParticles = pow(2, 15 + i).toInt();
    print("--------");
    testSystem(ObjectParticleSystem(), "Object Based", numParticles);
    testSystem(
        EcsParticleSystem(ParticleType.point), "ECS Based", numParticles);
    testSystem(VectorParticleSystem(), "Vector List", numParticles);
  }
}

void testSystem(ParticleSystem system, String name, int numParticles) {
  system.setSize(numParticles);

  int numIterations = 10;
  Duration total = Duration.zero;
  for (int i = 0; i < numIterations; i++) {
    final stopwatch = Stopwatch()..start();
    system.process(0.1);
    total += stopwatch.elapsed;
  }

  print(
      '[$numParticles] $name Particle system processed in ${total.inMilliseconds}ms  Average: ${total.inMilliseconds / numIterations}');

  system.printParticle();
}
