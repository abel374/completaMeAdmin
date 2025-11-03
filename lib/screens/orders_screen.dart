import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  String _formatOrderTime(dynamic raw) {
    try {
      if (raw == null) return '—';
      // Some orders use numeric string epoch millis
      if (raw is String && int.tryParse(raw) != null) {
        final ms = int.parse(raw);
        final dt = DateTime.fromMillisecondsSinceEpoch(ms);
        return '${dt.toLocal()}';
      }
      if (raw is int) {
        final dt = DateTime.fromMillisecondsSinceEpoch(raw);
        return '${dt.toLocal()}';
      }
      return raw.toString();
    } catch (_) {
      return raw.toString();
    }
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

  Future<void> _changeStatus(BuildContext context, DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final current = (data['status'] ?? '').toString();
    final controller = TextEditingController(text: current);
    final result = await showDialog<String?>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Alterar status'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Status'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(c).pop(null),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(c).pop(controller.text.trim()),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      try {
        await doc.reference.update({'status': result});
        if (context.mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Status alterado para $result')),
          );
      } catch (e) {
        if (context.mounted)
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Erro: $e')));
      }
    }
  }

  void _showDetails(BuildContext context, DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    showDialog<void>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Pedido ${data['orderId'] ?? doc.id}'),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              Text('OrderId: ${data['orderId'] ?? doc.id}'),
              Text('By: ${data['orderBy'] ?? ''}'),
              Text('Rider: ${data['riderName'] ?? ''}'),
              Text('Total: ${_formatCurrency(data['totalAmount'])}'),
              Text('Status: ${data['status'] ?? ''}'),
              const SizedBox(height: 8),
              Text('Address: ${data['address'] ?? ''}'),
              const SizedBox(height: 8),
              Text('Products:'),
              if (data['productIDs'] is List)
                ...((data['productIDs'] as List).map(
                  (e) => Text('- ${e.toString()}'),
                )),
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

  @override
  Widget build(BuildContext context) {
    final ordersRef = FirebaseFirestore.instance.collection('orders');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Orders',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Card(
            child: StreamBuilder<QuerySnapshot>(
              stream: ordersRef
                  .orderBy('orderTime', descending: true)
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
                      child: Text('Nenhum pedido encontrado.'),
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
                    final orderId = data['orderId'] ?? doc.id;
                    final userId = data['orderBy'] ?? '';
                    final total = data['totalAmount'] ?? '';
                    final status = data['status'] ?? '';
                    final riderName = data['riderName'] ?? '';
                    final orderTimeRaw = data['orderTime'];

                    return ListTile(
                      leading: const Icon(Icons.receipt_long),
                      title: Text(orderId.toString()),
                      subtitle: Text(
                        '${riderName.toString()} · ${status.toString()} · ${userId.toString()}',
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (v) async {
                          if (v == 'details')
                            _showDetails(context, doc);
                          else if (v == 'status')
                            await _changeStatus(context, doc);
                        },
                        itemBuilder: (c) => const [
                          PopupMenuItem(
                            value: 'details',
                            child: Text('Ver detalhes'),
                          ),
                          PopupMenuItem(
                            value: 'status',
                            child: Text('Alterar status'),
                          ),
                        ],
                        child: SizedBox(
                          height: 48,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _formatCurrency(total),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 13),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _formatOrderTime(orderTimeRaw),
                                style: const TextStyle(fontSize: 11),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
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
}
