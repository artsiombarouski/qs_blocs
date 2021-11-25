# qs_blocs

QS Blocs

## Getting Started

### Fetch cubit example

```dart
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
```

### Fetch widget usage example

```dart
class FetchPage extends StatelessWidget {
  const FetchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: QsFetchWidget<String, AppError>(
        params: QsFetchWidgetParams<String, AppError>(
          cubitResolver: (context) => _ExampleFetchCubit(),
          loadBuilder: (context, state) =>
          const Center(
            child: CircularProgressIndicator.adaptive(),
          ),
          errorBuilder: (context, state, error) =>
              Center(
                child: Text(error.message),
              ),
          contentBuilder: (context, state) =>
              CustomScrollView(
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
```

### List cubit example

```dart
class _ExampleListCubit extends ListCubit<String, AppError> {
  static final _tempData = List.generate(100, (index) => 'Item #$index');

  @override
  Future<void> fetch({
    required OnListSuccessCallback<String> onSuccess,
    required OnListErrorCallback onError,
    String? nextPageToken,
    int limit = kDefaultLimit,
  }) {
    int offset = nextPageToken != null ? int.parse(nextPageToken) : 0;
    final result = _tempData.sublist(offset, offset + kDefaultLimit);
    final hasMore = offset + limit < _tempData.length;
    return Future.delayed(
        const Duration(seconds: 3),
            () =>
            onSuccess(ListCubitDataState(
              data: result,
              hasMore: hasMore,
              nextPageToken: (offset + limit).toString(),
            )));
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
```

### List widget usage example

```dart
class ListPage extends StatelessWidget {
  const ListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: QsListWidget<String, AppError>(
        params: QsListWidgetParams<String, AppError>(
          cubitResolver: (context) => _ExampleListCubit(),
          loadBuilder: (context, state) =>
          const SliverFillRemaining(
            child: Center(
              child: CircularProgressIndicator.adaptive(),
            ),
          ),
          errorBuilder: (context, state, error) =>
              SliverFillRemaining(
                child: Center(
                  child: Text(error.message),
                ),
              ),
          contentBuilder: _buildContent,
          wrapperBuilder: (context, state, child) {
            return RefreshIndicator(
              onRefresh: state.requestRefresh,
              child: CustomScrollView(
                slivers: [
                  child,
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context,
      QsListState<String, AppError> state,) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          if (state.state.hasMore && index == state.state.count) {
            state.requestNextPage();
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          }
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            child: Text(state.state.itemAt(index)!),
          );
        },
        childCount: state.state.count + (state.state.hasMore ? 1 : 0),
      ),
    );
  }
}
```