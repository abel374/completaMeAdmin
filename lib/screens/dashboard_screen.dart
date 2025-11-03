import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final usersRef = FirebaseFirestore.instance.collection('users');
  final ridersRef = FirebaseFirestore.instance.collection('riders');
  final sellersRef = FirebaseFirestore.instance.collection('sellers');
  final ordersRef = FirebaseFirestore.instance.collection('orders');

  String _formatCurrency(num value) {
    final f = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'Kz',
      decimalDigits: 0,
    );
    return f.format(value);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dashboard',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              StreamBuilder<QuerySnapshot>(
                stream: usersRef.snapshots(),
                builder: (context, snap) {
                  final count = snap.hasData ? snap.data!.docs.length : '—';
                  return _StatCard(title: 'Users', value: '$count');
                },
              ),
              StreamBuilder<QuerySnapshot>(
                stream: ridersRef.snapshots(),
                builder: (context, snap) {
                  final count = snap.hasData ? snap.data!.docs.length : '—';
                  return _StatCard(title: 'Riders', value: '$count');
                },
              ),
              StreamBuilder<QuerySnapshot>(
                stream: ordersRef
                    .where('status', isNotEqualTo: 'delivered')
                    .snapshots(),
                builder: (context, snap) {
                  final count = snap.hasData ? snap.data!.docs.length : '—';
                  return _StatCard(title: 'Active Orders', value: '$count');
                },
              ),
              StreamBuilder<QuerySnapshot>(
                stream: ordersRef.snapshots(),
                builder: (context, snap) {
                  if (!snap.hasData)
                    return _StatCard(title: 'Revenue (24h)', value: '—');
                  final now = DateTime.now();
                  final cutoff = now.subtract(const Duration(hours: 24));
                  num total = 0;
                  for (final d in snap.data!.docs) {
                    final data = d.data() as Map<String, dynamic>? ?? {};
                    final orderTime = data['orderTime'];
                    DateTime? dt;
                    if (orderTime == null) {
                      dt = null;
                    } else if (orderTime is Timestamp) {
                      dt = orderTime.toDate();
                    } else if (orderTime is int) {
                      dt = DateTime.fromMillisecondsSinceEpoch(orderTime);
                    } else if (orderTime is String &&
                        int.tryParse(orderTime) != null) {
                      dt = DateTime.fromMillisecondsSinceEpoch(
                        int.parse(orderTime),
                      );
                    }
                    if (dt != null && dt.isAfter(cutoff)) {
                      final amt = data['totalAmount'];
                      final numVal = amt is num
                          ? amt
                          : num.tryParse(amt?.toString() ?? '0') ?? 0;
                      total += numVal;
                    }
                  }
                  return _StatCard(
                    title: 'Revenue (24h)',
                    value: _formatCurrency(total),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Recent activity',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No activity to show (placeholder).'),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  const _StatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
