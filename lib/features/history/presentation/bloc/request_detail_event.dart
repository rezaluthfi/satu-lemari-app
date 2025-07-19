part of 'request_detail_bloc.dart';

abstract class RequestDetailEvent extends Equatable {
  const RequestDetailEvent();
  @override
  List<Object> get props => [];
}

class FetchRequestDetail extends RequestDetailEvent {
  final String id;
  const FetchRequestDetail(this.id);
  @override
  List<Object> get props => [id];
}

class DeleteRequestButtonPressed extends RequestDetailEvent {
  final String id;
  const DeleteRequestButtonPressed(this.id);
  @override
  List<Object> get props => [id];
}
