abstract interface class NetworkStatusCode {
  NetworkStatusCode._();

  static const notFound = 404;
  static const forbidden = 403;
  static const internalServerError = 500;
  static const unauthorized = 401;
  static const badRequest = 400;
}
