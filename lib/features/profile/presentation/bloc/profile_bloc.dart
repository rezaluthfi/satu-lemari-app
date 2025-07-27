import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:satulemari/core/errors/failures.dart';
import 'package:satulemari/core/usecases/usecase.dart';
import 'package:satulemari/features/auth/presentation/bloc/auth_bloc.dart';
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
  final AuthBloc authBloc;

  // Add a flag to prevent multiple simultaneous fetches
  bool _isFetching = false;

  ProfileBloc({
    required this.getProfile,
    required this.getDashboardStats,
    required this.updateProfile,
    required this.deleteAccount,
    required this.authBloc,
  }) : super(ProfileInitial()) {
    on<FetchProfileData>(_onFetchProfileData);
    on<UpdateProfileButtonPressed>(_onUpdateProfile);
    on<DeleteAccountButtonPressed>(_onDeleteAccount);
    on<ProfileReset>(_onProfileReset);
  }

  void _onProfileReset(ProfileReset event, Emitter<ProfileState> emit) {
    print(
        "[PROFILE_BLOC_LOG] Event ProfileReset diterima. Mereset state ke ProfileInitial.");
    _isFetching = false; // Reset fetching flag
    emit(ProfileInitial());
  }

  Future<void> _onFetchProfileData(
      FetchProfileData event, Emitter<ProfileState> emit) async {
    print(
        "[PROFILE_BLOC_LOG] Event FetchProfileData diterima. Current state: ${state.runtimeType}");
    print("[PROFILE_BLOC_LOG] Is currently fetching: $_isFetching");

    // Prevent multiple simultaneous fetches
    if (_isFetching) {
      print("[PROFILE_BLOC_LOG] Already fetching, ignoring request");
      return;
    }

    _isFetching = true;

    final currentState = state;
    // Only show loading if not already loaded
    if (currentState is! ProfileLoaded) {
      emit(ProfileLoading());
    }

    try {
      print("[PROFILE_BLOC_LOG] Starting to fetch profile and dashboard data");

      final results = await Future.wait([
        getProfile(NoParams()),
        getDashboardStats(NoParams()),
      ]);

      final profileResult = results[0];
      final statsResult = results[1];

      print(
          "[PROFILE_BLOC_LOG] Profile result success: ${profileResult.isRight()}");
      print(
          "[PROFILE_BLOC_LOG] Stats result success: ${statsResult.isRight()}");

      if (profileResult.isRight() && statsResult.isRight()) {
        print(
            "[PROFILE_BLOC_LOG] Both results successful, emitting ProfileLoaded");
        emit(ProfileLoaded(
          profile: (profileResult as Right).value,
          stats: (statsResult as Right).value,
        ));
      } else {
        final failure = profileResult.isLeft()
            ? (profileResult as Left).value
            : (statsResult as Left).value;
        print(
            "[PROFILE_BLOC_LOG] Fetch failed: ${(failure as Failure).message}");
        emit(ProfileError((failure as Failure).message));
      }
    } catch (e) {
      print("[PROFILE_BLOC_LOG] Exception during fetch: $e");
      emit(ProfileError('Terjadi kesalahan: $e'));
    } finally {
      _isFetching = false;
      print("[PROFILE_BLOC_LOG] Fetch completed, resetting fetching flag");
    }
  }

  Future<void> _onUpdateProfile(
      UpdateProfileButtonPressed event, Emitter<ProfileState> emit) async {
    final currentState = state;
    if (currentState is ProfileLoaded) {
      emit(ProfileUpdateInProgress(
          profile: currentState.profile, stats: currentState.stats));

      final result =
          await updateProfile(UpdateProfileParams(request: event.request));

      result.fold(
        (failure) {
          emit(ProfileUpdateFailure(
              message: failure.message,
              profile: currentState.profile,
              stats: currentState.stats));
        },
        (updatedProfile) {
          emit(ProfileUpdateSuccess(
              profile: updatedProfile, stats: currentState.stats));

          final currentAuthState = authBloc.state;
          if (currentAuthState is Authenticated) {
            final updatedUser = currentAuthState.user.copyWith(
              username: updatedProfile.username,
            );
            authBloc.add(UserDataUpdated(updatedUser));
          }
        },
      );
    }
  }

  Future<void> _onDeleteAccount(
      DeleteAccountButtonPressed event, Emitter<ProfileState> emit) async {
    print("[PROFILE_BLOC_LOG] Event DeleteAccountButtonPressed diterima.");
    final currentState = state;
    if (currentState is ProfileLoaded) {
      emit(AccountDeleteInProgress());
    } else {
      emit(ProfileLoading());
    }

    final result = await deleteAccount(NoParams());

    result.fold(
      (failure) {
        print("[PROFILE_BLOC_LOG] Gagal hapus akun: ${failure.message}");
        if (currentState is ProfileLoaded) {
          emit(ProfileUpdateFailure(
              message: failure.message,
              profile: currentState.profile,
              stats: currentState.stats));
        } else {
          emit(ProfileError(failure.message));
        }
      },
      (_) {
        print("[PROFILE_BLOC_LOG] Berhasil hapus akun di backend.");
        emit(AccountDeleteSuccess());
        print(
            "[PROFILE_BLOC_LOG] Memanggil authBloc.add(LogoutButtonPressed).");
        authBloc.add(LogoutButtonPressed());
      },
    );
  }
}
