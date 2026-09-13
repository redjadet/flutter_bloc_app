// ignore_for_file: subtype_of_sealed_class

import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_bloc_app/features/walletconnect_auth/data/wallet_user_profile_mapper.dart';
import 'package:flutter_bloc_app/features/walletconnect_auth/data/walletconnect_auth_repository_impl.dart';
import 'package:flutter_bloc_app/features/walletconnect_auth/data/walletconnect_service.dart';
import 'package:flutter_bloc_app/features/walletconnect_auth/domain/wallet_address.dart';
import 'package:flutter_bloc_app/features/walletconnect_auth/domain/wallet_user_profile.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

class MockWalletConnectService extends Mock implements WalletConnectService {}

/// Valid Ethereum-style address used by upsert / profile read tests.
const String _kLinkedWallet = '0xabcdef1234567890123456789012345678901234';

void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference mockUsersCollection;
  late MockWalletConnectService mockWalletConnectService;
  final List<({String docId, Map<String, dynamic> data})> recordedWrites = [];

  /// Stubs `users/{test-uid}` with [linkedData] for get() and records set() writes.
  MockDocumentReference stubLinkedUserDoc({
    required Map<String, dynamic> linkedData,
  }) {
    final MockDocumentReference mockDocRef = MockDocumentReference();
    when(() => mockDocRef.get()).thenAnswer(
      (_) async => _FakeDocumentSnapshot(exists: true, data: linkedData),
    );
    when(() => mockDocRef.get(any())).thenAnswer(
      (_) async => _FakeDocumentSnapshot(exists: true, data: linkedData),
    );
    when(() => mockDocRef.id).thenReturn('test-uid');
    when(() => mockDocRef.set(any(), any())).thenAnswer((i) {
      recordedWrites.add((
        docId: 'test-uid',
        data: Map<String, dynamic>.from(
          i.positionalArguments[0] as Map<String, dynamic>,
        ),
      ));
      return Future<void>.value();
    });
    when(() => mockUsersCollection.doc(any())).thenAnswer((invocation) {
      final docId = invocation.positionalArguments[0] as String;
      if (docId == 'test-uid') return mockDocRef;
      final ref = MockDocumentReference();
      when(() => ref.id).thenReturn(docId);
      when(() => ref.set(any(), any())).thenAnswer((i) {
        final data = i.positionalArguments[0] as Map<String, dynamic>;
        recordedWrites.add((
          docId: docId,
          data: Map<String, dynamic>.from(data),
        ));
        return Future<void>.value();
      });
      return ref;
    });
    when(() => mockUsersCollection.doc('test-uid')).thenReturn(mockDocRef);
    return mockDocRef;
  }

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockUsersCollection = MockCollectionReference();
    mockWalletConnectService = MockWalletConnectService();
    recordedWrites.clear();

    when(() => mockFirestore.collection(any())).thenReturn(mockUsersCollection);
  });

  group('WalletConnectAuthRepositoryImpl', () {
    group('linkWalletToFirebaseUser', () {
      test(
        'writes single users/{uid} doc with linkage and profile fields',
        () async {
          const walletAddress = '0xABCDEF1234567890123456789012345678901234';
          const normalizedWallet = '0xabcdef1234567890123456789012345678901234';
          final auth = MockFirebaseAuth(
            signedIn: true,
            mockUser: MockUser(uid: 'test-uid'),
          );

          when(() => mockUsersCollection.doc(any())).thenAnswer((invocation) {
            final docId = invocation.positionalArguments[0] as String;
            final ref = MockDocumentReference();
            when(() => ref.id).thenReturn(docId);
            when(() => ref.set(any(), any())).thenAnswer((i) {
              final data = i.positionalArguments[0] as Map<String, dynamic>;
              recordedWrites.add((
                docId: docId,
                data: Map<String, dynamic>.from(data),
              ));
              return Future<void>.value();
            });
            return ref;
          });

          when(() => mockWalletConnectService.connect())
              .thenAnswer((_) async => const WalletAddress(walletAddress));

          final repository = WalletConnectAuthRepositoryImpl(
            walletConnectService: mockWalletConnectService,
            firebaseAuth: auth,
            firestore: mockFirestore,
          );

          await AppLogger.silenceAsync(() async {
            await repository.linkWalletToFirebaseUser(walletAddress);
          });

          expect(recordedWrites, hasLength(1));
          final uidWrite = recordedWrites.first;
          expect(uidWrite.docId, 'test-uid');
          expect(uidWrite.data['walletAddress'], walletAddress);
          expect(uidWrite.data['walletAddressNormalized'], normalizedWallet);
          expect(uidWrite.data.containsKey('connectedAt'), isTrue);
          expect(uidWrite.data[WalletUserProfileFields.balanceOffChain], 0.0);
          expect(uidWrite.data[WalletUserProfileFields.balanceOnChain], 0.0);
          expect(uidWrite.data[WalletUserProfileFields.rewards], 0.0);
          expect(uidWrite.data[WalletUserProfileFields.nfts], isEmpty);
          expect(
            uidWrite.data.containsKey(WalletUserProfileFields.updatedAt),
            isTrue,
          );
        },
      );
    });

    group('upsertWalletUserProfile', () {
      test(
        'writes default profile to users/{uid} when profile is null',
        () async {
          final auth = MockFirebaseAuth(
            signedIn: true,
            mockUser: MockUser(uid: 'test-uid'),
          );
          stubLinkedUserDoc(
            linkedData: <String, dynamic>{
              'walletAddress': _kLinkedWallet,
              'walletAddressNormalized': _kLinkedWallet,
            },
          );

          final repository = WalletConnectAuthRepositoryImpl(
            walletConnectService: mockWalletConnectService,
            firebaseAuth: auth,
            firestore: mockFirestore,
          );

          await AppLogger.silenceAsync(() async {
            await repository.upsertWalletUserProfile(_kLinkedWallet);
          });

          expect(recordedWrites, hasLength(1));
          expect(recordedWrites.first.docId, 'test-uid');
          expect(
            recordedWrites.first.data[WalletUserProfileFields.balanceOffChain],
            0.0,
          );
          expect(
            recordedWrites.first.data[WalletUserProfileFields.balanceOnChain],
            0.0,
          );
          expect(
            recordedWrites.first.data[WalletUserProfileFields.lastClaim],
            isNull,
          );
          expect(
            recordedWrites.first.data[WalletUserProfileFields.nfts],
            isEmpty,
          );
        },
      );
      test(
        'writes provided profile to users/{uid} when profile is not null',
        () async {
          final auth = MockFirebaseAuth(
            signedIn: true,
            mockUser: MockUser(uid: 'test-uid'),
          );
          stubLinkedUserDoc(
            linkedData: <String, dynamic>{
              'walletAddress': _kLinkedWallet,
              'walletAddressNormalized': _kLinkedWallet,
            },
          );

          final repository = WalletConnectAuthRepositoryImpl(
            walletConnectService: mockWalletConnectService,
            firebaseAuth: auth,
            firestore: mockFirestore,
          );

          const WalletUserProfile profile = WalletUserProfile(
            balanceOffChain: 10.0,
            balanceOnChain: 20.0,
            rewards: 3.0,
          );

          await AppLogger.silenceAsync(() async {
            await repository.upsertWalletUserProfile(
              _kLinkedWallet,
              profile: profile,
            );
          });

          expect(recordedWrites, hasLength(1));
          expect(recordedWrites.first.docId, 'test-uid');
          expect(
            recordedWrites.first.data[WalletUserProfileFields.balanceOffChain],
            10.0,
          );
          expect(
            recordedWrites.first.data[WalletUserProfileFields.balanceOnChain],
            20.0,
          );
          expect(
            recordedWrites.first.data[WalletUserProfileFields.rewards],
            3.0,
          );
          expect(
            recordedWrites.first.data[WalletUserProfileFields.lastClaim],
            isNull,
          );
          expect(
            recordedWrites.first.data[WalletUserProfileFields.nfts],
            isEmpty,
          );
        },
      );
    });

    group('getWalletUserProfile', () {
      test('returns null when document does not exist', () async {
        final auth = MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(uid: 'test-uid'),
        );
        final mockDocRef = MockDocumentReference();
        when(() => mockDocRef.get()).thenAnswer(
          (_) async => _FakeDocumentSnapshot(exists: false, data: null),
        );
        when(() => mockUsersCollection.doc(any())).thenAnswer((invocation) {
          final docId = invocation.positionalArguments[0] as String;
          if (docId == 'test-uid') return mockDocRef;
          final ref = MockDocumentReference();
          when(() => ref.id).thenReturn(docId);
          when(() => ref.set(any(), any()))
              .thenAnswer((_) => Future<void>.value());
          return ref;
        });
        when(() => mockUsersCollection.doc('test-uid')).thenReturn(mockDocRef);

        final repository = WalletConnectAuthRepositoryImpl(
          walletConnectService: mockWalletConnectService,
          firebaseAuth: auth,
          firestore: mockFirestore,
        );

        final result = await AppLogger.silenceAsync(() async {
          return repository.getWalletUserProfile(_kLinkedWallet);
        });

        expect(result, isNull);
      });

      test(
        'returns null when requested wallet is not linked to current user',
        () async {
          final auth = MockFirebaseAuth(
            signedIn: true,
            mockUser: MockUser(uid: 'test-uid'),
          );
          final mockDocRef = MockDocumentReference();
          when(() => mockDocRef.get()).thenAnswer(
            (_) async => _FakeDocumentSnapshot(
              exists: true,
              data: {
                'walletAddress': '0xother012345678901234567890123456789012',
                'walletAddressNormalized':
                    '0xother012345678901234567890123456789012',
              },
            ),
          );
          when(() => mockUsersCollection.doc(any())).thenAnswer((invocation) {
            final docId = invocation.positionalArguments[0] as String;
            if (docId == 'test-uid') return mockDocRef;
            final ref = MockDocumentReference();
            when(() => ref.id).thenReturn(docId);
            when(() => ref.set(any(), any()))
                .thenAnswer((_) => Future<void>.value());
            return ref;
          });
          when(() => mockUsersCollection.doc('test-uid'))
              .thenReturn(mockDocRef);

          final repository = WalletConnectAuthRepositoryImpl(
            walletConnectService: mockWalletConnectService,
            firebaseAuth: auth,
            firestore: mockFirestore,
          );

          final result = await AppLogger.silenceAsync(() async {
            return repository.getWalletUserProfile(_kLinkedWallet);
          });

          expect(result, isNull);
        },
      );

      test('returns profile from users/{uid} when document exists', () async {
        final auth = MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(uid: 'test-uid'),
        );
        final data = <String, dynamic>{
          'walletAddress': _kLinkedWallet,
          'walletAddressNormalized': _kLinkedWallet,
          WalletUserProfileFields.balanceOffChain: 1.0,
          WalletUserProfileFields.balanceOnChain: 2.0,
          WalletUserProfileFields.rewards: 0.5,
          WalletUserProfileFields.lastClaim: null,
          WalletUserProfileFields.nfts: <Map<String, dynamic>>[],
        };
        stubLinkedUserDoc(linkedData: data);

        final repository = WalletConnectAuthRepositoryImpl(
          walletConnectService: mockWalletConnectService,
          firebaseAuth: auth,
          firestore: mockFirestore,
        );

        final result = await AppLogger.silenceAsync(() async {
          return repository.getWalletUserProfile(_kLinkedWallet);
        });

        expect(result, isNotNull);
        expect(result!.balanceOffChain, 1.0);
        expect(result.balanceOnChain, 2.0);
        expect(result.rewards, 0.5);
        expect(result.nfts, isEmpty);
      });
    });
  });
}

/// Minimal fake for Firestore document snapshot.
class _FakeDocumentSnapshot implements DocumentSnapshot<Map<String, dynamic>> {
  _FakeDocumentSnapshot({required this.exists, this._data});

  @override
  final bool exists;

  final Map<String, dynamic>? _data;

  @override
  Map<String, dynamic>? data() => _data;

  @override
  String get id => '';

  @override
  DocumentReference<Map<String, dynamic>> get reference =>
      throw UnimplementedError();

  @override
  SnapshotMetadata get metadata => throw UnimplementedError();

  @override
  dynamic operator [](Object? fieldPath) =>
      _data != null && fieldPath is String ? _data[fieldPath] : null;

  @override
  dynamic get(Object? fieldPath) =>
      _data != null && fieldPath is String ? _data[fieldPath] : null;
}
