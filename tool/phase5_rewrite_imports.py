#!/usr/bin/env python3
"""Phase 5 pre-delete import rewrite for apps/mobile."""

from __future__ import annotations

import re
from pathlib import Path

REPO = Path(__file__).resolve().parents[1]
MOBILE = REPO / "apps/mobile"
TARGET_DIRS = [
    MOBILE / "lib",
    MOBILE / "test",
    MOBILE / "integration_test",
    REPO / "packages" / "storage" / "lib",
    REPO / "tool" / "fixtures",
    REPO / "tool" / "bloc_codegen" / "lib",
]

IMPORT_RE = re.compile(
    r"^import 'package:flutter_bloc_app/(?P<path>[^']+)';",
    re.MULTILINE,
)

EXPORT_RE = re.compile(
    r"^export 'package:flutter_bloc_app/(?P<path>[^']+)';",
    re.MULTILINE,
)

CORE_BARREL = "import 'package:flutter_bloc_app/core/core.dart';"

CORE_SYMBOL_IMPORTS: dict[str, str] = {
    "AppRoutes": "import 'package:flutter_bloc_app/app/router/app_routes.dart';",
    "getIt": "import 'package:flutter_bloc_app/app/composition/injector.dart';",
    "Flavor": "import 'package:flutter_bloc_app/app/config/flavor.dart';",
    "AppFlavor": "import 'package:flutter_bloc_app/app/config/flavor.dart';",
    "AppTheme": "import 'package:flutter_bloc_app/app/theme/app_theme.dart';",
    "buildAppTheme": "import 'package:flutter_bloc_app/app/theme/app_theme.dart';",
    "MixAppTheme": "import 'package:design_system/design_system.dart';",
    "buildAppMixScope": "import 'package:flutter_bloc_app/app/theme/theme.dart';",
    "TimerService": "import 'package:core/core.dart';",
    "TimerDisposable": "import 'package:core/core.dart';",
    "BackgroundSyncCoordinator": "import 'package:networking/networking.dart';",
    "NetworkStatus": "import 'package:networking/networking.dart';",
    "NetworkStatusService": "import 'package:networking/networking.dart';",
    "BackendAvailability": "import 'package:flutter_bloc_app/app/config/backend_availability.dart';",
    "SecretConfig": "import 'package:flutter_bloc_app/app/config/secret_config.dart';",
    "SupabaseConfigCoordinator": "import 'package:flutter_bloc_app/app/config/supabase_config_coordinator.dart';",
    "SupabaseConfigProvider": "import 'package:flutter_bloc_app/app/config/supabase_config_provider.dart';",
    "AppRuntimeConfig": "import 'package:flutter_bloc_app/app/config/app_runtime_config.dart';",
    "IotBleRuntimeConfig": "import 'package:flutter_bloc_app/app/config/iot_ble_runtime_config.dart';",
    "AppConstants": "import 'package:flutter_bloc_app/app/config/app_constants.dart';",
    "AppConfig": "import 'package:flutter_bloc_app/app/app_config.dart';",
    "createAppRoutes": "import 'package:flutter_bloc_app/app/router/routes.dart';",
    "createAuthRedirect": "import 'package:flutter_bloc_app/app/router/auth_redirect.dart';",
}

