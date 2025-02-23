import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../models/todo_model.dart';
import '../utils/constants.dart';
import '../../bin/server.dart';

/// **Get all todo items for the authenticated user**
///
/// This function fetches all the todo items belonging to the authenticated 
/// user. It filters the todos using the `userId` from the request context 
/// and returns them in a JSON array. In case of an error, it returns an 
/// internal server error response.
///
/// **Returns**: A `200 OK` response with a JSON list of todos.
Future<Response> getTodoList(Request request) async {
  try {
    final userId = request.context['userId'] as String;
    final userIdObject = ObjectId.fromHexString(userId);

    final todos = await db.collection('todos').find(where.eq('userId', userIdObject))
      .map((todo){
        return Todo.fromMap(todo).toJsonResponse();
      })
    .toList();

    return Response.ok(jsonEncode(todos), headers: myApiHeaders);
  } catch (e) {
    print(e);
    return Response.internalServerError(headers: myApiHeaders, body: jsonEncode({'success': false, 'message': 'Error getting todos list'}));
  }
}

/// **Get a single todo item**
///
/// This function retrieves a specific todo item by its `todoId` for the 
/// authenticated user. If the item is not found, it returns a `404 Not Found` 
/// response. Otherwise, it returns the todo item in a `200 OK` response.
///
/// **Returns**: A `200 OK` response with the todo item in JSON format if found, 
/// or a `404 Not Found` response if not found.
Future<Response> getTodoItem(Request request, String id) async {
  try {
    final userId = request.context['userId'] as String;
    final todo = await db.collection('todos').findOne(
      where.eq('todoId', int.parse(id)).eq('userId', ObjectId.fromHexString(userId)),
    );

    if (todo == null) {
      return Response.notFound(jsonEncode({'success': false, 'message': 'Todo item not found'}));
    }
    var todoJson = Todo.fromMap(todo).toJsonResponse();
    return Response.ok(headers: myApiHeaders, jsonEncode(todoJson));
  } catch (e) {
    print(e);
    return Response.internalServerError(headers: myApiHeaders, body: jsonEncode({'success': false, 'message': 'Error getting todo item'}));
  }
}

/// **Create a new todo item**
///
/// This function allows the authenticated user to create a new todo item. It 
/// expects a JSON payload with a `title` and `description` for the todo. If 
/// these fields are missing, it returns a `400 Bad Request` response. It also 
/// generates the next available `todoId` before creating the item.
///
/// **Returns**: A `201 Created` response with a success message or a `400 Bad Request` 
/// if required fields are missing.
Future<Response> postTodoItem(Request request) async {
  try {
    final userId = request.context['userId'] as String;
    final body = await request.readAsString();
    final data = jsonDecode(body);

    if (data['title'] == null || data['description'] == null) {
      return Response.badRequest(headers: myApiHeaders, body: jsonEncode({'success': false, 'message': 'Title and description are required'}));
    }

    // Generate the next `todoId`
    final nextTodoId = await Todo.getNextTodoId(db.collection('todos'));

    final newTodo = Todo(
      userId: ObjectId.fromHexString(userId),
      todoId: nextTodoId,
      title: data['title'],
      description: data['description'],
    );

    await db.collection('todos').insertOne(newTodo.toMap());

    return Response(201, headers: myApiHeaders, body: jsonEncode({'success': true, 'message': 'Todo item created successfully'}));
  } catch (e) {
    print(e);
    return Response.internalServerError(headers: myApiHeaders, body: jsonEncode({'success': false, 'message': 'Error creating todo item'}));
  }
}

