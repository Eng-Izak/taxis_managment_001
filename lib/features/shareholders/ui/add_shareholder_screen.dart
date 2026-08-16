import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/shared/widgets/app_button.dart';
import '../../../../core/shared/widgets/app_text_field.dart';
import '../../../../core/shared/models/shareholder_model.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/localization/app_localization_extension.dart';
import '../logic/shareholders_cubit.dart';

class AddShareholderScreen extends StatefulWidget {
  final ShareholderModel? shareholderToEdit;

  const AddShareholderScreen({
    super.key,
    this.shareholderToEdit,
  });

  @override
  State<AddShareholderScreen> createState() => _AddShareholderScreenState();
}

class _AddShareholderScreenState extends State<AddShareholderScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _nationalIdController;
  late final TextEditingController _accountDetailsController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final p = widget.shareholderToEdit;
    _nameController = TextEditingController(text: p?.name ?? '');
    _phoneController = TextEditingController(text: p?.phone ?? '');
    _nationalIdController = TextEditingController(text: p?.nationalId ?? '');
    _accountDetailsController = TextEditingController(text: p?.accountDetails ?? '');
    _notesController = TextEditingController(text: p?.notes ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _nationalIdController.dispose();
    _accountDetailsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveShareholder() {
    if (!_formKey.currentState!.validate()) return;

    final isEdit = widget.shareholderToEdit != null;
    final shareholder = ShareholderModel(
      id: isEdit ? widget.shareholderToEdit!.id : 'partner_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      nationalId: _nationalIdController.text.trim(),
      accountDetails: _accountDetailsController.text.trim(),
      notes: _notesController.text.trim(),
    );

    context.read<ShareholdersCubit>().addOrUpdateShareholder(shareholder);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.shareholderToEdit != null;
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? l10n.editShareholderTitle : l10n.addShareholderTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                label: l10n.shareholderName,
                hint: 'Ahmed Mahmoud',
                controller: _nameController,
                validator: (val) => AppValidators.requiredField(val, message: l10n.shareholderName),
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: l10n.phoneNumber,
                hint: '010XXXXXXXX',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                validator: AppValidators.validPhone,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: l10n.nationalId,
                hint: '2980101XXXXXXX',
                controller: _nationalIdController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: l10n.accountDetails,
                hint: 'InstaPay / Vodafone Cash / Bank IBAN',
                controller: _accountDetailsController,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: l10n.documentsAndNotes,
                hint: l10n.notesHint,
                controller: _notesController,
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              AppButton(
                text: isEdit ? l10n.edit : l10n.save,
                onPressed: _saveShareholder,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
