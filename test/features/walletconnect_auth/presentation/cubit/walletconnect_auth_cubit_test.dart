import 'package:flutter_bloc_app/features/walletconnect_auth/domain/wallet_address.dart';
import 'package:flutter_bloc_app/features/walletconnect_auth/domain/walletconnect_auth_repository.dart';
import 'package:flutter_bloc_app/features/walletconnect_auth/presentation/cubit/walletconnect_auth_cubit.dart';
import 'package:flutter_bloc_app/features/walletconnect_auth/presentation/cubit/walletconnect_auth_state.dart';
import 'package:flutter_bloc_app/shared/ui/view_status.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockWalletConnectAuthRepository extends Mock
    implements WalletConnectAuthRepository {}

void main() {
  late MockWalletConnectAuthRepository mockRepository;
  late WalletConnectAuthCubit cubit;

  setUp(() {
    mockRepository = MockWalletConnectAuthRepository();
    cubit = WalletConnectAuthCubit(repository: mockRepository);
  });

  tearDown(() {
    cubit.close();
  });

  test('initial state is correct', () {
    expect(
      cubit.state,
      const WalletConnectAuthState(
        status: ViewStatus.initial,
        walletAddress: null,
        linkedWalletAddress: null,
        errorMessage: null,
      ),
    );
  });

  group('loadLinkedWallet', () {
    test('loads linked wallet address successfully', () async {
      const address = WalletAddress(
        '0x1234567890123456789012345678901234567890',
      );
      when(
        () => mockRepository.getLinkedWalletAddress(),
      ).thenAnswer((_) async => address);

      await cubit.loadLinkedWallet();

      expect(cubit.state.linkedWalletAddress, address);
      expect(cubit.state.status, ViewStatus.success);
      expect(cubit.state.errorMessage, isNull);
    });

    test('handles no linked wallet', () async {
      when(
        () => mockRepository.getLinkedWalletAddress(),
      ).thenAnswer((_) async => null);

      await cubit.loadLinkedWallet();

      expect(cubit.state.linkedWalletAddress, isNull);
      expect(cubit.state.status, ViewStatus.success);
    });

    test('handles error', () async {
      when(
        () => mockRepository.getLinkedWalletAddress(),
      ).thenThrow(Exception('Failed to load'));

      await cubit.loadLinkedWallet();

      expect(cubit.state.status, ViewStatus.error);
      expect(cubit.state.errorMessage, isNotNull);
    });
  });

  group('connectWallet', () {
    test('connects wallet successfully', () async {
      const address = WalletAddress(
        '0x1234567890123456789012345678901234567890',
      );
      when(
        () => mockRepository.connectWallet(),
      ).thenAnswer((_) async => address);

      await cubit.connectWallet();

      expect(cubit.state.walletAddress, address);
      expect(cubit.state.status, ViewStatus.success);
      expect(cubit.state.errorMessage, isNull);
    });

    test('handles connection error', () async {
      when(
        () => mockRepository.connectWallet(),
      ).thenThrow(const WalletConnectException('Connection failed'));

      await cubit.connectWallet();

      expect(cubit.state.walletAddress, isNull);
      expect(cubit.state.status, ViewStatus.error);
      expect(cubit.state.errorMessage, isNotNull);
    });
  });

  group('linkWalletToUser', () {
    test('links wallet successfully', () async {
      const connectedAddress = WalletAddress(
        '0x1234567890123456789012345678901234567890',
      );
      const linkedAddress = WalletAddress(
        '0x1234567890123456789012345678901234567890',
      );

      // First connect
      when(
        () => mockRepository.connectWallet(),
      ).thenAnswer((_) async => connectedAddress);
      await cubit.connectWallet();

      // Then link
      when(
        () => mockRepository.linkWalletToFirebaseUser(any()),
      ).thenAnswer((_) async {});
      when(
        () => mockRepository.getLinkedWalletAddress(),
      ).thenAnswer((_) async => linkedAddress);

      await cubit.linkWalletToUser();

      expect(cubit.state.linkedWalletAddress, linkedAddress);
      expect(cubit.state.status, ViewStatus.success);
    });

    test('handles error when no wallet connected', () async {
      await cubit.linkWalletToUser();

      expect(cubit.state.status, ViewStatus.error);
      expect(cubit.state.errorMessage, contains('No wallet connected'));
    });

    test('handles linking error', () async {
      const address = WalletAddress(
        '0x1234567890123456789012345678901234567890',
      );
      when(
        () => mockRepository.connectWallet(),
      ).thenAnswer((_) async => address);
      await cubit.connectWallet();

      when(
        () => mockRepository.linkWalletToFirebaseUser(any()),
      ).thenThrow(const WalletConnectException('Linking failed'));

      await cubit.linkWalletToUser();

      expect(cubit.state.status, ViewStatus.error);
      expect(cubit.state.errorMessage, isNotNull);
    });
  });

  group('disconnectWallet', () {
    test('disconnects wallet successfully', () async {
      when(() => mockRepository.disconnectWallet()).thenAnswer((_) async {});

      await cubit.disconnectWallet();

      expect(cubit.state.walletAddress, isNull);
      expect(cubit.state.status, ViewStatus.initial);
    });
  });

  group('clearError', () {
    test('clears error message', () {
      cubit.emit(
        const WalletConnectAuthState(
          status: ViewStatus.error,
          errorMessage: 'Test error',
        ),
      );

      cubit.clearError();

      expect(cubit.state.errorMessage, isNull);
    });

    test('does nothing if no error', () {
      final initialState = cubit.state;
      cubit.clearError();
      expect(cubit.state, initialState);
    });
  });
}
