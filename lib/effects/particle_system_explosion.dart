import 'package:flutter/cupertino.dart';
import 'package:starfield/particle_system/ecs_particle_system.dart';
import 'package:vector_math/vector_math_64.dart';

class ParticleSystemExplosion extends EcsParticleSystem {
  ParticleSystemExplosion({
    super.sprite,
  }) : super(alignment: Alignment.center);

  double get gravity => 30;

  @override
  void setDefaultProperties(int index) {
    var pos = Vector2(r.nextDouble() - 0.5, r.nextDouble() - 0.5).normalized() *
        r.nextDouble() *
        100;
    setPositionX(index, pos.x);
    setPositionY(index, pos.y);

    var vel = pos * r.nextDouble() * 50;
    setVelocityX(index, vel.x);
    setVelocityY(index, vel.y);
  }

  @override
  void setDefaultSpriteProperties(int index) {
    setScale(index, (index % 100) / 100 * 1);
    setRotation(index, r.nextDouble() - 0.5);
    setColor(index, 0xffffffff);
    setFrame(index, 0);
  }

  @override
  void processVelocities(double delta) {
    for (int i = 0; i < numParticles; i++) {
      var vx = getVelocityX(i);
      var vy = getVelocityY(i);

      var r = (i % 100) / 100;

      vy += gravity;
      vy *= 0.98 - (r * 0.05);
      vx *= 0.98 - (r * 0.05);

      setVelocityX(i, vx);
      setVelocityY(i, vy);
    }
  }
}
