import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:menu_maker_demo/editing_element.dart';
import 'package:menu_maker_demo/editing_screen/editing_screen_controller.dart';
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

  void _updateEditorSize() {
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
            Container(color: Colors.red, height: 60, width: double.infinity),

            // ================= CANVAS =================
            Expanded(
              child: GestureDetector(
                onTap: () => _editingController.deSelectItem(),
                child: Container(
                  key: _editorKey,
                  color: Colors.black,
                  child: Obx(() {
                    if (_editingController.pageKeys.isEmpty) {
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
            SizedBox(
              height: 60,
              width: double.infinity,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => _editingController.moveSelectedLeft(10),
                    child: Container(
                      color: Colors.amber,
                      child: const Text(
                        "LeftDrag",
                        style: TextStyle(fontSize: 24, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () => _editingController.moveSelectedRight(10),
                    child: Container(
                      color: Colors.amber,
                      child: const Text(
                        "RightDrag",
                        style: TextStyle(fontSize: 24, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () => _editingController.changeApha(0.4),
                    child: Container(
                      color: Colors.amber,
                      child: const Text(
                        "Alpha",
                        style: TextStyle(fontSize: 24, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () => _editingController.saveAndReload(),
                    child: Container(
                      color: Colors.amber,
                      child: const Text(
                        "Save Menu",
                        style: TextStyle(fontSize: 24, color: Colors.white),
                      ),
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
