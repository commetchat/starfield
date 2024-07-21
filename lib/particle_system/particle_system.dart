import 'dart:typed_data';

abstract class ParticleSystem {
  void setSize(int particleCount);

  void process(double delta);

  void printParticle();

  // Float32x4 getPosition(int index);

  // Float32x4 getVelocity(int index);

  // void setPosition(int index, Float32x4 position);

  // void setVelocity(int index, Float32x4 velocity);
}
