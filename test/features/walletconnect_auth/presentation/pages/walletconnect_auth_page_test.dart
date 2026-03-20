import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/walletconnect_auth/domain/nft_metadata.dart';
import 'package:flutter_bloc_app/features/walletconnect_auth/domain/wallet_address.dart';
import 'package:flutter_bloc_app/features/walletconnect_auth/domain/wallet_user_profile.dart';
import 'package:flutter_bloc_app/features/walletconnect_auth/presentation/cubit/walletconnect_auth_cubit.dart';
import 'package:flutter_bloc_app/features/walletconnect_auth/presentation/cubit/walletconnect_auth_state.dart';
import 'package:flutter_bloc_app/features/walletconnect_auth/presentation/pages/walletconnect_auth_page.dart';
import 'package:flutter_bloc_app/features/walletconnect_auth/presentation/widgets/connect_wallet_button.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/l10n/app_localizations_en.dart';
import 'package:flutter_bloc_app/shared/ui/view_status.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockWalletConnectAuthCubit extends MockCubit<WalletConnectAuthState>
    implements WalletConnectAuthCubit {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WalletConnectAuthPage', () {
    late _MockWalletConnectAuthCubit cubit;

    setUp(() {
      cubit = _MockWalletConnectAuthCubit();
      when(() => cubit.connectWallet()).thenAnswer((_) async {});
      when(() => cubit.linkWalletToUser()).thenAnswer((_) async {});
      when(() => cubit.relinkWalletToUser()).thenAnswer((_) async {});
      when(() => cubit.disconnectWallet()).thenAnswer((_) async {});
      when(() => cubit.clearError()).thenReturn(null);
      when(() => cubit.close()).thenAnswer((_) async {});
    });

    testWidgets('shows connect action for initial state', (
      final WidgetTester tester,
    ) async {
      const WalletConnectAuthState state = WalletConnectAuthState();
      _stubState(cubit, state);

      await tester.pumpWidget(_buildTestApp(cubit));

      final Finder connectLabel = find.descendant(
        of: find.byType(ConnectWalletButton),
        matching: find.text(AppLocalizationsEn().connectWalletButton),
      );

      expect(connectLabel, findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      await tester.tap(connectLabel);
      await tester.pump();

      verify(() => cubit.connectWallet()).called(1);
    });

    testWidgets('shows linked wallet profile, actions, and dismissible error', (
      final WidgetTester tester,
    ) async {
      final WalletConnectAuthState state = WalletConnectAuthState(
        status: ViewStatus.success,
        walletAddress: _walletAddress,
        linkedWalletAddress: _walletAddress,
        errorMessage: 'Profile sync failed',
        userProfile: const WalletUserProfile(
          balanceOffChain: 12.5,
          balanceOnChain: 3.25,
          rewards: 7.0,
          nfts: <NftMetadata>[
            NftMetadata(
              contractAddress: '0xabc',
              tokenId: '1',
              name: 'Genesis',
              imageUrl: 'https://example.com/1.png',
            ),
            NftMetadata(
              contractAddress: '0xdef',
              tokenId: '2',
              name: 'Legend',
              imageUrl: 'https://example.com/2.png',
            ),
          ],
        ),
      );
      _stubState(cubit, state);

      await tester.pumpWidget(_buildTestApp(cubit));

      expect(find.text('Profile sync failed'), findsOneWidget);
      expect(find.text(AppLocalizationsEn().walletLinked), findsOneWidget);
      expect(
        find.text(AppLocalizationsEn().walletProfileSection),
        findsOneWidget,
      );
      expect(find.text(_walletAddress.truncated), findsOneWidget);
      expect(find.text('12.50'), findsOneWidget);
      expect(find.text('3.25'), findsOneWidget);
      expect(find.text('7.00'), findsOneWidget);
      expect(find.text(AppLocalizationsEn().lastClaimNever), findsOneWidget);
      expect(find.text(AppLocalizationsEn().nftsCount(2)), findsOneWidget);
      expect(find.text(AppLocalizationsEn().relinkToAccount), findsOneWidget);
      expect(find.text(AppLocalizationsEn().disconnectWallet), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      verify(() => cubit.clearError()).called(1);
    });

    testWidgets('shows loading state for linked wallet without relink button', (
      final WidgetTester tester,
    ) async {
      final WalletConnectAuthState state = WalletConnectAuthState(
        status: ViewStatus.loading,
        walletAddress: _walletAddress,
        linkedWalletAddress: _walletAddress,
      );
      _stubState(cubit, state);

      await tester.pumpWidget(_buildTestApp(cubit));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text(AppLocalizationsEn().relinkToAccount), findsNothing);
      expect(find.text(AppLocalizationsEn().disconnectWallet), findsOneWidget);
    });

    testWidgets('shows link and disconnect actions for connected wallet', (
      final WidgetTester tester,
    ) async {
      final WalletConnectAuthState state = WalletConnectAuthState(
        status: ViewStatus.success,
        walletAddress: _walletAddress,
      );
      _stubState(cubit, state);

      await tester.pumpWidget(_buildTestApp(cubit));

      expect(find.text(_walletAddress.truncated), findsOneWidget);
      expect(find.text(AppLocalizationsEn().linkToFirebase), findsOneWidget);
      expect(find.text(AppLocalizationsEn().disconnectWallet), findsOneWidget);

      await tester.tap(find.text(AppLocalizationsEn().linkToFirebase));
      await tester.pump();
      await tester.tap(find.text(AppLocalizationsEn().disconnectWallet));
      await tester.pump();

      verify(() => cubit.linkWalletToUser()).called(1);
      verify(() => cubit.disconnectWallet()).called(1);
    });
  });
}

void _stubState(
  final _MockWalletConnectAuthCubit cubit,
  final WalletConnectAuthState state,
) {
  when(() => cubit.state).thenReturn(state);
  whenListen(
    cubit,
    Stream<WalletConnectAuthState>.value(state),
    initialState: state,
  );
}

Widget _buildTestApp(final WalletConnectAuthCubit cubit) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: BlocProvider<WalletConnectAuthCubit>.value(
      value: cubit,
      child: const WalletConnectAuthPage(),
    ),
  );
}

const WalletAddress _walletAddress = WalletAddress(
  '0x1234567890abcdef1234567890abcdef12345678',
);
