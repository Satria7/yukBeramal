import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Mode target hitungan tasbih.
enum TasbihMode { target33, target99, manual, unlimited }

class TasbihController extends GetxController {
  // ─── State ────────────────────────────────────────────────────────────
  final count = 0.obs;
  final target = 33.obs;
  final mode = TasbihMode.target33.obs;
  final isLoaded = false.obs;

  // Optional: hitung berapa kali sudah menyelesaikan 1 putaran (khatam),
  // fallback lokal untuk mode manual/unlimited atau saat belum login.
  final roundCompleted = 0.obs;

  // Statistik "Selesai" untuk mode 33/99 diambil dari SERVER (bukan lokal),
  // biar akurat & sesuai per-mode (bukan gabungan semua mode kayak sebelumnya).
  final serverKhatam = Rxn<int>();
  final isLoadingServerStats = false.obs;

  // ─── Prefs keys ───────────────────────────────────────────────────────
  static const _kCount = 'tasbih_count';
  static const _kTarget = 'tasbih_target';
  static const _kMode = 'tasbih_mode';
  static const _kRound = 'tasbih_round';
  static const _kSessionRecorded = 'tasbih_session_recorded';

  // Cegah sesi yang sama tersinkron dobel (sudah dicatat pas capai target,
  // jangan dicatat ulang lagi pas Reset ditekan setelahnya). DISIMPAN ke
  // prefs (bukan cuma variabel in-memory) — soalnya kalau cuma in-memory,
  // begitu controller dibikin ulang (misal user pindah halaman lalu balik
  // lagi sebelum sempat tekan Reset), status ini ke-reset ke false padahal
  // sesi itu sebenarnya sudah tercatat, akibatnya sesi yang sama kecatat
  // DUA KALI ke server saat Reset akhirnya ditekan.
  bool _sessionRecorded = false;

  late SharedPreferences _prefs;

