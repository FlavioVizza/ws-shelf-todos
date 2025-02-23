import 'dart:io';

/// A class for managing environment configuration settings.
///
/// The `Config` class provides static fields that are used to manage 
/// application configuration settings, such as the environment mode (`SHELF_ENV`), 
/// server settings (`ip`, `port`), and secret keys for authentication (`accessTokenSecret`, 
/// `refreshTokenSecret`). These configurations are loaded from environment variables or 
/// default values are provided when necessary.
class Config {
  /// The environment mode the application is running in.
  ///
  /// This field retrieves the `SHELF_ENV` environment variable or defaults to `'development'`.
  static final env = Platform.environment['SHELF_ENV'] ?? 'development';

  /// The IP address the server will bind to.
  ///
  /// This field sets the server's IP address to listen on. By default, it listens on any
  /// available IPv4 address (`InternetAddress.anyIPv4`).
  static final ip = InternetAddress.anyIPv4; // Use any available host

  /// The port number the server will listen on.
  ///
  /// This field retrieves the `PORT` environment variable or defaults to `8080` if not provided.
  static final port = int.tryParse(Platform.environment['PORT'] ?? '8080') ?? 8080;

  /// The secret key used to sign and verify access tokens.
  ///
  /// This field retrieves the `ACCESS_TOKEN_SECRET` environment variable or defaults to 
  /// `'ACCESS_TOKEN_SECRET'` if not provided.
  static final accessTokenSecret = Platform.environment['ACCESS_TOKEN_SECRET'] ?? 'ACCESS_TOKEN_SECRET';

  /// The duration (in minutes) for which the access token is valid.
  ///
  /// This field retrieves the `ACCESS_TOKEN_DURATION` environment variable or defaults to 
  /// `15` minutes if not provided.
  static final accessTokenDuration = int.tryParse(Platform.environment['ACCESS_TOKEN_DURATION'] ?? '15') ?? 15; // minutes

  /// The secret key used to sign and verify refresh tokens.
  ///
  /// This field retrieves the `REFRESH_TOKEN_SECRET` environment variable or defaults to 
  /// `'REFRESH_TOKEN_SECRET'` if not provided.
  static final refreshTokenSecret = Platform.environment['REFRESH_TOKEN_SECRET'] ?? 'REFRESH_TOKEN_SECRET';

  /// The duration (in days) for which the refresh token is valid.
  ///
  /// This field retrieves the `REFRESH_TOKEN_DURATION` environment variable or defaults to 
  /// `1` day if not provided.
  static final refreshTokenDuration = int.tryParse(Platform.environment['REFRESH_TOKEN_DURATION'] ?? '1') ?? 1; // day

  /// The URI of the MongoDB database used by the application.
  ///
  /// This field retrieves the `TODOS_API_DB_URI` environment variable or defaults to 
  /// `'mongodb://localhost/todoapp'` if not provided.
  static final mongodbUri = Platform.environment['TODOS_API_DB_URI'] ?? 'mongodb://localhost/todoapp';  
}