abstract class RegisterEvent {}

class RegisterUserEvent extends RegisterEvent {

  final String empId;
  final String fullName;
  final String email;
  final String phone;
  final String address;

  RegisterUserEvent({
    required this.empId,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.address,
  });
}