import 'package:flutter_bloc/flutter_bloc.dart';

import 'kermesse_event.dart';
import 'kermesse_state.dart';

class KermesseBloc extends Bloc<KermesseEvent, KermesseState> {
  KermesseBloc() : super(KermesseInitial()) {
    on<SelectKermesseEvent>((event, emit) {
      emit(KermesseSelected(kermesseId: event.kermesseId));
    });

    on<DeselectKermesseEvent>((event, emit) {
      emit(KermesseInitial());
    });
  }
}
