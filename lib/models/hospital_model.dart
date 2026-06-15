class HospitalModel {
  final String id;
  final String name;
  final String city;
  final String area;
  final String address;

  HospitalModel({required this.id, required this.name, required this.city, required this.area, required this.address});

  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'city': city, 'area': area, 'address': address};

  factory HospitalModel.fromMap(Map<String, dynamic> map, String id) {
    return HospitalModel(
      id: id,
      name: map['name'] ?? '',
      city: map['city'] ?? '',
      area: map['area'] ?? '',
      address: map['address'] ?? '',
    );
  }
}
