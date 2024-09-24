import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/user_model.dart';
import '../../repositories/auth_repository.dart';
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
      if (kDebugMode) {
        print('Tentative de connexion sur desktop/web');
      }
      final userWithToken = await authRepository.login(event.username, event.password);
      final user = User.fromJson(userWithToken['user']);
      final token = userWithToken['token'];

      if (token == null || token.isEmpty) {
        throw Exception("Token invalide reçu lors de l'authentification");
      }

      if (kDebugMode) {
        print('Connexion réussie : $user');
      }
      emit(AuthAuthenticated(user: user, token: token));
    } catch (e) {
      if (kDebugMode) {
        print('Erreur de connexion : $e');
      }
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
      final message = await authRepository.register(event.username, event.lastName, event.firstName, event.email, event.password, event.role);
      if (message.isEmpty) {
        throw Exception("Erreur lors de l'inscription");
      }
      emit(AuthUnauthenticated());
    } catch (e) {
      if (e.toString().contains("Le nom d'utilisateur ou l'email existe déjà.")) {
        emit(AuthError(message: "Ce nom d'utilisateur ou cet email est déjà utilisé."));
      } else {
        emit(AuthError(message: e.toString()));
      }
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
        if (kDebugMode) {
          print(e);
        }
        emit(AuthError(message: e.toString()));
      }
    }
  }
}
