import 'package:mongo_dart/mongo_dart.dart';

/// Represents a **Todo** item.
///
/// Each **Todo** is associated with a specific user and contains:
/// - A unique `todoId`
/// - A `title` and `description`
/// - A `completed` status (default: `false`)
/// - A creation timestamp (`createAt`)
class Todo {
  /// The unique identifier of the todo in MongoDB.
  ObjectId? id;

  /// The user ID associated with this todo.
  ObjectId userId;

  /// A unique **todo identifier** (incremental).
  int todoId;

  /// The title of the todo.
  String title;

  /// A detailed description of the todo.
  String description;

  /// Indicates whether the todo is completed (`true`) or pending (`false`).
  bool completed;

  /// The timestamp when the todo was created.
  DateTime createAt;

  /// Creates a new `Todo` instance.
  ///
  /// If `createAt` is not provided, it defaults to the current timestamp.
  Todo({
    this.id,
    required this.userId,
    required this.todoId,
    required this.title,
    required this.description,
    this.completed = false,
    DateTime? createAt,
  }) : createAt = createAt ?? DateTime.now();

  /// Creates a `Todo` object from a **MongoDB document (Map)**.
  ///
  /// This is useful when retrieving a todo from the database.
  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id:           map['_id']          as ObjectId?,
      userId:       map['userId']       as ObjectId,
      todoId:       map['todoId']       as int,
      title:        map['title']        as String,
      description:  map['description']  as String,
      completed:    map['completed']    as bool? ?? false,
      createAt:    (map['createAt']     as DateTime?) ?? DateTime.now(),
    );
  }

  /// Converts the `Todo` object into a **MongoDB-compatible map**.
  ///
  /// This method is useful for storing the todo in the database.
  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'userId': userId,
      'todoId': todoId,
      'title': title,
      'description': description,
      'completed': completed,
      'createAt': createAt,
    };
  }

  /// Converts the `Todo` object into a **JSON representation**.
  ///
  /// The `createAt` field is formatted as an ISO 8601 string.
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'todoId': todoId,
      'title': title,
      'description': description,
      'completed': completed,
      'createAt': createAt.toIso8601String(), // Readable format
    };
  }

  /// Converts the `Todo` object into a **minimal JSON response**.
  ///
  /// The `_id` and `userId` fields are excluded.
  Map<String, dynamic> toJsonResponse() {
    return {
      'todoId': todoId,
      'title': title,
      'description': description,
      'completed': completed,
      'createAt': createAt.toIso8601String(), // Readable format
    };
  }

  /// Generates the **next incremental `todoId`**, similar to Mongoose auto-increment.
  ///
  /// This method:
  /// - Queries the database for the latest todo.
  /// - Extracts its `todoId` and increments it by 1.
  /// - If no todos exist, it starts from `1`.
  ///
  /// Returns the next available `todoId` as an integer.
  static Future<int> getNextTodoId(DbCollection collection) async {
    final lastTodo = await collection.findOne(
      where.sortBy('todoId', descending: true),
    );

    return (lastTodo?['todoId'] as int? ?? 0) + 1;
  }
}