CORE_PATH_REWRITES: dict[str, str] = {
    "core/router/app_routes.dart": "app/router/app_routes.dart",
    "core/di/injector.dart": "app/composition/injector.dart",
    "core/flavor.dart": "app/config/flavor.dart",
    "core/constants/constants.dart": "app/config/app_constants.dart",
    "core/constants/app_constants.dart": "app/config/app_constants.dart",
    "core/theme/app_theme.dart": "app/theme/app_theme.dart",
    "core/theme/mix_app_theme.dart": "app/theme/theme.dart",
    "core/theme/theme.dart": "app/theme/theme.dart",
    "core/platform_init.dart": "app/bootstrap/platform_init.dart",
    "core/platform_init_impl.dart": "app/bootstrap/platform_init_impl.dart",
    "core/app_config.dart": "app/app_config.dart",
    "core/supabase/edge_then_tables.dart": "app/supabase/edge_then_tables.dart",
    "core/chat/render_orchestration_remote_token_port.dart": "app/chat/render_orchestration_remote_token_port.dart",
    "core/diagnostics/graphql_cache_clear_port.dart": "app/diagnostics/graphql_cache_clear_port.dart",
    "core/diagnostics/profile_cache_controls_port.dart": "app/diagnostics/profile_cache_controls_port.dart",
    "core/diagnostics/remote_config_diagnostics_view_data.dart": "app/diagnostics/remote_config_diagnostics_view_data.dart",
    "core/diagnostics/diagnostics_sync_timestamp.dart": "app/diagnostics/diagnostics_sync_timestamp.dart",
    "core/config/secret_config.dart": "app/config/secret_config.dart",
    "core/config/supabase_config_coordinator.dart": "app/config/supabase_config_coordinator.dart",
    "core/config/supabase_config_provider.dart": "app/config/supabase_config_provider.dart",
    "core/config/backend_availability.dart": "app/config/backend_availability.dart",
    "core/config/app_runtime_config.dart": "app/config/app_runtime_config.dart",
    "core/bootstrap/bootstrap_coordinator.dart": "app/bootstrap/bootstrap_coordinator.dart",
    "core/bootstrap/firebase_bootstrap_service.dart": "app/bootstrap/firebase_bootstrap_service.dart",
    "core/bootstrap/supabase_bootstrap_service.dart": "app/bootstrap/supabase_bootstrap_service.dart",
}

