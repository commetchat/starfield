import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:starfield/particle_system/ecs_particle_system.dart';
import 'package:starfield/particle_system/particle_system.dart';

class ParticleSystemRenderer extends StatefulWidget {
  const ParticleSystemRenderer(
      {required this.system, this.showPerformance = false, super.key});
  final ParticleSystem system;
  final bool showPerformance;

  @override
  State<ParticleSystemRenderer> createState() => _ParticleSystemRendererState();
}

class _ParticleSystemRendererState extends State<ParticleSystemRenderer> {
  late Timer timer;
  double delta = 0;

  @override
  void initState() {
    timer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      setState(() {
        widget.system.process(0.016);
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var fps = (1 / (widget.system.processTime.inMicroseconds / 1000000));
    if (!fps.isFinite) {
      fps = 0;
    }
    return CustomPaint(
      painter: ParticleSystemPainter(widget.system),
      child: widget.showPerformance
          ? Text("${widget.system.processTime.inMicroseconds}μs")
          : null,
    );
  }
}

class ParticleSystemPainter extends CustomPainter {
  ParticleSystem system;
  ParticleSystemPainter(this.system);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    paint.color = Colors.black;
    paint.strokeWidth = 5;
    paint.strokeCap = StrokeCap.round;

    if (system is EcsParticleSystem) {
      var s = system as EcsParticleSystem;
      s.currentSize = size;
      if (!s.ready) {
        s.init();
      }

      var offset = s.alignment.alongSize(size);

      canvas.translate(offset.dx, offset.dy);

      if (s.sprite != null) {
        canvas.drawRawAtlas(s.sprite!.getCurrentFrame(), s.rstTransforms,
            s.rects, s.colors, BlendMode.modulate, null, paint);
      } else {
        canvas.drawRawPoints(PointMode.points, s.positions, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
