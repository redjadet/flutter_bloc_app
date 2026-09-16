import 'package:flutter_bloc_app/app/sync/network_sync_banner.dart';
import 'package:material_ui/material_ui.dart';

/// IoT demo sync banner: network/sync status plus pending from last summary.
class IotDemoSyncBanner extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) =>
      const NetworkSyncBanner(includePendingFromSummary: true);
}
