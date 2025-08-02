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
  final String status;
  const DeleteRequestButtonPressed(this.id, this.status);
  @override
  List<Object> get props => [id, status];
}
