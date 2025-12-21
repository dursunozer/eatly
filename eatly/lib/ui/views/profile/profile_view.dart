import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:stacked/stacked.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/config/policy_config.dart';
import 'profile_viewmodel.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ProfileViewModel>.reactive(
      viewModelBuilder: () => ProfileViewModel(),
      onViewModelReady: (vm) => vm.init(),
      builder: (context, model, child) {
        if (model.isBusy && model.name == null) {
        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        
        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          body: CustomScrollView(
            slivers: [
              // Profil Başlığı
              _ProfileHeader(model: model),
              
              // İçerik
              SliverToBoxAdapter(
                child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                      // Hedefler Kartı
                      _GoalsCard(model: model),
                const SizedBox(height: 16),
                      
                      // Kişisel Bilgiler
                      _SettingsSection(
                        title: 'Kişisel Bilgiler',
                        children: [
                          _SettingsTile(
                            icon: Icons.person_outline,
                            iconColor: Colors.blue,
                            title: 'Cinsiyet',
                            value: model.gender ?? '-',
                            onTap: () => _showEditDialog(context, model, 'gender'),
                          ),
                          _SettingsTile(
                            icon: Icons.cake_outlined,
                            iconColor: Colors.orange,
                            title: 'Yaş',
                            value: model.age?.toString() ?? '-',
                            onTap: () => _showEditDialog(context, model, 'age'),
                          ),
                          _SettingsTile(
                            icon: Icons.monitor_weight_outlined,
                            iconColor: Colors.green,
                            title: 'Kilo',
                            value: model.weight != null ? '${model.weight!.toStringAsFixed(1)} kg' : '-',
                            onTap: () => _showEditDialog(context, model, 'weight'),
                          ),
                          _SettingsTile(
                            icon: Icons.height,
                            iconColor: Colors.purple,
                            title: 'Boy',
                            value: model.height != null ? '${model.height!.toStringAsFixed(0)} cm' : '-',
                            onTap: () => _showEditDialog(context, model, 'height'),
                          ),
                          _SettingsTile(
                            icon: Icons.directions_run,
                            iconColor: Colors.teal,
                            title: 'Aktivite Seviyesi',
                            value: model.activityLevelTitle,
                            onTap: () => _showEditDialog(context, model, 'activity'),
                            showDivider: false,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Vücut Ölçüleri
                      _SettingsSection(
                        title: 'Vücut Ölçüleri',
                        children: [
                          _SettingsTile(
                            icon: Icons.speed,
                            iconColor: Colors.indigo,
                            title: 'Vücut Kitle İndeksi',
                            value: model.bmi != null 
                                ? '${model.bmi!.toStringAsFixed(1)} (${model.bmiCategory})'
                                : '-',
                            showArrow: false,
                          ),
                          _SettingsTile(
                            icon: Icons.straighten,
                            iconColor: Colors.amber,
                            title: 'Bel Çevresi',
                            value: model.waistCm != null ? '${model.waistCm!.toStringAsFixed(0)} cm' : '-',
                            onTap: () => _showEditDialog(context, model, 'waist'),
                          ),
                          _SettingsTile(
                            icon: Icons.accessibility_new,
                            iconColor: Colors.pink,
                            title: 'Kalça Çevresi',
                            value: model.hipCm != null ? '${model.hipCm!.toStringAsFixed(0)} cm' : '-',
                            onTap: () => _showEditDialog(context, model, 'hip'),
                            showDivider: false,
                          ),
              ],
            ),
                      const SizedBox(height: 16),
                      
                      // Hesap
                      _SettingsSection(
                        title: 'Hesap',
                        children: [
                          _SettingsTile(
                            icon: Icons.email_outlined,
                            iconColor: Colors.blue,
                            title: 'E-posta',
                            value: model.email ?? '-',
                            showArrow: false,
                          ),
                          _SettingsTile(
                            icon: Icons.lock_outline,
                            iconColor: Colors.orange,
                            title: 'Şifre Değiştir',
                            onTap: () => _showPasswordResetDialog(context, model),
                          ),
                          _SettingsTile(
                            icon: Icons.delete_outline,
                            iconColor: Colors.red,
                            title: 'Hesabı Sil',
                            titleColor: Colors.red,
                            onTap: () => _showDeleteAccountDialog(context, model),
                            showDivider: false,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Diğer
                      _SettingsSection(
                        title: 'Diğer',
                        children: [
                          _SettingsTile(
                            icon: Icons.help_outline,
                            iconColor: Colors.blue,
                            title: 'Yardım ve Destek',
                            onTap: () => _showHelpDialog(context),
                          ),
                          _SettingsTile(
                            icon: Icons.privacy_tip_outlined,
                            iconColor: Colors.green,
                            title: 'Gizlilik Politikası',
                            onTap: () => launchUrlString(PolicyConfig.policyUrl),
                          ),
                          _SettingsTile(
                            icon: Icons.info_outline,
                            iconColor: Colors.purple,
                            title: 'Hakkında',
                            onTap: () => _showAboutDialog(context),
                            showDivider: false,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Çıkış Yap Butonu
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: model.isBusy ? null : () => _showSignOutDialog(context, model),
                          icon: const Icon(Icons.logout, color: Colors.red),
                          label: const Text('Çıkış Yap', style: TextStyle(color: Colors.red)),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Versiyon
                      Text(
                        'Eatly v1.0.0',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 100), // Navbar için extra boşluk
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, ProfileViewModel model, String field) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EditBottomSheet(model: model, field: field),
    );
  }

  void _showPasswordResetDialog(BuildContext context, ProfileViewModel model) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Şifre Değiştir'),
        content: Text(
          'Şifre sıfırlama bağlantısı ${model.email} adresine gönderilecek.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await model.sendPasswordResetEmail();
              if (context.mounted) {
                Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Şifre sıfırlama e-postası gönderildi! Lütfen spam klasörünüzü de kontrol edin.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('E-posta gönderilemedi: ${model.passwordResetError ?? "Bilinmeyen hata"}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Gönder'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, ProfileViewModel model) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            const SizedBox(width: 8),
            const Text('Hesabı Sil'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bu işlem geri alınamaz!',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
            ),
            SizedBox(height: 12),
            Text('Aşağıdaki verileriniz kalıcı olarak silinecektir:'),
            SizedBox(height: 8),
            Text('• Profil bilgileriniz'),
            Text('• Yemek fotoğraflarınız'),
            Text('• Spor aktiviteleriniz'),
            Text('• Tüm beslenme geçmişiniz'),
            SizedBox(height: 12),
            Text('Devam etmek istiyor musunuz?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              
              // Loading göster
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Hesabınız siliniyor...'),
                        ],
                      ),
                    ),
                  ),
                ),
              );
              
              final success = await model.deleteAccount();
              
              if (context.mounted) {
                Navigator.pop(context); // Loading'i kapat
                
                if (!success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Hesap silinemedi: ${model.deleteAccountError ?? "Bilinmeyen hata"}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Hesabı Sil'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yardım ve Destek'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sorularınız için:'),
            SizedBox(height: 8),
            SelectableText('destek@eatly.app'),
            SizedBox(height: 16),
            Text('Uygulama hakkında geri bildirimlerinizi bekliyoruz!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('🥗', style: TextStyle(fontSize: 24)),
            ),
            const SizedBox(width: 12),
            const Text('Eatly'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Versiyon: 1.0.0'),
            SizedBox(height: 8),
            Text('Sağlıklı beslenme yolculuğunuzda yanınızdayız.'),
            SizedBox(height: 16),
            Text(
              'Yemeklerinizin fotoğrafını çekin, besin değerlerini otomatik olarak hesaplayalım ve hedeflerinize ulaşmanıza yardımcı olalım.',
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, ProfileViewModel model) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text('Hesabınızdan çıkış yapmak istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              model.signOut();
            },
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );
  }
}

// Profil Başlığı
class _ProfileHeader extends StatelessWidget {
  final ProfileViewModel model;
  
  const _ProfileHeader({required this.model});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: AppTheme.primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryColor,
                AppTheme.primaryColor.withOpacity(0.8),
                AppTheme.secondaryColor,
        ],
      ),
          ),
          child: SafeArea(
      child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
        children: [
                const SizedBox(height: 40),
                // Avatar
          Stack(
            alignment: Alignment.bottomRight,
            children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: CircleAvatar(
                radius: 50,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        backgroundImage: model.avatarUrl != null 
                            ? NetworkImage(model.avatarUrl!) 
                            : null,
                child: model.avatarUrl == null
                    ? Text(
                        model.initials,
                                style: const TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                      )
                    : null,
              ),
                    ),
                    _AvatarEditButton(model: model),
                  ],
                ),
                const SizedBox(height: 16),
                // İsim
                Text(
                  model.name ?? 'Kullanıcı',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                // E-posta
                if (model.email != null)
                  Text(
                    model.email!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                const SizedBox(height: 8),
                // Hedef Badge
                if (model.goal != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.flag, color: Colors.white, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          model.goalTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      title: const Text('Profilim'),
    );
  }
}

class _AvatarEditButton extends StatelessWidget {
  final ProfileViewModel model;
  
  const _AvatarEditButton({required this.model});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
                shape: const CircleBorder(),
      elevation: 4,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () async {
                    try {
                      final picker = ImagePicker();
                      final XFile? file = await picker.pickImage(
                        source: ImageSource.gallery,
                        imageQuality: kIsWeb ? null : 85,
                        maxWidth: kIsWeb ? null : 1024,
                      );
                      if (file != null) {
                        final bytes = await file.readAsBytes();
                        await model.uploadAvatar(bytes);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Profil fotoğrafı güncellendi')),
                        );
                      }
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Avatar yüklenemedi: $e')),
                      );
                    }
                  },
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(Icons.camera_alt, color: AppTheme.primaryColor, size: 20),
        ),
      ),
    );
  }
}

