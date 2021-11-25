import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qs_blocs/src/connectivity_helper.dart';

abstract class NetworkDependentCubit<T> extends Cubit<T> {
  late StreamSubscription _subscription;
  bool? _lastConnectionState;

  bool get isConnected => _lastConnectionState == true;

  NetworkDependentCubit(T initialState) : super(initialState) {
    final connectivityHelper = ConnectivityHelper.instance;
    _subscription = connectivityHelper.stream.listen(_updateConnectionState);
    connectivityHelper.init().then(_updateConnectionState);
  }

  void _updateConnectionState(bool connected) {
    if (connected == _lastConnectionState) {
      return;
    }
    _lastConnectionState = connected;
    onConnectionChanged(isConnected);
  }

  void onConnectionChanged(bool isConnected) {}

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
