import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:tasbih_web/controller/tasbih_controller.dart' show TasbihMode;
import 'package:tasbih_web/controller/tasbih_leaderboard_controller.dart';
import 'package:tasbih_web/entities/leaderboard_entry.dart';

class TasbihLeaderboardPage extends GetView<TasbihLeaderboardController> {
  const TasbihLeaderboardPage({super.key});

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
              child: RefreshIndicator(
                color: _green,
                onRefresh: controller.loadLeaderboard,
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(child: _buildAppBar()),
                    SliverToBoxAdapter(child: const SizedBox(height: 16)),
                    SliverToBoxAdapter(child: _buildModeToggle()),
                    SliverToBoxAdapter(child: const SizedBox(height: 10)),
                    SliverToBoxAdapter(child: _buildMetricToggle()),
                    SliverToBoxAdapter(child: const SizedBox(height: 16)),
                    SliverToBoxAdapter(child: _buildMyRankCard()),
                    SliverToBoxAdapter(child: const SizedBox(height: 8)),
                    SliverToBoxAdapter(child: _buildListSectionTitle()),
                    _buildList(),
                    const SliverToBoxAdapter(child: SizedBox(height: 32)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back_ios_rounded,
                color: _textDark, size: 20),
          ),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Leaderboard Tasbih',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: _textDark,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Lihat pencapaian dzikirmu vs yang lain',
                  style: TextStyle(
                    fontSize: 11,
                    color: _green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Obx(() => Row(
        children: [
          Expanded(child: _modeChip('Target 33', TasbihMode.target33)),
          const SizedBox(width: 10),
          Expanded(child: _modeChip('Target 99', TasbihMode.target99)),
        ],
      )),
    );
  }

  Widget _modeChip(String label, TasbihMode mode) {
    final selected = controller.selectedMode.value == mode;
    return GestureDetector(
      onTap: () => controller.selectedMode.value = mode,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? _green : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? _green : Colors.grey.shade200,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : _textDark,
          ),
        ),
      ),
    );
  }

  Widget _buildMetricToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Obx(() => Row(
        children: [
          _metricPill('Khatam', LeaderboardMetric.khatam,
              Icons.emoji_events_outlined),
          const SizedBox(width: 8),
          _metricPill('Total Hitungan', LeaderboardMetric.hitungan,
              Icons.pin_outlined),
        ],
      )),
    );
  }

  Widget _metricPill(String label, LeaderboardMetric metric, IconData icon) {
    final selected = controller.selectedMetric.value == metric;
    return GestureDetector(
      onTap: () => controller.selectedMetric.value = metric,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? _green.withOpacity(0.12) : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selected ? _green : Colors.grey.shade200,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 14, color: selected ? _greenDark : Colors.grey.shade500),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: selected ? _greenDark : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Kartu posisi kamu ────────────────────────────────────────────────
  Widget _buildMyRankCard() {
    return Obx(() {
      if (!controller.isLoggedIn) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded,
                  size: 16, color: Colors.grey.shade500),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Login untuk ikut tercatat di leaderboard',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ),
            ],
          ),
        );
      }

      final entry = controller.myEntry.value;
      final rank = controller.myRank.value;
      if (entry == null || rank == null) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded,
                  size: 16, color: Colors.grey.shade500),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Belum ada catatan di mode ini — mulai bertasbih dulu!',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ),
            ],
          ),
        );
      }

      // Kalau kamu udah kelihatan di list utama di bawah (top 50), jangan
      // tampilin lagi di sini — cukup baris kamu di list yang di-highlight.
      // Kartu ini cuma buat kasus kamu ADA datanya tapi di LUAR top 50.
      final alreadyVisibleInList =
      controller.list.any((e) => e.userUid == entry.userUid);
      if (alreadyVisibleInList) return const SizedBox.shrink();

      final value = controller.selectedMetric.value == LeaderboardMetric.khatam
          ? entry.totalKhatam
          : entry.totalHitungan;

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _green.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            _rankBadge(rank),
            const SizedBox(width: 12),
            _avatar(entry.photo, size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Posisi Kamu',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: _greenDark,
                    ),
                  ),
                  Text(
                    entry.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: _textDark,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '$value',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _greenDark,
              ),
            ),
          ],
        ),
      );
    });
  }

  // ─── List leaderboard ───────────────────────────────────────────────
  Widget _buildListSectionTitle() {
    return Obx(() {
      final modeLabel = controller.selectedMode.value == TasbihMode.target33
          ? 'Target 33'
          : 'Target 99';
      final metricLabel =
      controller.selectedMetric.value == LeaderboardMetric.khatam
          ? 'Khatam'
          : 'Total Hitungan';
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
        child: Text(
          'Peringkat $modeLabel — $metricLabel',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade500,
          ),
        ),
      );
    });
  }

  Widget _buildList() {
    return Obx(() {
      if (controller.isLoading.value && controller.list.isEmpty) {
        return const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(40),
            child: Center(child: CircularProgressIndicator(color: _green)),
          ),
        );
      }

      if (controller.list.isEmpty) {
        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Column(
              children: [
                Icon(Icons.emoji_events_outlined,
                    size: 40, color: Colors.grey.shade300),
                const SizedBox(height: 10),
                Text(
                  'Belum ada yang tercatat di mode ini.\nJadilah yang pertama!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12.5, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
        );
      }

      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
                (ctx, index) {
              final entry = controller.list[index];
              final rank = index + 1;
              final value = controller.selectedMetric.value ==
                  LeaderboardMetric.khatam
                  ? entry.totalKhatam
                  : entry.totalHitungan;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildEntryTile(rank, entry, value),
              );
            },
            childCount: controller.list.length,
          ),
        ),
      );
    });
  }

  Widget _buildEntryTile(int rank, LeaderboardEntry entry, int value) {
    final isMe = controller.isMe(entry.userUid);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isMe ? _green.withOpacity(0.08) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isMe ? Border.all(color: _green.withOpacity(0.4)) : null,
        boxShadow: isMe
            ? []
            : [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          _rankBadge(rank),
          const SizedBox(width: 12),
          _avatar(entry.photo, size: 42),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    entry.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: _textDark,
                    ),
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _green,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Kamu',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            '$value',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: _greenDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _rankBadge(int rank) {
    String? medal;
    if (rank == 1) medal = '🥇';
    if (rank == 2) medal = '🥈';
    if (rank == 3) medal = '🥉';

    return SizedBox(
      width: 28,
      child: medal != null
          ? Text(medal, style: const TextStyle(fontSize: 20))
          : Text(
        '$rank',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade500,
        ),
      ),
    );
  }

  Widget _avatar(String photoUrl, {required double size}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size / 2),
      child: photoUrl.isNotEmpty
          ? CachedNetworkImage(
        imageUrl: photoUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorWidget: (c, u, e) => _avatarPlaceholder(size),
      )
          : _avatarPlaceholder(size),
    );
  }

  Widget _avatarPlaceholder(double size) {
    return Container(
      width: size,
      height: size,
      color: _green.withOpacity(0.1),
      child: Icon(Icons.person_rounded, color: _green, size: size * 0.55),
    );
  }
}