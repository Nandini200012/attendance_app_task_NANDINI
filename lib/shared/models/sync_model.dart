/// Aggregates synchronization queue counts and network telemetry.
class SyncStats {
  final int pendingCount;
  final int syncedCount;
  final int rejectedCount;
  final DateTime? lastSyncTime;
  final bool isOnline;

  int get failedCount => rejectedCount;

  const SyncStats({
    required this.pendingCount,
    required this.syncedCount,
    required this.rejectedCount,
    this.lastSyncTime,
    required this.isOnline,
  });

  /// Factory constructor to deserialize from JSON map.
  factory SyncStats.fromJson(Map<String, dynamic> json) {
    return SyncStats(
      pendingCount: json['pendingCount'] as int? ?? 0,
      syncedCount: json['syncedCount'] as int? ?? 0,
      rejectedCount: json['rejectedCount'] as int? ?? 0,
      lastSyncTime: json['lastSyncTime'] != null
          ? DateTime.tryParse(json['lastSyncTime'] as String)
          : null,
      isOnline: json['isOnline'] as bool? ?? true,
    );
  }

  /// Serializes instance to JSON map.
  Map<String, dynamic> toJson() => {
    'pendingCount': pendingCount,
    'syncedCount': syncedCount,
    'rejectedCount': rejectedCount,
    'lastSyncTime': lastSyncTime?.toIso8601String(),
    'isOnline': isOnline,
  };

  SyncStats copyWith({
    int? pendingCount,
    int? syncedCount,
    int? rejectedCount,
    DateTime? lastSyncTime,
    bool? isOnline,
  }) {
    return SyncStats(
      pendingCount: pendingCount ?? this.pendingCount,
      syncedCount: syncedCount ?? this.syncedCount,
      rejectedCount: rejectedCount ?? this.rejectedCount,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      isOnline: isOnline ?? this.isOnline,
    );
  }

  static const SyncStats empty = SyncStats(
    pendingCount: 0,
    syncedCount: 0,
    rejectedCount: 0,
    lastSyncTime: null,
    isOnline: true,
  );
}
