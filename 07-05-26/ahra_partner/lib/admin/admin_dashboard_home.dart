import 'package:flutter/material.dart';

import 'admin_pending_kyc_list_screen.dart';
import 'admin_approved_kyc_list_screen.dart';
import 'admin_rejected_kyc_list_screen.dart';

class AdminDashboardHome extends StatelessWidget {
  const AdminDashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.pending_actions),
                text: 'Pending',
              ),
              Tab(
                icon: Icon(Icons.verified),
                text: 'Approved',
              ),
              Tab(
                icon: Icon(Icons.cancel),
                text: 'Rejected',
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AdminPendingKycListScreen(),
            AdminApprovedKycListScreen(),
            AdminRejectedKycListScreen(),
          ],
        ),
      ),
    );
  }
}
