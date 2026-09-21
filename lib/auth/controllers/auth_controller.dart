import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

/// Auth minimal khusus versi web: cuma Google, pakai signInWithPopup
/// langsung dari firebase_auth (TIDAK butuh package google_sign_in sama
/// sekali — itu package khusus mobile, di web malah lebih ribet setup-nya
/// dibanding manfaatnya).
class AuthController extends GetxController {
  final isLoading = false.obs;

  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;
      final provider = GoogleAuthProvider();
      final credential = await FirebaseAuth.instance.signInWithPopup(provider);
      final user = credential.user;
      if (user != null) {
        await _syncUserToSupabase(user);
      }
      // Tidak perlu navigasi manual — AuthGate di main.dart otomatis
      // pindah ke TasbihPage begitu FirebaseAuth.authStateChanges() berubah.
    } catch (e) {
      print('Error sign in with Google: $e');
      Get.snackbar(
        'Gagal Masuk',
        'Terjadi kesalahan saat login dengan Google. Coba lagi.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Simpan/update nama & foto user ke tabel 'users' di Supabase, biar
  /// muncul dengan benar di Leaderboard (bukan cuma "Pengguna" generik).
  Future<void> _syncUserToSupabase(User user) async {
    try {
      await Supabase.instance.client.from('users').upsert({
        'uid': user.uid,
        'email': user.email ?? '',
        'name': user.displayName ?? '',
        'photo': user.photoURL ?? '',
        'last_login': DateTime.now().toIso8601String(),
      }, onConflict: 'uid');
    } catch (e) {
      print('Gagal sync user ke Supabase: $e');
    }
  }
}
