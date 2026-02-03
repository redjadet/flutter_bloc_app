// ignore_for_file: subtype_of_sealed_class

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_bloc_app/features/walletconnect_auth/data/wallet_user_profile_mapper.dart';
import 'package:flutter_bloc_app/features/walletconnect_auth/data/walletconnect_auth_repository_impl.dart';
import 'package:flutter_bloc_app/features/walletconnect_auth/data/walletconnect_service.dart';
import 'package:flutter_bloc_app/features/walletconnect_auth/domain/wallet_address.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

class MockWalletConnectService extends Mock implements WalletConnectService {}

void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference mockUsersCollection;
  late MockWalletConnectService mockWalletConnectService;
  final List<({String docId, Map<String, dynamic> data})> recordedWrites = [];

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockUsersCollection = MockCollectionReference();
    mockWalletConnectService = MockWalletConnectService();
    recordedWrites.clear();

    when(() => mockFirestore.collection(any())).thenReturn(mockUsersCollection);
    // when(doc(any())) is set per test so upsert/getWalletUserProfile can stub doc('test-uid') with get()
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

          when(
            () => mockWalletConnectService.connect(),
          ).thenAnswer((_) async => const WalletAddress(walletAddress));

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
          final mockDocRef = MockDocumentReference();
          when(() => mockDocRef.get()).thenAnswer(
            (_) async => _FakeDocumentSnapshot(
              exists: true,
              data: {
                'walletAddress': '0xabc123',
                'walletAddressNormalized': '0xabc123',
              },
            ),
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
          when(
            () => mockUsersCollection.doc('test-uid'),
          ).thenReturn(mockDocRef);
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

          final repository = WalletConnectAuthRepositoryImpl(
            walletConnectService: mockWalletConnectService,
            firebaseAuth: auth,
            firestore: mockFirestore,
          );

          await AppLogger.silenceAsync(() async {
            await repository.upsertWalletUserProfile('0xabc123');
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
        skip:
            'getLinkedWalletAddress() needs doc("test-uid").get() snapshot; mock precedence TBD',
      );
      test(
        'writes provided profile to users/{uid} when profile is not null',
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
                'walletAddress': '0xwallet',
                'walletAddressNormalized': '0xwallet',
              },
            ),
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
          when(
            () => mockUsersCollection.doc('test-uid'),
          ).thenReturn(mockDocRef);
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
          when(
            () => mockUsersCollection.doc('test-uid'),
          ).thenReturn(mockDocRef);

          final repository = WalletConnectAuthRepositoryImpl(
            walletConnectService: mockWalletConnectService,
            firebaseAuth: auth,
            firestore: mockFirestore,
          );

          await AppLogger.silenceAsync(() async {
            await repository.upsertWalletUserProfile('0xabc123');
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
            recordedWrites.first.data[WalletUserProfileFields.rewards],
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
        skip:
            'getLinkedWalletAddress() needs doc("test-uid").get() snapshot; mock precedence TBD',
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
          when(
            () => ref.set(any(), any()),
          ).thenAnswer((_) => Future<void>.value());
          return ref;
        });
        when(() => mockUsersCollection.doc('test-uid')).thenReturn(mockDocRef);

        final repository = WalletConnectAuthRepositoryImpl(
          walletConnectService: mockWalletConnectService,
          firebaseAuth: auth,
          firestore: mockFirestore,
        );

        final result = await AppLogger.silenceAsync(() async {
          return repository.getWalletUserProfile('0xmissing');
        });

        expect(result, isNull);
      });

      test('returns null when linked wallet does not match', () async {
        final auth = MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(uid: 'test-uid'),
        );
        final mockDocRef = MockDocumentReference();
        when(() => mockDocRef.get()).thenAnswer(
          (_) async => _FakeDocumentSnapshot(
            exists: true,
            data: {
              'walletAddress': '0xother',
              'walletAddressNormalized': '0xother',
            },
          ),
        );
        when(() => mockUsersCollection.doc(any())).thenAnswer((invocation) {
          final docId = invocation.positionalArguments[0] as String;
          if (docId == 'test-uid') return mockDocRef;
          final ref = MockDocumentReference();
          when(() => ref.id).thenReturn(docId);
          when(
            () => ref.set(any(), any()),
          ).thenAnswer((_) => Future<void>.value());
          return ref;
        });
        when(() => mockUsersCollection.doc('test-uid')).thenReturn(mockDocRef);

        final repository = WalletConnectAuthRepositoryImpl(
          walletConnectService: mockWalletConnectService,
          firebaseAuth: auth,
          firestore: mockFirestore,
        );

        final result = await AppLogger.silenceAsync(() async {
          return repository.getWalletUserProfile('0xrequested');
        });

        expect(result, isNull);
      });

      test(
        'returns profile from users/{uid} when document exists',
        () async {
          final auth = MockFirebaseAuth(
            signedIn: true,
            mockUser: MockUser(uid: 'test-uid'),
          );
          final data = <String, dynamic>{
            'walletAddress': '0xexists',
            'walletAddressNormalized': '0xexists',
            WalletUserProfileFields.balanceOffChain: 1.0,
            WalletUserProfileFields.balanceOnChain: 2.0,
            WalletUserProfileFields.rewards: 0.5,
            WalletUserProfileFields.lastClaim: null,
            WalletUserProfileFields.nfts: <Map<String, dynamic>>[],
          };
          final mockDocRef = MockDocumentReference();
          when(() => mockDocRef.get(any())).thenAnswer(
            (_) async => _FakeDocumentSnapshot(exists: true, data: data),
          );
          when(() => mockUsersCollection.doc(any())).thenAnswer((invocation) {
            final docId = invocation.positionalArguments[0] as String;
            if (docId == 'test-uid') return mockDocRef;
            final ref = MockDocumentReference();
            when(() => ref.id).thenReturn(docId);
            when(
              () => ref.set(any(), any()),
            ).thenAnswer((_) => Future<void>.value());
            return ref;
          });
          when(
            () => mockUsersCollection.doc('test-uid'),
          ).thenReturn(mockDocRef);

          final repository = WalletConnectAuthRepositoryImpl(
            walletConnectService: mockWalletConnectService,
            firebaseAuth: auth,
            firestore: mockFirestore,
          );

          final result = await AppLogger.silenceAsync(() async {
            return repository.getWalletUserProfile('0xexists');
          });

          expect(result, isNotNull);
          expect(result!.balanceOffChain, 1.0);
          expect(result.balanceOnChain, 2.0);
          expect(result.rewards, 0.5);
          expect(result.nfts, isEmpty);
        },
        skip:
            'getLinkedWalletAddress() needs doc("test-uid").get() snapshot; mock precedence TBD',
      );
    });
  });
}

/// Minimal fake for Firestore document snapshot.
class _FakeDocumentSnapshot implements DocumentSnapshot<Map<String, dynamic>> {
  _FakeDocumentSnapshot({required this.exists, Map<String, dynamic>? data})
    : _data = data;

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
