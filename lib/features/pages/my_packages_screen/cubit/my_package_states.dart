
import '../../../../data/models/my_package_model.dart';

abstract class MyPackageState {}

class MyPackageInitial extends MyPackageState {}

class MyPackageLoading extends MyPackageState {}

class MyPackageLoaded extends MyPackageState {
  final MyPackageModel package;
  MyPackageLoaded(this.package);
}

class MyPackageError extends MyPackageState {
  final String message;
  MyPackageError(this.message);
}

