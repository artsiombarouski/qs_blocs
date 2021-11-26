import 'package:qs_blocs/src/models/qs.model.store.dart';

abstract class QsModel<T extends QsModel<T>> {
  late QsModelStore<T> store;

  dynamic get key;
}
