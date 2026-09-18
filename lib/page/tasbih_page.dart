import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:tasbih_web/controller/tasbih_controller.dart';


class TasbihPage extends GetView<TasbihController> {
  const TasbihPage({super.key});

  static const _green = Color(0xFF52B788);
  static const _greenDark = Color(0xFF2D6A4F);
  static const _textDark = Color(0xFF1B3A2D);
  static const _bg = Color(0xFFF5F3EE);

  @override
  Widget build(BuildContext context) {
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
            SafeArea(
              child: Obx(() {
                if (!controller.isLoaded.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: _green),
                  );
                }
                return Column(
                  children: [
                    _buildAppBar(),
                    const SizedBox(height: 28),
                    _buildTargetChip(context),
                    const SizedBox(height: 36),
                    Expanded(child: Center(child: _buildCounterCircle())),
                    const SizedBox(height: 28),
                    _buildStatsRow(),
                    const SizedBox(height: 18),
                    _buildHint(),
                    const SizedBox(height: 28),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ─── App bar: back + title/subtitle + reset (icon-only, kecil) ─────────
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(
              Icons.arrow_back_ios_rounded,
              color: _textDark,
              size: 20,
            ),
          ),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tasbih Digital',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: _textDark,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Hitung dzikir Anda dengan tenang',
                  style: TextStyle(
                    fontSize: 11,
                    color: _green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          _buildLeaderboardButton(),
          const SizedBox(width: 8),
          _buildResetButton(),
        ],
      ),
    );
  }

