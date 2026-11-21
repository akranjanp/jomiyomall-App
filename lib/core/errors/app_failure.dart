class AppFailure {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  const AppFailure({
    required this.message,
    this.statusCode,
    this.originalError,
  });

  factory AppFailure.fromDioError(dynamic error) {
    if (error is Exception) {
      final errorStr = error.toString().toLowerCase();
      if (errorStr.contains('connection refused') || errorStr.contains('socketexception')) {
        return const AppFailure(
          message: 'Unable to reach Jomiyo Mall server. Please check your internet or retry.',
          statusCode: 503,
        );
      }
      if (errorStr.contains('timeout')) {
        return const AppFailure(
          message: 'Server connection timed out. Please try again.',
          statusCode: 408,
        );
      }
    }
    return AppFailure(
      message: 'An unexpected error occurred. Please try again.',
      originalError: error,
    );
  }

  @override
  String toString() => message;
}
