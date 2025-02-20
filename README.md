<p align="center" style="padding-top:20px">
<h1 align="center">Starfield</h1>
<p align="center">High performance particle system for Flutter</p>

Existing particle systems for Flutter store particles as individual objects, which makes them slower to iterate over and process. Starfield takes a data-oriented approach, storing each particle attributes in contiguous memory (Float32List) allowing them to be processed much more efficiently. This has the added bonus of not needing to do any further processing at render time, as the renderer can read these memory buffers directly.

### Performance
Time to process n particles per storage method, see [starfield_measurement.dart](./test/starfield_measurement.dart) for process.

|                  | 32k   | 64k   | 131k   | 262k   | 524k   | 1.04m   |
|------------------|-------|-------|--------|--------|--------|---------|
| `Float32List`    | 0.8ms | 0.5ms | 1.0ms  | 1.9ms  | 4.0ms  | 8.3ms   |
| `Vector2List`    | 2.7ms | 3.9ms | 5.2ms  | 5.2ms  | 19.3ms | 35.8ms  |
| `List<Particle>` | 3.1ms | 4.7ms | 13.6ms | 28.2ms | 65.2ms | 127.1ms |

On desktop, Starfield can comfortably *process* roughly 500k particles at 60fps in a best case scenario, but performance is mostly limited by the Flutter renderer, where ~100k particles seems to be the limit in best case.

On Mobile, testing on Pixel 8a, around 50k particles appears to be where performance begins to degrade - again limited by performance of the renderer.
