import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/walletconnect_auth/domain/wallet_address.dart';
import 'package:flutter_bloc_app/features/walletconnect_auth/domain/wallet_user_profile.dart';
import 'package:flutter_bloc_app/features/walletconnect_auth/presentation/cubit/walletconnect_auth_cubit.dart';
import 'package:flutter_bloc_app/features/walletconnect_auth/presentation/cubit/walletconnect_auth_state.dart';
import 'package:flutter_bloc_app/features/walletconnect_auth/presentation/widgets/connect_wallet_button.dart';
import 'package:flutter_bloc_app/features/walletconnect_auth/presentation/widgets/wallet_address_display.dart';
import 'package:flutter_bloc_app/shared/shared.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';

part 'walletconnect_auth_page_impl.part.dart';
