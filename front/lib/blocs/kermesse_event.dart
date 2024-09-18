import 'package:equatable/equatable.dart';

abstract class KermesseEvent extends Equatable {
  const KermesseEvent();

  @override
  List<Object?> get props => [];
}

class SelectKermesseEvent extends KermesseEvent {
  final int kermesseId;

  const SelectKermesseEvent({required this.kermesseId});

  @override
  List<Object?> get props => [kermesseId];
}

class DeselectKermesseEvent extends KermesseEvent {}
