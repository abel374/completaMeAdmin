import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SellersScreen extends StatelessWidget {
  const SellersScreen({super.key});

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
        ).showSnackBar(SnackBar(content: Text('Erro ao atualizar: $e')));
    }
  }

  Future<void> _deleteSeller(BuildContext context, DocumentSnapshot doc) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) {
        return AlertDialog(
          title: const Text('Confirmar remoção'),
          content: const Text('Deseja remover este vendedor permanentemente?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(c).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(c).pop(true),
              child: const Text('Remover'),
            ),
          ],
        );
      },
    );
    if (confirm != true) return;

    try {
      await doc.reference.delete();
      if (context.mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Vendedor removido')));
    } catch (e) {
      if (context.mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao remover: $e')));
    }
  }

  void _showDetails(BuildContext context, DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    showDialog<void>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(data['sellerName']?.toString() ?? 'Detalhes'),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              if ((data['sellerAvatarUrl'] ?? '').toString().isNotEmpty)
                SizedBox(
                  height: 120,
                  child: CachedNetworkImage(
                    imageUrl: data['sellerAvatarUrl'].toString(),
                    fit: BoxFit.cover,
                    placeholder: (c, u) =>
                        const Center(child: CircularProgressIndicator()),
                    errorWidget: (c, u, e) =>
                        const Icon(Icons.storefront, size: 80),
                  ),
                ),
              const SizedBox(height: 8),
              Text('Email: ${data['sellerEmail'] ?? ''}'),
              Text('Phone: ${data['phone'] ?? ''}'),
              Text('Address: ${data['address'] ?? ''}'),
              Text('Earnings: ${_formatCurrency(data['earnings'])}'),
              Text('Categoria: ${data['categoria'] ?? ''}'),
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

  @override
  Widget build(BuildContext context) {
    final sellersRef = FirebaseFirestore.instance.collection('sellers');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sellers',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Card(
            child: StreamBuilder<QuerySnapshot>(
              stream: sellersRef
                  .orderBy('sellerName', descending: false)
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
                      child: Text('Nenhum vendedor encontrado.'),
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
                    final name = data['sellerName'] ?? '—';
                    final email = data['sellerEmail'] ?? '';
                    final avatar = data['sellerAvatarUrl'] as String?;
                    final phone = data['phone'] ?? '';
                    final earnings = data['earnings'] ?? '';
                    final category =
                        data['categoria'] ?? data['category'] ?? '';
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
                                  placeholder: (c, url) => const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  errorWidget: (_, url, error) =>
                                      const Icon(Icons.storefront),
                                )
                              : const Icon(Icons.storefront),
                        ),
                      ),
                      title: Text(name.toString()),
                      subtitle: Text(
                        '$email\n$phone',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      isThreeLine: true,
                      trailing: PopupMenuButton<String>(
                        onSelected: (v) async {
                          if (v == 'details') {
                            _showDetails(context, doc);
                          } else if (v == 'toggle') {
                            await _toggleStatus(context, doc);
                          } else if (v == 'delete') {
                            await _deleteSeller(context, doc);
                          }
                        },
                        itemBuilder: (context) => [
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
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text(
                              'Remover',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                      subtitleTextStyle: const TextStyle(fontSize: 12),
                      onTap: () => _showDetails(context, doc),
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
