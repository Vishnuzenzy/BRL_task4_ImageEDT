enum AppErrorType {
  permissionDenied,
  invalidFile,
  fileTooLarge,
  processingFailed,
  saveFailed,
}

class AppException implements Exception {
  final AppErrorType type;
  final String message;

  const AppException(this.type, this.message);

  @override
  String toString() => message;
}