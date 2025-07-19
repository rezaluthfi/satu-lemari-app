part of 'request_detail_bloc.dart';

abstract class RequestDetailState extends Equatable {
  const RequestDetailState();
  @override
  List<Object> get props => [];
}

class RequestDetailInitial extends RequestDetailState {}

class RequestDetailLoading extends RequestDetailState {}

class RequestDetailLoaded extends RequestDetailState {
  final RequestDetail detail;
  const RequestDetailLoaded(this.detail);
  @override
  List<Object> get props => [detail];
}

class RequestDetailError extends RequestDetailState {
  final String message;
  const RequestDetailError(this.message);
  @override
  List<Object> get props => [message];
}

class RequestDeleteSuccess extends RequestDetailState {}
