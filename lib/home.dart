import 'dart:math';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
  }

  static Matrix4 _pmat(num pv) {
    return new Matrix4(
      1.0, 0.0, 0.0, 0.0, //
      0.0, 1.0, 0.0, 0.0, //
      0.0, 0.0, 1.0, pv * 0.001, //
      0.0, 0.0, 0.0, 1.0,
    );
  }

  Matrix4 perspective = _pmat(1.0);
  double x = 0;

  double s = 0;

  BoxFit fit = BoxFit.fill;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final w = mq.size.width, h = mq.size.height;

    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          x += details.delta.dx / 100;
          s += details.delta.dy;
        });
      },
      onLongPress: () {
        pick();
      },
      onDoubleTap: () {
        setState(() {
          fit = fit == BoxFit.cover ? BoxFit.contain : BoxFit.cover;
        });
      },
      child: Container(
        color: Colors.black,
        height: h,
        width: w / 2,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.003)
                ..rotateY(x),
              alignment: FractionalOffset.centerRight,
              child: Container(
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      child: img != null ? buildImage(w, h) : Container(),
                    ),
                  ],
                ),
                height: min(h, h - s),
                width: w / 2 - s,
                color: Colors.black,
              ),
            ),
            Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.003)
                ..rotateY(-x),
              alignment: FractionalOffset.centerLeft,
              child: Container(
                alignment: Alignment.centerRight,
                child: Stack(
                  children: [
                    Positioned(
                      right: 0,
                      child: img != null ? buildImage(w, h) : Container(),
                    ),
                  ],
                ),
                height: min(h, h - s),
                width: w / 2 - s,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Image buildImage(double w, double h) => Image.memory(
        img!,
        height: min(h, h - s),
        width: (w / 2 - s) * 2,
        fit: fit,
        alignment: Alignment.center,
      );

  Uint8List? img;
  double ration = 0;

  pick() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    final f = result?.files[0];

    if (f != null) {
      f.readStream?.listen((event) {
        print(event.length);
      });
      setState(() {
        img = f.bytes;
      });
    }
  }
}