SHARED_PATH_REWRITES: dict[str, str] = {
    # app_shared_flutter
    "shared/utils/logger.dart": "package:app_shared_flutter/app_shared_flutter.dart",
    "shared/platform/secure_secret_storage.dart": "package:app_shared_flutter/app_shared_flutter.dart",
    "shared/diagnostics/integration_log_messages.dart": "package:app_shared_flutter/app_shared_flutter.dart",
    "shared/utils/platform_environment.dart": "package:app_shared_flutter/app_shared_flutter.dart",
    # networking
    "shared/services/network_status_service.dart": "package:networking/networking.dart",
    "shared/utils/network_guard.dart": "package:networking/networking.dart",
    "shared/utils/websocket_guard.dart": "package:networking/networking.dart",
    "shared/http/interceptors/telemetry_interceptor.dart": "package:networking/networking.dart",
    "shared/http/interceptors/retry_interceptor.dart": "package:networking/networking.dart",
    # storage
    "shared/storage/hive_service.dart": "package:storage/storage.dart",
    "shared/utils/storage_guard.dart": "package:storage/storage.dart",
    "shared/storage/shared_preferences_migration_service.dart": "package:storage/storage.dart",
    "shared/storage/migration_helpers.dart": "package:storage/storage.dart",
    "shared/storage/hive_settings_repository.dart": "package:storage/storage.dart",
    # utilities
    "shared/utils/safe_parse_utils.dart": "package:utilities/utilities.dart",
    "shared/utils/sealed_state_helpers.dart": "package:utilities/utilities.dart",
    "shared/utils/repository_initial_load_helper.dart": "package:utilities/utilities.dart",
    "shared/utils/repository_watch_helper.dart": "package:utilities/utilities.dart",
    "shared/utils/subscription_manager.dart": "package:utilities/utilities.dart",
    "shared/utils/stream_controller_lifecycle.dart": "package:utilities/utilities.dart",
    "shared/utils/completer_helper.dart": "package:utilities/utilities.dart",
    "shared/utils/timer_handle_manager.dart": "package:utilities/utilities.dart",
    "shared/utils/retry_policy.dart": "package:utilities/utilities.dart",
    "shared/utils/http_request_failure.dart": "package:utilities/utilities.dart",
    "shared/utils/failure_to_app_error.dart": "package:utilities/utilities.dart",
    "shared/utils/error_codes.dart": "package:utilities/utilities.dart",
    "shared/utils/app_error.dart": "package:utilities/utilities.dart",
    # design_system ui/responsive
    "shared/ui/view_status.dart": "package:design_system/design_system.dart",
    "shared/ui/typography.dart": "package:design_system/design_system.dart",
    "shared/responsive/responsive.dart": "package:design_system/responsive.dart",
    "shared/responsive/responsive_scope.dart": "package:design_system/responsive.dart",
    "shared/utils/platform_adaptive.dart": "package:design_system/design_system.dart",
    "shared/utils/platform_adaptive_buttons.dart": "package:design_system/design_system.dart",
    "shared/utils/platform_adaptive_inputs.dart": "package:design_system/design_system.dart",
    "shared/utils/markdown_parser.dart": "package:design_system/design_system.dart",
    "shared/utils/markdown_table_renderer.dart": "package:design_system/design_system.dart",
    "shared/widgets/settings_section.dart": "package:design_system/design_system.dart",
    "shared/widgets/resilient_svg_asset_image.dart": "package:design_system/design_system.dart",
    "shared/widgets/message_bubble.dart": "package:design_system/design_system.dart",
    "shared/widgets/icon_label_row.dart": "package:design_system/design_system.dart",
    "shared/widgets/image_from_path.dart": "package:design_system/design_system.dart",
    "shared/widgets/cached_network_image_widget.dart": "package:design_system/design_system.dart",
    "shared/widgets/common_dropdown_field.dart": "package:design_system/design_system.dart",
    "shared/widgets/common_loading_widget.dart": "package:design_system/design_system.dart",
    "shared/widgets/app_message.dart": "package:design_system/design_system.dart",
    # app shell
    "shared/extensions/build_context_l10n.dart": "app/extensions/build_context_l10n.dart",
    "shared/extensions/type_safe_bloc_access.dart": "app/extensions/type_safe_bloc_access.dart",
    "shared/utils/navigation.dart": "app/utils/navigation.dart",
    "shared/utils/error_handling.dart": "app/utils/error_handling.dart",
    "shared/utils/network_error_mapper.dart": "app/utils/network_error_mapper.dart",
    "shared/utils/context_utils.dart": "app/utils/context_utils.dart",
    "shared/utils/bloc_provider_helpers.dart": "app/utils/bloc_provider_helpers.dart",
    "shared/utils/bloc_lint_helpers.dart": "app/utils/bloc_lint_helpers.dart",
    "shared/utils/cubit_async_operations.dart": "app/utils/cubit_async_operations.dart",
    "shared/utils/cubit_helpers.dart": "app/utils/bloc/cubit_helpers.dart",
    "shared/utils/cubit_subscription_mixin.dart": "app/utils/bloc/cubit_subscription_mixin.dart",
    "shared/utils/cubit_state_emission_mixin.dart": "app/utils/bloc/state_helpers.dart",
    "shared/utils/state_restoration_mixin.dart": "app/utils/bloc/state_restoration_mixin.dart",
    "shared/utils/state_transition_validator.dart": "app/utils/bloc/state_transition_validator.dart",
    "shared/utils/platform_adaptive_sheets.dart": "app/utils/platform_adaptive_sheets.dart",
    "shared/utils/isolate_json.dart": "app/utils/isolate_json.dart",
    "shared/utils/isolate_samples.dart": "app/utils/isolate_samples.dart",
    "shared/utils/date_time_formatting.dart": "app/utils/date_time_formatting.dart",
    "shared/utils/initialization_guard.dart": "app/bootstrap/initialization_guard.dart",
    "shared/utils/performance_profiler.dart": "app/diagnostics/performance_profiler.dart",
    "shared/utils/performance_profiler_report.dart": "app/diagnostics/performance_profiler_report.dart",
    "shared/utils/performance_profiler_internal.dart": "app/diagnostics/performance_profiler_internal.dart",
    "shared/utils/performance_profiler_widget.dart": "app/diagnostics/performance_profiler_widget.dart",
    "shared/utils/performance_profiler_stats.dart": "app/diagnostics/performance_profiler_stats.dart",
    "shared/http/app_dio.dart": "app/http/app_dio.dart",
    "shared/http/auth_token_manager.dart": "app/http/auth/auth_token_manager.dart",
    "shared/http/auth_token_refresh_classifier.dart": "app/http/auth/auth_token_refresh_classifier.dart",
    "shared/http/supabase_session_manager.dart": "app/http/supabase/supabase_session_manager.dart",
    "shared/http/supabase_session_refresh_classifier.dart": "app/http/supabase/supabase_session_refresh_classifier.dart",
    "shared/http/interceptors/auth_token_interceptor.dart": "app/http/auth/interceptors/auth_token_interceptor.dart",
    "shared/widgets/view_status_switcher.dart": "app/widgets/view_status_switcher.dart",
    "shared/widgets/type_safe_bloc_selector.dart": "app/widgets/type_safe_bloc_selector.dart",
    "shared/widgets/sync_status_banner.dart": "app/widgets/sync_status_banner.dart",
    "shared/widgets/root_aware_back_button.dart": "app/widgets/root_aware_back_button.dart",
    "shared/widgets/retry_snackbar_listener.dart": "app/widgets/retry_snackbar_listener.dart",
    "shared/widgets/flavor_badge.dart": "app/widgets/flavor_badge.dart",
    "shared/widgets/deferred_page.dart": "app/widgets/deferred_page.dart",
    "shared/widgets/common_search_field.dart": "app/widgets/common_search_field.dart",
    "shared/widgets/common_page_layout.dart": "app/widgets/common_page_layout.dart",
    "shared/widgets/common_error_view.dart": "app/widgets/common_error_view.dart",
    "shared/widgets/common_empty_state.dart": "app/widgets/common_empty_state.dart",
    "shared/widgets/common_app_bar.dart": "app/widgets/common_app_bar.dart",
    "shared/widgets/backend_disabled_banner.dart": "app/widgets/backend_disabled_banner.dart",
    "shared/widgets/diagnostics/diagnostics.dart": "app/widgets/diagnostics/diagnostics.dart",
    "shared/widgets/diagnostics/settings_diagnostics_widgets.dart": "app/widgets/diagnostics/settings_diagnostics_widgets.dart",
    "shared/widgets/diagnostics/profile_cache_controls_section.dart": "app/widgets/diagnostics/profile_cache_controls_section.dart",
    "shared/widgets/diagnostics/graphql_cache_controls_section.dart": "app/widgets/diagnostics/graphql_cache_controls_section.dart",
    "shared/sync/sync_context_extensions.dart": "app/sync/sync_context_extensions.dart",
    "shared/sync/sync_banner_helpers.dart": "app/sync/sync_banner_helpers.dart",
    "shared/sync/presentation/sync_status_cubit.dart": "app/sync/presentation/sync_status_cubit.dart",
    "shared/sync/presentation/sync_status_state.dart": "app/sync/presentation/sync_status_state.dart",
    "shared/services/app_memory_service.dart": "app/services/app_memory_service.dart",
    "shared/services/app_memory_trim_level.dart": "app/services/app_memory_trim_level.dart",
    "shared/services/app_image_cache_manager.dart": "app/services/app_image_cache_manager.dart",
    "shared/services/retry_notification_service.dart": "app/services/retry_notification_service.dart",
    "shared/services/error_notification_service.dart": "app/services/error_notification_service.dart",
    "shared/platform/biometric_authenticator.dart": "app/platform/biometric_authenticator.dart",
    "shared/platform/native_platform_service.dart": "app/platform/native_platform_service.dart",
    "shared/firebase/auth_helpers.dart": "app/firebase/auth_helpers.dart",
    "shared/firebase/run_with_auth_user.dart": "app/firebase/run_with_auth_user.dart",
    "shared/firebase/stream_with_auth_user.dart": "app/firebase/stream_with_auth_user.dart",
    "shared/firebase/realtime_database_guard.dart": "app/firebase/realtime_database_guard.dart",
    "shared/media/media_pick_result.dart": "app/media/media_pick_result.dart",
    "shared/media/media_pick_error_keys.dart": "app/media/media_pick_error_keys.dart",
    "shared/media/media_pick_error_messages.dart": "app/media/media_pick_error_messages.dart",
    "shared/design_system/epoch_theme_extension.dart": "package:design_system/design_system.dart",
    "shared/annotations/bloc_annotations.dart": "app/annotations/bloc_annotations.dart",
}

