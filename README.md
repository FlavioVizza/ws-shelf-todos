![Banner](./assets/images/banner-shelf-api.png)

# Description:

RESTful APIs for managing todo lists, allowing users to create, read, update, and delete todo items, built with Dart, Shelf and MongoDB.

> This application is an alternative version of [ws-node-todos](https://github.com/FlavioVizza/ws-node-todos)

# Features:

- User authentication with JWT (JSON Web Tokens)
- CRUD operations for todo items
- Secure password hashing
- Swagger Documentation

# Technologies Used:

- **Dart SDK:** Tools to execute dart programs
- **Shelf:** Library to create http server application in dart
- **MongoDB:** NoSQL database
- **mongo_dart:** Dart library for MongoDB communication
- **shelf_swagger_ui:** To describe the structure of RESTful APIs 

# System Requirements:

Before running the application, make sure you have the following installed:

- Dart SDK (version: 3.7.0 or higher)
- MongoDB (local or remote)
- Docker (optional, for containerized deployment)

# Installation:

1. Clone the repository:

```bash
git clone https://github.com/FlavioVizza/ws-shelf-todos.git
```

2. Navigate to the project directory:

```bash
cd ws-shelf-todos
```

3. Install dependencies:

```bash
dart pub get
```

# Configuration:

You can edit the `config.dart` file or configure the following environment variables:

- `PORT`: Port number for the server (default is 8080)
- `TODOS_API_DB_URI`: MongoDB connection URI
- `ACCESS_TOKEN_SECRET`: Secret key for generating JWT access tokens
- `ACCESS_TOKEN_DURATION`: Duration for which access tokens are valid 
- `REFRESH_TOKEN_SECRET`: Secret key for generating JWT refresh tokens
- `REFRESH_TOKEN_DURATION`: Duration for which refresh tokens are valid

## MongoDB:

MongoDB can be configured by passing the connection string to the `TODOS_API_DB_URI` variable, and there are 2 options:

### 1. **Local**: 

Install MongoDB on your system.

Here's an example connection string for MongoDB running locally:
```bash
mongodb://localhost:27017/database_name
```

- `mongodb://`: Indicates that you are using MongoDB.
- `localhost`: Indicates that the MongoDB server is running on the same local machine.
- `27017`: Is the default port on which MongoDB listens for connections. Typically, it's the default port unless specified otherwise in the MongoDB configuration.
- `database_name`: Specifies the name of the database you want to connect to. You can replace "database_name" with the actual name of your database.


### 2. **MongoDB Atlas**: 

You can create an account on [MongoDB Atlas](https://www.mongodb.com/atlas/database) and follow the instructions to create a cluster and obtain the connection string.

Here's an example connection string for MongoDB:

```
mongodb+srv://username:password@clustername.mongodb.net/database_name
```

Here are the parts of the connection string:

- `mongodb+srv://`: Indicates that you are using MongoDB via the SRV protocol.
- `username:password`: Replace "username" with your username and "password" with your password to access MongoDB.
- `clustername.mongodb.net`: Replace "clustername" with the name of your MongoDB cluster.
- `database_name`: Specifies the name of the database you want to connect to. You can replace it with the name of your database.

# Usage:

### 1. Start the server:

```bash
dart run bin/server.dart
```

### 2. Use the following endpoints to interact with the Todos API:

- Register: `POST /api/auth/register`
- Login: `POST /api/auth/login`
- Refresh token: `POST /api/auth/refresh-token`

- Get todo list: `GET /api/todos`
- Get todo item: `GET /api/todos/:id`
- Create todo item: `POST /api/todos`
- Update todo item: `PUT /api/todos/:id`
- Delete todo item: `DELETE /api/todos/:id`

### 3. API documentation using Swagger

You can view the API documentation using Swagger by navigating to the following URL in your browser:
```bash
http://localhost:8080
```

## Docker Deployment:
To deploy the application using Docker, follow these steps:

Build the Docker image:
```
docker build -t ws-shelf-todos .
```

Run the Docker container:
```
docker run --name ws-todos -p 8080:8080 -d ws-shelf-todos
```

The application should now be accessible at http://localhost:8080

Now it will be possible to start and stop the Docker container with the following commands:

```sh
docker start ws-todos
```

```sh
docker stop ws-todos
```
