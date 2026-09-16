import 'package:flutter_bloc_app/app/sync/network_sync_banner.dart';
import 'package:material_ui/material_ui.dart';

/// Search sync banner: network/sync status only (no feature pending queue).
class SearchSyncBanner extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) => const NetworkSyncBanner();
}
