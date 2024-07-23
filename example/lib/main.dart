import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:show_fps/show_fps.dart';
import 'package:starfield/particle_system/ecs_particle_system.dart';
import 'package:starfield/starfield.dart';

import 'dart:ui' as ui;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Starfield',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Starfield Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  EcsParticleSystem? system;
  ui.Image? image;
  int numParticles = 1000;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    var data = await ImmutableBuffer.fromAsset("assets/star_07.png");
    var codec = await ui.instantiateImageCodecFromBuffer(data);
    var sprite = ParticleSprite();
    await sprite.init(codec: codec);

    setState(() {
      system = ParticleSystemExplosion(sprite: sprite);
      system!.setSize(numParticles);
    });
  }

  Future<ui.Image> textToImage(String str) async {
    final recorder = PictureRecorder();
    var newCanvas = Canvas(recorder);

    const textStyle = TextStyle(
      color: Colors.white,
      fontSize: 30,
    );
    final textSpan = TextSpan(
      text: str,
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(newCanvas, Offset.zero);
    final picture = recorder.endRecording();
    return await picture.toImage(
        textPainter.width.toInt(), textPainter.height.toInt());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: Stack(
          fit: StackFit.expand,
          alignment: Alignment.center,
          children: [
            if (system == null) CircularProgressIndicator(),
            if (system != null)
              ParticleSystemRenderer(
                system: system!,
                showPerformance: true,
              ),
            ShowFPS(
              alignment: Alignment.bottomLeft,
              child: Align(
                alignment: Alignment.topRight,
                child: Column(
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          setState(() {
                            var nParticles = system!.numParticles;
                            system =
                                ParticleSystemExplosion(sprite: system?.sprite);
                            system?.setSize(nParticles);
                          });
                        },
                        child: Text("Explosion")),
                    SizedBox(
                      height: 4,
                    ),
                    ElevatedButton(
                        onPressed: () {
                          setState(() {
                            var nParticles = system!.numParticles;
                            system = ParticleSystemRain(sprite: system?.sprite);
                            system?.setSize(nParticles);
                          });
                        },
                        child: Text("Rain")),
                    for (var x in [
                      100,
                      1000,
                      5000,
                      10000,
                      25000,
                      50000,
                      100000
                    ])
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
                        child: ElevatedButton(
                            onPressed: () => system!.setSize(x),
                            child: Text("$x Particles")),
                      ),
                  ],
                ),
              ),
            )
          ],
        ));
  }
}
