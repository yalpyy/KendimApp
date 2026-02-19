/// Base exception for all Kendin app errors.
class AppException implements Exception {
  const AppException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => 'AppException($code): $message';
}

class AuthException extends AppException {
  const AuthException(super.message, {super.code});
}

class EntryException extends AppException {
  const EntryException(super.message, {super.code});
}

class ReflectionException extends AppException {
  const ReflectionException(super.message, {super.code});
}

class PurchaseException extends AppException {
  const PurchaseException(super.message, {super.code});
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'Network error']);
}
