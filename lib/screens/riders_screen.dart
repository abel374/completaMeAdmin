import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

class RidersScreen extends StatelessWidget {
  const RidersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ridersRef = FirebaseFirestore.instance.collection('riders');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Riders',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Card(
            child: StreamBuilder<QuerySnapshot>(
              stream: ridersRef
                  .orderBy('riderName', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                }

                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('Nenhum rider encontrado.'),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(8),
                  separatorBuilder: (_, __) => const Divider(),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>? ?? {};
                    final name = data['riderName'] ?? '—';
                    final phone = data['phone'] ?? '';
                    final avatar = data['riderAvatarUrl'] as String?;
                    final earnings = data['earnings'] ?? '';
                    final status = data['status'] ?? '';

                    return ListTile(
                      leading: SizedBox(
                        width: 56,
                        height: 56,
                        child: ClipOval(
                          child: avatar != null && avatar.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: avatar,
                                  fit: BoxFit.cover,
                                  placeholder: (c, u) => const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  errorWidget: (_, __, ___) =>
                                      const Icon(Icons.pedal_bike),
                                )
                              : const Icon(Icons.pedal_bike),
                        ),
                      ),
                      title: Text(name.toString()),
                      subtitle: Text(
                        '${phone.toString()} · ${_formatCurrency(earnings)}',
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (v) async {
                          if (v == 'details')
                            _showDetails(context, doc);
                          else if (v == 'toggle')
                            await _toggleStatus(context, doc);
                        },
                        itemBuilder: (c) => [
                          const PopupMenuItem(
                            value: 'details',
                            child: Text('Ver detalhes'),
                          ),
                          PopupMenuItem(
                            value: 'toggle',
                            child: Text(
                              (status.toString().toLowerCase() == 'approved' ||
                                      status.toString().toLowerCase() ==
                                          'active')
                                  ? 'Bloquear'
                                  : 'Aprovar',
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  String _formatCurrency(dynamic value) {
    try {
      if (value == null) return 'Kz 0';
      final numVal = value is num ? value : num.tryParse(value.toString()) ?? 0;
      final f = NumberFormat.currency(
        locale: 'pt_BR',
        symbol: 'Kz',
        decimalDigits: 0,
      );
      return f.format(numVal);
    } catch (_) {
      return 'Kz ${value.toString()}';
    }
  }

  Future<void> _toggleStatus(BuildContext context, DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final current = (data['status'] ?? '').toString();
    final newStatus =
        (current.toLowerCase() == 'approved' ||
            current.toLowerCase() == 'active')
        ? 'blocked'
        : 'approved';
    try {
      await doc.reference.update({'status': newStatus});
      if (context.mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status alterado para $newStatus')),
        );
    } catch (e) {
      if (context.mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro: $e')));
    }
  }

  void _showDetails(BuildContext context, DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    showDialog<void>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(data['riderName']?.toString() ?? 'Detalhes'),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              if ((data['riderAvatarUrl'] ?? '').toString().isNotEmpty)
                SizedBox(
                  height: 120,
                  child: CachedNetworkImage(
                    imageUrl: data['riderAvatarUrl'].toString(),
                    fit: BoxFit.cover,
                    placeholder: (c, u) =>
                        const Center(child: CircularProgressIndicator()),
                    errorWidget: (_, __, ___) =>
                        const Icon(Icons.pedal_bike, size: 80),
                  ),
                ),
              const SizedBox(height: 8),
              Text('Email: ${data['riderEmail'] ?? ''}'),
              Text('Phone: ${data['phone'] ?? ''}'),
              Text('Address: ${data['address'] ?? ''}'),
              Text('Earnings: ${_formatCurrency(data['earnings'])}'),
              Text('Status: ${data['status'] ?? ''}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(c).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}
