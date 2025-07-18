part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object> get props => [];
}

class FetchProfileData extends ProfileEvent {}

class UpdateProfileButtonPressed extends ProfileEvent {
  final UpdateProfileRequest request;
  const UpdateProfileButtonPressed(this.request);
  @override
  List<Object> get props => [request];
}

class DeleteAccountButtonPressed extends ProfileEvent {}
