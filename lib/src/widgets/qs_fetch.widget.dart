import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qs_blocs/qs_blocs.dart';

typedef QsFetchCubitResolver<T, E> = FetchCubit<T, E> Function(
  BuildContext context,
);

typedef QsFetchLoadBuilder<T, E> = Widget Function(
  BuildContext context,
  QsFetchState<T, E> state,
);

typedef QsFetchErrorBuilder<T, E> = Widget Function(
  BuildContext context,
  QsFetchState<T, E> state,
  E e,
);

typedef QsFetchContentBuilder<T, E> = Widget Function(
  BuildContext context,
  QsFetchState<T, E> state,
);

typedef QsFetchWrapperBuilder<T, E> = Widget Function(
  BuildContext context,
  QsFetchState<T, E> state,
  Widget child,
);

class QsFetchWidgetParams<T, E> {
  final QsFetchCubitResolver<T, E> cubitResolver;
  final QsFetchLoadBuilder<T, E> loadBuilder;
  final QsFetchErrorBuilder<T, E> errorBuilder;
  final QsFetchContentBuilder<T, E> contentBuilder;
  final QsFetchWrapperBuilder<T, E>? wrapperBuilder;

  QsFetchWidgetParams({
    required this.cubitResolver,
    required this.loadBuilder,
    required this.errorBuilder,
    required this.contentBuilder,
    this.wrapperBuilder,
  });
}

class QsFetchState<T, E> {
  final FetchCubit<T, E> cubit;
  final FetchCubitState<T, E> state;

  final Future<void> Function() requestRefresh;

  QsFetchState(this.cubit, this.state, this.requestRefresh);
}

class QsFetchWidget<T, E> extends StatefulWidget {
  final QsFetchWidgetParams<T, E> params;

  const QsFetchWidget({Key? key, required this.params}) : super(key: key);

  @override
  State<QsFetchWidget<T, E>> createState() => _QsFetchWidgetState<T, E>();
}

class _QsFetchWidgetState<T, E> extends State<QsFetchWidget<T, E>> {
  late FetchCubit<T, E> cubit;

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
    return BlocBuilder<FetchCubit<T, E>, FetchCubitState<T, E>>(
      bloc: cubit,
      builder: buildContent,
    );
  }

  Widget buildContent(BuildContext context, FetchCubitState<T, E> state) {
    final loaderState = QsFetchState(cubit, state, requestRefresh);
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
    QsFetchState<T, E> state,
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

  Future<void> requestRefresh() => cubit.refresh();
}
