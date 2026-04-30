import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/bootstrap/firebase_bootstrap_service.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/data/staff_demo_location_service.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/pages/staff_app_demo_proof_page.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/proof/staff_demo_proof_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

import 'staff_app_demo_walkthrough_flow_helpers.dart';
import 'test_harness.dart';

part 'staff_app_demo_walkthrough_flow_test_impl.part.dart';

void main() {
  registerIntegrationHarness();
  staffAppDemoWalkthroughMain();
}
