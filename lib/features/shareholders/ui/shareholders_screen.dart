import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/shared/widgets/app_header_widgets.dart';
import '../../../../core/localization/app_localization_extension.dart';
import '../logic/shareholders_cubit.dart';
import '../logic/shareholders_state.dart';
import '../../home/logic/home_cubit.dart';
import 'widgets/shareholder_card.dart';
import 'shareholder_details_screen.dart';
import 'add_shareholder_screen.dart';
import '../../notifications/ui/notifications_screen.dart';

class ShareholdersScreen extends StatelessWidget {
  const ShareholdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final allAssets = context.watch<HomeCubit>().state.assets;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFF60A5FA) : const Color(0xFF0F56B3);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SadatTaxiLogo(),
            const SizedBox(width: 8),
            Text(
              l10n.shareholders,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F56B3),
              ),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          const ArchiveIconButton(),
          NotificationBellButton(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: BlocBuilder<ShareholdersCubit, ShareholdersState>(
        builder: (context, state) {
          return Column(
            children: [
              // Top Action Row
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Title
                    Text(
                      l10n.shareholdersList,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),

                    // Add Shareholder Button
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const AddShareholderScreen()),
                        );
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.add, color: Colors.white, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              l10n.addShareholder,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Shareholders List
              Expanded(
                child: state.status == ShareholdersStatus.loading
                    ? const Center(child: CircularProgressIndicator())
                    : state.shareholders.isEmpty
                        ? Center(
                            child: Text(
                              l10n.noShareholders,
                              style: const TextStyle(color: Color(0xFF64748B)),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            itemCount: state.shareholders.length,
                            itemBuilder: (context, index) {
                              final partner = state.shareholders[index];
                              return ShareholderCard(
                                shareholder: partner,
                                allAssets: allAssets,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ShareholderDetailsScreen(shareholder: partner),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
              ),
            ],
          );
        },
      ),
    );
  }
}
