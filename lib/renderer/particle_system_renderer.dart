import 'dart:async';
import 'dart:ui';

import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:starfield/particle_system/ecs_particle_system.dart';
import 'package:starfield/particle_system/particle_system.dart';

class ParticleSystemRenderer extends StatefulWidget {
  const ParticleSystemRenderer(
      {required this.system, required this.img, super.key});
  final ParticleSystem system;
  final ui.Image img;

  @override
  State<ParticleSystemRenderer> createState() => _ParticleSystemRendererState();
}

class _ParticleSystemRendererState extends State<ParticleSystemRenderer> {
  late Timer timer;
  double delta = 0;
  late ui.Image img;

  @override
  void initState() {
    timer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      setState(() {
        widget.system.process(0.016);
      });
    });

    img = widget.img;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ParticleSystemPainter(widget.system, img),
    );
  }
}

class ParticleSystemPainter extends CustomPainter {
  ParticleSystem system;
  ui.Image image;

  ParticleSystemPainter(this.system, this.image);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    paint.color = Colors.black;
    paint.strokeWidth = 5;
    paint.strokeCap = StrokeCap.round;

    if (system is EcsParticleSystem) {
      var s = system as EcsParticleSystem;

      canvas.translate(size.width / 2, size.height / 2);

      if (s.type == ParticleType.sprite) {
        canvas.drawRawAtlas(image, s.rstTransforms, s.rects, s.colors,
            BlendMode.dstATop, null, paint);
      } else {
        canvas.drawRawPoints(PointMode.points, s.positions, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
