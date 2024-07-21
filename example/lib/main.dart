import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
  late final EcsParticleSystem system;
  ui.Image? image;
  int numParticles = 1000;

  @override
  void initState() {
    system = EcsParticleSystem(ParticleType.sprite);
    system.setSize(numParticles);

    loadImageFromAsset("assets/star_07.png").then((loaded) {
      setState(() {
        image = loaded;
      });
    });

    super.initState();
  }

  Future<ui.Image> loadImageFromAsset(String assetName) async {
    if (kIsWeb) {
      WidgetsFlutterBinding.ensureInitialized();
      var image = AssetImage(assetName);
      var key = await image.obtainKey(ImageConfiguration.empty);
      var stream = image.loadBuffer(
          key, PaintingBinding.instance.instantiateImageCodecFromBuffer);
      var completer = Completer<ui.Image>();
      stream.addListener(ImageStreamListener((image, synchronousCall) {
        completer.complete(image.image);
      }));
      return completer.future;
    }
    var buffer = await ImmutableBuffer.fromAsset(assetName);
    var codec = await ui.instantiateImageCodecFromBuffer(buffer);
    var frame = await codec.getNextFrame();
    return frame.image;
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
            if (image == null) CircularProgressIndicator(),
            if (image != null)
              ParticleSystemRenderer(system: system, img: image!),
            Align(
              alignment: Alignment.topLeft,
              child: Column(
                children: [
                  for (var x in [100, 1000, 5000, 10000, 25000, 50000, 100000])
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                            onPressed: () => system.setSize(x),
                            child: Text("$x Particles")),
                      ),
                    ),
                ],
              ),
            )
          ],
        ));
  }
}
