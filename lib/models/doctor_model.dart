class DoctorModel {
  final String id;
  final String name;
  final String specialty;
  final String hospitalId;
  final double rating;

  DoctorModel({required this.id, required this.name, required this.specialty, required this.hospitalId, this.rating = 0.0});

  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'specialty': specialty, 'hospitalId': hospitalId, 'rating': rating};

  factory DoctorModel.fromMap(Map<String, dynamic> map, String id) {
    return DoctorModel(
      id: id,
      name: map['name'] ?? '',
      specialty: map['specialty'] ?? '',
      hospitalId: map['hospitalId'] ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
    );
  }
}
