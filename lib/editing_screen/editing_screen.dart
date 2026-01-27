import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:menu_maker_demo/editing_element.dart';
import 'package:menu_maker_demo/editing_screen/editing_screen_controller.dart';
import 'package:menu_maker_demo/main.dart';
import 'package:menu_maker_demo/model/editing_element_model.dart';

class EditingScreen extends StatefulWidget {
  const EditingScreen({super.key});

  @override
  State<EditingScreen> createState() => _EditingScreenState();
}

class _EditingScreenState extends State<EditingScreen> {
  final TransformationController _controller = TransformationController();
  final GlobalKey _editorKey = GlobalKey();
  bool _isDataLoaded = false;

  final EditingScreenController _editingController = Get.put(
    EditingScreenController(),
  );

  @override
  void initState() {
    super.initState();
    addAllWidget();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateEditorSize();
    });
  }

  void addAllWidget() async {
    final jsonString = await rootBundle.loadString(
      'assets/json/editor_data.json',
    );

    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    final editorData = EditorDataModel.fromJson(jsonMap);

    _editingController.loadAllPages(editorData);
    _isDataLoaded = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tryScale();
    });
  }

  void _updateEditorSize() async {
    await Future.delayed(Duration(seconds: 3));
    final context = _editorKey.currentContext;
    if (context == null) return;

    final box = context.findRenderObject() as RenderBox;
    final size = box.size;

    _editingController.editorViewWidth.value = size.width;
    _editingController.editorViewHeight.value = size.height;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tryScale();
    });
  }

  void _tryScale() {
    if (!_isDataLoaded) return;

    if (_editingController.editorViewWidth.value <= 0 ||
        _editingController.editorViewHeight.value <= 0) {
      return;
    }

    _editingController.calculateChildScale();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _editingController.scaffoldKey,
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Obx(() {
              return Container(
                height: 60,
                width: double.infinity,
                color: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    /// Undo Button
                    IconButton(
                      onPressed: appController.canUndo.value
                          ? appController.undo
                          : null,
                      icon: Icon(
                        Icons.undo,
                        color: appController.canUndo.value
                            ? Colors.white
                            : Colors.white.withOpacity(0.4),
                      ),
                    ),

                    /// Redo Button
                    IconButton(
                      onPressed: appController.canRedo.value
                          ? appController.redo
                          : null,
                      icon: Icon(
                        Icons.redo,
                        color: appController.canRedo.value
                            ? Colors.white
                            : Colors.white.withOpacity(0.4),
                      ),
                    ),
                  ],
                ),
              );
            }),
            // ================= CANVAS =================
            Expanded(
              child: GestureDetector(
                onTap: () => _editingController.deSelectItem(),
                child: Container(
                  key: _editorKey,
                  color: Colors.black,
                  child: Obx(() {
                    if (_editingController.pageKeys.isEmpty ||
                        _editingController.editorViewWidth.value <= 0 ||
                        _editingController.editorViewHeight.value <= 0) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _updateEditorSize();
                      });
                      return const Center(child: CircularProgressIndicator());
                    }

                    return PageView.builder(
                      physics:
                          _editingController.selectedController.value != null
                          ? const NeverScrollableScrollPhysics()
                          : const ScrollPhysics(),
                      itemCount: _editingController.pageKeys.length,
                      onPageChanged: (_) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _editingController.calculateChildScale();
                        });
                      },
                      itemBuilder: (context, index) {
                        final pageKey = _editingController.pageKeys[index];

                        return Obx(() {
                          final items = _editingController.pageItems[pageKey];

                          if (items == null) return const SizedBox();

                          return InteractiveViewer(
                            transformationController: _controller,
                            minScale: 1,
                            maxScale: 6,
                            child: Center(
                              child: Container(
                                color: Colors.amber,
                                child: SizedBox(
                                  width:
                                      _editingController.superViewWidth *
                                      _editingController.scaleX,
                                  height:
                                      _editingController.superViewHeight *
                                      _editingController.scaleY,
                                  child: Stack(
                                    children: [
                                      ...items.map((item) {
                                        final isBg = !item
                                            .controller
                                            .isUserInteractionEnabled
                                            .value;

                                        return EditingElement(
                                          editingElementController:
                                              item.controller,
                                          interactiveController: _controller,
                                          isSelected:
                                              !isBg &&
                                              _editingController.isSelected(
                                                item.controller,
                                              ),
                                          childWidget: item.child,
                                          onTap: () {
                                            if (isBg) {
                                              _editingController.deSelectItem();
                                            } else {
                                              _editingController.selectItem(
                                                item.controller,
                                              );
                                            }
                                          },
                                          onDelete: () {
                                            if (!isBg) {
                                              _editingController
                                                  .deleteChildWidget(
                                                    pageKey,
                                                    item.controller,
                                                  );
                                            }
                                          },
                                          isFirstItem: item == items.first,
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        });
                      },
                    );
                  }),
                ),
              ),
            ),

            // ================= TOOLBAR =================
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              height: 60,
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: () {},
                    child: const Text(
                      "Menu",
                      style: TextStyle(fontSize: 22, color: Colors.black),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: const Text(
                      "Text",
                      style: TextStyle(fontSize: 22, color: Colors.black),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: const Text(
                      "Shape",
                      style: TextStyle(fontSize: 22, color: Colors.black),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: const Text(
                      "Add Page",
                      style: TextStyle(fontSize: 22, color: Colors.black),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: const Text(
                      "QR",
                      style: TextStyle(fontSize: 22, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
