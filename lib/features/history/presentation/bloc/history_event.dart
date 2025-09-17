part of 'history_bloc.dart';

abstract class HistoryEvent extends Equatable {
  const HistoryEvent();
  @override
  List<Object?> get props => [];
}

class FetchAllHistory extends HistoryEvent {}

class HistoryReset extends HistoryEvent {}

class RefreshHistory extends HistoryEvent {}

class LoadMoreHistory extends HistoryEvent {
  final String type; // 'requests' or 'orders'
  const LoadMoreHistory({required this.type});
  @override
  List<Object?> get props => [type];
}
