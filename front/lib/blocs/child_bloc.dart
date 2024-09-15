import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/auth_state.dart';
import 'child_event.dart';
import 'child_state.dart';
import '../repositories/child_repository.dart';

class ChildBloc extends Bloc<ChildEvent, ChildState> {
  final ChildRepository childRepository;

  ChildBloc({required this.childRepository}) : super(ChildInitial()) {
    on<FetchChildrenRequested>(_onFetchChildrenRequested);
    on<AssignTokensToChild>(_onAssignTokensToChild);
    on<LoadChildren>(_onLoadChildren);
  }

  void _onFetchChildrenRequested(FetchChildrenRequested event, Emitter<ChildState> emit) async {
    emit(ChildLoading());
    try {
      final children = await childRepository.getChildren(event.token);
      emit(ChildLoaded(children: children));
    } catch (e) {
      emit(ChildError(message: e.toString()));
    }
  }

  void _onAssignTokensToChild(AssignTokensToChild event, Emitter<ChildState> emit) async {
    emit(ChildLoading());

    try {
      // Récupérer le token depuis le AuthBloc en utilisant le context de l'événement
      final authState = event.context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        final success = await childRepository.assignTokensToChild(
          childId: event.childId,
          tokens: event.tokens,
          token: authState.token,
        );

        if (success) {
          final updatedChildren = await childRepository.getChildren(authState.token);
          emit(ChildLoaded(children: updatedChildren)); // Recharger la liste avec les données mises à jour
        } else {
          emit(ChildError(message: "Échec de l'attribution des jetons"));
        }
      } else {
        emit(ChildError(message: "Parent non authentifié"));
      }
    } catch (e) {
      emit(ChildError(message: e.toString()));
    }
  }

  void _onLoadChildren(LoadChildren event, Emitter<ChildState> emit) async {
    if (kDebugMode) {
      print("Début du chargement des enfants avec le token : ${event.parentToken}");
    }
    emit(ChildLoading());

    try {
      if (event.parentToken.isEmpty) {
        throw Exception("Le token est vide !");
      }

      final children = await childRepository.getChildren(event.parentToken);
      if (kDebugMode) {
        print("Enfants récupérés : ${children.length}");
      }
      emit(ChildLoaded(children: children));
    } catch (e) {
      if (kDebugMode) {
        print("Erreur lors de la récupération des enfants : $e");
      }
      emit(ChildError(message: e.toString()));
    }
  }
}