  Widget _buildLeaderboardButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Get.toNamed('/dashboard/tasbih-leaderboard'),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.leaderboard_rounded,
            color: _greenDark,
            size: 19,
          ),
        ),
      ),
    );
  }

  Widget _buildResetButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: controller.reset,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFFFDAB9).withOpacity(0.55),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.refresh_rounded,
            color: _textDark,
            size: 19,
          ),
        ),
      ),
    );
  }

  // ─── Chip target: 33 / 99 / manual / unlimited ─────────────────────────
  Widget _buildTargetChip(BuildContext context) {
    return GestureDetector(
      onTap: () => _showTargetSheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.track_changes_rounded, color: _green, size: 18),
            const SizedBox(width: 8),
            Obx(() => Text(
              'Target: ${controller.targetLabel}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: _green,
              ),
            )),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down_rounded,
                color: _green, size: 20),
          ],
        ),
      ),
    );
  }

  // ─── Lingkaran counter utama ────────────────────────────────────────────
  Widget _buildCounterCircle() {
    const size = 300.0;
    return Obx(() {
      final reached = controller.isTargetReached;
      return GestureDetector(
        onTap: controller.increment,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _green.withOpacity(reached ? 0.35 : 0.18),
                blurRadius: 40,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Base putih
              Container(
                margin: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
              // Ring progress
              if (!controller.isUnlimited)
                CustomPaint(
                  size: const Size(size, size),
                  painter: _RingPainter(
                    progress: controller.progress,
                    trackColor: const Color(0xFFF0EAE6),
                    progressColor: _green,
                    strokeWidth: 14,
                  ),
                )
              else
                CustomPaint(
                  size: const Size(size, size),
                  painter: _RingPainter(
                    progress: 0,
                    trackColor: const Color(0xFFF0EAE6),
                    progressColor: _green,
                    strokeWidth: 14,
                  ),
                ),
              // Konten tengah
              reached
                  ? const Text(
                'Target\nTercapai',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: _green,
                  height: 1.2,
                ),
              )
                  : Text(
                '${controller.count.value}',
                style: const TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.w800,
                  color: _green,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildHint() {
    return Obx(() {
      final reached = controller.isTargetReached;
      if (reached) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.info_outline_rounded, size: 15, color: Colors.black38),
            SizedBox(width: 6),
            Text(
              'Tekan Reset untuk mengulang hitungan',
              style: TextStyle(fontSize: 13, color: Colors.black45),
            ),
          ],
        );
      }
      return const Text(
        'Ketuk lingkaran untuk bertasbih',
        style: TextStyle(fontSize: 14, color: Colors.black54),
      );
    });
  }

  // ─── Stat kecil di bawah lingkaran: progress %, sisa, sesi selesai ─────
  Widget _buildStatsRow() {
    return Obx(() {
      if (controller.isUnlimited) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.all_inclusive_rounded,
                    color: _green, size: 20),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Mode tanpa batas — hitung sesukamu',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '${controller.count.value}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: _textDark,
                  ),
                ),
              ],
            ),
          ),
        );
      }
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Expanded(
              child: _statCard(
                icon: Icons.donut_large_rounded,
                label: 'Progress',
                value: '${controller.progressPercent}%',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard(
                icon: Icons.hourglass_bottom_rounded,
                label: 'Sisa',
                value: '${controller.remaining}',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard(
                icon: Icons.emoji_events_outlined,
                label: controller.serverKhatam.value != null
                    ? 'Selesai'
                    : 'Selesai (lokal)',
                value: controller.isLoadingServerStats.value
                    ? '…'
                    : '${controller.serverKhatam.value ?? controller.roundCompleted.value}',
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _statCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: _green, size: 18),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10.5,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Bottom sheet pilih target ──────────────────────────────────────────
  void _showTargetSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pilih Target Tasbih',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 16),
                _sheetOption(ctx, '33', TasbihMode.target33),
                _sheetOption(ctx, '99', TasbihMode.target99),
                _sheetOption(ctx, 'Manual', TasbihMode.manual,
                    onManualTap: () => _showManualDialog(ctx)),
                _sheetOption(ctx, 'Unlimited', TasbihMode.unlimited),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sheetOption(
      BuildContext ctx,
      String label,
      TasbihMode targetMode, {
        VoidCallback? onManualTap,
      }) {
    return Obx(() {
      final selected = controller.mode.value == targetMode;
      return GestureDetector(
        onTap: () {
          if (targetMode == TasbihMode.manual) {
            Navigator.pop(ctx);
            onManualTap?.call();
          } else {
            controller.setTargetMode(targetMode);
            Navigator.pop(ctx);
          }
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: selected ? _green.withOpacity(0.1) : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? _green : Colors.grey.shade200,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  targetMode == TasbihMode.manual && selected
                      ? 'Manual (${controller.target.value})'
                      : label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: selected ? _greenDark : _textDark,
                  ),
                ),
              ),
              if (selected)
                const Icon(Icons.check_circle_rounded,
                    color: _green, size: 20),
            ],
          ),
        ),
      );
    });
  }

  void _showManualDialog(BuildContext context) {
    final textController =
    TextEditingController(text: controller.target.value.toString());
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Set Target Manual',
            style: TextStyle(
                fontWeight: FontWeight.w800, color: _textDark, fontSize: 16),
          ),
          content: TextField(
            controller: textController,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Masukkan jumlah target...',
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _green),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Batal',
                  style: TextStyle(color: Colors.grey.shade500)),
            ),
            TextButton(
              onPressed: () {
                final value = int.tryParse(textController.text.trim());
                if (value != null && value > 0) {
                  controller.setTargetMode(TasbihMode.manual,
                      customTarget: value);
                }
                Navigator.pop(ctx);
              },
              child: const Text(
                'Simpan',
                style: TextStyle(color: _green, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Custom painter untuk ring progress, mulai dari atas (jam 12) searah jarum jam.
class _RingPainter extends CustomPainter {
  final double progress; // 0.0 - 1.0
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  _RingPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Track (full circle, tipis di belakang)
    canvas.drawCircle(center, radius, trackPaint);

    // Progress arc mulai dari jam 12 (-90deg), searah jarum jam
    if (progress > 0) {
      final sweep = 2 * math.pi * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweep,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor;
  }
}