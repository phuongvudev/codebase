---
name: flutter-use-dio-retrofit
description: Use Dio and Retrofit for type-safe networking in Flutter. Use when building a production-ready networking layer with code generation and interceptors.
metadata:
  model: models/gemini-3.1-pro-preview
  last_modified: Wed, 12 Jun 2024 14:00:00 GMT
---
# Networking with Dio and Retrofit

## Contents
- [Dependencies](#dependencies)
- [Defining Data Models](#defining-data-models)
- [Defining the API Client](#defining-the-api-client)
- [Configuring Dio](#configuring-dio)
- [Handling Large Payloads (Background Parsing)](#handling-large-payloads-background-parsing)
- [File Uploads (Multipart Requests)](#file-uploads-multipart-requests)
- [Code Generation](#code-generation)
- [Workflow](#workflow)
- [Example](#example)

## Dependencies

Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  dio: ^5.5.0
  retrofit: ^4.1.0
  json_annotation: ^4.9.0

dev_dependencies:
  retrofit_generator: ^8.1.0
  json_serializable: ^6.8.0
  build_runner: ^2.4.9
```

## Defining Data Models

Use `json_serializable` for automated JSON parsing.

```dart
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class User {
  final int id;
  final String name;

  User({required this.id, required this.name});

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
```

## Defining the API Client

Retrofit uses interfaces and annotations to generate networking code.

```dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'user_model.dart';

part 'api_client.g.dart';

@RestApi(baseUrl: "https://api.example.com/")
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;

  @GET("/users")
  Future<List<User>> getUsers();

  // Multi-part file upload
  @POST("/upload")
  @MultiPart()
  Future<String> uploadFile({
    @Part(name: "file") required File file,
    @Part(name: "description") String? description,
  });
}
```

## Configuring Dio

Centralize Dio configuration with interceptors for logging and error handling.

```dart
final dio = Dio(BaseOptions(
  connectTimeout: const Duration(seconds: 5),
  receiveTimeout: const Duration(seconds: 3),
));

dio.interceptors.add(LogInterceptor(responseBody: true));
```

## Handling Large Payloads (Background Parsing)

To avoid UI jank when parsing large JSON responses, offload the processing to a background Isolate.

### 1. Built-in BackgroundTransformer
For simple background parsing of JSON responses:

```dart
dio.transformer = BackgroundTransformer();
```

### 2. Manual Isolate Parsing
For maximum control or when combining parsing with model mapping:

```dart
Future<List<User>> fetchLargeUserList() async {
  final response = await dio.get<String>(
    '/large-users',
    options: Options(responseType: ResponseType.plain),
  );

  return await Isolate.run(() {
    final List<dynamic> list = jsonDecode(response.data!);
    return list.map((item) => User.fromJson(item)).toList();
  });
}
```

## File Uploads (Multipart Requests)

Retrofit simplifies multipart requests using `@MultiPart` and `@Part`.

### Single File Upload
```dart
Future<void> upload(File file) async {
  final response = await apiClient.uploadFile(
    file: file,
    description: "User Profile Image",
  );
}
```

### Multiple Files
Use `List<MultipartFile>` for multiple files:
```dart
@POST("/upload-multiple")
@MultiPart()
Future<void> uploadMultiple(@Part(name: "files") List<MultipartFile> files);
```

## Code Generation

Run the following command to generate `.g.dart` files:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Workflow

### Task Progress
- [ ] **Step 1: Add dependencies.** Update `pubspec.yaml` and run `flutter pub get`.
- [ ] **Step 2: Define Domain/Data Models.** Create models using `json_serializable`.
- [ ] **Step 3: Define the API Interface.** Create the abstract class with `@RestApi` and methods.
- [ ] **Step 4: Run Code Generation.** Execute `build_runner`.
- [ ] **Step 5: Configure Dio.** Initialize `Dio` with necessary options, interceptors, and optionally `BackgroundTransformer`.
- [ ] **Step 6: Integrate with Repository.** Inject the `ApiClient` into your repositories.

## Example

### Repository Integration with Error Handling

```dart
class UserRepository {
  final ApiClient _apiClient;

  UserRepository(this._apiClient);

  Future<List<User>> getAllUsers() async {
    try {
      return await _apiClient.getUsers();
    } on DioException catch (e) {
      // Handle networking errors specifically
      throw Exception("Failed to load users: ${e.message}");
    }
  }
}
```