SHARED_BARREL_SYMBOLS: dict[str, str] = {
    "CubitHelpers": "import 'package:flutter_bloc_app/app/utils/bloc/cubit_helpers.dart';",
    "TypeSafeBlocConsumer": "import 'package:flutter_bloc_app/app/widgets/type_safe_bloc_selector.dart';",
    "TypeSafeBlocBuilder": "import 'package:flutter_bloc_app/app/widgets/type_safe_bloc_selector.dart';",
    "TypeSafeBlocSelector": "import 'package:flutter_bloc_app/app/widgets/type_safe_bloc_selector.dart';",
    "TypeSafeBlocListener": "import 'package:flutter_bloc_app/app/widgets/type_safe_bloc_selector.dart';",
    "AppMessage": "import 'package:design_system/design_system.dart';",
    "CommonPageLayout": "import 'package:flutter_bloc_app/app/widgets/common_page_layout.dart';",
    "CommonAppBar": "import 'package:flutter_bloc_app/app/widgets/common_app_bar.dart';",
    "CommonErrorView": "import 'package:flutter_bloc_app/app/widgets/common_error_view.dart';",
    "CommonEmptyState": "import 'package:flutter_bloc_app/app/widgets/common_empty_state.dart';",
    "CommonLoadingWidget": "import 'package:design_system/design_system.dart';",
    "CommonSearchField": "import 'package:flutter_bloc_app/app/widgets/common_search_field.dart';",
    "CommonFormField": "import 'package:design_system/design_system.dart';",
    "CommonStatusView": "import 'package:design_system/design_system.dart';",
    "DeferredPage": "import 'package:flutter_bloc_app/app/widgets/deferred_page.dart';",
    "FlavorBadge": "import 'package:flutter_bloc_app/app/widgets/flavor_badge.dart';",
    "SyncStatusBanner": "import 'package:flutter_bloc_app/app/widgets/sync_status_banner.dart';",
    "ViewStatusSwitcher": "import 'package:flutter_bloc_app/app/widgets/view_status_switcher.dart';",
    "ErrorNotificationService": "import 'package:flutter_bloc_app/app/services/error_notification_service.dart';",
    "BiometricAuthenticator": "import 'package:flutter_bloc_app/app/platform/biometric_authenticator.dart';",
    "LocalBiometricAuthenticator": "import 'package:flutter_bloc_app/app/platform/biometric_authenticator.dart';",
    "ViewStatus": "import 'package:design_system/design_system.dart';",
    "ViewStatusX": "import 'package:design_system/design_system.dart';",
    "AppTypography": "import 'package:design_system/design_system.dart';",
    "UI": "import 'package:design_system/responsive.dart';",
    "ResponsiveScope": "import 'package:design_system/responsive.dart';",
    "PlatformAdaptive": "import 'package:design_system/design_system.dart';",
    "PlatformAdaptiveSheets": "import 'package:flutter_bloc_app/app/utils/platform_adaptive_sheets.dart';",
    "PlatformAdaptiveButtons": "import 'package:design_system/design_system.dart';",
    "PlatformAdaptiveInputs": "import 'package:design_system/design_system.dart';",
    "SealedStateHelpers": "import 'package:utilities/utilities.dart';",
    "StateTransitionValidator": "import 'package:flutter_bloc_app/app/utils/bloc/state_transition_validator.dart';",
    "IsolateSamples": "import 'package:flutter_bloc_app/app/utils/isolate_samples.dart';",
    "AppLogger": "import 'package:app_shared_flutter/app_shared_flutter.dart';",
    "SecureSecretStorage": "import 'package:app_shared_flutter/app_shared_flutter.dart';",
    "NetworkStatusService": "import 'package:networking/networking.dart';",
    "ConnectivityNetworkStatusService": "import 'package:networking/networking.dart';",
}


