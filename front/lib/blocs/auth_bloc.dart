import 'package:flutter_bloc/flutter_bloc.dart';

import '../repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    // Register the event handler for AuthLoginRequested
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
  }

  // Handler for AuthLoginRequested event
  void _onLoginRequested(AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final token = await authRepository.login(event.username, event.password);
      print(token);
      emit(AuthAuthenticated(token: token));  // Pass only the token
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  // Handler for AuthLogoutRequested event
  void _onLogoutRequested(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthUnauthenticated());
  }

  // Handler for AuthRegisterRequested event
  void _onRegisterRequested(AuthRegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final token = await authRepository.register(event.username, event.email, event.password);
      emit(AuthAuthenticated(token: token));  // Pass only the token
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }
}
