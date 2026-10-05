// import 'package:flutter/material.dart';

// import '../../../core/theme/app_colors.dart';

// class SettingsScreen extends StatefulWidget {
//   const SettingsScreen({
//     super.key,
//     required this.onBack,
//     required this.onProfile,
//     required this.onContacts,
//     required this.onHistory,
//     required this.onPlans,
//     required this.onBilling,
//     required this.onHousehold,
//     required this.onOrganization,
//     this.hasHouseholdAccess = false,
//     this.hasOrganizationAccess = false,
//   });

//   final VoidCallback onBack;
//   final VoidCallback onProfile;
//   final VoidCallback onContacts;
//   final VoidCallback onHistory;
//   final VoidCallback onPlans;
//   final VoidCallback onBilling;
//   final VoidCallback onHousehold;
//   final VoidCallback onOrganization;

//   final bool hasHouseholdAccess;
//   final bool hasOrganizationAccess;

//   @override
//   State<SettingsScreen> createState() => _SettingsScreenState();
// }

// class _SettingsScreenState extends State<SettingsScreen> {
//   final TextEditingController _messageController = TextEditingController();

//   bool sendMapLink = true;
//   bool autoAudioRecording = true;
//   bool requireHold = true;

//   bool shakeArmed = true;
//   bool silentTapArmed = true;
//   bool voiceArmed = true;

//   @override
//   void dispose() {
//     _messageController.dispose();
//     super.dispose();
//   }

//   void _saveSettings() {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Settings saved successfully.')),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//         leading: IconButton(
//           onPressed: widget.onBack,
//           icon: const Icon(Icons.arrow_back),
//         ),
//         title: const Text(
//           'Settings',
//           style: TextStyle(fontWeight: FontWeight.w700),
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.only(top: 8, bottom: 32),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             // ==========================================================
//             // EMERGENCY MESSAGE
//             // ==========================================================
//             _sectionLabel('EMERGENCY MESSAGE'),

//             _card(
//               context,
//               child: Column(
//                 children: [
//                   _textField(
//                     context,
//                     label: 'Custom SMS text sent to contacts',
//                     controller: _messageController,
//                     hint: 'I need help. This is my live location.',
//                   ),

//                   const SizedBox(height: 8),

//                   _settingRow(
//                     context,
//                     title: 'Include map link',
//                     subtitle: 'Attach a Google Maps link with live GPS',
//                     trailing: _SettingsSwitch(
//                       value: sendMapLink,
//                       onChanged: (value) {
//                         setState(() {
//                           sendMapLink = value;
//                         });
//                       },
//                     ),
//                   ),

//                   _settingRow(
//                     context,
//                     title: 'Auto audio recording',
//                     subtitle: 'Record and upload audio during an alert',
//                     trailing: _SettingsSwitch(
//                       value: autoAudioRecording,
//                       onChanged: (value) {
//                         setState(() {
//                           autoAudioRecording = value;
//                         });
//                       },
//                     ),
//                   ),

//                   _settingRow(
//                     context,
//                     title: 'Require 3-second hold',
//                     subtitle: 'Prevents accidental SOS triggers',
//                     trailing: _SettingsSwitch(
//                       value: requireHold,
//                       onChanged: (value) {
//                         setState(() {
//                           requireHold = value;
//                         });
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // ==========================================================
//             // ALTERNATIVE TRIGGERS
//             // ==========================================================
//             _sectionLabel('ALTERNATIVE TRIGGERS'),

//             _card(
//               context,
//               child: Column(
//                 children: [
//                   _settingRow(
//                     context,
//                     title: 'Shake to activate',
//                     subtitle: 'Shake the phone hard three times',
//                     trailing: _SettingsSwitch(
//                       value: shakeArmed,
//                       onChanged: (value) {
//                         setState(() {
//                           shakeArmed = value;
//                         });
//                       },
//                     ),
//                   ),

//                   _settingRow(
//                     context,
//                     title: 'Silent tap',
//                     subtitle:
//                         'Quick-tap the SOS button 3 times without holding',
//                     trailing: _SettingsSwitch(
//                       value: silentTapArmed,
//                       onChanged: (value) {
//                         setState(() {
//                           silentTapArmed = value;
//                         });
//                       },
//                     ),
//                   ),

