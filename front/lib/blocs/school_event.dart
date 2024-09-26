import 'package:equatable/equatable.dart';

abstract class SchoolEvent extends Equatable {
  const SchoolEvent();

  @override
  List<Object?> get props => [];
}

class FetchSchoolsEvent extends SchoolEvent {}
