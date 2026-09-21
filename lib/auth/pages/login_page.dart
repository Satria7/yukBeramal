import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  static const _green = Color(0xFF52B788);
  static const _textDark = Color(0xFF1B3A2D);
  static const _bg = Color(0xFFF5F3EE);

  @override
  Widget build(BuildContext context) {
    // Controller di-put di sini (bukan lewat Binding terpisah) — sesuai
    // permintaan biar flow-nya sesimpel mungkin.
    final controller = Get.put(AuthController());

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: _bg,
        body: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFEDF7F2), Color(0xFFF5F3EE)],
                  ),
                ),
              ),
            ),
            Positioned(
              top: -60,
              right: -60,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _green.withOpacity(0.12),
                ),
              ),
            ),
            Positioned(
              bottom: -80,
              left: -60,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _green.withOpacity(0.08),
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Logo ──
                        Center(
                          child: Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: _green.withOpacity(0.2),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                '📿',
                                style: TextStyle(fontSize: 42),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: _green,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'YUK BERAMAL',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2.5,
                                color: _green,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          'Hitung Dzikir,\nTerhubung Bersama',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: _textDark,
                            letterSpacing: -0.5,
                            height: 1.25,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Text(
                          'Masuk untuk menyimpan pencapaianmu dan lihat peringkat bersama pengguna lain.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                            height: 1.6,
                          ),
                        ),

                        const SizedBox(height: 40),

                        // ── Tombol Google ──
                        Obx(
                              () => GestureDetector(
                            onTap: controller.isLoading.value
                                ? null
                                : controller.signInWithGoogle,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.07),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: controller.isLoading.value
                                  ? const Center(
                                child: SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: _green,
                                    strokeWidth: 2.5,
                                  ),
                                ),
                              )
                                  : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.login_rounded,
                                    color: _textDark,
                                    size: 20,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'Masuk dengan Google',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: _textDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        Center(
                          child: Text(
                            'Dengan masuk, kamu menyetujui syarat & ketentuan yang berlaku.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade400,
                              height: 1.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              left: 0,
              right: 0,
              bottom: 16,
              child: SafeArea(
                top: false,
                child: Center(
                  child: Text(
                    'yukBeramal by Satria Junanda',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade400,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
