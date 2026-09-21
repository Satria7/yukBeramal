class LeaderboardEntry {
  final String userUid;
  final String name;
  final String photo;
  final int totalKhatam;
  final int totalHitungan;

  const LeaderboardEntry({
    required this.userUid,
    required this.name,
    required this.photo,
    required this.totalKhatam,
    required this.totalHitungan,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    // Data user (nama/foto) datang dari relasi embed 'users' (foreign key
    // tasbih_stats.user_uid -> users.uid), Supabase otomatis nested-kan.
    final userInfo = json['users'] as Map<String, dynamic>?;
    return LeaderboardEntry(
      userUid: json['user_uid']?.toString() ?? '',
      name: userInfo?['name']?.toString().trim().isNotEmpty == true
          ? userInfo!['name'].toString()
          : 'Pengguna',
      photo: userInfo?['photo']?.toString() ?? '',
      totalKhatam:
      int.tryParse(json['total_khatam']?.toString() ?? '0') ?? 0,
      totalHitungan:
      int.tryParse(json['total_hitungan']?.toString() ?? '0') ?? 0,
    );
  }
}