//                   _settingRow(
//                     context,
//                     title: 'Voice activation',
//                     subtitle: 'Say "help me" out loud',
//                     trailing: _SettingsSwitch(
//                       value: voiceArmed,
//                       onChanged: (value) {
//                         setState(() {
//                           voiceArmed = value;
//                         });
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // ==========================================================
//             // ACCOUNT
//             // ==========================================================
//             _sectionLabel('ACCOUNT'),

//             _card(
//               context,
//               child: Column(
//                 children: [
//                   _actionRow(
//                     context,
//                     title: 'Profile',
//                     subtitle: 'Name, phone, email and password',
//                     actionText: 'Open',
//                     onTap: widget.onProfile,
//                   ),

//                   _actionRow(
//                     context,
//                     title: 'Trusted contacts',
//                     subtitle: 'Add, edit or remove',
//                     actionText: 'Manage',
//                     onTap: widget.onContacts,
//                   ),

//                   _actionRow(
//                     context,
//                     title: 'Alert history',
//                     subtitle: 'Past emergencies and check-ins',
//                     actionText: 'View',
//                     onTap: widget.onHistory,
//                   ),
//                 ],
//               ),
//             ),

//             // ==========================================================
//             // PLAN & BILLING
//             // ==========================================================
//             _sectionLabel('PLAN & BILLING'),

//             _card(
//               context,
//               child: Column(
//                 children: [
//                   _settingRow(
//                     context,
//                     title: 'Your plan',
//                     subtitle: 'Free · emergency SOS is the same on every plan',
//                     trailing: _PlanBadge(text: 'Free'),
//                   ),

//                   _actionRow(
//                     context,
//                     title: 'Compare plans',
//                     subtitle: 'Free, Premium, Family, Enterprise',
//                     actionText: 'View',
//                     onTap: widget.onPlans,
//                   ),

//                   _actionRow(
//                     context,
//                     title: 'Billing & receipts',
//                     subtitle: 'Renewals, cancellation, payment history',
//                     actionText: 'Open',
//                     onTap: widget.onBilling,
//                   ),

//                   if (widget.hasHouseholdAccess)
//                     _actionRow(
//                       context,
//                       title: 'Household',
//                       subtitle: 'Members, seats and live-alert sharing',
//                       actionText: 'Open',
//                       onTap: widget.onHousehold,
//                     ),

//                   if (widget.hasOrganizationAccess)
//                     _actionRow(
//                       context,
//                       title: 'Organization',
//                       subtitle: 'Members, seats and org audit log',
//                       actionText: 'Open',
//                       onTap: widget.onOrganization,
//                     ),
//                 ],
//               ),
//             ),

//             // ==========================================================
//             // SAVE
//             // ==========================================================
//             Padding(
//               padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
//               child: SizedBox(
//                 height: 50,
//                 child: ElevatedButton(
//                   onPressed: _saveSettings,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.primary,
//                     foregroundColor: Colors.white,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   child: const Text(
//                     'Save Settings',
//                     style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _sectionLabel(String text) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
//       child: Text(
//         text,
//         style: const TextStyle(
//           fontSize: 11,
//           fontWeight: FontWeight.w700,
//           letterSpacing: 0.8,
//         ),
//       ),
//     );
//   }

//   Widget _card(BuildContext context, {required Widget child}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20),
//       child: Container(
//         padding: const EdgeInsets.all(14),
//         decoration: BoxDecoration(
//           color: Theme.of(context).cardColor,
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(color: Theme.of(context).dividerColor),
//         ),
//         child: child,
//       ),
//     );
//   }

//   Widget _textField(
//     BuildContext context, {
//     required String label,
//     required String hint,
//     required TextEditingController controller,
//   }) {
//     return TextField(
//       controller: controller,
//       minLines: 1,
//       maxLines: 3,
//       decoration: InputDecoration(
//         labelText: label,
//         hintText: hint,
//         alignLabelWithHint: true,
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//       ),
//     );
//   }

//   Widget _settingRow(
//     BuildContext context, {
//     required String title,
//     required String subtitle,
//     required Widget trailing,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     fontSize: 13,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 const SizedBox(height: 3),
//                 Text(
//                   subtitle,
//                   style: TextStyle(
//                     fontSize: 11.5,
//                     height: 1.35,
//                     color: Theme.of(context).textTheme.bodySmall?.color,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(width: 12),
//           trailing,
//         ],
//       ),
//     );
//   }

