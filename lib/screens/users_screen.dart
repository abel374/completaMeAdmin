import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final usersRef = FirebaseFirestore.instance.collection('users');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Users',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Card(
            child: StreamBuilder<QuerySnapshot>(
              stream: usersRef
                  .orderBy('userName', descending: false)
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
                      child: Text('Nenhum usuário encontrado.'),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(8),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>? ?? {};
                    final name = data['userName'] ?? data['userName'] ?? '—';
                    final email = data['userEmail'] ?? '';
                    final avatar = data['userAvatarUrl'] as String?;
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
                                      const Icon(Icons.person),
                                )
                              : const Icon(Icons.person),
                        ),
                      ),
                      title: Text(name.toString()),
                      subtitle: Text(email.toString()),
                      trailing: PopupMenuButton<String>(
                        onSelected: (v) async {
                          if (v == 'details')
                            _showDetails(context, doc);
                          else if (v == 'toggle')
                            await _toggleStatus(context, doc);
                          else if (v == 'delete') {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (c) => AlertDialog(
                                title: const Text('Confirmar remoção'),
                                content: const Text(
                                  'Remover este usuário permanentemente?',
                                ),
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
                              ),
                            );
                            if (confirm == true) {
                              try {
                                await doc.reference.delete();
                                if (context.mounted)
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Usuário removido'),
                                    ),
                                  );
                              } catch (e) {
                                if (context.mounted)
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Erro: $e')),
                                  );
                              }
                            }
                          }
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
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text(
                              'Remover',
                              style: TextStyle(color: Colors.red),
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

  void _openImagePreview(BuildContext context, String url) {
    showDialog<void>(
      context: context,
      builder: (c) => Dialog(
        insetPadding: const EdgeInsets.all(12),
        child: SizedBox(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.75,
          child: InteractiveViewer(
            panEnabled: true,
            minScale: 0.5,
            maxScale: 5,
            child: CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.contain,
              placeholder: (c, u) =>
                  const Center(child: CircularProgressIndicator()),
              errorWidget: (c, u, e) =>
                  const Center(child: Icon(Icons.broken_image, size: 48)),
            ),
          ),
        ),
      ),
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
        title: Text(data['userName']?.toString() ?? 'Detalhes'),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              if ((data['userAvatarUrl'] ?? '').toString().isNotEmpty)
                GestureDetector(
                  onTap: () => _openImagePreview(
                    context,
                    data['userAvatarUrl'].toString(),
                  ),
                  child: SizedBox(
                    height: 200,
                    child: CachedNetworkImage(
                      imageUrl: data['userAvatarUrl'].toString(),
                      fit: BoxFit.cover,
                      placeholder: (c, u) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (_, __, ___) =>
                          const Icon(Icons.person, size: 80),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              Text('Email: ${data['userEmail'] ?? ''}'),
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
