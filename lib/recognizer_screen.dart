import 'package:flttf/constants.dart';
import 'package:flttf/drawing_painter.dart';
import 'package:flutter/material.dart';

class RecognizerScreen extends StatefulWidget {
  RecognizerScreen({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _RecognizerScreenState createState() => _RecognizerScreenState();
}

class _RecognizerScreenState extends State<RecognizerScreen> {
  final points = List<Offset>();

  void _addPoint({
    BuildContext context,
    Offset offset,
    end = false,
  }) {
    if (end) {
      setState(() {
        points.add(null);
      });
    } else {
      RenderBox renderBox = context.findRenderObject();
      setState(() {
        points.add(renderBox.globalToLocal(offset));
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.all(16),
                color: Colors.red,
                alignment: Alignment.center,
                child: const Text('Header'),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  width: 1.0,
                  color: Colors.blue,
                ),
              ),
              child: _buildCanvas(),
            ),
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.all(16),
                color: Colors.blueGrey,
                alignment: Alignment.center,
                child: const Text('Footer'),
              ),
            ),
          ],
        ),
      ),
    );

  _buildCanvas() => Builder(
    builder: (BuildContext context) =>
      GestureDetector(
        onPanUpdate: (details) {
          _addPoint(context: context, offset: details.globalPosition);
        },
        onPanStart: (details) {
          _addPoint(context: context, offset: details.globalPosition);
        },
        onPanEnd: (details) {
          _addPoint(end: true);
        },
        child: ClipRect(
          child: CustomPaint(
            size: const Size(canvasSize, canvasSize),
            painter: DrawingPainter(
              offsetPoints: points,
            ),
          ),
        ),
      ),
  );
}
