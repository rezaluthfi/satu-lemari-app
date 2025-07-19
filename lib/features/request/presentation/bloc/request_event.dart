part of 'request_bloc.dart';

abstract class RequestEvent extends Equatable {
  const RequestEvent();
  @override
  List<Object> get props => [];
}

class SubmitRequest extends RequestEvent {
  final CreateRequestModel request;
  const SubmitRequest(this.request);
  @override
  List<Object> get props => [request];
}
