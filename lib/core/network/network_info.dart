import 'package:internet_connection_checker/internet_connection_checker.dart';

// Abstract contract for network information
abstract class NetworkInfo {
  Future<bool> get isConnected;
}

// Concrete implementation of NetworkInfo
class NetworkInfoImpl implements NetworkInfo {
  final InternetConnectionChecker connectionChecker;

  NetworkInfoImpl(this.connectionChecker);

  @override
  Future<bool> get isConnected => connectionChecker.hasConnection;
}
