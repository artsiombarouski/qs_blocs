import 'package:qs_blocs/src/network_dependent.cubit.dart';

typedef OnFetchSuccessCallback<T> = Function(T);
typedef OnFetchErrorCallback<E> = Function(E);

class FetchCubitState<T, E> {
  final T? data;
  final E? error;
  final bool isLoading;

  bool get showError => isLoading == false && data == null && error != null;

  bool get showLoading => isLoading && data == null;

  bool get showRefresh => isLoading && data != null;

  FetchCubitState({this.data, this.error, this.isLoading = false});
}

abstract class FetchCubit<T, E>
    extends NetworkDependentCubit<FetchCubitState<T, E>> {
  bool _isInitialized = false;

  FetchCubit({T? initialData})
      : super(FetchCubitState<T, E>(
          data: initialData,
          isLoading: initialData == null,
        ));

  @override
  void onConnectionChanged(bool isConnected) {
    if (isConnectionError(state.error)) {
      refresh();
    }
  }

  E obtainUnknownError();

  bool isConnectionError(E? error);

  Future<T?> loadInitialData() async {
    return null;
  }

  Future<void> init({bool refresh = false}) async {
    if (_isInitialized && (state.data != null && !state.isLoading)) {
      return;
    }
    _isInitialized = true;
    if (state.data == null) {
      final data = await loadInitialData();
      if (data != null) {
        emit(FetchCubitState(data: data, error: null, isLoading: false));
      }
    }
    await _doFetch();
  }

  Future<void> refresh() async {
    await _doFetch();
  }

  Future<void> _handleSuccess(T? data) async {
    final result = await onSuccess(data);
    emit(FetchCubitState(data: result, error: null, isLoading: false));
  }

  Future<T?> onSuccess(T? data) async {
    return data;
  }

  Future<void> _handleError(E? error) async {
    emit(FetchCubitState(data: state.data, error: error, isLoading: false));
  }

  Future<void> fetch({
    required OnFetchSuccessCallback<T> onSuccess,
    required OnFetchErrorCallback<E> onError,
  });

  Future<void> _doFetch() async {
    emit(FetchCubitState(data: state.data, error: null, isLoading: true));
    return fetch(
      onSuccess: _handleSuccess,
      onError: _handleError,
    ).catchError((error) {
      _handleError(obtainUnknownError());
    });
  }
}
