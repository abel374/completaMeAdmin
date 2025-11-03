import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:foodpanda_admin_web_portal/firebase_options.dart';
import 'admin_home.dart';
import 'auth/auth_gate.dart';
import 'package:provider/provider.dart';
import 'theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const AdminApp());
}

class AdminApp extends StatefulWidget {
  const AdminApp({super.key});

  @override
  State<AdminApp> createState() => _AdminAppState();
}

class _AdminAppState extends State<AdminApp> {
  // ✨ Transição global personalizada (Fade + Slide Up)
  PageTransitionsTheme _customPageTransitions() {
    const duration = Duration(milliseconds: 450);
    return PageTransitionsTheme(
      builders: {
        TargetPlatform.android: _FadeSlidePageTransitionsBuilder(duration),
        TargetPlatform.iOS: _FadeSlidePageTransitionsBuilder(duration),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (c) => ThemeProvider())],
      child: Builder(
        builder: (context) {
          final themeProvider = Provider.of<ThemeProvider>(context);
          return MaterialApp(
            title: 'Foodpanda Admin Portal',

            // 🌗 Usa o modo de tema do provider
            themeMode: themeProvider.themeMode,

            // 🌤️ Tema claro CompletaMe
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: const ColorScheme.light(
                primary: Color(0xFFFF6F61), // rosa coral
                secondary: Color(0xFF1DD1A1), // azul turquesa
                background: Colors.white,
                surface: Color(0xFFF5F6FA),
                onPrimary: Colors.white,
                onSecondary: Colors.white,
                onBackground: Color(0xFF2C3E50),
              ),
              scaffoldBackgroundColor: Colors.white,
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFFFF6F61),
                foregroundColor: Colors.white,
                elevation: 2,
                centerTitle: true,
                titleTextStyle: TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              cardTheme: CardThemeData(
                color: const Color(0xFFF5F6FA),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 3,
              ),
              floatingActionButtonTheme: const FloatingActionButtonThemeData(
                backgroundColor: Color(0xFF1DD1A1),
                foregroundColor: Colors.white,
              ),
              textTheme: const TextTheme(
                headlineMedium: TextStyle(
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
                bodyMedium: TextStyle(
                  fontFamily: "Poppins",
                  color: Color(0xFF2C3E50),
                ),
              ),
              pageTransitionsTheme: _customPageTransitions(),
            ),

            // 🌙 Tema escuro CompletaMe
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: const ColorScheme.dark(
                primary: Color(0xFFFF6F61),
                secondary: Color(0xFF1DD1A1),
                background: Color(0xFF121212),
                surface: Color(0xFF1E1E1E),
                onPrimary: Colors.white,
                onSecondary: Colors.white,
                onBackground: Colors.white,
              ),
              scaffoldBackgroundColor: const Color(0xFF121212),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFFFF6F61),
                foregroundColor: Colors.white,
                elevation: 0,
                centerTitle: true,
                titleTextStyle: TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              cardTheme: CardThemeData(
                color: const Color(0xFF1E1E1E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 3,
              ),
              floatingActionButtonTheme: const FloatingActionButtonThemeData(
                backgroundColor: Color(0xFF1DD1A1),
                foregroundColor: Colors.white,
              ),
              textTheme: const TextTheme(
                headlineMedium: TextStyle(
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                bodyMedium: TextStyle(
                  fontFamily: "Poppins",
                  color: Colors.white70,
                ),
              ),
              pageTransitionsTheme: _customPageTransitions(),
            ),

            home: const AuthGate(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

// ✨ Fade + Slide Up Transitions
class _FadeSlidePageTransitionsBuilder extends PageTransitionsBuilder {
  final Duration duration;
  const _FadeSlidePageTransitionsBuilder(this.duration);

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const beginOffset = Offset(0.0, 0.08);
    const endOffset = Offset.zero;
    const curve = Curves.easeOutCubic;

    var slideAnimation = Tween(
      begin: beginOffset,
      end: endOffset,
    ).chain(CurveTween(curve: curve));
    var fadeAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeInOut,
    );

    return SlideTransition(
      position: animation.drive(slideAnimation),
      child: FadeTransition(opacity: fadeAnimation, child: child),
    );
  }
}
