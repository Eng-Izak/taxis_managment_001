import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../theming/app_colors.dart';
import '../../localization/app_localization_extension.dart';
import '../../network/sync/enums/sync_enums.dart';
import '../../../features/sync/logic/local_sync_cubit.dart';
import '../../../features/sync/logic/local_sync_state.dart';
import '../../../features/sync/ui/local_sync_dialog.dart';

class SyncStatusBadge extends StatelessWidget {
  final bool showLabel;
  final bool compact;

  const SyncStatusBadge({
    super.key,
    this.showLabel = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : const Color(0xFF0F56B3);
    final isArabic = context.isArabic;

    return BlocBuilder<LocalSyncCubit, LocalSyncState>(
      builder: (context, state) {
        Color badgeBgColor;
        Color badgeBorderColor;
        Color iconColor;
        IconData icon;
        String statusLabel;

        switch (state.status) {
          case LocalSyncConnectionState.serverRunning:
            icon = Icons.dns_rounded;
            iconColor = isDark ? const Color(0xFF4ADE80) : const Color(0xFF137333);
            badgeBgColor = isDark ? const Color(0xFF064E3B).withValues(alpha: 0.35) : const Color(0xFFE6F4EA);
            badgeBorderColor = isDark ? const Color(0xFF22C55E).withValues(alpha: 0.3) : const Color(0xFFA7F3D0);
            statusLabel = state.connectedClientsCount > 0
                ? (isArabic ? 'خادم (${state.connectedClientsCount})' : 'Server (${state.connectedClientsCount})')
                : (isArabic ? 'خادم' : 'Server');
            break;

          case LocalSyncConnectionState.connected:
            icon = Icons.cloud_done_rounded;
            iconColor = isDark ? const Color(0xFF4ADE80) : const Color(0xFF137333);
            badgeBgColor = isDark ? const Color(0xFF064E3B).withValues(alpha: 0.35) : const Color(0xFFE6F4EA);
            badgeBorderColor = isDark ? const Color(0xFF22C55E).withValues(alpha: 0.3) : const Color(0xFFA7F3D0);
            statusLabel = isArabic ? 'مُزامن' : 'Synced';
            break;

          case LocalSyncConnectionState.syncing:
            icon = Icons.sync_rounded;
            iconColor = primaryColor;
            badgeBgColor = primaryColor.withValues(alpha: isDark ? 0.2 : 0.1);
            badgeBorderColor = primaryColor.withValues(alpha: 0.3);
            statusLabel = isArabic ? 'مزامنة...' : 'Syncing...';
            break;

          case LocalSyncConnectionState.searching:
            icon = Icons.radar_rounded;
            iconColor = const Color(0xFFD97706);
            badgeBgColor = isDark ? const Color(0xFF78350F).withValues(alpha: 0.3) : const Color(0xFFFEF7E0);
            badgeBorderColor = const Color(0xFFFBBF24).withValues(alpha: 0.4);
            statusLabel = isArabic ? 'بحث...' : 'Search...';
            break;

          case LocalSyncConnectionState.connecting:
            icon = Icons.hourglass_top_rounded;
            iconColor = const Color(0xFFD97706);
            badgeBgColor = isDark ? const Color(0xFF78350F).withValues(alpha: 0.3) : const Color(0xFFFEF7E0);
            badgeBorderColor = const Color(0xFFFBBF24).withValues(alpha: 0.4);
            statusLabel = isArabic ? 'اتصال...' : 'Connecting...';
            break;

          case LocalSyncConnectionState.error:
          case LocalSyncConnectionState.disconnected:
            icon = Icons.cloud_off_rounded;
            iconColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
            badgeBgColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
            badgeBorderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
            statusLabel = isArabic ? 'محلي' : 'Offline';
            break;
        }

        if (compact) {
          return InkWell(
            onTap: () => LocalSyncDialog.show(context),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: badgeBgColor,
                shape: BoxShape.circle,
                border: Border.all(color: badgeBorderColor, width: 0.8),
              ),
              child: Icon(icon, size: 16, color: iconColor),
            ),
          );
        }

        return InkWell(
          onTap: () => LocalSyncDialog.show(context),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 95),
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
            decoration: BoxDecoration(
              color: badgeBgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: badgeBorderColor, width: 0.8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 13, color: iconColor),
                if (showLabel) ...[
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      statusLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: iconColor,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
