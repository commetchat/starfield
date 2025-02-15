import 'package:flutter/cupertino.dart';
import 'package:starfield/particle_system/ecs_particle_system.dart';

class ParticleSystemRain extends EcsParticleSystem {
  ParticleSystemRain({
    super.sprite,
    this.spriteSize = 1,
    this.gravity = 30,
    this.height = 1000,
  }) : super(alignment: Alignment.topLeft);

  double spriteSize;

  double gravity;

  double height;

  @override
  void setDefaultProperties(int index) {
    double x = r.nextDouble() * currentSize!.width;
    double y = -(sprite?.height ?? 10) + r.nextDouble() * -height;

    setPositionX(index, x);
    setPositionY(index, y);
  }

  @override
  void setDefaultSpriteProperties(int index) {
    setColor(index, 0xFFFFFFFF);
    setScale(index, (index % 100) / 100 * spriteSize);
    setRotation(index, index % 100);
  }

  @override
  void processVelocities(double delta) {
    for (int i = 0; i < numParticles; i++) {
      int iy = indexToPosYIndex(i);
      var vy = velocities[iy];

      var r = (i % 100) / 100;

      vy += gravity;
      vy *= 0.98 - (r * 0.05);

      velocities[iy] = vy;
    }
  }

  @override
  void processRotations(double delta) {
    for (int i = 0; i < numParticles; i++) {
      var r = rotations[i];
      r += delta;
      rotations[i] = r;
    }
  }

  @override
  void processAngularVelocities(double delta) {
    return;
  }
}
