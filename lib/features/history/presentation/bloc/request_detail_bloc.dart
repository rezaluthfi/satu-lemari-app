import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:satulemari/core/errors/failures.dart';
import 'package:satulemari/features/history/domain/entities/request_detail.dart';
import 'package:satulemari/features/history/domain/usecases/delete_request_usecase.dart';
import 'package:satulemari/features/history/domain/usecases/get_request_detail_usecase.dart';

part 'request_detail_event.dart';
part 'request_detail_state.dart';

class RequestDetailBloc extends Bloc<RequestDetailEvent, RequestDetailState> {
  final GetRequestDetailUseCase getRequestDetail;
  final DeleteRequestUseCase deleteRequest;

  RequestDetailBloc({
    required this.getRequestDetail,
    required this.deleteRequest,
  }) : super(RequestDetailInitial()) {
    on<FetchRequestDetail>(_onFetchRequestDetail);
    on<DeleteRequestButtonPressed>(_onDeleteRequest);
  }

  Future<void> _onFetchRequestDetail(
      FetchRequestDetail event, Emitter<RequestDetailState> emit) async {
    emit(RequestDetailLoading());
    final result = await getRequestDetail(GetRequestDetailParams(id: event.id));

    result.fold(
      (failure) {
        if (failure is NotFoundFailure) {
          emit(RequestDetailNotFound());
        } else {
          emit(RequestDetailError(failure.message));
        }
      },
      (detail) => emit(RequestDetailLoaded(detail)),
    );
  }

  Future<void> _onDeleteRequest(DeleteRequestButtonPressed event,
      Emitter<RequestDetailState> emit) async {
    final result = await deleteRequest(
        DeleteRequestParams(id: event.id, status: event.status));
    result.fold(
      (failure) => emit(RequestDetailError(failure.message)),
      (_) {
        final isHardDelete = event.status.toLowerCase() == 'pending';
        emit(RequestDeleteSuccess(isHardDelete: isHardDelete));
      },
    );
  }
}
