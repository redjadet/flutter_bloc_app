/// Deferred library for Markdown Editor feature.
///
/// This library is loaded on-demand to reduce initial app bundle size.
/// The markdown package parser is heavy and only needed when the user
/// navigates to the markdown editor page.
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc_app/features/example/presentation/pages/markdown_editor_page.dart';

/// Builds the Markdown Editor page.
///
/// This function is called after the deferred library is loaded.
/// It returns the markdown editor page widget.
Widget buildMarkdownEditorPage() => const MarkdownEditorPage();
