import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front/blocs/school_event.dart';
import 'package:front/blocs/school_state.dart';

import '../repositories/school_repository.dart';

class SchoolBloc extends Bloc<SchoolEvent, SchoolState> {
  final SchoolRepository schoolRepository;

  SchoolBloc({required this.schoolRepository}) : super(SchoolInitial()) {
    on<FetchSchoolsEvent>((event, emit) async {
      emit(SchoolLoading());
      try {
        final schools = await schoolRepository.getSchools();
        emit(SchoolLoaded(schools: schools));
      } catch (e) {
        emit(SchoolError(message: e.toString()));
      }
    });
  }
}
