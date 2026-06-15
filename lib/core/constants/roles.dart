enum UserRole {
  patient("Patient"),
  doctor("Doctor"),
  hospitalAdmin("Hospital Admin"),
  receptionist("Receptionist"),
  labTechnician("Lab Technician"),
  mainAdmin("Main Admin");

  final String title;
  const UserRole(this.title);
}
