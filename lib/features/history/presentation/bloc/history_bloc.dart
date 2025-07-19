import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:satulemari/features/history/domain/entities/request_item.dart';
import 'package:satulemari/features/history/domain/usecases/get_my_requests_usecase.dart';

part 'history_event.dart';
part 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final GetMyRequestsUseCase getMyRequests;

  HistoryBloc({required this.getMyRequests}) : super(const HistoryState()) {
    on<FetchHistory>(_onFetchHistory);
  }

  Future<void> _onFetchHistory(
      FetchHistory event, Emitter<HistoryState> emit) async {
    if (event.type == 'donation') {
      emit(state.copyWith(donationStatus: HistoryStatus.loading));
    } else {
      emit(state.copyWith(rentalStatus: HistoryStatus.loading));
    }

    final result = await getMyRequests(GetMyRequestsParams(type: event.type));

    result.fold(
      (failure) {
        if (event.type == 'donation') {
          emit(state.copyWith(
              donationStatus: HistoryStatus.error,
              donationError: failure.message));
        } else {
          emit(state.copyWith(
              rentalStatus: HistoryStatus.error, rentalError: failure.message));
        }
      },
      (data) {
        if (event.type == 'donation') {
          emit(state.copyWith(
              donationStatus: HistoryStatus.loaded, donationRequests: data));
        } else {
          emit(state.copyWith(
              rentalStatus: HistoryStatus.loaded, rentalRequests: data));
        }
      },
    );
  }
}
