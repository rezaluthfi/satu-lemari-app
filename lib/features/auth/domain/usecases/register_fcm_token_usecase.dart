import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:satulemari/core/errors/failures.dart';
import 'package:satulemari/core/usecases/usecase.dart';
import 'package:satulemari/features/notification/domain/repositories/notification_repository.dart';

class RegisterFCMTokenUseCase implements UseCase<void, RegisterFCMTokenParams> {
  final NotificationRepository repository;
  RegisterFCMTokenUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(RegisterFCMTokenParams params) async {
    return await repository.registerFCMToken(params.token);
  }
}

class RegisterFCMTokenParams extends Equatable {
  final String token;
  const RegisterFCMTokenParams({required this.token});
  @override
  List<Object> get props => [token];
}
