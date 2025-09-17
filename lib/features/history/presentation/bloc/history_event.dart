part of 'history_bloc.dart';

abstract class HistoryEvent extends Equatable {
  const HistoryEvent();

  @override
  List<Object?> get props => [];
}

class FetchAllHistoryTypes extends HistoryEvent {}

class FetchHistory extends HistoryEvent {
  final String type;
  const FetchHistory({required this.type});

  @override
  List<Object?> get props => [type];
}

class HistoryReset extends HistoryEvent {}

class LoadMoreHistory extends HistoryEvent {
  final String type;
  const LoadMoreHistory({required this.type});

  @override
  List<Object?> get props => [type];
}

class RefreshHistory extends HistoryEvent {
  final String type;
  const RefreshHistory({required this.type});

  @override
  List<Object?> get props => [type];
}

class FetchOrderHistory extends HistoryEvent {}
