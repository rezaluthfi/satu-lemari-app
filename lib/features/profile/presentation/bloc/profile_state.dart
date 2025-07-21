part of 'profile_bloc.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();
  @override
  List<Object> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final Profile profile;
  final DashboardStats stats;
  const ProfileLoaded({required this.profile, required this.stats});
  @override
  List<Object> get props => [profile, stats];
}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);
  @override
  List<Object> get props => [message];
}

class ProfileUpdateInProgress extends ProfileLoaded {
  const ProfileUpdateInProgress({required super.profile, required super.stats});
}

class ProfileUpdateSuccess extends ProfileLoaded {
  const ProfileUpdateSuccess({required super.profile, required super.stats});
}

class ProfileUpdateFailure extends ProfileLoaded {
  final String message;
  const ProfileUpdateFailure(
      {required this.message, required super.profile, required super.stats});
  @override
  List<Object> get props => [message, profile, stats];
}

class AccountDeleteInProgress extends ProfileState {}

class AccountDeleteSuccess extends ProfileState {}
