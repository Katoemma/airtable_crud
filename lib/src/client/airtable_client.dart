import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/airtable_config.dart';
import '../constants/airtable_constants.dart';
import '../errors/airtable_exception.dart';
import '../errors/auth_exception.dart';
import '../errors/network_exception.dart';
import '../errors/not_found_exception.dart';
import '../errors/rate_limit_exception.dart';
import '../errors/validation_exception.dart';

/// HTTP client wrapper for making requests to the Airtable API.
///
/// This class handles:
/// - Authentication headers
/// - Retry logic with exponential backoff
/// - Error parsing and exception creation
/// - Timeout management
/// - Optional logging
class AirtableClient {
  /// The configuration for this client.
  final AirtableConfig config;

  /// The underlying HTTP client.
  final http.Client _httpClient;

  /// Creates an [AirtableClient] with the given configuration.
  ///
  /// Optionally accepts a custom [httpClient] for testing.
  AirtableClient(this.config, {http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  /// Creates a simple client with just an API key.
  ///
  /// Uses default configuration values.
  factory AirtableClient.simple(String apiKey) {
    return AirtableClient(
      AirtableConfig.simple(apiKey: apiKey, baseId: ''),
    );
  }

  /// Common headers used for all requests.
  Map<String, String> get _headers => {
        AirtableConstants.headerAuthorization:
            '${AirtableConstants.bearerPrefix} ${config.apiKey}',
        AirtableConstants.headerContentType: AirtableConstants.contentTypeJson,
      };

  /// Makes a GET request to the specified URI.
  ///
  /// Automatically handles retries and errors.
  Future<http.Response> get(Uri uri) async {
    return _makeRequest(() => _httpClient.get(uri, headers: _headers));
  }

  /// Makes a POST request to the specified URI with the given body.
  ///
  /// Automatically handles retries and errors.
  Future<http.Response> post(Uri uri, Map<String, dynamic> body) async {
    return _makeRequest(
      () => _httpClient.post(
        uri,
        headers: _headers,
        body: jsonEncode(body),
      ),
    );
  }

  /// Makes a PATCH request to the specified URI with the given body.
  ///
  /// Automatically handles retries and errors.
  Future<http.Response> patch(Uri uri, Map<String, dynamic> body) async {
    return _makeRequest(
      () => _httpClient.patch(
        uri,
        headers: _headers,
        body: jsonEncode(body),
      ),
    );
  }

  /// Makes a DELETE request to the specified URI.
  ///
  /// Automatically handles retries and errors.
  Future<http.Response> delete(Uri uri) async {
    return _makeRequest(() => _httpClient.delete(uri, headers: _headers));
  }

  /// Makes an HTTP request with retry logic and error handling.
  Future<http.Response> _makeRequest(
    Future<http.Response> Function() request,
  ) async {
    int attempt = 0;

    while (attempt <= config.maxRetries) {
      try {
        if (config.enableLogging) {
          print(
              '[AirtableClient] Attempt ${attempt + 1}/${config.maxRetries + 1}');
        }

        // Make the request with timeout
        final response = await request().timeout(config.timeout);

        // Log response if enabled
        if (config.enableLogging) {
          print('[AirtableClient] Response: ${response.statusCode}');
        }

        // Check for successful response
        if (response.statusCode == AirtableConstants.statusOk ||
            response.statusCode == AirtableConstants.statusCreated) {
          return response;
        }

        // Handle error responses
        _handleErrorResponse(response);

        // If we get here, throw a general exception
        throw GeneralAirtableException(
          message: 'Request failed with status ${response.statusCode}',
          statusCode: response.statusCode,
        );
      } on AirtableException {
        // Don't retry on auth, validation, or not found errors
        rethrow;
      } catch (e) {
        attempt++;

        // If we've exhausted retries, throw network exception
        if (attempt > config.maxRetries) {
          throw NetworkException(
            message: 'Request failed after ${config.maxRetries} retries',
            details: e.toString(),
          );
        }

        // Wait before retrying with exponential backoff
        final delay = config.retryDelay * attempt;
        if (config.enableLogging) {
          print('[AirtableClient] Retry in ${delay.inSeconds}s...');
        }
        await Future.delayed(delay);
      }
    }

    // This should never be reached, but just in case
    throw NetworkException(
      message: 'Request failed unexpectedly',
    );
  }

  /// Handles error responses from the Airtable API.
  ///
  /// Parses the error response and throws the appropriate exception type.
  void _handleErrorResponse(http.Response response) {
    String? errorMessage;
    String? errorDetails;

    // Try to parse error message from response body
    try {
      final errorBody = jsonDecode(response.body);
      errorMessage = errorBody['error']?['message'] as String?;
      errorDetails = errorBody['error']?['type'] as String?;
    } catch (_) {
      // If parsing fails, use status code message
      errorMessage = 'HTTP ${response.statusCode}';
    }

    final statusCode = response.statusCode;
    final message = errorMessage ?? 'Request failed';

    // Throw specific exception based on status code
    switch (statusCode) {
      case AirtableConstants.statusUnauthorized:
      case AirtableConstants.statusForbidden:
        throw AuthException(
          message: message,
          details: errorDetails,
          statusCode: statusCode,
        );

      case AirtableConstants.statusNotFound:
        throw NotFoundException(
          message: message,
          details: errorDetails,
          statusCode: statusCode,
        );

      case AirtableConstants.statusUnprocessableEntity:
        throw ValidationException(
          message: message,
          details: errorDetails,
          statusCode: statusCode,
        );

      case AirtableConstants.statusTooManyRequests:
        // Try to parse retry-after header
        Duration? retryAfter;
        final retryAfterHeader = response.headers['retry-after'];
        if (retryAfterHeader != null) {
          final seconds = int.tryParse(retryAfterHeader);
          if (seconds != null) {
            retryAfter = Duration(seconds: seconds);
          }
        }

        throw RateLimitException(
          message: message,
          details: errorDetails,
          statusCode: statusCode,
          retryAfter: retryAfter,
        );

      default:
        throw GeneralAirtableException(
          message: message,
          details: errorDetails,
          statusCode: statusCode,
        );
    }
  }

  /// Closes the underlying HTTP client.
  ///
  /// Call this when you're done with the client to free up resources.
  void close() {
    _httpClient.close();
  }
}
