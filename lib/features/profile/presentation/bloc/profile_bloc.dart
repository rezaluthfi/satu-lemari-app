import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
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
  }

  Future<void> _onFetchProfileData(
      FetchProfileData event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());

    try {
      final profileResult = await getProfile(NoParams());
      final statsResult = await getDashboardStats(NoParams());

      profileResult.fold(
        (failure) => emit(ProfileError(failure.message)),
        (profile) {
          statsResult.fold(
            (failure) => emit(ProfileError(failure.message)),
            (stats) => emit(ProfileLoaded(profile: profile, stats: stats)),
          );
        },
      );
    } catch (e) {
      emit(ProfileError('Terjadi kesalahan: $e'));
    }
  }

  Future<void> _onUpdateProfile(
      UpdateProfileButtonPressed event, Emitter<ProfileState> emit) async {
    final currentState = state;

    if (currentState is ProfileLoaded) {
      emit(ProfileUpdateInProgress());

      try {
        final result =
            await updateProfile(UpdateProfileParams(request: event.request));

        result.fold(
          (failure) => emit(ProfileUpdateFailure(failure.message)),
          (updatedProfile) {
            // Update berhasil, langsung emit state ProfileLoaded dengan data baru
            emit(ProfileLoaded(
              profile: updatedProfile,
              stats: currentState.stats,
            ));

            // Emit state sukses untuk listener di UI
            emit(ProfileUpdateSuccess());
          },
        );
      } catch (e) {
        emit(ProfileUpdateFailure('Terjadi kesalahan: $e'));
      }
    } else {
      emit(ProfileUpdateFailure('Data profil tidak tersedia'));
    }
  }

  Future<void> _onDeleteAccount(
      DeleteAccountButtonPressed event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());

    try {
      final result = await deleteAccount(NoParams());

      result.fold(
        (failure) {
          // Jika gagal, refresh halaman untuk menampilkan error
          add(FetchProfileData());
        },
        (_) => emit(AccountDeleteSuccess()),
      );
    } catch (e) {
      emit(ProfileError('Terjadi kesalahan: $e'));
    }
  }
}