  @override
  void onInit() {
    super.onInit();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      final modeIndex = _prefs.getInt(_kMode) ?? 0;
      mode.value = TasbihMode.values[
      modeIndex.clamp(0, TasbihMode.values.length - 1)];
      target.value = _prefs.getInt(_kTarget) ?? 33;
      count.value = _prefs.getInt(_kCount) ?? 0;
      roundCompleted.value = _prefs.getInt(_kRound) ?? 0;
      _sessionRecorded = _prefs.getBool(_kSessionRecorded) ?? false;
    } catch (e) {
      // fallback ke default kalau prefs gagal dibaca
    } finally {
      isLoaded.value = true;
      _refreshServerKhatam();
      ever(mode, (_) => _refreshServerKhatam());
    }
  }

  // ─── Computed ─────────────────────────────────────────────────────────
  bool get isUnlimited => mode.value == TasbihMode.unlimited;

  bool get isTargetReached =>
      !isUnlimited && target.value > 0 && count.value >= target.value;

  double get progress {
    if (isUnlimited || target.value <= 0) return 0;
    return (count.value / target.value).clamp(0.0, 1.0);
  }

  String get targetLabel {
    if (isUnlimited) return 'Unlimited';
    return target.value.toString();
  }

  /// Sisa hitungan menuju target (0 kalau unlimited atau sudah tercapai).
  int get remaining {
    if (isUnlimited) return 0;
    final r = target.value - count.value;
    return r > 0 ? r : 0;
  }

  int get progressPercent => (progress * 100).round();

  // ─── Actions ──────────────────────────────────────────────────────────

  /// Ketuk lingkaran untuk menambah hitungan.
  /// Kalau target sudah tercapai, tap diabaikan (tidak reset otomatis)
  /// supaya user tidak kelewat/kepencet tanpa sadar. Harus tekan Reset
  /// secara sadar untuk mengulang.
  void increment() {
    if (isTargetReached) {
      HapticFeedback.heavyImpact(); // getar "nolak" sebagai sinyal sudah penuh
      return;
    }

    count.value++;
    _prefs.setInt(_kCount, count.value);

    if (isTargetReached) {
      // baru saja mencapai target → catat sebagai satu sesi selesai
      roundCompleted.value++;
      _prefs.setInt(_kRound, roundCompleted.value);
      HapticFeedback.mediumImpact();

      // sinkron ke server SEKARANG JUGA (jangan nunggu Reset ditekan),
      // biar leaderboard langsung update begitu target tercapai
      _recordSessionIfNeeded();
      _sessionRecorded = true;
      _prefs.setBool(_kSessionRecorded, true);
    } else {
      HapticFeedback.lightImpact();
    }
  }

  void reset() {
    HapticFeedback.selectionClick();
    // kalau sesi ini BELUM tercatat (user reset di tengah jalan sebelum
    // capai target), tetap catat sebagai sesi parsial sebelum di-nol-kan
    if (!_sessionRecorded) {
      _recordSessionIfNeeded();
    }
    _sessionRecorded = false;
    _prefs.setBool(_kSessionRecorded, false);
    count.value = 0;
    _prefs.setInt(_kCount, 0);
  }

  /// Ganti target/mode, otomatis reset hitungan & simpan ke prefs.
  Future<void> setTargetMode(TasbihMode newMode, {int? customTarget}) async {
    if (!_sessionRecorded) {
      _recordSessionIfNeeded(); // sesi lama (kalau ada & belum tercatat) dicatat dulu
    }
    _sessionRecorded = false;
    await _prefs.setBool(_kSessionRecorded, false);
    mode.value = newMode;
    switch (newMode) {
      case TasbihMode.target33:
        target.value = 33;
        break;
      case TasbihMode.target99:
        target.value = 99;
        break;
      case TasbihMode.manual:
        target.value = customTarget ?? target.value;
        break;
      case TasbihMode.unlimited:
      // target diabaikan saat unlimited, tapi tetap disimpan buat referensi terakhir
        break;
    }
    count.value = 0;
    await _prefs.setInt(_kMode, mode.value.index);
    await _prefs.setInt(_kTarget, target.value);
    await _prefs.setInt(_kCount, 0);
  }

  // ─── Sinkronisasi leaderboard (mode 33 & 99 saja) ───────────────────────
  /// Dipanggil tiap kali sesi berakhir (Reset ditekan / ganti mode).
  /// Cuma kirim ke server kalau: mode 33/99 (bukan manual/unlimited),
  /// user sudah login, dan ada tap yang tercatat (count > 0).
  /// Best-effort, tidak memblokir UI kalau gagal/offline.
  void _recordSessionIfNeeded() {
    if (count.value <= 0) return;
    if (mode.value != TasbihMode.target33 && mode.value != TasbihMode.target99) {
      return;
    }
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) return;

    final modeStr = mode.value == TasbihMode.target33 ? 'target33' : 'target99';
    final completed = isTargetReached;
    final countSnapshot = count.value;

    Supabase.instance.client.rpc('record_tasbih_session', params: {
      'p_user_uid': uid,
      'p_mode': modeStr,
      'p_count': countSnapshot,
      'p_completed': completed,
    }).then((_) {
      // sukses sinkron → refresh angka "Selesai" biar langsung update dari server
      _refreshServerKhatam();
    }).catchError((e) {
      // best-effort, gagal sinkron nggak boleh ganggu pengalaman utama
      print('Gagal sinkron tasbih: $e');
    });
  }

  /// Ambil total khatam untuk mode saat ini (33/99) langsung dari server.
  /// null artinya: mode manual/unlimited (nggak ditrack server), atau
  /// belum login, atau belum pernah punya catatan sama sekali di mode ini.
  Future<void> _refreshServerKhatam() async {
    if (mode.value != TasbihMode.target33 && mode.value != TasbihMode.target99) {
      serverKhatam.value = null;
      return;
    }
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      serverKhatam.value = null;
      return;
    }

    final modeStr = mode.value == TasbihMode.target33 ? 'target33' : 'target99';
    try {
      isLoadingServerStats.value = true;
      final row = await Supabase.instance.client
          .from('tasbih_stats')
          .select('total_khatam')
          .eq('user_uid', uid)
          .eq('mode', modeStr)
          .maybeSingle();
      serverKhatam.value =
      row != null ? (row['total_khatam'] as num).toInt() : 0;
    } catch (e) {
      print('Gagal ambil statistik server: $e');
    } finally {
      isLoadingServerStats.value = false;
    }
  }
}