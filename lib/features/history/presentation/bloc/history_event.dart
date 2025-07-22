// lib/features/history/presentation/bloc/history_event.dart

part of 'history_bloc.dart';

abstract class HistoryEvent extends Equatable {
  const HistoryEvent();
  @override
  List<Object> get props => [];
}

class FetchHistory extends HistoryEvent {
  final String type; // 'donation' or 'rental'
  const FetchHistory({required this.type});
  @override
  List<Object> get props => [type];
}

// --- TAMBAHKAN KELAS INI ---
class HistoryReset extends HistoryEvent {}
