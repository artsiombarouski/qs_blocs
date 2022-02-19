import 'package:qs_blocs/src/models/qs.model.store.dart';
import 'package:qs_blocs/src/models/qs_dto.model.dart';

abstract class QsDtoModelStore<T extends QsDtoModel<T, D>, D>
    extends QsModelStore<T> {
  QsDtoModelStore();

  T createModel(D dto);

  D createDto(Map<String, dynamic> json);

  dynamic keyFromDto(D dto);

  T obtainRaw(Map<String, dynamic> json) {
    return obtain(createDto(json));
  }

  T obtain(D data) {
    final existsModel = get(keyFromDto(data));
    if (existsModel != null) {
      final existing = (existsModel.dto.value as dynamic).toJson();
      final updated = (data as dynamic).toJson();
      final Map<String, dynamic> merged = merge(existing, updated);
      final updatedDto = createDto(merged);
      existsModel.dto.value = updatedDto;
      onUpdate(existsModel, updatedDto);
      return existsModel;
    }
    final result = createModel(data);
    add(result);
    return result;
  }

  List<T> obtainList(List<D> data) {
    return data.map((e) => obtain(e)).toList();
  }

  void onUpdate(T model, D dto) {}

  Map<String, dynamic> merge(
    Map<String, dynamic> existing,
    Map<String, dynamic> updated,
  ) {
    return {...existing, ...updated};
  }
}
