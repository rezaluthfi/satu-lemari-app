import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:satulemari/core/errors/failures.dart';
import 'package:satulemari/core/usecases/usecase.dart';
import 'package:satulemari/features/profile/data/models/update_profile_request.dart';
import 'package:satulemari/features/profile/domain/entities/dashboard_stats.dart';
import 'package:satulemari/features/profile/domain/entities/profile.dart';
import 'package:satulemari/features/profile/domain/usecases/delete_account_usecase.dart';
import 'package:satulemari/features/profile/domain/usecases/get_dashboard_stats_usecase.dart';
import 'package:satulemari/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:satulemari/features/profile/domain/usecases/update_profile_usecase.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUseCase getProfile;
  final GetDashboardStatsUseCase getDashboardStats;
  final UpdateProfileUseCase updateProfile;
  final DeleteAccountUseCase deleteAccount;

  ProfileBloc({
    required this.getProfile,
    required this.getDashboardStats,
    required this.updateProfile,
    required this.deleteAccount,
  }) : super(ProfileInitial()) {
    on<FetchProfileData>(_onFetchProfileData);
    on<UpdateProfileButtonPressed>(_onUpdateProfile);
    on<DeleteAccountButtonPressed>(_onDeleteAccount);
    // --- TAMBAHKAN HANDLER INI ---
    on<ProfileReset>(_onProfileReset);
  }

  // --- TAMBAHKAN METHOD INI ---
  void _onProfileReset(ProfileReset event, Emitter<ProfileState> emit) {
    print('ProfileBloc state has been reset.');
    emit(ProfileInitial());
  }

  Future<void> _onFetchProfileData(
      FetchProfileData event, Emitter<ProfileState> emit) async {
    final currentState = state;
    if (currentState is! ProfileLoaded) {
      emit(ProfileLoading());
    }

    try {
      final results = await Future.wait([
        getProfile(NoParams()),
        getDashboardStats(NoParams()),
      ]);

      final profileResult = results[0];
      final statsResult = results[1];

      if (profileResult.isRight() && statsResult.isRight()) {
        emit(ProfileLoaded(
          profile: (profileResult as Right).value,
          stats: (statsResult as Right).value,
        ));
      } else {
        final failure = profileResult.isLeft()
            ? (profileResult as Left).value
            : (statsResult as Left).value;
        emit(ProfileError((failure as Failure).message));
      }
    } catch (e) {
      emit(ProfileError('Terjadi kesalahan: $e'));
    }
  }

  Future<void> _onUpdateProfile(
      UpdateProfileButtonPressed event, Emitter<ProfileState> emit) async {
    final currentState = state;
    if (currentState is ProfileLoaded) {
      // Emit state InProgress sambil membawa data lama agar UI tidak rusak
      emit(ProfileUpdateInProgress(
          profile: currentState.profile, stats: currentState.stats));

      final result =
          await updateProfile(UpdateProfileParams(request: event.request));

      result.fold(
        (failure) {
          // Emit state Failure sambil membawa data lama
          emit(ProfileUpdateFailure(
              message: failure.message,
              profile: currentState.profile,
              stats: currentState.stats));
        },
        (updatedProfile) {
          // Emit state Success sambil membawa data BARU
          emit(ProfileUpdateSuccess(
              profile: updatedProfile, stats: currentState.stats));
        },
      );
    }
  }

  Future<void> _onDeleteAccount(
      DeleteAccountButtonPressed event, Emitter<ProfileState> emit) async {
    emit(AccountDeleteInProgress());
    final result = await deleteAccount(NoParams());
    result.fold(
      (failure) {
        if (state is ProfileLoaded) {
          emit(state as ProfileLoaded);
        }
        emit(ProfileError(failure.message));
      },
      (_) => emit(AccountDeleteSuccess()),
    );
  }
}
