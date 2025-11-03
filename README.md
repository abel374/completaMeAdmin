# Foodpanda Admin Web Portal

Este projeto é o esqueleto do portal de administração (web) para gerenciar os apps `foodpanda_user_app` e `foodpanda_riders_app`.

O que foi criado nesta etapa:
- `lib/main.dart` — novo ponto de entrada com navegação responsiva (NavigationRail + Drawer)
- `lib/screens/*` — telas placeholder: Dashboard, Users, Riders, Orders, Settings

Como rodar (Web):

1. Certifique-se que Flutter e o suporte web estão instalados e ativados.
   - `flutter channel stable`;
   - `flutter upgrade`;
   - `flutter config --enable-web`

2. No diretório `foodpanda_admin_web_portal`, rode:

```powershell
flutter pub get
flutter run -d chrome
```

Integração com Firebase (próximos passos recomendados):
- Se você quer que o admin leia/escreva dados no mesmo projeto Firebase dos apps `user` e `riders`, recomendo usar o FlutterFire CLI para gerar `lib/firebase_options.dart` e adicionar `firebase_core`, `cloud_firestore`, `firebase_auth` ao `pubspec.yaml`.
- Alternativamente, posso implementar primeiro as telas com dados mock e, depois, integrar Firestore quando você confirmar o projeto/credenciais Firebase.

Problema comum com imagens (CORS) e solução
------------------------------------------------
Se as imagens hospedadas no Firebase Storage não aparecem no navegador e você vê erros como "HTTP request failed, statusCode: 0" no console, provavelmente é um bloqueio CORS no bucket do Storage.

Passos rápidos para corrigir (recomendo aplicar):
1. Crie um arquivo `cors.json` (já incluído neste repositório) com conteúdo de exemplo que permite requests GET/HEAD do `localhost` durante o desenvolvimento.
2. Instale o Google Cloud SDK e use `gsutil` para aplicar o CORS ao seu bucket (substitua o bucket se diferente):

```powershell
gcloud auth login
gsutil cors set cors.json gs://restaurantefoodly.appspot.com
```

3. Limpe o cache do navegador e recarregue a página (Ctrl+F5). As requisições às URLs do Storage deverão retornar 200 e as imagens carregarão.

Nota de segurança: não deixe `"origin": ["*"]` em produção — substitua por seus domínios e origens de desenvolvimento específicos.

Se quiser, eu também posso adicionar `cached_network_image` (já incluído no `pubspec.yaml`) para reduzir chamadas repetidas e melhorar o fallback visual quando alguma imagem falhar.

Próximas ações que eu posso executar agora (escolha uma):
- Adicionar Firebase + inicialização web (preciso que você confirme em qual projeto Firebase conectar ou me forneça `firebase_options.dart`).
- Implementar as listas reais de Users/Riders/Orders consultando Firestore (após a inicialização do Firebase).
- Melhorar UI/UX, tabelas, filtros e ações (ativar/desativar usuário, editar rider, etc.).
# foodpanda_admin_web_portal

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
