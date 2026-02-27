import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/auth_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/password_field.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _businessAddressController = TextEditingController();
  final _yearEstablishedController = TextEditingController();
  final _cacNumberController = TextEditingController();
  final _passwordController = TextEditingController();
  final _productionCapacityController = TextEditingController();

  // Selections & Booleans
  String? _businessStructure;
  String? _nepcStatus;
  String? _recentExportActivity;
  String? _productCategory;
  String? _productionLocation;
  String? _salesModel;
  String? _exportObjective;

  File? _cacCertificate;
  File? _nepcCertificate;
  File? _profilePhoto;
  File? _haccpCertificate;
  File? _fdaCertificate;
  File? _halalCertificate;
  File? _sonCertificate;

  bool _commercialScale = false;
  bool _packagedForRetail = false;
  bool _regulatoryRegistration = false;
  bool _engagedLogistics = false;
  bool _receivedInquiries = false;
  bool _productionCompliant = false;

  final Map<String, bool> _activeChannels = {
    'Website': false,
    'Instagram': false,
    'Facebook': false,
    'LinkedIn': false,
    'E-commerce': false,
  };

  final List<String> _businessStructures = [
    'Limited Company',
    'Business Name',
    'Cooperative / Association',
    'Not Formally Registered',
  ];

  final List<String> _nepcStatuses = [
    'Registered',
    'In Progress',
    'Not Registered',
  ];

  final List<String> _exportActivities = [
    'Within last 12 months',
    '1–3 years ago',
    'More than 3 years ago',
    'No exports yet',
  ];

  final List<String> _productCategories = [
    'Agricultural Products',
    'Manufactured Goods',
    'Solid Minerals',
    'Services',
    'Other',
  ];

  final List<String> _productionLocations = [
    'Owned facility',
    'Rented facility',
    'Contract manufacturing',
    'Home-based',
  ];

  final List<String> _salesModels = [
    'Retail',
    'Wholesale',
    'Institutional',
    'Export',
    'Mixed',
  ];

  final List<String> _exportObjectives = [
    'Already exporting',
    'Ready to export within 6–12 months',
    'Exploring export opportunities',
    'General business interest',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _businessNameController.dispose();
    _businessAddressController.dispose();
    _yearEstablishedController.dispose();
    _cacNumberController.dispose();
    _passwordController.dispose();
    _productionCapacityController.dispose();
    super.dispose();
  }

  Future<void> _pickFile(bool forCAC, {String? type}) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        if (forCAC) {
          _cacCertificate = File(result.files.single.path!);
        } else if (type == 'nepc') {
          _nepcCertificate = File(result.files.single.path!);
        } else if (type == 'haccp') {
          _haccpCertificate = File(result.files.single.path!);
        } else if (type == 'fda') {
          _fdaCertificate = File(result.files.single.path!);
        } else if (type == 'halal') {
          _halalCertificate = File(result.files.single.path!);
        } else if (type == 'son') {
          _sonCertificate = File(result.files.single.path!);
        } else {
          _nepcCertificate = File(result.files.single.path!);
        }
      });
    }
  }

  Future<void> _pickProfilePhoto() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _profilePhoto = File(result.files.single.path!);
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final selectedChannels = _activeChannels.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .join(', ');

      final data = {
        'name': _nameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'profile_photo': _profilePhoto,
        'phone': _phoneController.text,
        'business_name': _businessNameController.text,
        'business_address': _businessAddressController.text,
        'year_established': _yearEstablishedController.text,
        'business_structure': _businessStructure,
        'cac_number': _cacNumberController.text,
        'cac_certificate': _cacCertificate,
        'nepc_certificate': _nepcCertificate,
        'haccp_certificate': _haccpCertificate,
        'fda_certificate': _fdaCertificate,
        'halal_certificate': _halalCertificate,
        'son_certificate': _sonCertificate,
        'product_category': _productCategory,
        'registered_with_cac': _cacNumberController.text.isNotEmpty,
        'exported_before': _recentExportActivity != 'No exports yet',
        'registered_with_nepc': _nepcStatus == 'Registered',
        'nepc_status': _nepcStatus,
        'recent_export_activity': _recentExportActivity,
        'commercial_scale': _commercialScale,
        'packaged_for_retail': _packagedForRetail,
        'regulatory_registration': _regulatoryRegistration,
        'engaged_logistics': _engagedLogistics,
        'received_inquiries': _receivedInquiries,
        'production_location': _productionLocation,
        'production_compliant': _productionCompliant,
        'production_capacity': _productionCapacityController.text,
        'active_channels': selectedChannels,
        'sales_model': _salesModel,
        'export_objective': _exportObjective,
      };

      ref.read(authProvider.notifier).register(data);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Account"),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(
          color: AppTheme.text,
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: authState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: Stepper(
                  type: StepperType.horizontal,
                  currentStep: _currentStep,
                  onStepContinue: () {
                    if (_currentStep < 2) {
                      setState(() => _currentStep++);
                    } else {
                      _submit();
                    }
                  },
                  onStepCancel: () {
                    if (_currentStep > 0) {
                      setState(() => _currentStep--);
                    }
                  },
                  controlsBuilder: (context, details) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 32),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: details.onStepContinue,
                              child: Text(_currentStep == 2
                                  ? "Complete Registration"
                                  : "Next Step"),
                            ),
                          ),
                          if (_currentStep > 0) ...[
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: details.onStepCancel,
                                child: const Text("Previous"),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                  steps: [
                    _buildStep1(),
                    _buildStep2(),
                    _buildStep3(),
                  ],
                ),
              ),
      ),
    );
  }

  Step _buildStep1() {
    return Step(
      title: const Text("Identity"),
      isActive: _currentStep >= 0,
      state: _currentStep > 0 ? StepState.complete : StepState.indexed,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoNote("Step 1: Core Identity & Business Profile"),
          const SizedBox(height: 16),
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppTheme.primary.withOpacity(0.1),
                  backgroundImage:
                      _profilePhoto != null ? FileImage(_profilePhoto!) : null,
                  child: _profilePhoto == null
                      ? const Icon(Icons.person,
                          size: 50, color: AppTheme.primary)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickProfilePhoto,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppTheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Center(
            child: Text(
              "Upload Profile Photo *",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
                labelText: "Full Name *", prefixIcon: Icon(Icons.person)),
            validator: (v) => v!.isEmpty ? "Required" : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
                labelText: "Email address *", prefixIcon: Icon(Icons.email)),
            validator: (v) => v!.isEmpty ? "Required" : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(
                labelText: "Telephone Number *", prefixIcon: Icon(Icons.phone)),
            validator: (v) => v!.isEmpty ? "Required" : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _businessNameController,
            decoration: const InputDecoration(
                labelText: "Business Name *", prefixIcon: Icon(Icons.store)),
            validator: (v) => v!.isEmpty ? "Required" : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _businessAddressController,
            decoration: const InputDecoration(
                labelText: "Business Address *", prefixIcon: Icon(Icons.map)),
            validator: (v) => v!.isEmpty ? "Required" : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _yearEstablishedController,
            decoration: const InputDecoration(
                labelText: "Year Established",
                prefixIcon: Icon(Icons.calendar_today)),
          ),
          const SizedBox(height: 16),
          PasswordField(
            controller: _passwordController,
            labelText: "Secret Password *",
            validator: (v) => v!.isEmpty ? "Required" : null,
          ),
        ],
      ),
    );
  }

  Step _buildStep2() {
    return Step(
      title: const Text("Legal"),
      isActive: _currentStep >= 1,
      state: _currentStep > 1 ? StepState.complete : StepState.indexed,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoNote("Step 2: Legal & Regulatory Status"),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _businessStructure,
            decoration: const InputDecoration(labelText: "Business Structure"),
            items: _businessStructures
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (v) => setState(() => _businessStructure = v),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _cacNumberController,
            decoration:
                const InputDecoration(labelText: "CAC Registration Number"),
          ),
          const SizedBox(height: 16),
          _buildFileUpload(
            label: "Upload CAC Certificate",
            file: _cacCertificate,
            onTap: () => _pickFile(true),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _nepcStatus,
            decoration:
                const InputDecoration(labelText: "NEPC Registration Status"),
            items: _nepcStatuses
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (v) => setState(() => _nepcStatus = v),
          ),
          const SizedBox(height: 16),
          _buildFileUpload(
            label: "Upload NEPC Certificate (if applicable)",
            file: _nepcCertificate,
            onTap: () => _pickFile(false, type: 'nepc'),
          ),
          const SizedBox(height: 16),
          _buildFileUpload(
            label: "Upload HACCP Certificate (Optional)",
            file: _haccpCertificate,
            onTap: () => _pickFile(false, type: 'haccp'),
          ),
          const SizedBox(height: 16),
          _buildFileUpload(
            label: "Upload FDA Certificate (Optional)",
            file: _fdaCertificate,
            onTap: () => _pickFile(false, type: 'fda'),
          ),
          const SizedBox(height: 16),
          _buildFileUpload(
            label: "Upload Halal Certificate (Optional)",
            file: _halalCertificate,
            onTap: () => _pickFile(false, type: 'halal'),
          ),
          const SizedBox(height: 16),
          _buildFileUpload(
            label: "Upload SON Certificate (Optional)",
            file: _sonCertificate,
            onTap: () => _pickFile(false, type: 'son'),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _productCategory,
            decoration: const InputDecoration(labelText: "Export Category *"),
            items: _productCategories
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (v) => setState(() => _productCategory = v),
          ),
        ],
      ),
    );
  }

  Step _buildStep3() {
    return Step(
      title: const Text("Readiness"),
      isActive: _currentStep >= 2,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoNote("Step 3: Export Activity & Readiness"),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _recentExportActivity,
            decoration:
                const InputDecoration(labelText: "Recent Export Activity"),
            items: _exportActivities
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (v) => setState(() => _recentExportActivity = v),
          ),
          const SizedBox(height: 24),
          const Text("Evidence of Export Readiness",
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: AppTheme.primary)),
          SwitchListTile(
            title: const Text("Produce at commercial scale?"),
            value: _commercialScale,
            onChanged: (v) => setState(() => _commercialScale = v),
          ),
          SwitchListTile(
            title: const Text("Products packaged for retail?"),
            value: _packagedForRetail,
            onChanged: (v) => setState(() => _packagedForRetail = v),
          ),
          SwitchListTile(
            title: const Text("Undergone regulatory registration?"),
            value: _regulatoryRegistration,
            onChanged: (v) => setState(() => _regulatoryRegistration = v),
          ),
          SwitchListTile(
            title: const Text("Engaged export logistics provider?"),
            value: _engagedLogistics,
            onChanged: (v) => setState(() => _engagedLogistics = v),
          ),
          SwitchListTile(
            title: const Text("Received inquiries from foreign buyers?"),
            value: _receivedInquiries,
            onChanged: (v) => setState(() => _receivedInquiries = v),
          ),
          const SizedBox(height: 24),
          const Text("Production Integrity",
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: AppTheme.primary)),
          DropdownButtonFormField<String>(
            value: _productionLocation,
            decoration:
                const InputDecoration(labelText: "Primary Production Location"),
            items: _productionLocations
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (v) => setState(() => _productionLocation = v),
          ),
          SwitchListTile(
            title: const Text("Location compliant with regulations?"),
            value: _productionCompliant,
            onChanged: (v) => setState(() => _productionCompliant = v),
          ),
          TextFormField(
            controller: _productionCapacityController,
            decoration:
                const InputDecoration(labelText: "Monthly Production Capacity"),
          ),
          const SizedBox(height: 24),
          const Text("Channels & Strategy",
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: AppTheme.primary)),
          Wrap(
            spacing: 8,
            children: _activeChannels.keys.map((channel) {
              return FilterChip(
                label: Text(channel),
                selected: _activeChannels[channel]!,
                onSelected: (selected) {
                  setState(() => _activeChannels[channel] = selected);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _salesModel,
            decoration: const InputDecoration(labelText: "Primary Sales Model"),
            items: _salesModels
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (v) => setState(() => _salesModel = v),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _exportObjective,
            decoration: const InputDecoration(
                labelText: "Export Objective Classification"),
            items: _exportObjectives
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (v) => setState(() => _exportObjective = v),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoNote(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: AppTheme.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8)),
      child: Text(text,
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: AppTheme.primary)),
    );
  }

  Widget _buildFileUpload(
      {required String label, File? file, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.upload_file, color: AppTheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                file != null ? file.path.split('/').last : label,
                style: TextStyle(
                    color: file != null ? AppTheme.text : Colors.grey),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (file != null)
              const Icon(Icons.check_circle, color: Colors.green),
          ],
        ),
      ),
    );
  }
}
