import 'package:flutter/foundation.dart';

Future<int> runPresentationTask() => compute(_work, 1);

int _work(int value) => value + 1;
