import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';
import '../../core/services/partner_sync_service.dart';
import 'partner_dashboard_screen.dart';

class PartnerLinkScreen extends StatefulWidget {
  const PartnerLinkScreen({super.key});

  @override
  State<PartnerLinkScreen> createState() => _PartnerLinkScreenState();
}

class _PartnerLinkScreenState extends State<PartnerLinkScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;

  Future<void> _link() async {
    final code = _codeController.text.trim();
    if (code.length < 6) return;

    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);

    final success = await PartnerSyncService.linkPartner(code);

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const PartnerDashboardScreen())
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Invalid or expired code. Please check and try again."))
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(color: const Color(0xFF8E71C7).withOpacity(0.1), shape: BoxShape.circle),
                child: const Center(child: Text("🤝", style: TextStyle(fontSize: 32))),
              ),
              const SizedBox(height: 24),
              Text("Enter Invite Code", style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.textPrimary, height: 1.1)),
              const SizedBox(height: 12),
              Text("Ask your partner to generate a 6-digit code in their Ayla app settings.", style: GoogleFonts.inter(fontSize: 15, color: AppColors.textSecondary, height: 1.5)),
              const SizedBox(height: 40),

              // Поле ввода кода
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.tintedSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.textSecondary.withOpacity(0.1)),
                ),
                child: TextField(
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                  maxLength: 7, // Для формата 123-456
                  style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: 4.0, color: AppColors.primary),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    counterText: "",
                    border: InputBorder.none,
                    hintText: "000-000",
                    hintStyle: GoogleFonts.outfit(color: AppColors.textSecondary.withOpacity(0.3)),
                  ),
                  onChanged: (val) {
                    // Автоматическое добавление тире
                    if (val.length == 3 && !_codeController.text.contains('-')) {
                      _codeController.text = '$val-';
                      _codeController.selection = TextSelection.fromPosition(TextPosition(offset: _codeController.text.length));
                    }
                  },
                ),
              ),

              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: CupertinoButton(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  color: const Color(0xFF8E71C7),
                  borderRadius: BorderRadius.circular(16),
                  onPressed: _isLoading ? null : _link,
                  child: _isLoading
                      ? const CupertinoActivityIndicator(color: Colors.white)
                      : Text("Connect to Partner", style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}