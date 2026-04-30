import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc_app/features/walletconnect_auth/data/wallet_user_profile_mapper.dart';
import 'package:flutter_bloc_app/features/walletconnect_auth/data/walletconnect_service.dart';
import 'package:flutter_bloc_app/features/walletconnect_auth/domain/wallet_address.dart';
import 'package:flutter_bloc_app/features/walletconnect_auth/domain/wallet_user_profile.dart';
import 'package:flutter_bloc_app/features/walletconnect_auth/domain/walletconnect_auth_repository.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:flutter_bloc_app/shared/utils/safe_parse_utils.dart';

part 'walletconnect_auth_repository_impl_body.part.dart';
