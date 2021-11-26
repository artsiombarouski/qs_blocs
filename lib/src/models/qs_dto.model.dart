import 'package:flutter/foundation.dart';
import 'package:qs_blocs/src/models/qs.model.dart';

abstract class QsDtoModel<T extends QsModel<T>, D> extends QsModel<T> {
  late ValueNotifier<D> dto;

  QsDtoModel({required D dto}) {
    this.dto = ValueNotifier(dto);
    this.dto.addListener(onUpdate);
  }

  D get value => dto.value!;

  void onUpdate() {}
}
