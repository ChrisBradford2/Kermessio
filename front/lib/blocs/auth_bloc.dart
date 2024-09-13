import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import '../models/user_model.dart';
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
    on<AuthRefreshRequested>(_onRefreshRequested);
  }

  // Handler for AuthLoginRequested event
  void _onLoginRequested(AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final userWithToken = await authRepository.login(event.username, event.password);
      final user = User.fromJson(userWithToken['user']);
      final token = userWithToken['token'];

      emit(AuthAuthenticated(user: user, token: token));
    } catch (e) {
      if (e is http.ClientException) {
        emit(AuthError(message: "Problème de connexion au serveur"));
      } else {
        emit(AuthError(message: e.toString()));
      }
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
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  void _onRefreshRequested(AuthRefreshRequested event, Emitter<AuthState> emit) async {
    final currentState = state;
    if (currentState is AuthAuthenticated) {
      try {
        // Récupérer les informations mises à jour de l'utilisateur
        final userWithToken = await authRepository.getUserDetails(currentState.token);
        final updatedUser = User.fromJson(userWithToken['user']);

        // Émettre un nouvel état avec l'utilisateur mis à jour
        emit(AuthAuthenticated(user: updatedUser, token: currentState.token));
      } catch (e) {
        print(e);
        emit(AuthError(message: e.toString()));
      }
    }
  }
}
