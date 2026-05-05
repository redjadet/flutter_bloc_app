import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc_app/core/time/timer_service.dart';
import 'package:flutter_bloc_app/features/todo_list/data/hive_todo_repository.dart';
import 'package:flutter_bloc_app/features/todo_list/data/todo_merge_policy.dart';
import 'package:flutter_bloc_app/features/todo_list/data/todo_payload_builder.dart';
import 'package:flutter_bloc_app/features/todo_list/domain/todo_item.dart';
import 'package:flutter_bloc_app/features/todo_list/domain/todo_repository.dart';
import 'package:flutter_bloc_app/shared/sync/pending_sync_repository.dart';
import 'package:flutter_bloc_app/shared/sync/sync_operation.dart';
import 'package:flutter_bloc_app/shared/sync/syncable_repository.dart';
import 'package:flutter_bloc_app/shared/sync/syncable_repository_registry.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:flutter_bloc_app/shared/utils/subscription_manager.dart';
import 'package:flutter_bloc_app/shared/utils/timer_handle_manager.dart';

part 'offline_first_todo_repository_helpers.dart';
part 'offline_first_todo_repository_impl.part.dart';