/// **Delete a todo item**
///
/// This function deletes a todo item based on the `todoId` provided in the 
/// URL and the authenticated user's `userId`. If the item is not found, 
/// it returns a `404 Not Found` response. Otherwise, it returns a success 
/// message in a `200 OK` response.
///
/// **Returns**: A `200 OK` response with a success message if the todo item 
/// is deleted, or a `404 Not Found` response if the item is not found.
Future<Response> deleteTodoItem(Request request, String id) async {
  try {
    final userId = request.context['userId'] as String;
    final result = await db.collection('todos').deleteOne(
      where.eq('todoId', int.parse(id)).eq('userId', ObjectId.fromHexString(userId)),
    );

    if (result.nRemoved == 0) {
      return Response.notFound(jsonEncode({'success': false, 'message': 'Todo item not found'}));
    }

    return Response.ok(headers: myApiHeaders, jsonEncode({'success': true, 'message': 'Todo item deleted successfully'}));
  } catch (e) {
    print(e);
    return Response.internalServerError(headers: myApiHeaders, body: jsonEncode({'success': false, 'message': 'Error deleting todo item'}));
  }
}

/// **Update a todo item**
///
/// This function allows the authenticated user to update an existing todo 
/// item. The fields `title`, `description`, and `completed` can be updated. 
/// If no fields are provided to update, it returns a `400 Bad Request` response.
///
/// **Returns**: A `200 OK` response with a success message if the todo item 
/// is updated, or a `404 Not Found` response if the item is not found.
Future<Response> putTodoItem(Request request, String id) async {
  try {
    final userId = request.context['userId'] as String;
    final body = await request.readAsString();
    final data = jsonDecode(body);

    final updateData = <String, dynamic>{};
    if (data['title'] != null) updateData['title'] = data['title'];
    if (data['description'] != null) updateData['description'] = data['description'];
    if (data['completed'] != null) updateData['completed'] = data['completed'];

    if (updateData.isEmpty) {
      return Response.badRequest(body: jsonEncode({'success': false, 'message': 'No fields to update'}));
    }

    // Create ModifierBuilder
    final modify = ModifierBuilder();
    updateData.forEach((key, value) {
      modify.set(key, value); // ✅ Use set() for each field
    });

    final result = await db.collection('todos').updateOne(
      where.eq('todoId', int.parse(id)).eq('userId', ObjectId.fromHexString(userId)),
      modify, // ✅ Pass the ModifierBuilder with set()
    );

    if (result.nModified == 0) {
      return Response.notFound(jsonEncode({'success': false, 'message': 'Todo item not found'}));
    }

    return Response.ok(jsonEncode({'success': true, 'message': 'Todo item updated successfully'}));
  } catch (e) {
    print(e);
    return Response.internalServerError(body: jsonEncode({'success': false, 'message': 'Error updating todo item'}));
  }
}

/// **Alternative method for updating a todo item**
///
/// This method works similarly to the `putTodoItem` method, but uses 
/// `findAndModify` to return the updated todo item directly after modification. 
/// If no fields are provided to update, it returns a `400 Bad Request` response.
///
/// **Returns**: A `200 OK` response with the updated todo item in the body 
/// or a `404 Not Found` response if the item is not found.
Future<Response> putTodoItem2(Request request, String id) async {
  try {
    final userId = request.context['userId'] as String;
    final body = await request.readAsString();
    final data = jsonDecode(body);

    final updateData = <String, dynamic>{};
    if (data['title'] != null) updateData['title'] = data['title'];
    if (data['description'] != null) updateData['description'] = data['description'];
    if (data['completed'] != null) updateData['completed'] = data['completed'];

    if (updateData.isEmpty) {
      return Response.badRequest(
        body: jsonEncode({'success': false, 'message': 'No fields to update'}),
      );
    }

    final updatedTodo = await db.collection('todos').findAndModify(
      query: where.eq('todoId', int.parse(id)).eq('userId', ObjectId.fromHexString(userId)),
      update: updateData,
      returnNew: true, // Return the updated document
    );

    if (updatedTodo == null) {
      return Response.notFound(
        jsonEncode({'success': false, 'message': 'Todo item not found'}),
      );
    }

    return Response.ok(jsonEncode({
      'success': true,
      'message': 'Todo item updated successfully',
      'todo': updatedTodo, // ✅ Send the updated document
    }));
  } catch (e) {
    print(e);
    return Response.internalServerError(
      body: jsonEncode({'success': false, 'message': 'Error updating todo item'}),
    );
  }
}