import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

abstract class ChildEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchChildrenRequested extends ChildEvent {
  final String token;

  FetchChildrenRequested({required this.token});

  @override
  List<Object?> get props => [token];
}

class AssignTokensToChild extends ChildEvent {
  final String childId;
  final int tokens;
  final BuildContext context;

  AssignTokensToChild({
    required this.childId,
    required this.tokens,
    required this.context,
  });

  @override
  List<Object?> get props => [childId, tokens, context];
}

class LoadChildren extends ChildEvent {
  final String parentToken;

  LoadChildren({required this.parentToken});

  @override
  List<Object> get props => [parentToken];
}
