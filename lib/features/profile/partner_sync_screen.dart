import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/theme/app_theme.dart';
import '../../core/services/partner_sync_service.dart';
import '../../shared/widgets/premium_glass_card.dart';

class PartnerSyncScreen extends StatefulWidget {
  const PartnerSyncScreen({super.key});

  @override
  State<PartnerSyncScreen> createState() => _PartnerSyncScreenState();
}

class _PartnerSyncScreenState extends State<PartnerSyncScreen> {
  bool _isLoading = false;

  Future<void> _generateCode() async {
    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);

    await PartnerSyncService.generateInviteCode();

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _unlink() async {
    HapticFeedback.heavyImpact();

    final confirm = await showCupertinoDialog<bool>(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: const Text("Unlink Partner?"),
          content: const Text("Your partner will immediately lose access to your cycle updates."),
          actions: [
            CupertinoDialogAction(child: const Text("Cancel"), onPressed: () => Navigator.pop(ctx, false)),
            CupertinoDialogAction(isDestructiveAction: true, child: const Text("Unlink"), onPressed: () => Navigator.pop(ctx, true)),
          ],
        )
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      await PartnerSyncService.unlinkPartner();
      if (mounted) setState(() => _isLoading = false);
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
        title: Text("Partner Sync", style: GoogleFonts.outfit(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 20)),
        centerTitle: true,
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box('settings').listenable(keys: ['couple_id']),
        builder: (context, Box box, _) {
          final String? coupleId = box.get('couple_id');

          if (coupleId == null) {
            return _buildUnlinkedState();
          }

          return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: PartnerSyncService.partnerDataStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CupertinoActivityIndicator());
              }

              if (!snapshot.hasData || !snapshot.data!.exists) {
                // Если документ удален из облака (например, парнем)
                WidgetsBinding.instance.addPostFrameCallback((_) => PartnerSyncService.unlinkPartner());
                return _buildUnlinkedState();
              }

              final data = snapshot.data!.data()!;
              final bool isLinked = data['partner_uid'] != null;
              final String? inviteCode = data['invite_code'];
              final Map<String, dynamic> perms = data['permissions'] ?? {};

              return _buildLinkedState(isLinked, inviteCode, perms['share_mood'] ?? false, perms['share_ttc'] ?? false);
            },
          );
        },
      ),
    );
  }

  Widget _buildUnlinkedState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120, height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF8E71C7).withOpacity(0.1),
            ),
            child: const Center(child: Text("💑", style: TextStyle(fontSize: 60))),
          ),
          const SizedBox(height: 32),
          Text(
            "Invite Your Partner",
            style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          Text(
            "Share your cycle phase and mood so your partner knows when you need extra support, chocolate, or space.",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 15, color: AppColors.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: CupertinoButton(
              padding: const EdgeInsets.symmetric(vertical: 16),
              color: const Color(0xFF8E71C7),
              borderRadius: BorderRadius.circular(16),
              onPressed: _isLoading ? null : _generateCode,
              child: _isLoading
                  ? const CupertinoActivityIndicator(color: Colors.white)
                  : Text("Generate Invite Code", style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(CupertinoIcons.lock_shield_fill, size: 14, color: Colors.green),
              const SizedBox(width: 6),
              Text("You control what they see.", style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildLinkedState(bool isLinked, String? inviteCode, bool shareMood, bool shareTtc) {
    return ListView(
      padding: const EdgeInsets.all(24),
      physics: const BouncingScrollPhysics(),
      children: [
        // СТАТУС КАРТОЧКА
        PremiumGlassCard(
          borderRadius: 24,
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isLinked ? Colors.green.withOpacity(0.1) : AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                    isLinked ? CupertinoIcons.checkmark_seal_fill : CupertinoIcons.hourglass,
                    color: isLinked ? Colors.green : AppColors.primary,
                    size: 32
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isLinked ? "Partner Connected" : "Waiting for Partner...",
                style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                isLinked
                    ? "Your Ayla app is securely syncing data."
                    : "Ask your partner to download Ayla and enter this code during setup:",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
              ),

              if (!isLinked && inviteCode != null) ...[
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: inviteCode));
                    HapticFeedback.lightImpact();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Code copied to clipboard!")));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                    decoration: BoxDecoration(
                      color: AppColors.textPrimary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 2),
                    ),
                    child: Text(
                      inviteCode,
                      style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: 4.0, color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text("Tap to copy • Expires in 24h", style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
              ]
            ],
          ),
        ),

        const SizedBox(height: 32),
        Text("PRIVACY SETTINGS", style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 1.0)),
        const SizedBox(height: 12),

        // НАСТРОЙКИ ПРИВАТНОСТИ
        PremiumGlassCard(
          borderRadius: 24,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              _buildToggleRow(
                icon: CupertinoIcons.moon_stars_fill,
                color: const Color(0xFF8E71C7),
                title: "Share Mood & Energy",
                subtitle: "Partner will see if you are tired, anxious, or happy.",
                value: shareMood,
                onChanged: (val) {
                  HapticFeedback.lightImpact();
                  PartnerSyncService.updatePermissions(val, shareTtc);
                },
              ),
              Divider(height: 1, indent: 56, color: AppColors.textPrimary.withOpacity(0.05)),
              _buildToggleRow(
                icon: CupertinoIcons.heart_circle_fill,
                color: const Color(0xFFE85D75),
                title: "Share Fertility Window",
                subtitle: "Partner will be notified when your conception chance is high.",
                value: shareTtc,
                onChanged: (val) {
                  HapticFeedback.lightImpact();
                  PartnerSyncService.updatePermissions(shareMood, val);
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          child: CupertinoButton(
            color: Colors.redAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            onPressed: _unlink,
            child: Text("Unlink Partner", style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.redAccent)),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleRow({required IconData icon, required Color color, required String title, required String subtitle, required bool value, required Function(bool) onChanged}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary, height: 1.3)),
              ],
            ),
          ),
          CupertinoSwitch(
            value: value,
            activeColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}