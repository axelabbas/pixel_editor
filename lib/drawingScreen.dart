import 'package:flutter/material.dart';

class PixelArtEditor extends StatefulWidget {
  @override
  _PixelArtEditorState createState() => _PixelArtEditorState();
}

class _PixelArtEditorState extends State<PixelArtEditor> {
  final int gridSize = 225;
  Color selectedColor = Colors.black;
  late List<List<Color>> pixelColors;
  int brushSize = 1;

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
      pixelColors[row][col] = selectedColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Pixel Art Editor")),
      body: Column(
        children: [
          TextField(
            controller: TextEditingController(text: brushSize.toString()),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "Brush Size",
            ),
            onChanged: (value) {
              int? newSize = int.tryParse(value);
              if (newSize != null && newSize > 0) {
                setState(() => brushSize = newSize);
              } else {
                print("Invalid brush size");
              }
            },
          ),
          buildColorPalette(),
          Expanded(
            child: InteractiveViewer(
              child: GestureDetector(
                onPanUpdate: (details) {
                  _handleTouch(details.localPosition);
                  setState(() {}); // Repaint to show updates immediately
                },
                onTapDown: (details) {
                  _handleTouch(details.localPosition);
                  setState(() {}); // Repaint to show updates immediately
                },
                child: CustomPaint(
                  size: MediaQuery.of(context).size,
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

  void _handleTouch(Offset localPosition) {
    final pixelSize = MediaQuery.of(context).size.width / gridSize;

    for (int i = -(brushSize ~/ 2); i <= (brushSize ~/ 2); i++) {
      for (int j = -(brushSize ~/ 2); j <= (brushSize ~/ 2); j++) {
        int row = ((localPosition.dy ~/ pixelSize) + i).clamp(0, gridSize - 1);
        int col = ((localPosition.dx ~/ pixelSize) + j).clamp(0, gridSize - 1);
        onColorChange(row, col);
      }
    }
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
        // Draw the border
        paint.color = Colors.grey;
        canvas.drawRect(
          Rect.fromLTWH(col * pixelSize, row * pixelSize, pixelSize, pixelSize),
          paint,
        );

        // Draw the pixel color inside the border
        paint.color = pixelColors[row][col];
        canvas.drawRect(
          Rect.fromLTWH(
            col * pixelSize + borderWidth,
            row * pixelSize + borderWidth,
            pixelSize - 2 * borderWidth,
            pixelSize - 2 * borderWidth,
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
