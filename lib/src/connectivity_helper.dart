import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:synchronized/synchronized.dart';

class ConnectivityHelper {
  static ConnectivityHelper? _instance;

  static ConnectivityHelper get instance {
    return _instance ??= ConnectivityHelper._();
  }

  final _lock = Lock();
  final _controller = StreamController<bool>.broadcast();
  bool _isInitialized = false;

  StreamSubscription? _connectivitySubscription;
  ConnectivityResult? _lastKnownResult;

  Sink<bool> get sink => _controller.sink;

  Stream<bool> get stream => _controller.stream;

  ConnectivityHelper._();

  Future<bool> init() async {
    return _lock.synchronized(() async {
      if (!_isInitialized) {
        final connectivity = Connectivity();
        _connectivitySubscription =
            connectivity.onConnectivityChanged.listen(_updateConnectionState);
        await connectivity.checkConnectivity().then(_updateConnectionState);
        _isInitialized = true;
      }
      return isConnected;
    });
  }

  Future<void> dispose() async {
    await _connectivitySubscription?.cancel();
    await _controller.close();
  }

  bool get isConnected => _lastKnownResult != ConnectivityResult.none;

  void _updateConnectionState(ConnectivityResult result) {
    if (_lastKnownResult != result) {
      _lastKnownResult = result;
      sink.add(isConnected);
    }
  }
}
