import 'package:flutter/material.dart';

class PixelArtEditor extends StatefulWidget {
  @override
  _PixelArtEditorState createState() => _PixelArtEditorState();
}

class _PixelArtEditorState extends State<PixelArtEditor> {
  final int gridSize = 128;
  Color selectedColor = Colors.black;
  late List<List<Color>> pixelColors;

  @override
  void initState() {
    super.initState();
    pixelColors = List.generate(
      gridSize,
      (_) => List.generate(gridSize, (_) => Colors.white),
    );
  }

  void onColorChange(int row, int col) {
    if (row >= 0 && row < gridSize && col >= 0 && col < gridSize) {
      setState(() {
        pixelColors[row][col] = selectedColor;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Pixel Art Editor")),
      body: Column(
        children: [
          buildColorPalette(),
          Expanded(
            child: InteractiveViewer(
              child: GestureDetector(
                onPanUpdate: (details) {
                  _handleTouch(details.localPosition);
                },
                onTapDown: (details) {
                  _handleTouch(details.localPosition);
                },
                child: CustomPaint(
                  painter: PixelGridPainter(pixelColors),
                  child: Container(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleTouch(Offset position) {
    final pixelSize = MediaQuery.of(context).size.width / gridSize;
    int row = (position.dy ~/ pixelSize).clamp(0, gridSize - 1);
    int col = (position.dx ~/ pixelSize).clamp(0, gridSize - 1);

    onColorChange(row, col);
  }

  Widget buildColorPalette() {
    List<Color> colors = [Colors.black, Colors.red, Colors.green, Colors.blue];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: colors.map((color) {
        return GestureDetector(
          onTap: () => setState(() => selectedColor = color),
          child: Container(
            margin: EdgeInsets.all(8),
            width: 30,
            height: 30,
            color: color,
          ),
        );
      }).toList(),
    );
  }
}

class PixelGridPainter extends CustomPainter {
  final List<List<Color>> pixelColors;
  final double borderWidth;
  PixelGridPainter(this.pixelColors, {this.borderWidth = 0.5});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final pixelSize = size.width / pixelColors.length;
    for (int row = 0; row < pixelColors.length; row++) {
      for (int col = 0; col < pixelColors[row].length; col++) {
        paint.color = Colors.grey; // Border color
        canvas.drawRect(
          Rect.fromLTWH(
            col * pixelSize,
            row * pixelSize,
            pixelSize,
            pixelSize,
          ),
          paint,
        );

        // Draw the pixel color inside the border
        paint.color = pixelColors[row][col];
        canvas.drawRect(
          Rect.fromLTWH(
            col * pixelSize + borderWidth, // Shift inside border
            row * pixelSize + borderWidth, // Shift inside border
            pixelSize - 2 * borderWidth, // Reduce for border
            pixelSize - 2 * borderWidth, // Reduce for border
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