//   Widget _actionRow(
//     BuildContext context, {
//     required String title,
//     required String subtitle,
//     required String actionText,
//     required VoidCallback onTap,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     fontSize: 13,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 const SizedBox(height: 3),
//                 Text(
//                   subtitle,
//                   style: TextStyle(
//                     fontSize: 11.5,
//                     height: 1.35,
//                     color: Theme.of(context).textTheme.bodySmall?.color,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           TextButton(
//             onPressed: onTap,
//             child: Text(
//               actionText,
//               style: TextStyle(
//                 color: AppColors.primary,
//                 fontWeight: FontWeight.w600,
//                 fontSize: 12,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _SettingsSwitch extends StatelessWidget {
//   const _SettingsSwitch({required this.value, required this.onChanged});

//   final bool value;
//   final ValueChanged<bool> onChanged;

//   @override
//   Widget build(BuildContext context) {
//     return Switch(
//       value: value,
//       onChanged: onChanged,
//       activeThumbColor: AppColors.primary,
//     );
//   }
// }

// class _PlanBadge extends StatelessWidget {
//   const _PlanBadge({required this.text});

//   final String text;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
//       decoration: BoxDecoration(
//         color: Colors.grey.withValues(alpha: 0.12),
//         borderRadius: BorderRadius.circular(5),
//       ),
//       child: Text(
//         text,
//         style: TextStyle(
//           fontSize: 10,
//           fontWeight: FontWeight.w600,
//           color: Theme.of(context).textTheme.bodySmall?.color,
//         ),
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';

// import '../../../core/theme/app_colors.dart';

// class SettingsScreen extends StatefulWidget {
//   const SettingsScreen({
//     super.key,
//     required this.onBack,
//     required this.onProfile,
//     required this.onContacts,
//     required this.onHistory,
//     required this.onPlans,
//     required this.onBilling,
//     required this.onHousehold,
//     required this.onOrganization,
//     this.hasHouseholdAccess = false,
//     this.hasOrganizationAccess = false,
//   });

//   final VoidCallback onBack;
//   final VoidCallback onProfile;
//   final VoidCallback onContacts;
//   final VoidCallback onHistory;
//   final VoidCallback onPlans;
//   final VoidCallback onBilling;
//   final VoidCallback onHousehold;
//   final VoidCallback onOrganization;

//   final bool hasHouseholdAccess;
//   final bool hasOrganizationAccess;

//   @override
//   State<SettingsScreen> createState() => _SettingsScreenState();
// }

// class _SettingsScreenState extends State<SettingsScreen> {
//   final TextEditingController _messageController =
//       TextEditingController();

//   bool sendMapLink = true;
//   bool autoAudioRecording = true;
//   bool requireHold = true;

//   bool shakeArmed = true;
//   bool silentTapArmed = true;
//   bool voiceArmed = true;

//   @override
//   void dispose() {
//     _messageController.dispose();
//     super.dispose();
//   }