def build_shim_map(shared_root: Path) -> dict[str, str]:
    mapping: dict[str, str] = dict(SHARED_PATH_REWRITES)
    mapping.update(CORE_PATH_REWRITES)
    for shim in shared_root.rglob("*.dart"):
        rel = shim.relative_to(MOBILE / "lib").as_posix()
        if rel.startswith("shared/") or rel.startswith("core/"):
            text = shim.read_text(encoding="utf-8")
            match = re.search(r"^export '([^']+)';", text, re.MULTILINE)
            if match:
                target = match.group(1)
                if target.startswith("package:"):
                    mapping[rel] = target.removeprefix("package:flutter_bloc_app/")
                    if not mapping[rel].startswith("package:"):
                        mapping[rel] = f"package:flutter_bloc_app/{mapping[rel]}"
                elif target.startswith("package:"):
                    mapping[rel] = target
    return mapping


def rewrite_core_barrel(text: str) -> str:
    if CORE_BARREL not in text:
        return text
    body = text.replace(CORE_BARREL, "")
    needed: list[str] = []
    for sym, imp in CORE_SYMBOL_IMPORTS.items():
        if re.search(r"\b" + re.escape(sym) + r"\b", body) and imp not in needed:
            needed.append(imp)
    text = body
    if needed:
        first_import = text.find("import ")
        block = "\n".join(needed) + "\n"
        if first_import >= 0:
            text = text[:first_import] + block + text[first_import:]
        else:
            text = block + text
    return text


