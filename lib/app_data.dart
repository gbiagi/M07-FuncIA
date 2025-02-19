// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'constants.dart';
import 'drawable.dart';

class AppData extends ChangeNotifier {
  String _responseText = "";
  bool _isLoading = false;
  bool _isInitial = true;
  http.Client? _client;
  IOClient? _ioClient;
  HttpClient? _httpClient;
  StreamSubscription<String>? _streamSubscription;

  final List<Drawable> drawables = [];

  String get responseText =>
      _isInitial ? "..." : (_isLoading ? "Esperant ..." : _responseText);

  bool get isLoading => _isLoading;

  AppData() {
    _httpClient = HttpClient();
    _ioClient = IOClient(_httpClient!);
    _client = _ioClient;
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void addDrawable(Drawable drawable) {
    drawables.add(drawable);
    notifyListeners();
  }

  Future<void> callStream({required String question}) async {
    _isInitial = false;
    setLoading(true);

    try {
      var request = http.Request(
        'POST',
        Uri.parse('http://localhost:11434/api/generate'),
      );

      request.headers.addAll({'Content-Type': 'application/json'});
      request.body = jsonEncode(
          {'model': 'llama3.2:3b', 'prompt': question, 'stream': true});

      var streamedResponse = await _client!.send(request);
      _streamSubscription =
          streamedResponse.stream.transform(utf8.decoder).listen((value) {
        var jsonResponse = jsonDecode(value);
        var jsonResponseStr = jsonResponse['response'];
        _responseText = "$_responseText\n$jsonResponseStr";
        notifyListeners();
      }, onError: (error) {
        if (error is http.ClientException &&
            error.message == 'Connection closed while receiving data') {
          _responseText += "\nRequest cancelled.";
        } else {
          _responseText += "\nError during streaming: $error";
        }
        setLoading(false);
        notifyListeners();
      }, onDone: () {
        setLoading(false);
      });
    } catch (e) {
      _responseText = "\nError during streaming.";
      setLoading(false);
      notifyListeners();
    }
  }

  dynamic fixJsonInStrings(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data.map((key, value) => MapEntry(key, fixJsonInStrings(value)));
    } else if (data is List) {
      return data.map(fixJsonInStrings).toList();
    } else if (data is String) {
      try {
        // Si és JSON dins d'una cadena, el deserialitzem
        final parsed = jsonDecode(data);
        return fixJsonInStrings(parsed);
      } catch (_) {
        // Si no és JSON, retornem la cadena tal qual
        return data;
      }
    }
    // Retorna qualsevol altre tipus sense canvis (números, booleans, etc.)
    return data;
  }

  dynamic cleanKeys(dynamic value) {
    if (value is Map<String, dynamic>) {
      final result = <String, dynamic>{};
      value.forEach((k, v) {
        result[k.trim()] = cleanKeys(v);
      });
      return result;
    }
    if (value is List) {
      return value.map(cleanKeys).toList();
    }
    return value;
  }

