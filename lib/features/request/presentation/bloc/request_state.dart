part of 'request_bloc.dart';

abstract class RequestState extends Equatable {
  const RequestState();
  @override
  List<Object> get props => [];
}

class RequestInitial extends RequestState {}

class RequestInProgress extends RequestState {}

class RequestSuccess extends RequestState {
  final RequestDetail requestDetail;
  const RequestSuccess(this.requestDetail);
  @override
  List<Object> get props => [requestDetail];
}

class RequestFailure extends RequestState {
  final String message;
  const RequestFailure(this.message);
  @override
  List<Object> get props => [message];
}
