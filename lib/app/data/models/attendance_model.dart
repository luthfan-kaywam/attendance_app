class AttendanceModel {
  final String id;
  final DateTime dateTime;
  final String status; // 'Hadir', 'Izin', 'Sakit'
  final String note;
  final String? photoPath;

  const AttendanceModel({
    required this.id,
    required this.dateTime,
    required this.status,
    required this.note,
    this.photoPath,
  });

  AttendanceModel copyWith({
    String? id,
    DateTime? dateTime,
    String? status,
    String? note,
    String? photoPath,
  }) {
    return AttendanceModel(
      id: id ?? this.id,
      dateTime: dateTime ?? this.dateTime,
      status: status ?? this.status,
      note: note ?? this.note,
      photoPath: photoPath ?? this.photoPath,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dateTime': dateTime.toIso8601String(),
      'status': status,
      'note': note,
      'photoPath': photoPath,
    };
  }

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'] as String? ?? '',
      dateTime: json['dateTime'] != null
          ? DateTime.tryParse(json['dateTime'] as String) ?? DateTime.now()
          : DateTime.now(),
      status: json['status'] as String? ?? 'Hadir',
      note: json['note'] as String? ?? '',
      photoPath: json['photoPath'] as String?,
    );
  }

  @override
  String toString() {
    return 'AttendanceModel(id: $id, dateTime: $dateTime, status: $status, note: $note, photoPath: $photoPath)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AttendanceModel &&
        other.id == id &&
        other.dateTime == dateTime &&
        other.status == status &&
        other.note == note &&
        other.photoPath == photoPath;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        dateTime.hashCode ^
        status.hashCode ^
        note.hashCode ^
        (photoPath?.hashCode ?? 0);
  }
}
