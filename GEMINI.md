# GEMINI — Flutter BLoC App

This document outlines the guidelines for interacting with Gemini, the AI assistant, for the Flutter BLoC App.

## Gemini's Role

Gemini is here to help you with a variety of tasks, including:

* Answering questions about the codebase
* Implementing new features
* Fixing bugs
* Refactoring code
* Writing tests

## Interaction Guidelines

* **Be specific:** The more specific you are with your requests, the better Gemini will be able to understand and help you.
* **Provide context:** When asking for help with a specific piece of code, provide as much context as possible, including the file path and the relevant code snippets.
* **One task at a time:** It's best to focus on one task at a time. This will help Gemini to stay focused and provide you with the best possible assistance.

## Architecture Guidelines

* **Clean Architecture:** The project follows the principles of Clean Architecture. This means that the code is separated into three layers: Domain, Data, and Presentation.
* **MVP:** The project uses the Model-View-Presenter (MVP) pattern. Widgets are the View, Cubits are the Presenter, and Repositories/Models are the Model.
* **SOLID & Clean Code:** The project follows the SOLID principles and Clean Code best practices. This means that the code is well-organized, easy to read, and easy to maintain.

## Testing Guidelines

* **`bloc_test`:** Use the `bloc_test` package for testing Blocs and Cubits.
* **Widget/golden tests:** Use widget and golden tests to prevent UI regressions.
* **Mocking:** Use the `mockito` package for mocking dependencies.

## Important Commands

```bash
flutter pub get
dart format .
flutter analyze
flutter test
dart run tool/update_coverage_summary.dart
dart run build_runner build --delete-conflicting-outputs
flutter run
```
