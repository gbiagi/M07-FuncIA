import 'package:flutter/cupertino.dart';
import 'drawable.dart';

class DrawingForm extends StatefulWidget {
  final Drawable selectedDrawable;

  const DrawingForm({super.key, required this.selectedDrawable});

  @override
  State<DrawingForm> createState() => _DrawingFormState();
}

class _DrawingFormState extends State<DrawingForm> {
  Color selectedColor = CupertinoColors.black;

  @override
  Widget build(BuildContext context) {
    return CupertinoPopupSurface(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.selectedDrawable is Line)
              ..._buildLineOptions(widget.selectedDrawable as Line),
            if (widget.selectedDrawable is Rectangle)
              ..._buildRectangleOptions(widget.selectedDrawable as Rectangle),
            if (widget.selectedDrawable is Circle)
              ..._buildCircleOptions(widget.selectedDrawable as Circle),
            if (widget.selectedDrawable is TextElement)
              ..._buildTextElementOptions(
                  widget.selectedDrawable as TextElement),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildLineOptions(Line line) {
    return [
      const Text('Line Options', style: TextStyle(fontWeight: FontWeight.bold)),
      CupertinoTextField(
        placeholder: 'Enter start X',
        keyboardType: TextInputType.number,
        onChanged: (value) {
          setState(() => line.start =
              Offset(double.tryParse(value) ?? line.start.dx, line.start.dy));
        },
      ),
      CupertinoTextField(
        placeholder: 'Enter start Y',
        keyboardType: TextInputType.number,
        onChanged: (value) {
          setState(() => line.start =
              Offset(line.start.dx, double.tryParse(value) ?? line.start.dy));
        },
      ),
      CupertinoTextField(
        placeholder: 'Enter end X',
        keyboardType: TextInputType.number,
        onChanged: (value) {
          setState(() => line.end =
              Offset(double.tryParse(value) ?? line.end.dx, line.end.dy));
        },
      ),
      CupertinoTextField(
        placeholder: 'Enter end Y',
        keyboardType: TextInputType.number,
        onChanged: (value) {
          setState(() => line.end =
              Offset(line.end.dx, double.tryParse(value) ?? line.end.dy));
        },
      ),
      _buildColorPicker(
          line.color, (newColor) => setState(() => line.setColor(newColor))),
    ];
  }

  List<Widget> _buildRectangleOptions(Rectangle rectangle) {
    return [
      const Text('Rectangle Options',
          style: TextStyle(fontWeight: FontWeight.bold)),
      CupertinoSlider(
        value: rectangle.strokeWidth,
        min: 1,
        max: 100,
        onChanged: (value) {
          setState(() => rectangle.setStrokeWidth(value));
        },
      ),
      _buildColorPicker(rectangle.color,
          (newColor) => setState(() => rectangle.setColor(newColor))),
    ];
  }

  List<Widget> _buildCircleOptions(Circle circle) {
    return [
      const Text('Circle Options',
          style: TextStyle(fontWeight: FontWeight.bold)),
      CupertinoSlider(
        value: circle.thickness,
        min: 1,
        max: 100,
        onChanged: (value) {
          setState(() => circle.setStrokeWidth(value));
        },
      ),
      _buildColorPicker(circle.color,
          (newColor) => setState(() => circle.setColor(newColor))),
    ];
  }

  List<Widget> _buildTextElementOptions(TextElement textElement) {
    return [
      const Text('Text Options', style: TextStyle(fontWeight: FontWeight.bold)),
      CupertinoTextField(
        placeholder: 'Enter text',
        onChanged: (value) {
          setState(() => textElement.text = value);
        },
      ),
      _buildColorPicker(textElement.color,
          (newColor) => setState(() => textElement.setColor(newColor))),
    ];
  }

  Widget _buildColorPicker(
      Color currentColor, ValueChanged<Color> onColorSelected) {
    return CupertinoButton(
      child: Text('Select Color', style: TextStyle(color: currentColor)),
      onPressed: () {
        // You can implement a CupertinoPicker for color selection
      },
    );
  }
}
