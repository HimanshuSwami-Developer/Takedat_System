
import 'package:image_picker/image_picker.dart';
import 'package:takedat_app/models/contractor_model.dart';

abstract class ContractorEvent {}

class LoadContractorsEvent extends ContractorEvent {}

class LoadMoreContractorsEvent extends ContractorEvent {}

class SearchContractorsEvent extends ContractorEvent {
  final String query;
  SearchContractorsEvent(this.query);
}

class FilterContractorsEvent extends ContractorEvent {
  final double? minAmount;
  final double? maxAmount;
  final DateTime? payDate;

  FilterContractorsEvent({
    this.minAmount,
    this.maxAmount,
    this.payDate,
  });
}
class CreateContractorEvent extends ContractorEvent {
  final ContractorModel model;
  final XFile? paySlipFile; // ✅ XFile works on both web and mobile
  CreateContractorEvent(this.model, {this.paySlipFile});
}

class UpdateContractorEvent extends ContractorEvent {
  final int id;
  final ContractorModel model;
  final XFile? paySlipFile; // ✅
  UpdateContractorEvent(this.id, this.model, {this.paySlipFile});
}
class DeleteContractorEvent extends ContractorEvent {
  final int id;
  DeleteContractorEvent(this.id);
}