  Future<void> callWithCustomTools({required String userPrompt}) async {
    const apiUrl = 'http://localhost:11434/api/chat';
    _isInitial = false;
    setLoading(true);

    final body = {
      "model": "llama3.2:3b",
      "stream": false,
      "messages": [
        {"role": "user", "content": userPrompt}
      ],
      "tools": tools
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['message'] != null &&
            jsonResponse['message']['tool_calls'] != null) {
          final toolCalls = (jsonResponse['message']['tool_calls'] as List)
              .map((e) => cleanKeys(e))
              .toList();
          for (final tc in toolCalls) {
            if (tc['function'] != null) {
              _processFunctionCall(tc['function']);
            }
          }
        }
        setLoading(false);
      } else {
        setLoading(false);
        throw Exception("Error: ${response.body}");
      }
    } catch (e) {
      print("Error during API call: $e");
      setLoading(false);
    }
  }

  void cancelRequests() {
    _streamSubscription?.cancel();
    _httpClient?.close(force: true);
    _httpClient = HttpClient();
    _ioClient = IOClient(_httpClient!);
    _client = _ioClient;
    _responseText += "\nRequest cancelled.";
    setLoading(false);
    notifyListeners();
  }

  double parseDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  void _processFunctionCall(Map<String, dynamic> functionCall) {
    final fixedJson = fixJsonInStrings(functionCall);
    final parameters = fixedJson['arguments'];

    String name = fixedJson['name'];
    String infoText = "Draw $name: $parameters";

    print(infoText);
    _responseText = "$_responseText\n$infoText";

    switch (name) {
      case 'draw_circle':
        if (parameters['x'] != null &&
            parameters['y'] != null &&
            parameters['radius'] != null) {
          final dx = parseDouble(parameters['x']);
          final dy = parseDouble(parameters['y']);
          final radius = max(0.0, parseDouble(parameters['radius']));
          final color = (parameters['color']);
          if (parameters["gradientType"] != null && 
            parameters["gradientColor"] != null && 
            parameters['fill'] != null && 
            parameters['thickness'] != null)  {
              final gradientType = (parameters['gradientType']);
              final gradientColor = (parameters['gradientColor']);
              final fill = (parameters['fill']);
              final thickness = parseDouble(parameters['thickness']);
              Gradient gradient;
              switch (gradientType) {
                case 'radial':
                  gradient = RadialGradient(colors: [getColor(fill), getColor(gradientColor)]);
                  break;
                case 'linear':
                  gradient = LinearGradient(colors: [getColor(fill), getColor(gradientColor)]);
                  break;
                case 'sweep':
                  gradient = SweepGradient(colors: [getColor(fill), getColor(gradientColor)]);
                  break;
                default:
                  gradient = LinearGradient(colors: [getColor(fill), getColor(gradientColor)]);
                }
                addDrawable(Circle(center: Offset(dx, dy), radius: radius, color: getColor(color), fill: getColor(fill), thickness: parseDouble(thickness), gradient: gradient));
          } else {
            addDrawable(Circle(center: Offset(dx, dy), radius: radius, color: getColor(color)));
          }
        } else {
          print("Missing circle properties: $parameters");
        }
        break;

      case 'draw_line':
        if (parameters['startX'] != null &&
            parameters['startY'] != null &&
            parameters['endX'] != null &&
            parameters['endY'] != null) {
          final startX = parseDouble(parameters['startX']);
          final startY = parseDouble(parameters['startY']);
          final endX = parseDouble(parameters['endX']);
          final endY = parseDouble(parameters['endY']);
          final start = Offset(startX, startY);
          final end = Offset(endX, endY);
          final color = (parameters['color']);
          final thickness = parseDouble(parameters['thickness']);
          addDrawable(Line(start: start, end: end, color: getColor(color), strokeWidth: thickness));
        } else {
          print("Missing line properties: $parameters");
        }
        break;

      case 'draw_rectangle':
        if (parameters['topLeftX'] != null &&
            parameters['topLeftY'] != null &&
            parameters['bottomRightX'] != null &&
            parameters['bottomRightY'] != null) {
          final topLeftX = parseDouble(parameters['topLeftX']);
          final topLeftY = parseDouble(parameters['topLeftY']);
          final bottomRightX = parseDouble(parameters['bottomRightX']);
          final bottomRightY = parseDouble(parameters['bottomRightY']);
          final topLeft = Offset(topLeftX, topLeftY);
          final bottomRight = Offset(bottomRightX, bottomRightY);
          final color = (parameters['color']);
          final thickness = parseDouble(parameters['thickness']);
          if (parameters['fill'] != null && parameters['gradientType'] != null && parameters['gradientColor'] != null) {
            final fill = (parameters['fill']);
            final gradientType = (parameters['gradientType']);
            final gradientColor = (parameters['gradientColor']);
            Gradient gradient;
            switch (gradientType) {
              case 'radial':
                gradient = RadialGradient(colors: [getColor(fill), getColor(gradientColor)]);
                break;
              case 'linear':
                gradient = LinearGradient(colors: [getColor(fill), getColor(gradientColor)]);
                break;
              case 'sweep':
                gradient = SweepGradient(colors: [getColor(fill), getColor(gradientColor)]);
                break;
              default:
                gradient = LinearGradient(colors: [getColor(fill), getColor(gradientColor)]);
              }

            addDrawable(Rectangle(topLeft: topLeft, bottomRight: bottomRight, color: getColor(color), strokeWidth: thickness, fill: getColor(fill), gradient: gradient));  
          } else {
            addDrawable(Rectangle(topLeft: topLeft, bottomRight: bottomRight, color: getColor(color), strokeWidth: thickness));
          }
        } else {
          print("Missing rectangle properties: $parameters");
        }
        break;

      case 'draw_text':
        if (parameters['text'] != null &&
            parameters['x'] != null &&
            parameters['y'] != null) {
          final text = (parameters['text']);
          final dx = parseDouble(parameters['x']);
          final dy = parseDouble(parameters['y']);
          Offset position = Offset(dx, dy);
          if (parameters['color'] != null && parameters['fontSize'] != null) {
            final color = (parameters['color']);
            final fontSize = parseDouble(parameters['fontSize']);
            addDrawable(TextElement(position: position, text: text, color: getColor(color), fontSize: fontSize));
          } else {
            addDrawable(TextElement(position: position, text: text));
          }
        } else {
          print("Missing text properties: $parameters");
        }
      break;

      default:
        print("Unknown function call: ${fixedJson['name']}");
    }
  }

  Color getColor(String color) {
    switch (color.toLowerCase()) {
      case 'red':
      return Colors.red;
      case 'green':
      return Colors.green;
      case 'blue':
      return Colors.blue;
      case 'yellow':
      return Colors.yellow;
      case 'black':
      return Colors.black;
      case 'white':
      return Colors.white;
      case 'purple':
      return Colors.purple;
      case 'orange':
      return Colors.orange;
      case 'pink':
      return Colors.pink;
      case 'brown':
      return Colors.brown;
      case 'grey':
      return Colors.grey;
      default:
      return Colors.transparent; // Default color if no match is found
    }
  }
  
}
