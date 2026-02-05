typedef UndoAction = void Function();

enum _UndoMode { normal, undoing, redoing }

class UndoRedoManager {
  final List<UndoAction> _undoStack = [];
  final List<UndoAction> _redoStack = [];

  _UndoMode _mode = _UndoMode.normal;
  bool _inTransaction = false;
  final List<UndoAction> _transactionActions = [];

  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;

  /// iOS-equivalent registerUndo
  void registerUndo(UndoAction action) {
    if (_inTransaction) {
      _transactionActions.add(action);
      return;
    }

    switch (_mode) {
      case _UndoMode.normal:
        _undoStack.add(action);
        _redoStack.clear(); // iOS behavior
        break;

      case _UndoMode.undoing:
        _redoStack.add(action);
        break;

      case _UndoMode.redoing:
        _undoStack.add(action);
        break;
    }
  }

  void undo() {
    if (!canUndo) return;

    final action = _undoStack.removeLast();
    _mode = _UndoMode.undoing;
    action();
    _mode = _UndoMode.normal;
  }

  void redo() {
    if (!canRedo) return;

    final action = _redoStack.removeLast();
    _mode = _UndoMode.redoing;
    action();
    _mode = _UndoMode.normal;
  }

  void clear() {
    _undoStack.clear();
    _redoStack.clear();
  }

  void beginTransaction() {
    if (_inTransaction) return;
    _inTransaction = true;
    _transactionActions.clear();
  }

  void endTransaction() {
    if (!_inTransaction) return;

    if (_transactionActions.isNotEmpty) {
      final actions = List<UndoAction>.from(_transactionActions);

      _inTransaction = false;

      registerUndo(() {
        for (final action in actions.reversed) {
          action();
        }
      });
    } else {
      _inTransaction = false;
    }

    _transactionActions.clear();
  }
}
