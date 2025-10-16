import 'package:airtable_crud/src/errors/airtable_exception.dart';
import 'package:airtable_crud/src/errors/auth_exception.dart';
import 'package:airtable_crud/src/errors/network_exception.dart';
import 'package:airtable_crud/src/errors/not_found_exception.dart';
import 'package:airtable_crud/src/errors/rate_limit_exception.dart';
import 'package:airtable_crud/src/errors/validation_exception.dart';
import 'package:test/test.dart';

void main() {
  group('AirtableException Hierarchy', () {
    group('GeneralAirtableException', () {
      test('creates exception with message', () {
        final exception = GeneralAirtableException(message: 'Test error');

        expect(exception.message, equals('Test error'));
        expect(exception.details, isNull);
        expect(exception.statusCode, isNull);
      });

      test('creates exception with all fields', () {
        final exception = GeneralAirtableException(
          message: 'Test error',
          details: 'Additional info',
          statusCode: 500,
        );

        expect(exception.message, equals('Test error'));
        expect(exception.details, equals('Additional info'));
        expect(exception.statusCode, equals(500));
      });

      test('toString includes all available information', () {
        final exception = GeneralAirtableException(
          message: 'Test error',
          details: 'Additional info',
          statusCode: 500,
        );

        final str = exception.toString();
        expect(str, contains('GeneralAirtableException'));
        expect(str, contains('Test error'));
        expect(str, contains('Additional info'));
        expect(str, contains('500'));
      });

      test('toString handles missing fields', () {
        final exception = GeneralAirtableException(message: 'Test error');

        final str = exception.toString();
        expect(str, contains('GeneralAirtableException'));
        expect(str, contains('Test error'));
      });
    });

    group('NetworkException', () {
      test('creates network exception', () {
        final exception = NetworkException(
          message: 'Connection failed',
          details: 'Timeout after 30s',
        );

        expect(exception, isA<AirtableException>());
        expect(exception.message, equals('Connection failed'));
        expect(exception.details, equals('Timeout after 30s'));
      });

      test('toString includes type name', () {
        final exception = NetworkException(message: 'Connection failed');
        final str = exception.toString();

        expect(str, contains('NetworkException'));
      });
    });

    group('AuthException', () {
      test('creates auth exception with 401', () {
        final exception = AuthException(
          message: 'Invalid API key',
          statusCode: 401,
        );

        expect(exception, isA<AirtableException>());
        expect(exception.message, equals('Invalid API key'));
        expect(exception.statusCode, equals(401));
      });

      test('creates auth exception with 403', () {
        final exception = AuthException(
          message: 'Insufficient permissions',
          statusCode: 403,
        );

        expect(exception.statusCode, equals(403));
      });

      test('toString includes status code', () {
        final exception = AuthException(
          message: 'Invalid API key',
          statusCode: 401,
        );

        final str = exception.toString();
        expect(str, contains('AuthException'));
        expect(str, contains('401'));
      });
    });

    group('RateLimitException', () {
      test('creates rate limit exception', () {
        final exception = RateLimitException(
          message: 'Too many requests',
        );

        expect(exception, isA<AirtableException>());
        expect(exception.message, equals('Too many requests'));
        expect(exception.statusCode, equals(429));
      });

      test('includes retry after duration', () {
        final retryAfter = Duration(seconds: 30);
        final exception = RateLimitException(
          message: 'Too many requests',
          retryAfter: retryAfter,
        );

        expect(exception.retryAfter, equals(retryAfter));
      });

      test('toString includes retry after', () {
        final exception = RateLimitException(
          message: 'Too many requests',
          retryAfter: Duration(seconds: 30),
        );

        final str = exception.toString();
        expect(str, contains('RateLimitException'));
        expect(str, contains('30s'));
      });

      test('toString works without retry after', () {
        final exception = RateLimitException(
          message: 'Too many requests',
        );

        final str = exception.toString();
        expect(str, contains('RateLimitException'));
        expect(str, isNot(contains('Retry after')));
      });
    });

    group('ValidationException', () {
      test('creates validation exception', () {
        final exception = ValidationException(
          message: 'Invalid field',
          details: 'Field "age" must be a number',
        );

        expect(exception, isA<AirtableException>());
        expect(exception.message, equals('Invalid field'));
        expect(exception.details, equals('Field "age" must be a number'));
        expect(exception.statusCode, equals(422));
      });

      test('toString includes details', () {
        final exception = ValidationException(
          message: 'Invalid field',
          details: 'Field "age" must be a number',
        );

        final str = exception.toString();
        expect(str, contains('ValidationException'));
        expect(str, contains('Invalid field'));
        expect(str, contains('Field "age" must be a number'));
      });
    });

    group('NotFoundException', () {
      test('creates not found exception', () {
        final exception = NotFoundException(
          message: 'Record not found',
          details: 'Record ID rec123 does not exist',
        );

        expect(exception, isA<AirtableException>());
        expect(exception.message, equals('Record not found'));
        expect(exception.statusCode, equals(404));
      });

      test('toString includes status code', () {
        final exception = NotFoundException(
          message: 'Record not found',
        );

        final str = exception.toString();
        expect(str, contains('NotFoundException'));
        expect(str, contains('404'));
      });
    });

    group('Exception type checking', () {
      test('all exceptions are AirtableException', () {
        expect(NetworkException(message: 'test'), isA<AirtableException>());
        expect(AuthException(message: 'test'), isA<AirtableException>());
        expect(RateLimitException(message: 'test'), isA<AirtableException>());
        expect(ValidationException(message: 'test'), isA<AirtableException>());
        expect(NotFoundException(message: 'test'), isA<AirtableException>());
      });

      test('exceptions can be caught specifically', () {
        void throwAuthException() {
          throw AuthException(message: 'Invalid API key');
        }

        expect(throwAuthException, throwsA(isA<AuthException>()));
        expect(throwAuthException, throwsA(isA<AirtableException>()));
      });

      test('different exception types are distinguishable', () {
        final networkException = NetworkException(message: 'network');
        final authException = AuthException(message: 'auth');

        expect(networkException, isNot(isA<AuthException>()));
        expect(authException, isNot(isA<NetworkException>()));
      });
    });

    group('Exception inheritance', () {
      test('can catch any AirtableException', () {
        void throwSpecificException() {
          throw RateLimitException(message: 'Rate limited');
        }

        try {
          throwSpecificException();
          fail('Should have thrown');
        } on AirtableException catch (e) {
          expect(e, isA<RateLimitException>());
          expect(e.message, equals('Rate limited'));
        }
      });

      test('specific catch comes before general catch', () {
        void throwAuthException() {
          throw AuthException(message: 'Auth error');
        }

        var caughtSpecific = false;
        var caughtGeneral = false;

        try {
          throwAuthException();
        } on AuthException {
          caughtSpecific = true;
        } on AirtableException {
          caughtGeneral = true;
        }

        expect(caughtSpecific, isTrue);
        expect(caughtGeneral, isFalse);
      });
    });
  });
}
