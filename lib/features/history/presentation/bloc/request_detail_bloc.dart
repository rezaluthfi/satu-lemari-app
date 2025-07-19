import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:satulemari/features/history/domain/entities/request_detail.dart';
import 'package:satulemari/features/history/domain/usecases/get_request_detail_usecase.dart';

part 'request_detail_event.dart';
part 'request_detail_state.dart';

class RequestDetailBloc extends Bloc<RequestDetailEvent, RequestDetailState> {
  final GetRequestDetailUseCase getRequestDetail;

  RequestDetailBloc({required this.getRequestDetail})
      : super(RequestDetailInitial()) {
    on<FetchRequestDetail>((event, emit) async {
      emit(RequestDetailLoading());
      final result =
          await getRequestDetail(GetRequestDetailParams(id: event.id));
      result.fold(
        (failure) => emit(RequestDetailError(failure.message)),
        (detail) => emit(RequestDetailLoaded(detail)),
      );
    });
  }
}
