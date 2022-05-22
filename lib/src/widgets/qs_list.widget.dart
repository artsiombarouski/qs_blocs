import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qs_blocs/qs_blocs.dart';

typedef QsListCubitResolver<T, E> = ListCubit<T, E> Function(
  BuildContext context,
);

typedef QsListLoadBuilder<T, E> = Widget Function(
  BuildContext context,
  QsListState<T, E> state,
);

typedef QsListErrorBuilder<T, E> = Widget Function(
  BuildContext context,
  QsListState<T, E> state,
  E e,
);

typedef QsListContentBuilder<T, E> = Widget Function(
  BuildContext context,
  QsListState<T, E> state,
);

typedef QsListWrapperBuilder<T, E> = Widget Function(
  BuildContext context,
  QsListState<T, E> state,
  Widget child,
);

class QsListWidgetParams<T, E> {
  final QsListCubitResolver<T, E> cubitResolver;
  final QsListLoadBuilder<T, E> loadBuilder;
  final QsListErrorBuilder<T, E> errorBuilder;
  final QsListContentBuilder<T, E> contentBuilder;
  final QsListWrapperBuilder<T, E>? wrapperBuilder;

  QsListWidgetParams({
    required this.cubitResolver,
    required this.loadBuilder,
    required this.errorBuilder,
    required this.contentBuilder,
    this.wrapperBuilder,
  });
}

class QsListState<T, E> {
  final ListCubit<T, E> cubit;
  final ListCubitState<T, E> state;
  final ListCubitDataState<T>? dataState;

  final VoidCallback requestNextPage;
  final Future<void> Function() requestRefresh;

  QsListState(
    this.cubit,
    this.state,
    this.dataState,
    this.requestNextPage,
    this.requestRefresh,
  );
}

class QsListWidget<T, E> extends StatefulWidget {
  final QsListWidgetParams<T, E> params;

  const QsListWidget({Key? key, required this.params}) : super(key: key);

  @override
  _QsListWidgetState<T, E> createState() => _QsListWidgetState<T, E>();
}

class _QsListWidgetState<T, E> extends State<QsListWidget<T, E>> {
  late ListCubit<T, E> cubit;
  bool _isNextPageRequested = false;

  bool get disposeCubit => true;

  @override
  void initState() {
    cubit = widget.params.cubitResolver(context);
    cubit.init();
    super.initState();
  }

  @override
  void dispose() {
    if (disposeCubit) {
      cubit.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ListCubit<T, E>, ListCubitState<T, E>>(
      bloc: cubit,
      builder: buildContent,
    );
  }

  Widget buildContent(BuildContext context, ListCubitState<T, E> state) {
    final loaderState = QsListState<T, E>(
      cubit,
      state,
      state.data,
      requestNextPage,
      requestRefresh,
    );
    final Widget child;
    if (state.showError) {
      child = widget.params.errorBuilder(context, loaderState, state.error!);
    } else if (state.showLoading) {
      child = widget.params.loadBuilder(context, loaderState);
    } else {
      child = widget.params.contentBuilder(context, loaderState);
    }
    return wrapContent(context, loaderState, child);
  }

  Widget wrapContent(
    BuildContext context,
    QsListState<T, E> state,
    Widget child,
  ) {
    if (widget.params.wrapperBuilder != null) {
      return widget.params.wrapperBuilder!(context, state, child);
    }
    return RefreshIndicator(
      child: child,
      onRefresh: state.requestRefresh,
    );
  }

  void requestNextPage() {
    if (_isNextPageRequested) {
      return;
    }
    _isNextPageRequested = true;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      cubit.next(silent: true).whenComplete(() => _isNextPageRequested = false);
    });
  }

  Future<void> requestRefresh() => cubit.refresh();
}
