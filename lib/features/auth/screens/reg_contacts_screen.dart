import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class RegContactsScreen extends StatefulWidget {
  const RegContactsScreen({
    super.key,
    required this.onBack,
    required this.onNext,
  });

  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  State<RegContactsScreen> createState() => _RegContactsScreenState();
}

class _RegContactsScreenState extends State<RegContactsScreen> {
  final List<TextEditingController> _nameControllers = List.generate(
    5,
    (_) => TextEditingController(),
  );

  final List<TextEditingController> _phoneControllers = List.generate(
    5,
    (_) => TextEditingController(),
  );

  final List<TextEditingController> _relationshipControllers = List.generate(
    5,
    (_) => TextEditingController(),
  );

  @override
  void dispose() {
    for (final controller in _nameControllers) {
      controller.dispose();
    }

    for (final controller in _phoneControllers) {
      controller.dispose();
    }

    for (final controller in _relationshipControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  void _continue() {
    for (int i = 0; i < 5; i++) {
      if (_nameControllers[i].text.trim().isEmpty ||
          _phoneControllers[i].text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Contact ${i + 1}: name and phone are required'),
          ),
        );
        return;
      }
    }

    widget.onNext();
  }

  Widget _field({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: AppTextStyles.body,
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }

  Widget _contactCard(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contact ${index + 1}',
            style: AppTextStyles.caption.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.7,
            ),
          ),

          const SizedBox(height: 12),

          _field(
            label: 'Full name',
            hint: 'e.g. Ngozi Okafor',
            controller: _nameControllers[index],
          ),

          const SizedBox(height: 12),

          _field(
            label: 'Phone number',
            hint: '+234 801 234 5678',
            controller: _phoneControllers[index],
            keyboardType: TextInputType.phone,
          ),

          const SizedBox(height: 12),

          _field(
            label: 'Relationship',
            hint: 'Sister / Friend / Colleague',
            controller: _relationshipControllers[index],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 64,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton(
                        onPressed: widget.onBack,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          side: const BorderSide(color: AppColors.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text('← Back', style: AppTextStyles.caption),
                      ),
                    ),
                  ),

                  Expanded(
                    child: Text(
                      'Trusted Contacts',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyBold.copyWith(
                        fontFamily: 'Syne',
                        fontSize: 17,
                      ),
                    ),
                  ),

                  const SizedBox(
                    width: 64,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text('2 of 3', style: AppTextStyles.caption),
                    ),
                  ),
                ],
              ),
            ),

            // Progress
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _stepBar(AppColors.secondary),
                  const SizedBox(width: 6),
                  _stepBar(AppColors.primary),
                  const SizedBox(width: 6),
                  _stepBar(AppColors.stepInactive),
                ],
              ),
            ),

            // Alert
            Container(
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceSoft,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 5),
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Add at least 5 contacts who will receive your SOS alerts',
                      style: AppTextStyles.caption,
                    ),
                  ),
                ],
              ),
            ),

            // Contacts
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                children: [
                  _contactCard(0),
                  _contactCard(1),
                  _contactCard(2),
                  _contactCard(3),
                  _contactCard(4),
                ],
              ),
            ),

            // Continue
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _continue,
                  child: const Text('Continue →'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepBar(Color color) {
    return Container(
      width: 28,
      height: 4,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
