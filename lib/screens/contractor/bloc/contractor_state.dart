import 'package:takedat_app/models/contractor_model.dart';

abstract class ContractorState {}

class ContractorInitial extends ContractorState {}

class ContractorLoading extends ContractorState {}

class ContractorLoaded extends ContractorState {
  final List<ContractorModel> contractors;
  final bool hasMore;

  ContractorLoaded({
    required this.contractors,
    this.hasMore = true,
  });
}

class ContractorFailure extends ContractorState {
  final String message;
  ContractorFailure(this.message);
}