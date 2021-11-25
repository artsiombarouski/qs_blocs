import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:qs_blocs/qs_blocs.dart';
import 'package:qs_blocs_example/app_error.dart';

class FetchPage extends StatelessWidget {
  const FetchPage({Key? key}) : super(key: key);

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
          contentBuilder: (context, state) => CustomScrollView(
            slivers: [
              SliverFillRemaining(
                child: Center(
                  child: Text('Fetch result: ${state.state.data}'),
                ),
              ),
            ],
          ),
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
      () => onSuccess('Success'),
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
