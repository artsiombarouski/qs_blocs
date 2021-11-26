import 'package:qs_blocs/src/models/qs.model.dart';

class QsModelStore<T extends QsModel<T>> {
  final Map<dynamic, T> _data = {};

  T? get(dynamic key) {
    return _data[key];
  }

  void add(T model) {
    _data[model.key] = model;
    model.store = this;
  }
}
