import 'package:collection_ext/iterables.dart';
import 'package:flttf/constants.dart';
import 'package:flttf/drawing_painter.dart';
import 'package:flttf/recognizer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  final recognizer = Recognizer();
  bool modelReady = false;
  List predicts;

  @override
  void initState() {
    super.initState();
    _initModel();
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
              color: Colors.grey.shade200,
              alignment: Alignment.center,
              child: const Text("Draw any digit 0~9 within the box below, one at a time"),
            ),
          ),
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1.5,
                    color: Colors.blue,
                  ),
                ),
                child: modelReady ? _buildCanvas() : const SizedBox(width: canvasSize, height: canvasSize),
              ),
              _buildClearButton(),
            ],
          ),
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 32),
              color: Colors.grey.shade100,
              alignment: Alignment.topCenter,
              child: _buildDigitsPane(),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildCanvas() => Builder(
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

  Widget _buildDigitsPane() => Row(
    children: List.generate(10, (i) => _buildDigitContainer(i, _findPredict(i))).asList(),
  );

  Widget _buildDigitContainer(int index, dynamic predict) => Expanded(
    flex: 1,
    child: Container(
      color: Colors.blueGrey.shade100,
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: AspectRatio(
        aspectRatio: 0.36,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _buildDigitCell(index, predict),
            const SizedBox(height: 4),
            _buildDigitProb(index, predict),
          ],
        ),
      ),
    ),
  );

  Widget _buildDigitCell(int index, dynamic predict) => Text(
    "$index",
    style: TextStyle(
      color: _digitFontColorByProb(predict),
      fontWeight: FontWeight.bold,
      fontSize: 60,
    ),
  );

  Widget _buildDigitProb(int index, dynamic predict) => Text(
    _formatProb(predict),
    style: const TextStyle(
      color: Colors.black38,
      fontSize: 10,
    ),
  );

  Widget _buildClearButton() => Positioned(
    right: 0,
    child: IconButton(
      icon: const Icon(Icons.refresh, color: Colors.grey),
      onPressed: _onClear,
    ),
  );

  String _formatProb(dynamic p) {
    if (p == null || p["confidence"] == null) return "";

    final prob = p["confidence"];
    return NumberFormat.decimalPercentPattern(decimalDigits: 1).format(prob);
  }

  Color _digitFontColorByProb(dynamic p) {
    if (p == null || p["confidence"] == null) return Color.fromARGB(20, 0xAC, 0x3A, 0xB7);;

    final alpha = (p["confidence"] * 255).toInt();
    return Color.fromARGB(alpha, 0xAC, 0x3A, 0xB7);
  }

  void _addPoint({
    BuildContext context,
    Offset offset,
    end = false,
  }) {
    if (end) {
      points.add(null);
      _recognize();
    } else {
      RenderBox renderBox = context.findRenderObject();
      setState(() {
        points.add(renderBox.globalToLocal(offset));
      });
    }
  }

  void _onClear() => setState(() {
    points.clear();
    predicts = null;
  });

  Future _initModel() async {
    await recognizer.loadModel();
    debugPrint("model is loaded...");
    setState(() {
      modelReady = true;
    });
  }

  Future _recognize() async {
    final pred = await recognizer.recognize(points);
    debugPrint("prediction: [${pred.length}]$pred");
    setState(() {
      this.predicts = pred;
    });
  }

  dynamic _findPredict(int index) {
    if (predicts == null || predicts.isEmpty) return null;
    final i = predicts.indexWhere((p) => p["index"] == index);
    return i < 0 ? null : predicts[i];
  }
}
