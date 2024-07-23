import 'package:starfield/particle_system/particle_system.dart';
import 'package:vector_math/vector_math_64.dart';

class _Particle {
  late Vector2 position;
  late Vector2 velocity;

  _Particle(this.position, this.velocity);
}

class ObjectParticleSystem implements ParticleSystem {
  late List<_Particle> _particles;

  @override
  void process(double delta) {
    for (var particle in _particles) {
      particle.velocity += Vector2(0.1, 0.1);

      particle.velocity *= 0.9;

      particle.position += particle.velocity * delta;
    }
  }

  @override
  void setSize(int particleCount) {
    _particles = List.generate(
        particleCount, (index) => _Particle(Vector2.zero(), Vector2.zero()));
  }

  @override
  void printParticle() {
    var p = _particles.first;
    print("X: ${p.position.x}, Y: ${p.position.y}");
  }

  @override
  Duration get processTime => Duration.zero;
}
