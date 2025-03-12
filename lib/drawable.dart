import 'package:flutter/material.dart';

abstract class Drawable {
  void draw(Canvas canvas);
  bool contains(Offset position);
  Rect getBounds();
  void move(Offset offset);
}

class Line extends Drawable {
  Offset start;
  Offset end;
  Color color;
  double strokeWidth;

  Line({
    required this.start,
    required this.end,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void draw(Canvas canvas) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth;
    canvas.drawLine(start, end, paint);
  }

  @override
  bool contains(Offset position) {
    // Check if the position is close to the line segment
    double distance = (position - start).distance + (position - end).distance;
    double lineLength = (start - end).distance;
    return (distance - lineLength).abs() < strokeWidth;
  }

  @override
  Rect getBounds() {
    return Rect.fromPoints(start, end).inflate(strokeWidth / 2);
  }

  @override
  void move(Offset offset) {
    start += offset;
    end += offset;
  }

  void setColor(Color newColor) {
    color = newColor;
  }

  void setStrokeWidth(double newStrokeWidth) {
    strokeWidth = newStrokeWidth;
  }
}

class Rectangle extends Drawable {
  Offset topLeft;
  Offset bottomRight;
  Color color;
  double strokeWidth;
  Color fill;
  final Gradient gradient;

  Rectangle({
    required this.topLeft,
    required this.bottomRight,
    required this.color,
    required this.strokeWidth,
    Color? fill,
    Gradient? gradient,
  })  : fill = fill ?? color,
        gradient = gradient ?? LinearGradient(colors: [color, color]);

  @override
  void draw(Canvas canvas) {
    final rect = Rect.fromPoints(topLeft, bottomRight);

    final gradientPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill;
    canvas.drawRect(rect, gradientPaint);

    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawRect(rect, borderPaint);
  }

  @override
  bool contains(Offset position) {
    final rect = Rect.fromPoints(topLeft, bottomRight);
    return rect.contains(position);
  }

  @override
  Rect getBounds() {
    return Rect.fromPoints(topLeft, bottomRight).inflate(strokeWidth / 2);
  }

  @override
  void move(Offset offset) {
    topLeft += offset;
    bottomRight += offset;
  }

  void setColor(Color newColor) {
    color = newColor;
  }

  void setStrokeWidth(double newStrokeWidth) {
    strokeWidth = newStrokeWidth;
  }

  void setFill(Color newFill) {
    fill = newFill;
  }
}

class Circle extends Drawable {
  Offset center;
  final double radius;
  Color color;
  Color fill;
  double thickness;
  final Gradient gradient;

  Circle({
    required this.center,
    required this.radius,
    required this.color,
    Color? fill,
    this.thickness = 2.0,
    Gradient? gradient,
  })  : fill = fill ?? color,
        gradient = gradient ?? RadialGradient(colors: [color, color]);

  @override
  void draw(Canvas canvas) {
    final rect = Rect.fromCircle(center: center, radius: radius);
    final gradientPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, gradientPaint);

    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness;
    canvas.drawCircle(center, radius, borderPaint);
  }

  @override
  bool contains(Offset position) {
    return (position - center).distance <= radius;
  }

  @override
  Rect getBounds() {
    return Rect.fromCircle(center: center, radius: radius + 5)
        .inflate(thickness / 2);
  }

  @override
  void move(Offset offset) {
    center += offset;
  }

  void setColor(Color newColor) {
    color = newColor;
  }

  void setStrokeWidth(double newStrokeWidth) {
    thickness = newStrokeWidth;
  }

  void setFill(Color newFill) {
    fill = newFill;
  }
}

class TextElement extends Drawable {
  String text;
  Offset position;
  Color color;
  final double fontSize;
  final String font;

  TextElement({
    required this.text,
    required this.position,
    this.color = Colors.black,
    this.fontSize = 14.0,
    this.font = 'Roboto',
  });

  @override
  void draw(Canvas canvas) {
    final textStyle =
        TextStyle(color: color, fontSize: fontSize, fontFamily: font);
    final textSpan = TextSpan(
      text: text,
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, position);
  }

  @override
  bool contains(Offset position) {
    final textStyle =
        TextStyle(color: color, fontSize: fontSize, fontFamily: font);
    final textSpan = TextSpan(
      text: text,
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    final textRect = Offset(position.dx, position.dy) & textPainter.size;
    return textRect.contains(position);
  }

  @override
  Rect getBounds() {
    final textStyle =
        TextStyle(color: color, fontSize: fontSize, fontFamily: font);
    final textSpan = TextSpan(
      text: text,
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    return Offset(position.dx, position.dy) & textPainter.size;
  }

  @override
  void move(Offset offset) {
    position += offset;
  }

  void setColor(Color newColor) {
    color = newColor;
  }
}
