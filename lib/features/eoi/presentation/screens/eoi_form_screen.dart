import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/eoi_provider.dart';
import '../../../../core/theme/app_theme.dart';

// Nigeria's 36 states + FCT
const List<String> kNigerianStates = [
  'Abia',
  'Adamawa',
  'Akwa Ibom',
  'Anambra',
  'Bauchi',
  'Bayelsa',
  'Benue',
  'Borno',
  'Cross River',
  'Delta',
  'Ebonyi',
  'Edo',
  'Ekiti',
  'Enugu',
  'FCT (Abuja)',
  'Gombe',
  'Imo',
  'Jigawa',
  'Kaduna',
  'Kano',
  'Katsina',
  'Kebbi',
  'Kogi',
  'Kwara',
  'Lagos',
  'Nasarawa',
  'Niger',
  'Ogun',
  'Ondo',
  'Osun',
  'Oyo',
  'Plateau',
  'Rivers',
  'Sokoto',
  'Taraba',
  'Yobe',
  'Zamfara',
];

const List<String> kCertifications = [
  'NEPC Exporter\'s Certificate',
  'HACCP Certification',
  'FDA Certification',
  'NAFDAC Registration Certificate',
  'SON Conformity Certificate (MANCAP)',
  'Halal Certification',
  'Phytosanitary Certificate (NAQS)',
  'Veterinary Health Certificate',
  'Fumigation Certificate',
  'Laboratory Test / Analysis Report',
  'Clean Certificate of Inspection (CCI)',
  'Certificate of Origin (NACCIMA)',
  'AfCFTA Certificate of Origin',
  'ISO Certification',
  'Organic Certification',
  'None of the above',
];

const List<String> kSeminarGoals = [
  'Access to export financing',
  'Market access/buyer linkages',
  'Compliance & documentation guidance',
  'Packaging & labelling standards',
  'General export awareness',
  'Other',
];

class EoiFormScreen extends ConsumerStatefulWidget {
  final int summitId;
  final String summitTitle;

  const EoiFormScreen({
    super.key,
    required this.summitId,
    required this.summitTitle,
  });

  @override
  ConsumerState<EoiFormScreen> createState() => _EoiFormScreenState();
}

class _EoiFormScreenState extends ConsumerState<EoiFormScreen> {
  int _step = 0;
  final _formKeyA = GlobalKey<FormState>();
  final _formKeyB = GlobalKey<FormState>();
  final _formKeyC = GlobalKey<FormState>();

  // Section A controllers
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _businessNameCtrl = TextEditingController();
  String? _state;
  String? _preferredLocation;
  String? _howHeard;

  // Section B
  String? _sector;
  final _productsCtrl = TextEditingController();
  String? _cacReg;
  String? _nepcReg;
  String? _exportStatus;
  String? _exportValue;

