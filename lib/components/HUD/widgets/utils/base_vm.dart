import 'package:flutter/material.dart';

class BaseModel extends ChangeNotifier {
  bool disposed = false;
  String? errorTitle;
  String? errorDescription;

  String? emptyTitle;
  String? emptyDescription;

  bool _busy = false;

  bool get busy => _busy;

  bool isEmpty = false;
  bool hasErrors = false;

  BaseModel() : super();

  @override
  void dispose() {
    if (disposed) {
      return;
    }
    super.dispose();
    disposed = true;
  }

  @override
  void notifyListeners() {
    //Avoid exception when notifying listeners when vm is disposed
    if (disposed) {
      return;
    }
    super.notifyListeners();
  }

  void setBusy(bool value) {
    _busy = value;
    notifyListeners();
  }

  void setEmpty({bool empty = true}) {
    isEmpty = empty;
    _busy = false;
    notifyListeners();
  }

  void setError({String? errorTitle, String? errorDescription}) {
    if ((errorTitle == null && errorDescription == null) ||
        this.errorTitle != errorTitle ||
        this.errorDescription != errorDescription) {}
    this.errorTitle = errorTitle!;
    this.errorDescription = errorDescription!;
    hasErrors = true;
    _busy = false;
    notifyListeners();
  }
}
