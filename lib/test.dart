import 'package:flutter/material.dart';

class PixelArtEditor extends StatefulWidget {
  @override
  _PixelArtEditorState createState() => _PixelArtEditorState();
}

class _PixelArtEditorState extends State<PixelArtEditor> {
  final int gridSize = 16;
  Color selectedColor = Colors.black;
  late List<List<Color>>
      pixelColors; // 2D list of pixels, each value is the color of that pixel.
  final TransformationController _transformationController =
      TransformationController();

  @override
  void initState() {
    super.initState();
    pixelColors = List.generate(
        gridSize,
        (_) => List.generate(
            gridSize, (_) => Colors.white)); // Initialize all pixels to white
  }

  // Change the color of the pixel at row, col
  void onColorChange(int row, int col) {
    // Ensure row and col are within bounds
    if (row >= 0 && row < gridSize && col >= 0 && col < gridSize) {
      setState(() {
        pixelColors[row][col] = selectedColor;
      });
    }
  }

  void removeColor(int row, int col) {
    // Ensure row and col are within bounds
    if (row >= 0 && row < gridSize && col >= 0 && col < gridSize) {
      setState(() {
        pixelColors[row][col] = Colors.transparent;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 230, 201, 36),
      appBar: AppBar(
        title: Text("Pixel Art Editor"),
      ),
      body: Column(
        children: [
          buildColorPalette(),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final pixelSize = constraints.maxWidth / gridSize;

                return InteractiveViewer(
                  transformationController: _transformationController,
                  panEnabled: false, // Set it to false to prevent panning.
                  boundaryMargin: EdgeInsets.all(5),
                  minScale: 0.1,
                  maxScale: 4,
                  child: GridView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: gridSize * gridSize,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: gridSize,
                    ),
                    itemBuilder: (context, index) {
                      int row = index ~/ gridSize;
                      int col = index % gridSize;

                      return Listener(
                        onPointerDown: (event) => {
                          if (event.buttons == 1)
                            {onColorChange(row, col)}
                          else if (event.buttons == 2)
                            {removeColor(row, col)}
                        },
                        onPointerMove: (event) {
                          // Adjust the pixel size based on the scale
                          // Calculate the row and col movement
                          int calculatedRow =
                              (event.localPosition.dy / pixelSize).floor();
                          int calculatedCol =
                              (event.localPosition.dx / pixelSize).floor();
                          print("Row: $calculatedRow, Col: $calculatedCol");
                          if (event.buttons == 1) {
                            onColorChange(
                                calculatedRow + row, calculatedCol + col);
                          } else if (event.buttons == 2) {
                            removeColor(
                                calculatedRow + row, calculatedCol + col);
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey, width: 0.5),
                            color: pixelColors[row][col],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
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
