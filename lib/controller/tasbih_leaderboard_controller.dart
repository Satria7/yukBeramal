import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../entities/leaderboard_entry.dart';
import 'tasbih_controller.dart' show TasbihMode;

enum LeaderboardMetric { khatam, hitungan }

class TasbihLeaderboardController extends GetxController {
  final _supabase = Supabase.instance.client;

  final selectedMode = TasbihMode.target33.obs;
  final selectedMetric = LeaderboardMetric.khatam.obs;

  final list = <LeaderboardEntry>[].obs;
  final isLoading = false.obs;

  final myRank = Rxn<int>();
  final myEntry = Rxn<LeaderboardEntry>();

  String get _modeStr =>
      selectedMode.value == TasbihMode.target33 ? 'target33' : 'target99';

  String get _metricColumn => selectedMetric.value == LeaderboardMetric.khatam
      ? 'total_khatam'
      : 'total_hitungan';

  bool get isLoggedIn => FirebaseAuth.instance.currentUser != null;

  bool isMe(String userUid) =>
      userUid.isNotEmpty && userUid == FirebaseAuth.instance.currentUser?.uid;

  @override
  void onInit() {
    super.onInit();
    loadLeaderboard();
    ever(selectedMode, (_) => loadLeaderboard());
    ever(selectedMetric, (_) => loadLeaderboard());
  }

  Future<void> loadLeaderboard() async {
    try {
      isLoading.value = true;
      myRank.value = null;
      myEntry.value = null;

      final response = await _supabase
          .from('tasbih_stats')
          .select('*, users(name, photo)')
          .eq('mode', _modeStr)
          .order(_metricColumn, ascending: false)
          .limit(50);

      list.value =
          (response as List).map((e) => LeaderboardEntry.fromJson(e)).toList();

      await _loadMyRank();
    } catch (e) {
      print('Error load leaderboard: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadMyRank() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) return;

    // Kalau kebetulan udah masuk top 50 yang sudah di-fetch, pakai itu aja
    final idxInList = list.indexWhere((e) => e.userUid == uid);
    if (idxInList != -1) {
      myRank.value = idxInList + 1;
      myEntry.value = list[idxInList];
      return;
    }

    // Belum masuk top 50 (atau belum pernah tercatat sama sekali)
    try {
      final myRow = await _supabase
          .from('tasbih_stats')
          .select('*, users(name, photo)')
          .eq('mode', _modeStr)
          .eq('user_uid', uid)
          .maybeSingle();

      if (myRow == null) return; // belum pernah punya record di mode ini

      final entry = LeaderboardEntry.fromJson(myRow);
      myEntry.value = entry;

      final myValue = selectedMetric.value == LeaderboardMetric.khatam
          ? entry.totalKhatam
          : entry.totalHitungan;

      final countResponse = await _supabase
          .from('tasbih_stats')
          .select()
          .eq('mode', _modeStr)
          .gt(_metricColumn, myValue)
          .count(CountOption.exact);

      myRank.value = countResponse.count + 1;
    } catch (e) {
      print('Error load my rank: $e');
    }
  }
}