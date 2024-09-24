import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthLoginRequested extends AuthEvent {
  final String username;
  final String password;

  AuthLoginRequested({required this.username, required this.password});

  @override
  List<Object?> get props => [username, password];
}

class AuthLogoutRequested extends AuthEvent {}

class AuthRegisterRequested extends AuthEvent {
  final String lastName;
  final String firstName;
  final String username;
  final String email;
  final String password;
  final String role;

  AuthRegisterRequested(
      {required this.username,
      required this.lastName,
      required this.firstName,
      required this.email,
      required this.password,
      required this.role});

  @override
  List<Object?> get props =>
      [username, lastName, firstName, email, password, role];
}

class AuthRefreshRequested extends AuthEvent {}

class FetchChildrenRequested extends AuthEvent {
  final String token;

  FetchChildrenRequested({required this.token});

  @override
  List<Object?> get props => [token];
}
