import 'package:equatable/equatable.dart';
import '../models/user_model.dart';

abstract class ChildState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ChildInitial extends ChildState {}

class ChildLoading extends ChildState {}

class ChildLoaded extends ChildState {
  final List<User> children;

  ChildLoaded({required this.children});

  @override
  List<Object?> get props => [children];
}

class ChildError extends ChildState {
  final String message;

  ChildError({required this.message});

  @override
  List<Object?> get props => [message];
}
