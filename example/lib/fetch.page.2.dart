import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:qs_blocs/qs_blocs.dart';
import 'package:qs_blocs_example/app_error.dart';

class FetchPage2 extends StatelessWidget {
  const FetchPage2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: QsFetchWidget<String, AppError>(
        params: QsFetchWidgetParams<String, AppError>(
          cubitResolver: (context) => _ExampleFetchCubit(),
          loadBuilder: (context, state) => const Center(
            child: CircularProgressIndicator.adaptive(),
          ),
          errorBuilder: (context, state, error) => Center(
            child: Text(error.message),
          ),
          contentBuilder: (context, state) => Center(
            child: Text('Fetch result: ${state.state.data}'),
          ),
          wrapperBuilder: (context, state, child) {
            return RefreshIndicator(
              onRefresh: state.requestRefresh,
              child: CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    child: child,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ExampleFetchCubit extends FetchCubit<String, AppError> {
  @override
  Future<void> fetch({
    required OnFetchSuccessCallback<String> onSuccess,
    required OnFetchErrorCallback<AppError> onError,
  }) {
    return Future.delayed(
      const Duration(seconds: 3),
      () => onError(AppError('Error from fetch')),
    );
  }

  @override
  bool isConnectionError(AppError? error) {
    return false;
  }

  @override
  AppError obtainUnknownError() {
    return AppError('Unknown error');
  }
}