  // Section C
  bool _commercialScale = false;
  bool _regulatoryReg = false;
  final _regulatoryBodyCtrl = TextEditingController();
  final Set<String> _selectedCerts = {};
  final Set<String> _selectedGoals = {};

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _businessNameCtrl.dispose();
    _productsCtrl.dispose();
    _regulatoryBodyCtrl.dispose();
    super.dispose();
  }

  void _next() {
    final keys = [_formKeyA, _formKeyB, _formKeyC];
    if (keys[_step].currentState!.validate()) {
      if (_step < 2) {
        setState(() => _step++);
      } else {
        _submit();
      }
    }
  }

  void _submit() {
    ref.read(eoiProvider.notifier).submitEoi(widget.summitId, {
      'full_name': _nameCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'business_name': _businessNameCtrl.text.trim(),
      'state': _state,
      'preferred_location': _preferredLocation,
      'how_heard': _howHeard,
      'sector': _sector,
      'primary_products': _productsCtrl.text.trim(),
      'cac_registration': _cacReg,
      'nepc_registration': _nepcReg,
      'export_status': _exportStatus,
      'recent_export_value': _exportValue,
      'commercial_scale': _commercialScale,
      'regulatory_registration': _regulatoryReg,
      'regulatory_body': _regulatoryBodyCtrl.text.trim().isEmpty
          ? null
          : _regulatoryBodyCtrl.text.trim(),
      'certifications': _selectedCerts.toList(),
      'seminar_goals': _selectedGoals.toList(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(eoiProvider);

    // Navigate to confirmation when submitted
    ref.listen<EoiState>(eoiProvider, (prev, next) {
      if (!prev!.submitted && next.submitted) {
        context.go('/eoi/confirmation');
      }
      if (next.error != null && prev.error != next.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Express Interest',
          style:
              TextStyle(color: Color(0xFF1A1A2E), fontWeight: FontWeight.bold),
        ),
        leading: _step > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A2E)),
                onPressed: () => setState(() => _step--),
              )
            : IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A2E)),
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/summits-landing');
                  }
                },
              ),
      ),
      body: Column(
        children: [
          // Progress indicator
          _buildProgressBar(),
          // Summit info banner
          _buildSummitBanner(),
          Expanded(
            child: state.isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: AppTheme.primary),
                        SizedBox(height: 16),
                        Text('Submitting your application...'),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: _buildCurrentStep(),
                  ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final steps = ['Contact', 'Business', 'Additional'];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: List.generate(steps.length, (i) {
          final isActive = i == _step;
          final isDone = i < _step;
          return Expanded(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: isDone
                      ? Colors.green
                      : isActive
                          ? AppTheme.primary
                          : Colors.grey.shade300,
                  child: isDone
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : Text('${i + 1}',
                          style: TextStyle(
                            color: isActive ? Colors.white : Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          )),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(steps[i],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight:
                                isActive ? FontWeight.bold : FontWeight.normal,
                            color: isActive
                                ? AppTheme.primary
                                : Colors.grey.shade600,
                          )),
                      if (i < steps.length - 1)
                        Container(
                            height: 2,
                            color:
                                isDone ? Colors.green : Colors.grey.shade300),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSummitBanner() {
    return Container(
      width: double.infinity,
      color: AppTheme.primary.withOpacity(0.08),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.location_on, size: 16, color: AppTheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.summitTitle,
              style: const TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_step) {
      case 0:
        return _buildSectionA();
      case 1:
        return _buildSectionB();
      case 2:
        return _buildSectionC();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildSectionA() {
    return Form(
      key: _formKeyA,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Section A', 'Contact & Business Identity'),
          const SizedBox(height: 20),
          _field(_nameCtrl, 'Full Name *', Icons.person, validator: _required),
          _field(_phoneCtrl, 'Phone Number (WhatsApp) *', Icons.phone,
              keyboardType: TextInputType.phone, validator: _required),
          _field(_emailCtrl, 'Email Address *', Icons.email,
              keyboardType: TextInputType.emailAddress, validator: (v) {
            if (v == null || v.isEmpty) return 'Required';
            if (!v.contains('@')) return 'Enter a valid email';
            return null;
          }),
          _field(_businessNameCtrl, 'Business / Organisation Name *',
              Icons.business,
              validator: _required),
          _dropdown(
            label: 'State / City *',
            value: _state,
            items: kNigerianStates,
            onChanged: (v) => setState(() => _state = v),
            validator: (v) => v == null ? 'Required' : null,
          ),
          _dropdown(
            label: 'Preferred Event Location *',
            value: _preferredLocation,
            items: const ['Port Harcourt', 'Lagos', 'Kano'],
            onChanged: (v) => setState(() => _preferredLocation =
                v == 'Port Harcourt' ? 'port_harcourt' : v?.toLowerCase()),
            validator: (v) => v == null ? 'Required' : null,
          ),
          _dropdown(
            label: 'How did you hear about this Seminar? *',
            value: _howHeard,
            items: const [
              'NEPC',
              'Bank',
              'Industry Association/Network',
              'Word-of-Mouth',
              'Other',
            ],
            onChanged: (v) {
              final map = {
                'NEPC': 'nepc',
                'Bank': 'bank',
                'Industry Association/Network': 'industry_association',
                'Word-of-Mouth': 'word_of_mouth',
                'Other': 'other',
              };
              setState(() => _howHeard = map[v]);
            },
            validator: (v) => v == null ? 'Required' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionB() {
    return Form(
      key: _formKeyB,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Section B', 'Business Profile & Export Status'),
          const SizedBox(height: 20),
          _dropdown(
            label: 'Sector *',
            value: _sector,
            items: const [
              'Agro-processing',
              'Solid Minerals',
              'Manufacturing',
              'Services',
              'Multiple Sectors',
              'Other',
            ],
            onChanged: (v) {
              final map = {
                'Agro-processing': 'agro_processing',
                'Solid Minerals': 'solid_minerals',
                'Manufacturing': 'manufacturing',
                'Services': 'services',
                'Multiple Sectors': 'multiple',
                'Other': 'other',
              };
              setState(() => _sector = map[v]);
            },
            validator: (v) => v == null ? 'Required' : null,
          ),
          _field(_productsCtrl, 'Primary Product(s) for Export *',
              Icons.inventory_2,
              validator: _required),
          _dropdown(
            label: 'CAC Registration? *',
            value: _cacReg,
            items: const ['Yes', 'No', 'In Progress'],
            onChanged: (v) =>
                setState(() => _cacReg = v?.toLowerCase().replaceAll(' ', '_')),
            validator: (v) => v == null ? 'Required' : null,
          ),
          _dropdown(
            label: 'NEPC Registration? *',
            value: _nepcReg,
            items: const ['Yes', 'No', 'In Progress'],
            onChanged: (v) => setState(
                () => _nepcReg = v?.toLowerCase().replaceAll(' ', '_')),
            validator: (v) => v == null ? 'Required' : null,
          ),
          _dropdown(
            label: 'Export Status *',
            value: _exportStatus,
            items: const [
              'Currently exporting (active in last 12 months)',
              'Exported before (last export 1–3 years ago)',
              'Export-ready (product ready, no export yet)',
              'Exploring / learning about export',
            ],
            onChanged: (v) {
              final map = {
                'Currently exporting (active in last 12 months)':
                    'currently_exporting',
                'Exported before (last export 1–3 years ago)':
                    'exported_before',
                'Export-ready (product ready, no export yet)': 'export_ready',
                'Exploring / learning about export': 'exploring',
              };
              setState(() => _exportStatus = map[v]);
            },
            validator: (v) => v == null ? 'Required' : null,
          ),
          _dropdown(
            label: 'Most Recent Export Value (approx.) *',
            value: _exportValue,
            items: const [
              'Above ₦50m',
              '₦10m - ₦50m',
              'Below ₦10m',
              'No export yet',
            ],
            onChanged: (v) {
              final map = {
                'Above ₦50m': 'above_50m',
                '₦10m - ₦50m': '10m_to_50m',
                'Below ₦10m': 'below_10m',
                'No export yet': 'no_export_yet',
              };
              setState(() => _exportValue = map[v]);
            },
            validator: (v) => v == null ? 'Required' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionC() {
    return Form(
      key: _formKeyC,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Section C', 'Additional Information'),
          const SizedBox(height: 20),

          // Commercial scale
          _yesNoTile(
            'Do you produce at a commercial scale? *',
            _commercialScale,
            (v) => setState(() => _commercialScale = v),
          ),

          const SizedBox(height: 12),

          // Regulatory registration
          _yesNoTile(
            'Are your products registered with any regulatory body? *',
            _regulatoryReg,
            (v) => setState(() => _regulatoryReg = v),
          ),

          if (_regulatoryReg) ...[
            const SizedBox(height: 12),
            _field(
                _regulatoryBodyCtrl,
                'Which regulatory body? (if yes, please indicate)',
                Icons.verified_user),
          ],

          const SizedBox(height: 20),
          _subHeader('Which certifications do you hold?'),
          const Text(
            'Select all that apply',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: kCertifications.map((cert) {
              final selected = _selectedCerts.contains(cert);
              return FilterChip(
                label: Text(cert, style: const TextStyle(fontSize: 12)),
                selected: selected,
                selectedColor: AppTheme.primary.withOpacity(0.15),
                checkmarkColor: AppTheme.primary,
                onSelected: (v) {
                  setState(() {
                    if (v) {
                      _selectedCerts.add(cert);
                    } else {
                      _selectedCerts.remove(cert);
                    }
                  });
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 20),
          _subHeader('What do you most want from this seminar? *'),
          const Text(
            'Select up to 2',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: kSeminarGoals.map((goal) {
              final selected = _selectedGoals.contains(goal);
              return FilterChip(
                label: Text(goal, style: const TextStyle(fontSize: 12)),
                selected: selected,
                selectedColor: AppTheme.primary.withOpacity(0.15),
                checkmarkColor: AppTheme.primary,
                onSelected: (v) {
                  setState(() {
                    if (v && _selectedGoals.length < 2) {
                      _selectedGoals.add(goal);
                    } else {
                      _selectedGoals.remove(goal);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Privacy notice
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade100),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade600, size: 18),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'The information you provide will be used strictly for participant selection and programme planning.',
                    style: TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: Row(
        children: [
          if (_step > 0) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _step--),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppTheme.primary),
                ),
                child: const Text('Previous'),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _next,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                _step == 2 ? 'Submit Application' : 'Next',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _sectionHeader(String tag, String title) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary, AppTheme.primary.withOpacity(0.7)],
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(tag,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(title,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15)),
          ),
        ],
      ),
    );
  }

  Widget _subHeader(String text) {
    return Text(text,
        style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Color(0xFF1A1A2E)));
  }

  Widget _field(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: ctrl,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppTheme.primary, size: 20),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String? Function(String?)? validator,
  }) {
    // Normalize: show first match where lowercased == value
    String? displayValue;
    if (value != null) {
      final match = items.cast<String?>().firstWhere(
            (item) =>
                item?.toLowerCase() == value ||
                item?.toLowerCase().replaceAll(' ', '_') == value ||
                item == value,
            orElse: () => null,
          );
      displayValue = match;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: displayValue,
        validator: validator,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _yesNoTile(String label, bool value, ValueChanged<bool> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(label, style: const TextStyle(fontSize: 13)),
        value: value,
        activeColor: AppTheme.primary,
        onChanged: onChanged,
      ),
    );
  }

  String? _required(String? v) => (v == null || v.isEmpty) ? 'Required' : null;
}
