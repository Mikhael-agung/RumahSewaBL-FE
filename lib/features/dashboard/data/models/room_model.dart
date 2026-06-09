
import 'package:rumah_sewa_biru_laut_fe/features/dashboard/domain/entities/building.dart';
import 'package:rumah_sewa_biru_laut_fe/features/dashboard/domain/entities/rooms.dart';

class RoomModel extends Room {
  const RoomModel({
    required super.id,
    required super.buildingId,
    required super.roomCode,
    required super.monthlyPrice,
    required super.roomStatus,
    required super.notes,
    super.building,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return RoomModel(
      id: data['id'] ?? 0,
      buildingId: data['building_id'] ?? 0,
      roomCode: data['room_code'] ?? '',
      monthlyPrice: double.tryParse(data['monthly_price']?.toString() ?? '')?.round() ?? 0,
      roomStatus: data['room_status'] ?? '',
      notes: data['notes'] ?? '',
      building: data['building'] != null ? Building.fromJson(data['building']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'building_id': buildingId,
      'room_code': roomCode,
      'monthly_price': monthlyPrice.toString(),
      'room_status': roomStatus,
      'notes': notes,
      'building': building,
    };
  }
}