// Hedefler Kartı
class _GoalsCard extends StatelessWidget {
  final ProfileViewModel model;
  
  const _GoalsCard({required this.model});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Günlük Hedeflerim',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => _GoalEditBottomSheet(model: model),
                  );
                },
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Düzenle'),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Kalori
          _GoalItem(
            icon: Icons.local_fire_department,
            color: Colors.orange,
            title: 'Kalori',
            value: model.targetCalories?.toInt().toString() ?? '-',
            unit: 'kcal',
          ),
          const SizedBox(height: 12),
          // Makrolar
          Row(
            children: [
              Expanded(
                child: _GoalItem(
                  icon: Icons.egg_alt,
                  color: Colors.red,
                  title: 'Protein',
                  value: model.targetProtein?.toInt().toString() ?? '-',
                  unit: 'g',
                  compact: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _GoalItem(
                  icon: Icons.grain,
                  color: Colors.amber,
                  title: 'Karbonhidrat',
                  value: model.targetCarbs?.toInt().toString() ?? '-',
                  unit: 'g',
                  compact: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _GoalItem(
                  icon: Icons.water_drop,
                  color: Colors.purple,
                  title: 'Yağ',
                  value: model.targetFat?.toInt().toString() ?? '-',
                  unit: 'g',
                  compact: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GoalItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String value;
  final String unit;
  final bool compact;

  const _GoalItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
    required this.unit,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 12 : 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: compact ? 20 : 24),
          SizedBox(width: compact ? 8 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: compact ? 11 : 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: compact ? 18 : 24,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        unit,
                        style: TextStyle(
                          fontSize: compact ? 10 : 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Ayarlar Bölümü
class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

// Ayar Öğesi
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? value;
  final VoidCallback? onTap;
  final bool showArrow;
  final bool showDivider;
  final Color? titleColor;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.value,
    this.onTap,
    this.showArrow = true,
    this.showDivider = true,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: titleColor,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (value != null)
                Text(
                  value!,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
              if (showArrow && onTap != null) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  color: AppTheme.textSecondary,
                ),
              ],
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 56,
            endIndent: 16,
            color: Colors.grey.shade200,
          ),
      ],
    );
  }
}

// Düzenleme Bottom Sheet
class _EditBottomSheet extends StatefulWidget {
  final ProfileViewModel model;
  final String field;

  const _EditBottomSheet({required this.model, required this.field});

  @override
  State<_EditBottomSheet> createState() => _EditBottomSheetState();
}

class _EditBottomSheetState extends State<_EditBottomSheet> {
  late TextEditingController _controller;
  String? _selectedGender;
  String? _selectedActivity;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _selectedGender = widget.model.gender ?? 'Erkek';
    _selectedActivity = widget.model.activityLevel ?? 'moderately_active';
    
    switch (widget.field) {
      case 'age':
        _controller.text = widget.model.age?.toString() ?? '';
        break;
      case 'weight':
        _controller.text = widget.model.weight?.toString() ?? '';
        break;
      case 'height':
        _controller.text = widget.model.height?.toString() ?? '';
        break;
      case 'waist':
        _controller.text = widget.model.waistCm?.toString() ?? '';
        break;
      case 'hip':
        _controller.text = widget.model.hipCm?.toString() ?? '';
        break;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _title {
    switch (widget.field) {
      case 'gender':
        return 'Cinsiyet';
      case 'age':
        return 'Yaş';
      case 'weight':
        return 'Kilo (kg)';
      case 'height':
        return 'Boy (cm)';
      case 'activity':
        return 'Aktivite Seviyesi';
      case 'waist':
        return 'Bel Çevresi (cm)';
      case 'hip':
        return 'Kalça Çevresi (cm)';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
      child: Padding(
          padding: const EdgeInsets.all(20),
        child: Column(
            mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildInput(),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Kaydet'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput() {
    if (widget.field == 'gender') {
      return Column(
        children: [
          _GenderOption(
            title: 'Erkek',
            icon: Icons.male,
            isSelected: _selectedGender == 'Erkek',
            onTap: () => setState(() => _selectedGender = 'Erkek'),
          ),
            const SizedBox(height: 12),
          _GenderOption(
            title: 'Kadın',
            icon: Icons.female,
            isSelected: _selectedGender == 'Kadın',
            onTap: () => setState(() => _selectedGender = 'Kadın'),
          ),
        ],
      );
    }
    
    if (widget.field == 'activity') {
      return Column(
        children: [
          _ActivityOption(
            id: 'sedentary',
            title: 'Hareketsiz',
            subtitle: 'Masa başı iş, çok az egzersiz',
            isSelected: _selectedActivity == 'sedentary',
            onTap: () => setState(() => _selectedActivity = 'sedentary'),
          ),
          _ActivityOption(
            id: 'lightly_active',
            title: 'Hafif Aktif',
            subtitle: 'Haftada 1-3 gün hafif egzersiz',
            isSelected: _selectedActivity == 'lightly_active',
            onTap: () => setState(() => _selectedActivity = 'lightly_active'),
          ),
          _ActivityOption(
            id: 'moderately_active',
            title: 'Orta Aktif',
            subtitle: 'Haftada 3-5 gün egzersiz',
            isSelected: _selectedActivity == 'moderately_active',
            onTap: () => setState(() => _selectedActivity = 'moderately_active'),
                ),
          _ActivityOption(
            id: 'active',
            title: 'Aktif',
            subtitle: 'Haftada 6-7 gün yoğun egzersiz',
            isSelected: _selectedActivity == 'active',
            onTap: () => setState(() => _selectedActivity = 'active'),
            ),
          _ActivityOption(
            id: 'very_active',
            title: 'Çok Aktif',
            subtitle: 'Günlük yoğun egzersiz',
            isSelected: _selectedActivity == 'very_active',
            onTap: () => setState(() => _selectedActivity = 'very_active'),
          ),
        ],
      );
    }

    return TextField(
      controller: _controller,
              keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
      ],
      autofocus: true,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        hintText: 'Değer girin',
      ),
    );
  }

  Future<void> _save() async {
    switch (widget.field) {
      case 'gender':
        await widget.model.updatePersonalInfo(newGender: _selectedGender);
        break;
      case 'age':
        final value = int.tryParse(_controller.text);
        if (value != null) {
          await widget.model.updatePersonalInfo(newAge: value);
        }
        break;
      case 'weight':
        final value = double.tryParse(_controller.text);
        if (value != null) {
          await widget.model.updatePersonalInfo(newWeight: value);
        }
        break;
      case 'height':
        final value = double.tryParse(_controller.text);
        if (value != null) {
          await widget.model.updatePersonalInfo(newHeight: value);
        }
        break;
      case 'activity':
        await widget.model.updatePersonalInfo(newActivityLevel: _selectedActivity);
        break;
      case 'waist':
        final waistValue = double.tryParse(_controller.text);
        if (waistValue != null) {
          await widget.model.updateBodyMeasurements(newWaistCm: waistValue);
        }
        break;
      case 'hip':
        final hipValue = double.tryParse(_controller.text);
        if (hipValue != null) {
          await widget.model.updateBodyMeasurements(newHipCm: hipValue);
        }
        break;
    }
    if (mounted) {
      Navigator.pop(context);
    }
  }
}

class _GenderOption extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderOption({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryColor : Colors.grey,
              size: 28,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimary,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(Icons.check_circle, color: AppTheme.primaryColor),
          ],
        ),
      ),
    );
  }
}

