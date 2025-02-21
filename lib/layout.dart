// ignore_for_file: avoid_print

import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cupertino_desktop_kit/cdk.dart';
import 'package:provider/provider.dart';
import 'app_data.dart';
import 'canvas_painter.dart';
import 'drawable.dart';

class Layout extends StatefulWidget {
  const Layout({super.key, required this.title});

  final String title;

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  Drawable? selectedDrawable;
  Offset? startDragOffset;

  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context);
    final ScrollController scrollController = ScrollController();
    final TextEditingController textController = TextEditingController();

    final random = Random();
    final placeholders = [
      'Dibuixa una línia 10, 50 i 100, 25 ...',
      'Dibuixa dues linies i dos cercles',
      'Dibuixa un cercle amb centre a 150, 200 i radi 50 ...',
      'Fes un rectangle entre x=10, y=20 i x=100, y=200 ...',
      'Dibuixa un cercle a la posició 50,100 de radi 34.66',
    ];

    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(widget.title),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      color: CupertinoColors.systemGrey5,
                      child: GestureDetector(
                        onTapDown: (details) {
                          setState(() {
                            final painter =
                                CanvasPainter(drawables: appData.drawables);
                            painter.selectDrawable(details.localPosition);
                            selectedDrawable = painter.selectedDrawable;
                            startDragOffset = details.localPosition;

                            print("Selected $selectedDrawable");
                          });
                        },
                        onPanUpdate: (details) {
                          if (selectedDrawable != null &&
                              startDragOffset != null) {
                            setState(() {
                              final offset =
                                  details.localPosition - startDragOffset!;
                              selectedDrawable!.move(offset);
                              startDragOffset = details.localPosition;
                            });
                          }
                        },
                        onPanEnd: (details) {
                          startDragOffset = null;
                        },
                        child: CustomPaint(
                          painter: CanvasPainter(
                            drawables: appData.drawables,
                            selectedDrawable: selectedDrawable,
                          ),
                          child: Container(),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: CupertinoScrollbar(
                              controller: scrollController,
                              child: SingleChildScrollView(
                                controller: scrollController,
                                child: SizedBox(
                                  width: double.infinity,
                                  child: Text(
                                    appData.responseText,
                                    style: const TextStyle(fontSize: 16.0),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 100,
                          width: double.infinity,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: FocusScope(
                              onKeyEvent: (node, event) {
                                //print("Key event: $event");
                                if (event is KeyDownEvent &&
                                    event.logicalKey ==
                                        LogicalKeyboardKey.delete &&
                                    selectedDrawable != null) {
                                  setState(() {
                                    appData.deleteDrawable(selectedDrawable!);
                                    selectedDrawable = null;

                                    print("Removing $selectedDrawable");
                                  });
                                  return KeyEventResult.handled;
                                }
                                return KeyEventResult.ignored;
                              },
                              child: Focus(
                                onKeyEvent: (node, event) {
                                  //print("Key event in FieldText: $event");
                                  if (event is KeyDownEvent &&
                                      event.logicalKey ==
                                          LogicalKeyboardKey.delete &&
                                      selectedDrawable != null) {
                                    setState(() {
                                      print("Removing $selectedDrawable");
                                      appData.deleteDrawable(selectedDrawable!);
                                      selectedDrawable = null;
                                    });
                                    return KeyEventResult.handled;
                                  }
                                  return KeyEventResult.ignored;
                                },
                                child: CDKFieldText(
                                  maxLines: 5,
                                  controller: textController,
                                  placeholder: placeholders[
                                      random.nextInt(placeholders.length)],
                                  enabled: !appData
                                      .isLoading, // Desactiva si carregant
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: CDKButton(
                                  style: CDKButtonStyle.action,
                                  onPressed: appData.isLoading
                                      ? null
                                      : () {
                                          final userPrompt =
                                              textController.text;
                                          appData.callWithCustomTools(
                                              userPrompt: userPrompt);
                                        },
                                  child: const Text('Query'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: CDKButton(
                                  onPressed: appData.isLoading
                                      ? () => appData.cancelRequests()
                                      : null,
                                  child: const Text('Cancel'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (appData.isLoading)
                Positioned.fill(
                  child: Container(
                    color: CupertinoColors.systemGrey.withOpacity(0.5),
                    child: const Center(
                      child: CupertinoActivityIndicator(
                        radius: 20,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ));
  }
}
