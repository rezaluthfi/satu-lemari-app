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

class ProfileUpdateInProgress extends ProfileState {}

class ProfileUpdateSuccess extends ProfileState {}

class ProfileUpdateFailure extends ProfileState {
  final String message;
  const ProfileUpdateFailure(this.message);
  @override
  List<Object> get props => [message];
}

// --- TAMBAHKAN STATE INI ---
class AccountDeleteInProgress extends ProfileState {}

// ---
class AccountDeleteSuccess extends ProfileState {}
