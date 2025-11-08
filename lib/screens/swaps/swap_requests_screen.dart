import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/swap_provider.dart';
import '../../providers/access_request_provider.dart';
import '../../widgets/common/loading_indicator.dart';

class SwapRequestsScreen extends StatelessWidget {
  const SwapRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Swap Requests')),
      body: Consumer2<SwapProvider, AccessRequestProvider>(
        builder: (context, swapProvider, accessProvider, _) {
          if (swapProvider.isLoading || accessProvider.isLoading) {
            return const LoadingIndicator(message: 'Loading requests...');
          }

          final swaps = swapProvider.swapsReceived;
          final access = accessProvider.received;

          if (swaps.isEmpty && access.isEmpty) {
            return const Center(child: Text('No requests yet'));
          }

          return ListView(
            children: [
              if (swaps.isNotEmpty) ...[
                const ListTile(title: Text('Swap Offers')),
                ...swaps.map((s) => Card(
                      child: ListTile(
                        leading: const Icon(Icons.swap_horiz),
                        title: Text(s.bookTitle),
                        subtitle: Text('From: ${s.senderName}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton(
                              onPressed: () => swapProvider.rejectSwap(s),
                              child: const Text(
                                'Decline',
                                style: TextStyle(color: AppColors.error),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () => swapProvider.acceptSwap(s),
                              child: const Text('Accept'),
                            ),
                          ],
                        ),
                      ),
                    )),
              ],
              if (access.isNotEmpty) ...[
                const ListTile(title: Text('Access Requests')),
                ...access.map((r) => Card(
                      child: ListTile(
                        leading: Icon(r.type == 'watch' ? Icons.play_circle : Icons.menu_book),
                        title: Text('${r.bookTitle} (${r.type})'),
                        subtitle: Text('From: ${r.requesterName}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton(
                              onPressed: () => context.read<AccessRequestProvider>().decline(r),
                              child: const Text(
                                'Decline',
                                style: TextStyle(color: AppColors.error),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () => context.read<AccessRequestProvider>().accept(r),
                              child: const Text('Accept'),
                            ),
                          ],
                        ),
                      ),
                    )),
              ]
            ],
          );
        },
      ),
    );
  }
}
