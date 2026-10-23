import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

/// Line splitter that rejects frames larger than [maxLineBytes].
///
/// Prevents a misbehaving child from unbounded-buffering the Flutter process.
final class BoundedNdjsonLineSplitter
    extends StreamTransformerBase<List<int>, String> {
  const new({this.maxLineBytes = 64 * 1024});

  final int maxLineBytes;

  @override
  Stream<String> bind(Stream<List<int>> stream) {
    late final StreamController<String> controller;
    StreamSubscription<List<int>>? subscription;
    final BytesBuilder buffer = BytesBuilder(copy: false);

    void fail(Object error, [StackTrace? stackTrace]) {
      if (!controller.isClosed) {
        controller.addError(error, stackTrace);
      }
      unawaited(subscription?.cancel());
    }

    controller = StreamController<String>(
      onListen: () {
        subscription = stream.listen(
          (chunk) {
            for (final int byte in chunk) {
              if (byte == 10 /* \n */ ) {
                final List<int> lineBytes = buffer.takeBytes();
                if (lineBytes.length > maxLineBytes) {
                  fail(
                    StateError(
                      'Agent NDJSON line exceeded $maxLineBytes bytes',
                    ),
                  );
                  return;
                }
                controller.add(utf8.decode(lineBytes));
                continue;
              }
              buffer.addByte(byte);
              if (buffer.length > maxLineBytes) {
                buffer.clear();
                fail(
                  StateError(
                    'Agent NDJSON line exceeded $maxLineBytes bytes '
                    '(unterminated)',
                  ),
                );
                return;
              }
            }
          },
          onError: fail,
          onDone: () {
            if (buffer.isNotEmpty) {
              final List<int> trailing = buffer.takeBytes();
              if (trailing.length > maxLineBytes) {
                fail(
                  StateError('Agent NDJSON line exceeded $maxLineBytes bytes'),
                );
                return;
              }
              controller.add(utf8.decode(trailing));
            }
            unawaited(controller.close());
          },
          cancelOnError: true,
        );
      },
      onCancel: () => subscription?.cancel(),
    );

    return controller.stream;
  }
}