//   void _saveSettings() {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Settings saved successfully.'),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor:
//           Theme.of(context).scaffoldBackgroundColor,
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor:
//             Theme.of(context).scaffoldBackgroundColor,
//         leading: IconButton(
//           onPressed: widget.onBack,
//           icon: const Icon(Icons.arrow_back),
//         ),
//         title: const Text(
//           'Settings',
//           style: TextStyle(
//             fontWeight: FontWeight.w700,
//           ),
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.only(
//           top: 8,
//           bottom: 32,
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             // ==========================================================
//             // EMERGENCY MESSAGE
//             // ==========================================================
//             _sectionLabel('EMERGENCY MESSAGE'),

//             _card(
//               context,
//               child: Column(
//                 children: [
//                   _textField(
//                     context,
//                     label: 'Custom SMS text sent to contacts',
//                     controller: _messageController,
//                     hint:
//                         'I need help. This is my live location.',
//                   ),

//                   const SizedBox(height: 8),

//                   _settingRow(
//                     context,
//                     title: 'Include map link',
//                     subtitle:
//                         'Attach a Google Maps link with live GPS',
//                     trailing: _SettingsSwitch(
//                       value: sendMapLink,
//                       onChanged: (value) {
//                         setState(() {
//                           sendMapLink = value;
//                         });
//                       },
//                     ),
//                   ),

//                   _settingRow(
//                     context,
//                     title: 'Auto audio recording',
//                     subtitle:
//                         'Record and upload audio during an alert',
//                     trailing: _SettingsSwitch(
//                       value: autoAudioRecording,
//                       onChanged: (value) {
//                         setState(() {
//                           autoAudioRecording = value;
//                         });
//                       },
//                     ),
//                   ),

//                   _settingRow(
//                     context,
//                     title: 'Require 3-second hold',
//                     subtitle:
//                         'Prevents accidental SOS triggers',
//                     trailing: _SettingsSwitch(
//                       value: requireHold,
//                       onChanged: (value) {
//                         setState(() {
//                           requireHold = value;
//                         });
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // ==========================================================
//             // ALTERNATIVE TRIGGERS
//             // ==========================================================
//             _sectionLabel('ALTERNATIVE TRIGGERS'),

//             _card(
//               context,
//               child: Column(
//                 children: [
//                   _settingRow(
//                     context,
//                     title: 'Shake to activate',
//                     subtitle:
//                         'Shake the phone hard three times',
//                     trailing: _SettingsSwitch(
//                       value: shakeArmed,
//                       onChanged: (value) {
//                         setState(() {
//                           shakeArmed = value;
//                         });
//                       },
//                     ),
//                   ),

//                   _settingRow(
//                     context,
//                     title: 'Silent tap',
//                     subtitle:
//                         'Quick-tap the SOS button 3 times without holding',
//                     trailing: _SettingsSwitch(
//                       value: silentTapArmed,
//                       onChanged: (value) {
//                         setState(() {
//                           silentTapArmed = value;
//                         });
//                       },
//                     ),
//                   ),

//                   _settingRow(
//                     context,
//                     title: 'Voice activation',
//                     subtitle:
//                         'Say "help me" out loud',
//                     trailing: _SettingsSwitch(
//                       value: voiceArmed,
//                       onChanged: (value) {
//                         setState(() {
//                           voiceArmed = value;
//                         });
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // ==========================================================
//             // ACCOUNT
//             // ==========================================================
//             _sectionLabel('ACCOUNT'),

//             _card(
//               context,
//               child: Column(
//                 children: [
//                   _actionRow(
//                     context,
//                     title: 'Profile',
//                     subtitle:
//                         'Name, phone, email and password',
//                     actionText: 'Open',
//                     onTap: widget.onProfile,
//                   ),

//                   _actionRow(
//                     context,
//                     title: 'Trusted contacts',
//                     subtitle:
//                         'Add, edit or remove',
//                     actionText: 'Manage',
//                     onTap: widget.onContacts,
//                   ),

//                   _actionRow(
//                     context,
//                     title: 'Alert history',
//                     subtitle:
//                         'Past emergencies and check-ins',
//                     actionText: 'View',
//                     onTap: widget.onHistory,
//                   ),
//                 ],
//               ),
//             ),

//             // ==========================================================
//             // PLAN & BILLING
//             // ==========================================================
//             _sectionLabel('PLAN & BILLING'),

//             _card(
//               context,
//               child: Column(
//                 children: [
//                   _settingRow(
//                     context,
//                     title: 'Your plan',
//                     subtitle:
//                         'Free · emergency SOS is the same on every plan',
//                     trailing: _PlanBadge(
//                       text: 'Free',
//                     ),
//                   ),

//                   _actionRow(
//                     context,
//                     title: 'Compare plans',
//                     subtitle:
//                         'Free, Premium, Family, Enterprise',
//                     actionText: 'View',
//                     onTap: widget.onPlans,
//                   ),

//                   _actionRow(
//                     context,
//                     title: 'Billing & receipts',
//                     subtitle:
//                         'Renewals, cancellation, payment history',
//                     actionText: 'Open',
//                     onTap: widget.onBilling,
//                   ),

//                   if (widget.hasHouseholdAccess)
//                     _actionRow(
//                       context,
//                       title: 'Household',
//                       subtitle:
//                           'Members, seats and live-alert sharing',
//                       actionText: 'Open',
//                       onTap: widget.onHousehold,
//                     ),

//                   if (widget.hasOrganizationAccess)
//                     _actionRow(
//                       context,
//                       title: 'Organization',
//                       subtitle:
//                           'Members, seats and org audit log',
//                       actionText: 'Open',
//                       onTap: widget.onOrganization,
//                     ),
//                 ],
//               ),
//             ),

//             // ==========================================================
//             // SAVE
//             // ==========================================================
//             Padding(
//               padding: const EdgeInsets.fromLTRB(
//                 20,
//                 12,
//                 20,
//                 0,
//               ),
//               child: SizedBox(
//                 height: 50,
//                 child: ElevatedButton(
//                   onPressed: _saveSettings,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.primary,
//                     foregroundColor: Colors.white,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   child: const Text(
//                     'Save Settings',
//                     style: TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _sectionLabel(String text) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(
//         20,
//         18,
//         20,
//         8,
//       ),
//       child: Text(
//         text,
//         style: const TextStyle(
//           fontSize: 11,
//           fontWeight: FontWeight.w700,
//           letterSpacing: 0.8,
//         ),
//       ),
//     );
//   }

//   Widget _card(
//     BuildContext context, {
//     required Widget child,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(
//         horizontal: 20,
//       ),
//       child: Container(
//         padding: const EdgeInsets.all(14),
//         decoration: BoxDecoration(
//           color: Theme.of(context).cardColor,
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(
//             color: Theme.of(context).dividerColor,
//           ),
//         ),
//         child: child,
//       ),
//     );
//   }

//   Widget _textField(
//     BuildContext context, {
//     required String label,
//     required String hint,
//     required TextEditingController controller,
//   }) {
//     return TextField(
//       controller: controller,
//       minLines: 1,
//       maxLines: 3,
//       decoration: InputDecoration(
//         labelText: label,
//         hintText: hint,
//         alignLabelWithHint: true,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//         ),
//       ),
//     );
//   }

//   Widget _settingRow(
//     BuildContext context, {
//     required String title,
//     required String subtitle,
//     required Widget trailing,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(
//         vertical: 8,
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment:
//                   CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     fontSize: 13,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 const SizedBox(height: 3),
//                 Text(
//                   subtitle,
//                   style: TextStyle(
//                     fontSize: 11.5,
//                     height: 1.35,
//                     color: Theme.of(context)
//                         .textTheme
//                         .bodySmall
//                         ?.color,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(width: 12),
//           trailing,
//         ],
//       ),
//     );
//   }

//   Widget _actionRow(
//     BuildContext context, {
//     required String title,
//     required String subtitle,
//     required String actionText,
//     required VoidCallback onTap,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(
//         vertical: 8,
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment:
//                   CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     fontSize: 13,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 const SizedBox(height: 3),
//                 Text(
//                   subtitle,
//                   style: TextStyle(
//                     fontSize: 11.5,
//                     height: 1.35,
//                     color: Theme.of(context)
//                         .textTheme
//                         .bodySmall
//                         ?.color,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           TextButton(
//             onPressed: onTap,
//             child: Text(
//               actionText,
//               style: TextStyle(
//                 color: AppColors.primary,
//                 fontWeight: FontWeight.w600,
//                 fontSize: 12,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _SettingsSwitch extends StatelessWidget {
//   const _SettingsSwitch({
//     required this.value,
//     required this.onChanged,
//   });

//   final bool value;
//   final ValueChanged<bool> onChanged;

//   @override
//   Widget build(BuildContext context) {
//     return Switch(
//       value: value,
//       onChanged: onChanged,
//       activeThumbColor: AppColors.primary,
//     );
//   }
// }

// class _PlanBadge extends StatelessWidget {
//   const _PlanBadge({
//     required this.text,
//   });

//   final String text;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(
//         horizontal: 8,
//         vertical: 5,
//       ),
//       decoration: BoxDecoration(
//         color: Colors.grey.withValues(alpha: 0.12),
//         borderRadius: BorderRadius.circular(5),
//       ),
//       child: Text(
//         text,
//         style: TextStyle(
//           fontSize: 10,
//           fontWeight: FontWeight.w600,
//           color: Theme.of(context)
//               .textTheme
//               .bodySmall
//               ?.color,
//         ),
//       ),
//     );
//   }
// }
