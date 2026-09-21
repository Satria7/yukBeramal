import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'auth/pages/login_page.dart';
import 'features/tasbih/persentation/controllers/tasbih_controller.dart';
import 'features/tasbih/persentation/controllers/tasbih_leaderboard_controller.dart';
import 'features/tasbih/persentation/pages/tasbih_leaderboard_page.dart';
import 'features/tasbih/persentation/pages/tasbih_page.dart';

// ============================================================
// GANTI semua nilai di bawah ini sesuai project Firebase & Supabase kamu.
//
// Firebase: buka Firebase Console -> project "exploresumbawa-b0e70"
// (atau project Firebase kamu yang lain) -> klik ikon gear -> Project
// Settings -> scroll ke "Your apps". Kalau belum ada app dengan ikon
// "</>" (Web), klik "Add app" -> pilih Web -> daftarkan (kasih nama
// bebas, misal "Tasbih Web") -> nanti muncul object firebaseConfig,
// isi nilainya ke bawah ini.
//
// Supabase: nilai ini SAMA PERSIS seperti yang sudah kamu pakai di
// index.html untuk halaman QR warung kemarin (Project Settings -> API
// Keys -> Publishable key).
// ============================================================
const _firebaseOptionsWeb = FirebaseOptions(
  apiKey: 'AIzaSyD6qzxek2BEXBi7pv_m-hiMmaRgVQgR-UI',
  authDomain: 'exploresumbawa-b0e70.firebaseapp.com',
  projectId: 'exploresumbawa-b0e70',
  storageBucket: 'exploresumbawa-b0e70.appspot.com',
  messagingSenderId: '744806959040',
  appId: '1:744806959040:web:df2ca0faec684ffcb52a25',
);

const _supabaseUrl = 'https://qdvctenwuswmwqqglstc.supabase.co';
const _supabaseAnonKey = 'sb_publishable_uGozUFkkHh8GZBB4WEjbWw_aJkbD4jW';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: _firebaseOptionsWeb);
  await Supabase.initialize(url: _supabaseUrl, anonKey: _supabaseAnonKey);

  runApp(const TasbihWebApp());
}

class TasbihWebApp extends StatelessWidget {
  const TasbihWebApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Tasbih Digital',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        colorSchemeSeed: const Color(0xFF52B788),
        scaffoldBackgroundColor: const Color(0xFFF5F3EE),
      ),
      home: const AuthGate(),
      getPages: [
        GetPage(
          name: '/leaderboard',
          page: () => const TasbihLeaderboardPage(),
          binding: BindingsBuilder(() {
            Get.lazyPut<TasbihLeaderboardController>(
                    () => TasbihLeaderboardController());
          }),
        ),
      ],
    );
  }
}

/// Alur paling simpel: dengar status login Firebase — belum login munculin
/// LoginPage, udah login langsung ke TasbihPage. Nggak ada splash/dashboard/
/// halaman perantara lain.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFFF5F3EE),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF52B788)),
            ),
          );
        }

        final user = snapshot.data;
        if (user == null) {
          return const LoginPage();
        }

        if (!Get.isRegistered<TasbihController>()) {
          Get.put(TasbihController());
        }
        return const TasbihPage();
      },
    );
  }
}
