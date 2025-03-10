import 'package:exemple0700/app.dart';
import 'package:exemple0700/app_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cupertino_desktop_kit/cdk.dart';
import 'package:provider/provider.dart';
import 'drawable.dart';

class DrawingForm extends StatefulWidget {
  final Drawable selectedDrawable;

  const DrawingForm({super.key, required this.selectedDrawable});

  @override
  State<DrawingForm> createState() => _DrawingFormState();
}

class _DrawingFormState extends State<DrawingForm> {
  Color selectedColor = CupertinoColors.black;
  int _colorIndex = 0;

  final colors = [
    'Red',
    'Green',
    'Blue',
    'Yellow',
    'Black',
    'White',
    'Purple',
    'Orange',
    'Pink',
    'Brown',
    'Grey'
  ];

  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context);
    return CupertinoPopupSurface(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.selectedDrawable is Line)
              ..._buildLineOptions(widget.selectedDrawable as Line, appData),
            if (widget.selectedDrawable is Rectangle)
              ..._buildRectangleOptions(
                  widget.selectedDrawable as Rectangle, appData),
            if (widget.selectedDrawable is Circle)
              ..._buildCircleOptions(
                  widget.selectedDrawable as Circle, appData),
            if (widget.selectedDrawable is TextElement)
              ..._buildTextElementOptions(
                  widget.selectedDrawable as TextElement, appData),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildLineOptions(Line line, AppData appData) {
    return [
      const Text('Line Options', style: TextStyle(fontWeight: FontWeight.bold)),
      CupertinoTextField(
        placeholder: line.start.dx.toString(),
        keyboardType: TextInputType.number,
        onChanged: (value) {
          setState(() => line.start =
              Offset(double.tryParse(value) ?? line.start.dx, line.start.dy));
        },
      ),
      CupertinoTextField(
        placeholder: line.start.dy.toString(),
        keyboardType: TextInputType.number,
        onChanged: (value) {
          setState(() => line.start =
              Offset(line.start.dx, double.tryParse(value) ?? line.start.dy));
        },
      ),
      CupertinoTextField(
        placeholder: line.end.dx.toString(),
        keyboardType: TextInputType.number,
        onChanged: (value) {
          setState(() => line.end =
              Offset(double.tryParse(value) ?? line.end.dx, line.end.dy));
        },
      ),
      CupertinoTextField(
        placeholder: line.end.dy.toString(),
        keyboardType: TextInputType.number,
        onChanged: (value) {
          setState(() => line.end =
              Offset(line.end.dx, double.tryParse(value) ?? line.end.dy));
        },
      ),
      const Text('Color', style: TextStyle(fontWeight: FontWeight.bold)),
      CDKButtonSelect(
        options: colors,
        selectedIndex: _colorIndex,
        onSelected: (int index) {
          setState(() {
            _colorIndex = index;
            line.setColor(appData.getColor(colors[index]));
          });
        },
      )
    ];
  }

  List<Widget> _buildRectangleOptions(Rectangle rectangle, AppData appData) {
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
      CDKButtonSelect(
        options: colors,
        selectedIndex: _colorIndex,
        onSelected: (int index) {
          setState(() {
            _colorIndex = index;
            rectangle.setColor(appData.getColor(colors[index]));
          });
        },
      )
    ];
  }

  List<Widget> _buildCircleOptions(Circle circle, AppData appData) {
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
      CDKButtonSelect(
        options: colors,
        selectedIndex: _colorIndex,
        onSelected: (int index) {
          setState(() {
            _colorIndex = index;
            circle.setColor(appData.getColor(colors[index]));
          });
        },
      )
    ];
  }

  List<Widget> _buildTextElementOptions(
      TextElement textElement, AppData appData) {
    return [
      const Text('Text Options', style: TextStyle(fontWeight: FontWeight.bold)),
      CupertinoTextField(
        placeholder: textElement.text,
        onChanged: (value) {
          setState(() => textElement.text = value);
        },
      ),
      CDKButtonSelect(
        options: colors,
        selectedIndex: _colorIndex,
        onSelected: (int index) {
          setState(() {
            _colorIndex = index;
            textElement.setColor(appData.getColor(colors[index]));
          });
        },
      )
    ];
  }
}
