import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SlidersScreen extends StatefulWidget {
  const SlidersScreen({super.key});

  @override
  State<SlidersScreen> createState() => _SlidersScreenState();
}

class _SlidersScreenState extends State<SlidersScreen> {
  final docRef = FirebaseFirestore.instance
      .collection('sliders')
      .doc('home_slider');
  final TextEditingController _urlController = TextEditingController();
  bool _saving = false;

  Future<void> _addImage(List images) async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;
    if (!_isValidImageUrl(url)) {
      if (context.mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'URL inválida. Use http(s) e a URL deve apontar para uma imagem.',
            ),
          ),
        );
      return;
    }
    images.add(url);
    _urlController.clear();
    await _save(images);
  }

  bool _isValidImageUrl(String url) {
    try {
      final uri = Uri.tryParse(url);
      if (uri == null) return false;
      if (!(uri.scheme == 'http' || uri.scheme == 'https')) return false;
      final path = uri.path.toLowerCase();
      if (path.endsWith('.png') ||
          path.endsWith('.jpg') ||
          path.endsWith('.jpeg') ||
          path.endsWith('.webp') ||
          path.endsWith('.gif'))
        return true;
      if (url.length > 10 && url.length < 2000) return true;
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> _save(List images) async {
    setState(() => _saving = true);
    try {
      await docRef.set({
        'images': images,
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      if (context.mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Slider atualizado')));
    } catch (e) {
      if (context.mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return FutureBuilder<IdTokenResult?>(
      future: user?.getIdTokenResult(),
      builder: (context, tokenSnap) {
        final claims = tokenSnap.data?.claims ?? {};
        final isAdmin =
            (claims['admin'] == true) ||
            (claims['isAdmin'] == true) ||
            (claims['role'] == 'admin');

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sliders',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Card(
                child: StreamBuilder<DocumentSnapshot>(
                  stream: docRef.snapshots(),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snap.hasError)
                      return Center(child: Text('Erro: ${snap.error}'));

                    final data =
                        snap.data?.data() as Map<String, dynamic>? ?? {};
                    final images = List.of(data['images'] ?? []);

                    return Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Imagem do slider (array de URLs)'),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _urlController,
                                  decoration: const InputDecoration(
                                    hintText:
                                        'Cole a URL da imagem e clique em Adicionar',
                                  ),
                                  enabled: isAdmin,
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: (!isAdmin || _saving)
                                    ? null
                                    : () => _addImage(images),
                                child: _saving
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text('Adicionar'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: images.isEmpty
                                ? const Center(
                                    child: Text('Nenhuma imagem configurada.'),
                                  )
                                : ReorderableListView.builder(
                                    itemCount: images.length,
                                    onReorder: (!isAdmin)
                                        ? (_, __) {}
                                        : (oldIndex, newIndex) async {
                                            setState(() {
                                              if (newIndex > oldIndex)
                                                newIndex -= 1;
                                              final item = images.removeAt(
                                                oldIndex,
                                              );
                                              images.insert(newIndex, item);
                                            });
                                            await _save(images);
                                          },
                                    itemBuilder: (context, index) {
                                      final url = images[index] as String;
                                      return ListTile(
                                        key: ValueKey(url + index.toString()),
                                        leading: SizedBox(
                                          width: 80,
                                          height: 56,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                            child: CachedNetworkImage(
                                              imageUrl: url,
                                              fit: BoxFit.cover,
                                              placeholder: (c, u) => const Center(
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                              ),
                                              errorWidget: (c, u, e) =>
                                                  const Icon(
                                                    Icons.broken_image,
                                                  ),
                                            ),
                                          ),
                                        ),
                                        title: Text(
                                          url,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        trailing: IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed: !isAdmin
                                              ? null
                                              : () async {
                                                  final keep = await showDialog<bool>(
                                                    context: context,
                                                    builder: (c) => AlertDialog(
                                                      title: const Text(
                                                        'Remover imagem?',
                                                      ),
                                                      content: const Text(
                                                        'Deseja remover esta imagem do slider?',
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.of(
                                                                c,
                                                              ).pop(false),
                                                          child: const Text(
                                                            'Cancelar',
                                                          ),
                                                        ),
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.of(
                                                                c,
                                                              ).pop(true),
                                                          child: const Text(
                                                            'Remover',
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                  if (keep == true) {
                                                    images.removeAt(index);
                                                    await _save(images);
                                                  }
                                                },
                                        ),
                                      );
                                    },
                                  ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: (!isAdmin || _saving)
                                ? null
                                : () => _save(images),
                            icon: const Icon(Icons.save),
                            label: Text(
                              isAdmin
                                  ? 'Salvar alterações'
                                  : 'Apenas leitura (admin required)',
                            ),
                          ),
                          if (!isAdmin)
                            const Padding(
                              padding: EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Você não tem permissão para editar sliders. Faça login com uma conta admin.',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
