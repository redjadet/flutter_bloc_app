import 'dart:typed_data';

/// Extracts X.509 SubjectPublicKeyInfo (SPKI) DER from a leaf certificate DER.
///
/// Used for SHA-256 public-key pinning (survives leaf cert renewal when the
/// key pair is unchanged).
abstract final class CertificateSpkiExtractor {
  /// Returns the full DER encoding of `subjectPublicKeyInfo`, or `null` if
  /// the certificate cannot be parsed.
  static Uint8List? extract(final Uint8List certificateDer) {
    try {
      final _Asn1Reader reader = _Asn1Reader(certificateDer);
      final _Asn1Element cert = reader.readElement();
      if (cert.tag != _Asn1Reader.tagSequence) {
        return null;
      }
      final _Asn1Reader certBody = _Asn1Reader(cert.content);
      final _Asn1Element tbs = certBody.readElement();
      if (tbs.tag != _Asn1Reader.tagSequence) {
        return null;
      }
      return _extractSpkiFromTbs(tbs.content);
    } on FormatException {
      return null;
    }
  }

  static Uint8List? _extractSpkiFromTbs(final Uint8List tbsContent) {
    final _Asn1Reader reader = _Asn1Reader(tbsContent);
    // version [0] EXPLICIT is optional
    if (!reader.hasMore) {
      return null;
    }
    if (reader.peekTag() == _Asn1Reader.tagContext0Constructed) {
      reader.readElement(); // skip version
    }
    // serialNumber, signature, issuer, validity, subject
    for (var i = 0; i < 5; i++) {
      if (!reader.hasMore) {
        return null;
      }
      reader.readElement();
    }
    if (!reader.hasMore) {
      return null;
    }
    final _Asn1Element spki = reader.readElement();
    if (spki.tag != _Asn1Reader.tagSequence) {
      return null;
    }
    // Return full TLV (tag + length + content), not content alone.
    return spki.tlv;
  }
}

final class _Asn1Element {
  const _Asn1Element({
    required this.tag,
    required this.content,
    required this.tlv,
  });

  final int tag;
  final Uint8List content;
  final Uint8List tlv;
}

final class _Asn1Reader {
  _Asn1Reader(this._bytes) : _offset = 0;

  static const int tagSequence = 0x30;
  static const int tagContext0Constructed = 0xa0;

  final Uint8List _bytes;
  int _offset;

  bool get hasMore => _offset < _bytes.length;

  int peekTag() {
    if (!hasMore) {
      throw const FormatException('ASN.1: unexpected end of data');
    }
    return _bytes[_offset];
  }

  _Asn1Element readElement() {
    final int start = _offset;
    if (!hasMore) {
      throw const FormatException('ASN.1: unexpected end of data');
    }
    final int tag = _bytes[_offset++];
    if ((_offset) >= _bytes.length) {
      throw const FormatException('ASN.1: missing length');
    }
    final int firstLen = _bytes[_offset++];
    late final int length;
    if (firstLen & 0x80 == 0) {
      length = firstLen;
    } else {
      final int numBytes = firstLen & 0x7f;
      if (numBytes == 0 || numBytes > 4) {
        throw const FormatException('ASN.1: unsupported length form');
      }
      if (_offset + numBytes > _bytes.length) {
        throw const FormatException('ASN.1: truncated length');
      }
      var value = 0;
      for (var i = 0; i < numBytes; i++) {
        value = (value << 8) | _bytes[_offset++];
      }
      length = value;
    }
    if (_offset + length > _bytes.length) {
      throw const FormatException('ASN.1: truncated content');
    }
    final Uint8List content = Uint8List.sublistView(
      _bytes,
      _offset,
      _offset + length,
    );
    _offset += length;
    final Uint8List tlv = Uint8List.sublistView(_bytes, start, _offset);
    return _Asn1Element(tag: tag, content: content, tlv: tlv);
  }
}
