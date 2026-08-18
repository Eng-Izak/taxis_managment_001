import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theming/app_colors.dart';
import '../../../core/shared/widgets/app_card.dart';
import '../../../core/shared/widgets/app_toast.dart';
import '../../../core/localization/app_localization_extension.dart';
import '../../../core/network/sync/enums/sync_enums.dart';
import '../logic/local_sync_cubit.dart';
import '../logic/local_sync_state.dart';

class LocalSyncDialog extends StatefulWidget {
  const LocalSyncDialog({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const LocalSyncDialog(),
    );
  }

  @override
  State<LocalSyncDialog> createState() => _LocalSyncDialogState();
}

class _LocalSyncDialogState extends State<LocalSyncDialog> {
  final _ipController = TextEditingController();
  bool _isManualInputVisible = false;

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : const Color(0xFF0F56B3);
    final isArabic = context.isArabic;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131D31) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: BlocBuilder<LocalSyncCubit, LocalSyncState>(
        builder: (context, state) {
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            state.isServer ? Icons.dns_rounded : Icons.wifi_tethering_rounded,
                            color: primaryColor,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isArabic ? 'المزامنة المحلية (Windows ↔ Android)' : 'Local Network Sync',
                              style: TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1F2937),
                              ),
                            ),
                            Text(
                              state.isServer
                                  ? (isArabic ? 'نسخة الويندوز (الخادم الرئيسي)' : 'Windows Server Mode')
                                  : (isArabic ? 'نسخة الأندرويد (عميل متصل)' : 'Android Client Mode'),
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? AppColors.darkTextTertiary : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Connection Banner Card
                _buildStatusBanner(context, state, isDark, primaryColor, isArabic),
                const SizedBox(height: 14),

                // Server info or Discovery / Manual connection section
                if (state.isServer) ...[
                  _buildServerStats(context, state, isDark, primaryColor, isArabic),
                ] else ...[
                  _buildClientDiscoverySection(context, state, isDark, primaryColor, isArabic),
                ],

                const SizedBox(height: 18),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: state.isSyncing
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.sync_rounded, color: Colors.white, size: 18),
                        label: Text(
                          state.isSyncing
                              ? (isArabic ? 'جاري المزامنة...' : 'Syncing...')
                              : (isArabic ? 'مزامنة فورية الآن' : 'Sync Now'),
                          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        onPressed: state.isSyncing
                            ? null
                            : () async {
                                await context.read<LocalSyncCubit>().triggerManualSync();
                                if (context.mounted) {
                                  AppToast.show(
                                    context,
                                    message: isArabic ? 'تم طلب المزامنة اللحظية' : 'Sync request dispatched',
                                  );
                                }
                              },
                      ),
                    ),
                    if (!state.isServer) ...[
                      const SizedBox(width: 10),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          side: BorderSide(color: primaryColor),
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                        ),
                        icon: Icon(Icons.radar_rounded, color: primaryColor, size: 18),
                        label: Text(
                          isArabic ? 'إعادة البحث' : 'Rescan',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: primaryColor),
                        ),
                        onPressed: () => context.read<LocalSyncCubit>().autoDiscoverAndConnect(),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusBanner(BuildContext context, LocalSyncState state, bool isDark, Color primaryColor, bool isArabic) {
    Color bgColor;
    Color borderColor;
    Color textColor;
    IconData icon;
    String title;
    String subtitle = state.message ?? '';

    switch (state.status) {
      case LocalSyncConnectionState.serverRunning:
        bgColor = isDark ? const Color(0xFF064E3B).withValues(alpha: 0.35) : const Color(0xFFE6F4EA);
        borderColor = isDark ? const Color(0xFF22C55E).withValues(alpha: 0.3) : const Color(0xFFA7F3D0);
        textColor = const Color(0xFF137333);
        icon = Icons.check_circle_rounded;
        title = isArabic ? 'خادم المزامنة نشط ومتاح للأجهزة' : 'Server Running & Available';
        break;

      case LocalSyncConnectionState.connected:
        bgColor = isDark ? const Color(0xFF064E3B).withValues(alpha: 0.35) : const Color(0xFFE6F4EA);
        borderColor = isDark ? const Color(0xFF22C55E).withValues(alpha: 0.3) : const Color(0xFFA7F3D0);
        textColor = const Color(0xFF137333);
        icon = Icons.link_rounded;
        title = isArabic ? 'متصل بالخادم وتتم المزامنة تلقائياً' : 'Connected & Auto-Syncing';
        break;

      case LocalSyncConnectionState.syncing:
        bgColor = primaryColor.withValues(alpha: isDark ? 0.2 : 0.1);
        borderColor = primaryColor.withValues(alpha: 0.3);
        textColor = primaryColor;
        icon = Icons.sync_rounded;
        title = isArabic ? 'جاري تبادل البيانات...' : 'Syncing Data in Progress...';
        break;

      case LocalSyncConnectionState.searching:
        bgColor = isDark ? const Color(0xFF1E3A8A).withValues(alpha: 0.25) : const Color(0xFFE8F0FE);
        borderColor = const Color(0xFF60A5FA).withValues(alpha: 0.3);
        textColor = const Color(0xFF1A73E8);
        icon = Icons.radar_rounded;
        title = isArabic ? 'جاري البحث عبر الشبكة المحلية (mDNS)...' : 'Discovering Servers...';
        break;

      case LocalSyncConnectionState.connecting:
        bgColor = isDark ? const Color(0xFF78350F).withValues(alpha: 0.3) : const Color(0xFFFEF7E0);
        borderColor = const Color(0xFFFBBF24).withValues(alpha: 0.4);
        textColor = const Color(0xFFB06000);
        icon = Icons.hourglass_top_rounded;
        title = isArabic ? 'جاري تأسيس الاتصال الآمن...' : 'Connecting to Server...';
        break;

      case LocalSyncConnectionState.error:
      case LocalSyncConnectionState.disconnected:
        bgColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFF8F9FA);
        borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
        textColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
        icon = Icons.wifi_off_rounded;
        title = isArabic ? 'غير متصل بالخادم المحلي' : 'Not Connected';
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 0.9),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: textColor),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.darkTextSecondary : const Color(0xFF475569),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServerStats(BuildContext context, LocalSyncState state, bool isDark, Color primaryColor, bool isArabic) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isArabic ? 'عنوان الخادم المحلي (Local IP)' : 'Server Local IP',
                style: TextStyle(
                  fontSize: 11.5,
                  color: isDark ? AppColors.darkTextTertiary : const Color(0xFF64748B),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Port 8080 (mDNS: _sync._tcp)',
                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: primaryColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            state.serverAddress ?? '0.0.0.0:8080',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isArabic ? 'هواتف الأندرويد المتصلة حالياً:' : 'Connected Android Clients:',
                style: const TextStyle(fontSize: 12.5),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: state.connectedClientsCount > 0
                      ? (isDark ? const Color(0xFF064E3B).withValues(alpha: 0.4) : const Color(0xFFE6F4EA))
                      : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${state.connectedClientsCount} ${isArabic ? "أجهزة" : "devices"}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: state.connectedClientsCount > 0 ? const Color(0xFF137333) : const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClientDiscoverySection(BuildContext context, LocalSyncState state, bool isDark, Color primaryColor, bool isArabic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (state.discoveredServers.isNotEmpty) ...[
          Text(
            isArabic ? 'الخوادم المكتشفة على الشبكة المحلية:' : 'Discovered Local Servers:',
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...state.discoveredServers.map((server) {
            final host = server.primaryIp ?? server.host;
            final isCurrent = state.serverAddress == '$host:${server.port}';

            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: AppCard(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.desktop_windows_rounded, size: 20, color: Color(0xFF0F56B3)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            server.name,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '$host:${server.port}',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? AppColors.darkTextTertiary : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isCurrent && state.isConnected)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF137333).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isArabic ? 'متصل' : 'Connected',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF137333)),
                        ),
                      )
                    else
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => context.read<LocalSyncCubit>().connectToManualIp(host, port: server.port),
                        child: Text(
                          isArabic ? 'اتصال' : 'Connect',
                          style: const TextStyle(fontSize: 11.5, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        ],

        // Manual IP toggle
        TextButton.icon(
          onPressed: () => setState(() => _isManualInputVisible = !_isManualInputVisible),
          icon: Icon(_isManualInputVisible ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, size: 18),
          label: Text(
            isArabic ? 'إدخال عنوان IP الخادم يدوياً (في حال تعذر الاكتشاف التلقائي)' : 'Manual Server IP Input (Fallback)',
            style: const TextStyle(fontSize: 11.5),
          ),
        ),

        if (_isManualInputVisible) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ipController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: isArabic ? 'عنوان IP خادم الويندوز' : 'Windows Server IP',
                    hintText: '192.168.1.100',
                    prefixIcon: const Icon(Icons.lan_rounded, size: 18),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  final ip = _ipController.text.trim();
                  if (ip.isNotEmpty) {
                    context.read<LocalSyncCubit>().connectToManualIp(ip);
                  }
                },
                child: Text(
                  isArabic ? 'اتصال' : 'Connect',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
