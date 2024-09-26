import 'package:equatable/equatable.dart';

import '../models/school_model.dart';

abstract class SchoolState extends Equatable {
  const SchoolState();

  @override
  List<Object?> get props => [];
}

class SchoolInitial extends SchoolState {}

class SchoolLoading extends SchoolState {}

class SchoolLoaded extends SchoolState {
  final List<School> schools;

  const SchoolLoaded({required this.schools});

  @override
  List<Object?> get props => [schools];
}

class SchoolError extends SchoolState {
  final String message;

  const SchoolError({required this.message});

  @override
  List<Object?> get props => [message];
}
