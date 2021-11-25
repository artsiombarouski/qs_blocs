import 'package:flutter/foundation.dart';
import 'package:qs_blocs/src/network_dependent.cubit.dart';

const kDefaultLimit = 20;

typedef OnListSuccessCallback<T> = Function(ListCubitDataState<T>);
typedef OnListErrorCallback<E> = Function(E);

class ListCubitDataState<T> {
  final List<T>? data;
  final String? nextPageToken;
  final bool? hasMore;
  final Map<String, dynamic>? extra;

  ListCubitDataState({this.data, this.nextPageToken, this.hasMore, this.extra});
}

class ListCubitState<T, E> {
  final ListCubitDataState<T>? data;
  final E? error;
  final bool isLoading;

  ListCubitState({
    this.data,
    this.error,
    this.isLoading = false,
  });

  bool get showError => isLoading == false && data == null && error != null;

  bool get showLoading => isLoading && data == null;

  bool get showRefresh => isLoading && data != null;

  T? itemAt(int index) => data?.data?[index];

  int get count => data?.data?.length ?? 0;

  bool get isEmpty => !(data?.data?.isNotEmpty == true);

  bool get hasMore => data?.hasMore == true && data?.nextPageToken != null;
}

abstract class ListCubit<T, E>
    extends NetworkDependentCubit<ListCubitState<T, E>> {
  ListCubit() : super(ListCubitState<T, E>());

  @override
  void onConnectionChanged(bool isConnected) {
    if (isConnectionError(state.error)) {
      refresh();
    }
  }

  E obtainUnknownError();

  bool isConnectionError(E? error);

  Future<void> init() async {
    await _doFetch(force: true);
  }

  Future<void> refresh() async {
    await _doFetch(force: true);
  }

  Future<void> next({bool silent = false}) async {
    if (!state.isLoading &&
        state.data?.hasMore == true &&
        state.data?.nextPageToken != null) {
      await _doFetch(nextPageToken: state.data!.nextPageToken!, silent: silent);
    }
  }

  Future<void> fetch({
    required OnListSuccessCallback<T> onSuccess,
    required OnListErrorCallback onError,
    String? nextPageToken,
    int limit = kDefaultLimit,
  });

  Future<void> _doFetch({
    String? nextPageToken,
    bool force = false,
    bool silent = false,
  }) async {
    if (!silent) {
      emit(ListCubitState(data: state.data, error: null, isLoading: true));
    }
    return fetch(
      onSuccess: (value) {
        if (isClosed) {
          return;
        }
        final data = ListCubitDataState(
          data: force
              ? value.data
              : (state.data?.data ?? []) + (value.data ?? []),
          nextPageToken: value.nextPageToken,
          hasMore: value.hasMore,
          extra: value.extra,
        );
        emit(ListCubitState(data: data, error: null, isLoading: false));
      },
      onError: (error) {
        if (isClosed) {
          return;
        }
        debugPrint("list error: $error");
        emit(ListCubitState(
          data: state.data,
          error: error,
          isLoading: false,
        ));
      },
      nextPageToken: force ? null : nextPageToken,
      limit: kDefaultLimit,
    ).catchError((error) {
      if (isClosed) {
        return;
      }
      debugPrint("list error: $error");
      emit(ListCubitState(
        data: state.data,
        error: obtainUnknownError(),
        isLoading: false,
      ));
    });
  }
}
