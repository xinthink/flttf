import 'dart:typed_data' show Float32List, Uint8List;
import 'dart:ui' show Picture, PictureRecorder;

import 'package:flttf/constants.dart';
import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';

class Recognizer {
  Future loadModel() => Tflite.loadModel(
    model: "models/mnist/mnist.tflite",
    labels: "models/mnist/labels.txt",
  ).catchError((e, s) => debugPrint("loading model failure: $e $s"));

  Future recognize(List<Offset> points) async {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder, _canvasCullRect)..scale(canvasScale);

    // background of the image
    canvas.drawRect(Rect.fromLTWH(0, 0, _imageSize, _imageSize), _bgPaint);

    // draw lines connecting the points
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i] + _canvasOffset, points[i + 1] + _canvasOffset, _fgPaint);
      }
    }

    // create image from the canvas
    final picture = recorder.endRecording();
    Uint8List bytes = await _toGreyScaleBytes(picture, modelInputSize);
    // debugPrint("--- greyscale uint8 bytes: ${bytes.length}");
    return _predict(bytes);
  }

  Future<Uint8List> _toGreyScaleBytes(Picture pic, int size) async {
    final img = await pic.toImage(size, size);
    final imgBytes = await img.toByteData();
    final resultBytes = Float32List(size * size);
    final buffer = Float32List.view(resultBytes.buffer);
    int index = 0;
    for (int i = 0; i < imgBytes.lengthInBytes; i += 4) {
      final r = imgBytes.getUint8(i);
      final g = imgBytes.getUint8(i + 1);
      final b = imgBytes.getUint8(i + 2);
      // final a = imgBytes.getUint8(i + 3);
      // debugPrint("pixel[$i] argb=${a},${r},${g},${b} ${(r + g + b) / 3.0 / 255.0}");
      buffer[index++] = (r + g + b) / 3.0 / 255.0;

      // for (int j = 0; j < size; j++) {
      //   final c = Color(imgBytes.getUint32((i + j * size) * 4)); // argb
      //   buffer[index++] = (c.red + c.green + c.blue) / 3.0 / 255.0;
      //   debugPrint("pixel[$i,$j]: $c ${c.red},${c.green},${c.blue}");
      // }
    }
    return resultBytes.buffer.asUint8List();
  }

  Future _predict(Uint8List bytes) => Tflite.runModelOnBinary(
    binary: bytes,
  ).catchError((e, s) => debugPrint("prediction failure: $e $s"));
}

const _imageSize = canvasSize + 2 * canvasPadding;
const _canvasOffset = Offset(canvasPadding, canvasPadding);
final _canvasCullRect = Rect.fromPoints(Offset(0.0, 0.0), Offset(_imageSize, _imageSize));

// final Paint _drawingPaint = Paint()
//   ..strokeCap = StrokeCap.square
//   ..isAntiAlias = isAntiAlias
//   ..color = _brushBlack
//   ..strokeWidth = strokeWidth;

final Paint _whitePaint = Paint()
  ..strokeCap = StrokeCap.square
  ..isAntiAlias = isAntiAlias
  ..color = Colors.white
  ..strokeWidth = strokeWidth;

final _bgPaint = Paint()..color = Colors.black;
final _fgPaint = _whitePaint;
