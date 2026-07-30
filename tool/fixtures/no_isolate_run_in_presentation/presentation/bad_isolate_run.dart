import 'dart:isolate';

Future<void> runPresentationTask() async {
  await Isolate.run(() => 1);
}
