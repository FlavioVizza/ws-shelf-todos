import 'package:bcrypt/bcrypt.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../../bin/server.dart';

/// Represents a user in the system.
///
/// This class provides methods for:
/// - User authentication using **bcrypt**.
/// - Storing user details in **MongoDB**.
/// - Retrieving user details from the database.
class User {
  /// The unique identifier of the user in MongoDB.
  ObjectId? id;

  /// The username of the user.
  String username;

  /// The email address of the user.
  String email;

  /// The hashed password of the user (stored securely).
  String hasedPassword;

  /// The salt used for hashing the password.
  String salt;

  /// The timestamp when the user was created.
  DateTime created;

  /// Creates a new user instance.
  ///
  /// If [created] is not provided, it defaults to the current timestamp.
  User({
    this.id,
    required this.username,
    required this.email,
    this.hasedPassword = '',
    this.salt = '',
    DateTime? created,
  }) : created = created ?? DateTime.now();

  /// Creates a `User` object from a **MongoDB document** (map).
  ///
  /// This is useful when retrieving user data from the database.
  factory User.fromMap(Map<String, dynamic> map) => User(
    id:             map['_id'],
    username:       map['username'],
    email:          map['email'],
    hasedPassword:  map['hasedPassword'],
    salt:           map['salt'],
    created:        map['created'],
  );

  /// Converts the `User` object to a **map** for MongoDB storage.
  ///
  /// This method removes the `_id` field since MongoDB generates it automatically.
  Map<String, dynamic> toMap() => {
    'username': username,
    'email': email,
    'hasedPassword': hasedPassword,
    'salt': salt,
    'created': created,
  };

  /// Sets the password for the user.
  ///
  /// This method:
  /// - Generates a new salt.
  /// - Hashes the password with the generated salt.
  void setPassword(String password) {
    salt = _generateSalt();
    hasedPassword = _encryptedPassword(password, salt);
  }

  /// Authenticates the user by comparing the provided password with the stored hash.
  ///
  /// Returns `true` if the password matches, otherwise returns `false`.
  bool authenticate(String password) =>
      _encryptedPassword(password, salt) == hasedPassword;

  /// Hashes the given password using **bcrypt** and the provided salt.
  ///
  /// This method ensures that passwords are stored securely.
  String _encryptedPassword(String password, String salt) =>
      BCrypt.hashpw(password, salt).toString();

  /// Generates a new **bcrypt salt** for password hashing.
  ///
  /// The salt uses a log-rounds value of `10` to enhance security.
  String _generateSalt() => BCrypt.gensalt(logRounds: 10);

  /// Saves the user to the **MongoDB database**.
  ///
  /// - If a user with the same email already exists, an exception is thrown.
  /// - If insertion fails, a generic exception is thrown.
  /// - Otherwise, the user is successfully stored in the database.
  Future<void> save() async {
    final collection = db.collection('users');
    final userData = await collection.findOne({'email': email});

    if (userData != null) {
      throw Exception('User already exists');
    }

    var result = await collection.insertOne({
      'username': username,
      'email': email,
      'hashed_password': hasedPassword,
      'salt': salt,
      'created': created,
    });

    if(!result.isSuccess){
      throw Exception('Generic Error registering user');
    }
  }

  /// Finds a user by email in the **MongoDB database**.
  ///
  /// Returns a `User` object if found, otherwise returns `null`.
  static Future<User?> findByEmail(String email) async {
    final collection = db.collection('users');
    final userData = await collection.findOne({'email': email});
    if (userData == null) return null;

    return User(
      id:             userData['_id'],
      username:       userData['username'],
      email:          userData['email'],
      hasedPassword:  userData['hashed_password'],
      salt:           userData['salt'],
      created:        userData['created']
    );
  }
}
