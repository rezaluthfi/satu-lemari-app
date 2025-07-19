import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:satulemari/features/history/domain/entities/request_detail.dart';
import 'package:satulemari/features/request/data/models/create_request_model.dart';
import 'package:satulemari/features/request/domain/usecases/create_request_usecase.dart';

part 'request_event.dart';
part 'request_state.dart';

class RequestBloc extends Bloc<RequestEvent, RequestState> {
  final CreateRequestUseCase createRequest;

  RequestBloc({required this.createRequest}) : super(RequestInitial()) {
    on<SubmitRequest>((event, emit) async {
      emit(RequestInProgress());
      final result =
          await createRequest(CreateRequestParams(request: event.request));
      result.fold(
        (failure) => emit(RequestFailure(failure.message)),
        (detail) => emit(RequestSuccess(detail)),
      );
    });
  }
}
