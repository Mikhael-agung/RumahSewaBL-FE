class Building {
  final int id;
  final String buildingCode;
  final String buildingName;
  final String buildingAddress;
  final String description;

  const Building({
    required this.id,
    required this.buildingCode,
    required this.buildingName,
    required this.buildingAddress,
    required this.description,
  });

  factory Building.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return Building(
      id: data['id'] ?? 0,
      buildingCode: data['building_code'] ?? '',
      buildingName: data['building_name'] ?? '',
      buildingAddress: data['building_address'] ?? '',
      description: data['description'] ?? '',
    );
  }
}
