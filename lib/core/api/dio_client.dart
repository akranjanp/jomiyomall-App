import 'dart:convert';
import 'package:dio/dio.dart';
import '../../app/config/api_constants.dart';
import '../storage/secure_storage_service.dart';
import '../storage/local_storage_service.dart';

class DioClient {
  late final Dio dio;
  final SecureStorageService _secureStorage;
  final LocalStorageService _localStorage;

  DioClient(this._secureStorage, this._localStorage) {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'User-Agent': 'JomiyoMallApp/1.0.0 (Flutter)',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Prioritize WooCommerce Basic Auth for /wp-json/wc/v3 endpoints
          if (options.path.contains('/wp-json/wc/v3')) {
            final authString = '${ApiConstants.consumerKey}:${ApiConstants.consumerSecret}';
            final basicAuth = base64Encode(utf8.encode(authString));
            options.headers['Authorization'] = 'Basic $basicAuth';
          } else {
            // Attach JWT token for bridge or general endpoints
            final token = await _secureStorage.getAuthToken();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }

          // Attach Store API Cart Token & Nonce if available
          final cartToken = _localStorage.getCartToken();
          if (cartToken != null && cartToken.isNotEmpty) {
            options.headers['Cart-Token'] = cartToken;
          }

          final cartNonce = _localStorage.getCartNonce();
          if (cartNonce != null && cartNonce.isNotEmpty) {
            options.headers['Nonce'] = cartNonce;
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          // Capture Cart-Token & Nonce from response headers if present
          final respCartToken = response.headers.value('Cart-Token');
          if (respCartToken != null && respCartToken.isNotEmpty) {
            _localStorage.setCartToken(respCartToken);
          }

          final respNonce = response.headers.value('Nonce');
          if (respNonce != null && respNonce.isNotEmpty) {
            _localStorage.setCartNonce(respNonce);
          }

          return handler.next(response);
        },
        onError: (DioException error, handler) {
          return handler.next(error);
        },
      ),
    );
  }
}