class _ActivityOption extends StatelessWidget {
  final String id;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _ActivityOption({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: AppTheme.primaryColor, size: 20),
          ],
        ),
      ),
    );
  }
}

// Hedef Düzenleme Bottom Sheet
class _GoalEditBottomSheet extends StatefulWidget {
  final ProfileViewModel model;

  const _GoalEditBottomSheet({required this.model});

  @override
  State<_GoalEditBottomSheet> createState() => _GoalEditBottomSheetState();
}

class _GoalEditBottomSheetState extends State<_GoalEditBottomSheet> {
  late String _selectedGoal;
  late String _selectedActivity;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedGoal = widget.model.goal ?? 'maintain';
    _selectedActivity = widget.model.activityLevel ?? 'moderately_active';
  }

  String _getGoalTitle(String goal) {
    switch (goal) {
      case 'lose_weight':
        return 'Kilo Vermek';
      case 'gain_weight':
        return 'Kilo Almak';
      case 'maintain':
        return 'Kilomu Korumak';
      case 'build_muscle':
        return 'Kas Kütlesi Kazanmak';
      default:
        return goal;
    }
  }

  String _getGoalDescription(String goal) {
    switch (goal) {
      case 'lose_weight':
        return 'Kalori açığı ile yağ yakımı';
      case 'gain_weight':
        return 'Kalori fazlası ile kilo artışı';
      case 'maintain':
        return 'Mevcut kiloyu koruma';
      case 'build_muscle':
        return 'Protein ağırlıklı kas gelişimi';
      default:
        return '';
    }
  }

  IconData _getGoalIcon(String goal) {
    switch (goal) {
      case 'lose_weight':
        return Icons.trending_down;
      case 'gain_weight':
        return Icons.trending_up;
      case 'maintain':
        return Icons.balance;
      case 'build_muscle':
        return Icons.fitness_center;
      default:
        return Icons.flag;
    }
  }

  String _getActivityTitle(String activity) {
    switch (activity) {
      case 'sedentary':
        return 'Hareketsiz';
      case 'lightly_active':
        return 'Hafif Aktif';
      case 'moderately_active':
        return 'Orta Aktif';
      case 'active':
        return 'Aktif';
      case 'very_active':
        return 'Çok Aktif';
      default:
        return activity;
    }
  }

  String _getActivityDescription(String activity) {
    switch (activity) {
      case 'sedentary':
        return 'Masa başı iş, çok az hareket';
      case 'lightly_active':
        return 'Haftada 1-3 gün hafif egzersiz';
      case 'moderately_active':
        return 'Haftada 3-5 gün egzersiz';
      case 'active':
        return 'Haftada 6-7 gün yoğun egzersiz';
      case 'very_active':
        return 'Günde 2 kez veya ağır fiziksel iş';
      default:
        return '';
    }
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      await widget.model.updateGoalAndActivity(
        newGoal: _selectedGoal,
        newActivityLevel: _selectedActivity,
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hedefleriniz güncellendi!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.flag, color: AppTheme.primaryColor),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hedeflerini Düzenle',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Kalori ve makro hedeflerin yeniden hesaplanacak',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: Colors.grey.shade200),
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hedef Seçimi
                    const Text(
                      'Hedefin Nedir?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...['lose_weight', 'maintain', 'gain_weight', 'build_muscle']
                        .map((goal) => _GoalOption(
                              id: goal,
                              title: _getGoalTitle(goal),
                              subtitle: _getGoalDescription(goal),
                              icon: _getGoalIcon(goal),
                              isSelected: _selectedGoal == goal,
                              onTap: () => setState(() => _selectedGoal = goal),
                            )),
                    const SizedBox(height: 24),
                    // Aktivite Seçimi
                    const Text(
                      'Aktivite Seviyeni Seç',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...['sedentary', 'lightly_active', 'moderately_active', 'active', 'very_active']
                        .map((activity) => _ActivityOptionCard(
                              id: activity,
                              title: _getActivityTitle(activity),
                              subtitle: _getActivityDescription(activity),
                              isSelected: _selectedActivity == activity,
                              onTap: () => setState(() => _selectedActivity = activity),
                            )),
                  ],
                ),
              ),
            ),
            // Save Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Hedefleri Güncelle',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalOption extends StatelessWidget {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _GoalOption({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppTheme.primaryColor : Colors.grey.shade200,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppTheme.primaryColor.withOpacity(0.2) 
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? AppTheme.primaryColor : Colors.grey,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, color: AppTheme.primaryColor, size: 24),
            ],
          ),
        ),
      ),
    );
    }
}

class _ActivityOptionCard extends StatelessWidget {
  final String id;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _ActivityOptionCard({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppTheme.primaryColor : Colors.grey.shade200,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, color: AppTheme.primaryColor, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
