import 'package:rumah_sewa_biru_laut_fe/features/dashboard/domain/entities/building.dart';

enum RoomStatus {
  available,
  occupied,
  maintenance,
}

class Room {
  final int id;
  final int buildingId;
  final String roomCode;
  final int monthlyPrice;
  final String roomStatus;
  final String notes;
  final Building? building;

  const Room({
    required this.id,
    required this.buildingId,
    required this.roomCode,
    required this.monthlyPrice,
    required this.roomStatus,
    required this.notes,
    this.building,
  });

  Room copyWith({
    int? id,
    int? buildingId,
    String? roomCode,
    int? monthlyPrice,
    String? roomStatus,
    String? notes,
    Building? building,
  }) {
    return Room(
      id: id ?? this.id,
      buildingId: buildingId ?? this.buildingId,
      roomCode: roomCode ?? this.roomCode,
      monthlyPrice: monthlyPrice ?? this.monthlyPrice,
      roomStatus: roomStatus ?? this.roomStatus,
      notes: notes ?? this.notes,
      building: building ?? this.building,
    );
  }
}
