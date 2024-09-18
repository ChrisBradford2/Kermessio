import 'package:equatable/equatable.dart';

abstract class KermesseState extends Equatable {
  const KermesseState();

  @override
  List<Object?> get props => [];
}

class KermesseInitial extends KermesseState {}

class KermesseSelected extends KermesseState {
  final int kermesseId;

  const KermesseSelected({required this.kermesseId});

  @override
  List<Object?> get props => [kermesseId];
}
