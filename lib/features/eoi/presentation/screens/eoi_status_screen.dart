import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/eoi_provider.dart';
import '../../../../core/theme/app_theme.dart';

class EoiStatusScreen extends ConsumerStatefulWidget {
  final int summitId;

  const EoiStatusScreen({super.key, required this.summitId});

  @override
  ConsumerState<EoiStatusScreen> createState() => _EoiStatusScreenState();
}

class _EoiStatusScreenState extends ConsumerState<EoiStatusScreen> {
  final _emailCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  void _check() {
    if (_formKey.currentState!.validate()) {
      ref
          .read(eoiProvider.notifier)
          .checkStatus(_emailCtrl.text.trim(), widget.summitId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(eoiProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Check Application Status',
          style:
              TextStyle(color: Color(0xFF1A1A2E), fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A2E)),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Instruction card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: AppTheme.primary, size: 28),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Enter the email address you used when submitting your expression of interest.',
                      style: TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Email form
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      prefixIcon:
                          const Icon(Icons.email, color: AppTheme.primary),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      if (!v.contains('@')) return 'Enter a valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: state.isLoading ? null : _check,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: state.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('Check Status',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Error
            if (state.error != null) _errorCard(state.error!),

            // Status result
            if (state.statusResult != null)
              _buildStatusCard(context, state.statusResult!),
          ],
        ),
      ),
    );
  }

  Widget _errorCard(String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade600),
          const SizedBox(width: 10),
          Expanded(
              child: Text(error,
                  style: TextStyle(color: Colors.red.shade700, fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, Map<String, dynamic> result) {
    final status = result['status'] as String;

    Color cardColor;
    Color iconBg;
    IconData icon;
    String title;
    String subtitle;

    switch (status) {
      case 'selected':
        cardColor = Colors.green.shade50;
        iconBg = Colors.green;
        icon = Icons.emoji_events_rounded;
        title = 'Congratulations! You\'ve been selected';
        subtitle = result['message'] ?? 'Please complete your registration.';
        break;
      case 'rejected':
        cardColor = Colors.red.shade50;
        iconBg = Colors.red.shade400;
        icon = Icons.cancel_rounded;
        title = 'Application Unsuccessful';
        subtitle = result['message'] ?? '';
        break;
      default:
        cardColor = Colors.orange.shade50;
        iconBg = Colors.orange;
        icon = Icons.hourglass_empty_rounded;
        title = 'Application Under Review';
        subtitle = result['message'] ??
            'We\'ll notify you of the outcome. Please check back later.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: iconBg.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: iconBg,
            child: Icon(icon, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: Color(0xFF1A1A2E)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
            textAlign: TextAlign.center,
          ),

          // Show rejection reason if present
          if (status == 'rejected' && result['reason'] != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(8)),
              child: Text(result['reason'],
                  style: const TextStyle(fontSize: 12),
                  textAlign: TextAlign.center),
            ),
          ],

          // CTA for selected participants
          if (status == 'selected') ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  final token = result['registration_token'] as String?;
                  if (token != null) {
                    context.go('/eoi/complete-registration',
                        extra: {'token': token, 'name': result['full_name']});
                  }
                },
                icon: const Icon(Icons.arrow_forward, color: Colors.white),
                label: const Text(
                  'Complete Your Registration →',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