def rewrite_shared_barrel(text: str) -> str:
    barrel = "import 'package:flutter_bloc_app/shared/shared.dart';"
    if barrel not in text:
        return text
    body = text.replace(barrel, "")
    needed: list[str] = []
    for sym, imp in SHARED_BARREL_SYMBOLS.items():
        if re.search(r"\b" + re.escape(sym) + r"\b", body) and imp not in needed:
            needed.append(imp)
    if re.search(r"\.responsive[A-Z]", body) or re.search(r"context\.responsive", body):
        imp = "import 'package:design_system/responsive.dart';"
        if imp not in needed:
            needed.append(imp)
    if re.search(r"context\.l10n", body):
        imp = "import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';"
        if imp not in needed:
            needed.append(imp)
    text = body
    if needed:
        first_import = text.find("import ")
        block = "\n".join(needed) + "\n"
        if first_import >= 0:
            text = text[:first_import] + block + text[first_import:]
        else:
            text = block + text
    return text


def _rewrite_package_path(old: str, new: str | None, kind: str) -> str | None:
    if new is None:
        return None
    if new.startswith("package:"):
        return f"{kind} '{new}';"
    return f"{kind} 'package:flutter_bloc_app/{new}';"


def rewrite_paths(text: str, mapping: dict[str, str]) -> str:
    def import_repl(match: re.Match[str]) -> str:
        rewritten = _rewrite_package_path(match.group("path"), mapping.get(match.group("path")), "import")
        return rewritten if rewritten is not None else match.group(0)

    def export_repl(match: re.Match[str]) -> str:
        rewritten = _rewrite_package_path(match.group("path"), mapping.get(match.group("path")), "export")
        return rewritten if rewritten is not None else match.group(0)

    text = IMPORT_RE.sub(import_repl, text)
    return EXPORT_RE.sub(export_repl, text)


def process_file(path: Path, mapping: dict[str, str]) -> bool:
    original = path.read_text(encoding="utf-8")
    updated = original
    updated = rewrite_core_barrel(updated)
    updated = rewrite_shared_barrel(updated)
    updated = rewrite_paths(updated, mapping)
    if updated != original:
        path.write_text(updated, encoding="utf-8")
        return True
    return False


def main() -> None:
    mapping = build_shim_map(MOBILE / "lib" / "shared")
    changed = 0
    for base in TARGET_DIRS:
        if not base.exists():
            continue
        for path in sorted(base.rglob("*.dart")):
            if process_file(path, mapping):
                changed += 1
    print(f"updated {changed} dart files")


if __name__ == "__main__":
    main()
