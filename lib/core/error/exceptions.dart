class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException({
    this.message = 'A server error occurred. Please try again later.',
    this.statusCode,
  });

  @override
  String toString() => 'ServerException: $message (code: $statusCode)';
}

class NetworkException implements Exception {
  final String message;

  const NetworkException({
    this.message =
        'Network connection failed. Please check your internet connection.',
  });

  @override
  String toString() => 'NetworkException: $message';
}

class ParsingException implements Exception {
  final String message;

  const ParsingException({this.message = 'Failed to parse server response.'});

  @override
  String toString() => 'ParsingException: $message';
}
