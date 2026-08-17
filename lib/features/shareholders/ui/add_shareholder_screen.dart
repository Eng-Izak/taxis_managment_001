import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/shared/widgets/app_button.dart';
import '../../../../core/shared/widgets/app_text_field.dart';
import '../../../../core/shared/widgets/app_phone_field.dart';
import '../../../../core/shared/widgets/documents_section_widget.dart';
import '../../../../core/shared/models/shareholder_model.dart';
import '../../../../core/shared/models/document_meta_model.dart';
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
  List<DocumentMeta> _documents = [];

  @override
  void initState() {
    super.initState();
    final p = widget.shareholderToEdit;
    _nameController = TextEditingController(text: p?.name ?? '');
    _phoneController = TextEditingController(text: p?.phone ?? '');
    _nationalIdController = TextEditingController(text: p?.nationalId ?? '');
    _accountDetailsController = TextEditingController(text: p?.accountDetails ?? '');
    _notesController = TextEditingController(text: p?.notes ?? '');
    _documents = p != null ? List<DocumentMeta>.from(p.documents) : [];
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
      documents: _documents,
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
        title: Text(
          isEdit ? l10n.editShareholderTitle : l10n.addShareholderTitle,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Shareholder Name: Text + Numbers
              AppTextField(
                label: l10n.shareholderName,
                hint: context.isArabic ? 'أحمد محمود سالم' : 'Ahmed Mahmoud Salem',
                controller: _nameController,
                keyboardType: TextInputType.text,
                validator: (val) => AppValidators.requiredField(val, message: l10n.shareholderName),
              ),
              const SizedBox(height: 16),

              // Phone Number: Country selector and strict length validation
              AppPhoneField(
                label: l10n.phoneNumber,
                controller: _phoneController,
                isRequired: true,
              ),
              const SizedBox(height: 16),

              // National ID: Digits only
              AppTextField(
                label: l10n.nationalId,
                hint: '2980101XXXXXXXX',
                controller: _nationalIdController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(14),
                ],
              ),
              const SizedBox(height: 16),

              // Account Details: Text + Numbers
              AppTextField(
                label: l10n.accountDetails,
                hint: 'InstaPay / Vodafone Cash / Bank IBAN',
                controller: _accountDetailsController,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 16),

              // Documents & Multi-Image Section
              DocumentsSectionWidget(
                title: context.isArabic ? 'مستندات وهوية المساهم (صور البطاقة / العقود)' : 'Shareholder Documents & ID (Cards/Contracts)',
                documents: _documents,
                onDocumentsChanged: (docs) {
                  setState(() => _documents = docs);
                },
              ),
              const SizedBox(height: 16),

              // Notes: Text + Numbers
              AppTextField(
                label: l10n.documentsAndNotes,
                hint: l10n.notesHint,
                controller: _notesController,
                keyboardType: TextInputType.multiline,
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              // Save Button
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
