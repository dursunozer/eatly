import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:stacked/stacked.dart';
import '../../../core/theme/app_theme.dart';
import 'profile_viewmodel.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ProfileViewModel>.reactive(
      viewModelBuilder: () => ProfileViewModel(),
      onViewModelReady: (vm) => vm.init(),
      builder: (context, model, child) {
        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          appBar: AppBar(title: const Text('Profilim')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _header(model, context),
                const SizedBox(height: 16),
                _profileForm(context, model),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _header(ProfileViewModel model, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: AppTheme.primaryColor.withOpacity(0.15),
                backgroundImage: model.avatarUrl != null ? NetworkImage(model.avatarUrl!) : null,
                child: model.avatarUrl == null
                    ? Text(
                        model.initials,
                        style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                      )
                    : null,
              ),
              Material(
                color: AppTheme.primaryColor,
                shape: const CircleBorder(),
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
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.edit, color: Colors.white, size: 18),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          Text(model.name ?? '-', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 4),
          if (model.email != null)
            Text(model.email!, style: const TextStyle(color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  Widget _profileForm(BuildContext context, ProfileViewModel model) {
    final nameCtrl = TextEditingController(text: model.name ?? '');
    final ageCtrl = TextEditingController(text: model.age?.toString() ?? '');
    final weightCtrl = TextEditingController(text: model.weight?.toString() ?? '');
    final heightCtrl = TextEditingController(text: model.height?.toString() ?? '');
    final waistCtrl = TextEditingController(text: model.waistCm?.toString() ?? '');
    final hipCtrl = TextEditingController(text: model.hipCm?.toString() ?? '');
    String gender = model.gender ?? 'Erkek';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Kullanıcı Bilgileri', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Ad Soyad'),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r"[a-zA-ZğüşöçıİĞÜŞÖÇ ]"),
                ),
              ],
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: ageCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(labelText: 'Yaş')),
            const SizedBox(height: 8),
            TextField(
              controller: weightCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(labelText: 'Kilo (kg)')),
            const SizedBox(height: 8),
            TextField(
              controller: heightCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(labelText: 'Boy (cm)')),
            const SizedBox(height: 8),
            TextField(
              controller: waistCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(labelText: 'Bel çevresi (cm)')),
            const SizedBox(height: 8),
            TextField(
              controller: hipCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(labelText: 'Kalça çevresi (cm)')),
            const SizedBox(height: 8),
            _BmiInline(heightCtrl: heightCtrl, weightCtrl: weightCtrl),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: gender,
              items: const [DropdownMenuItem(value: 'Erkek', child: Text('Erkek')), DropdownMenuItem(value: 'Kadın', child: Text('Kadın'))],
              onChanged: (v) => gender = v ?? 'Erkek',
              decoration: const InputDecoration(labelText: 'Cinsiyet'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: model.isBusy
                  ? null
                  : () async {
                    await model.saveProfile(
                      newName: nameCtrl.text.trim(),
                      newAge: int.tryParse(ageCtrl.text) ?? (model.age ?? 0),
                      newWeight: double.tryParse(weightCtrl.text) ?? (model.weight ?? 0),
                      newHeight: double.tryParse(heightCtrl.text) ?? (model.height ?? 0),
                      newGender: gender,
                      newWaistCm: double.tryParse(waistCtrl.text),
                      newHipCm: double.tryParse(hipCtrl.text),
                    );
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Profil güncellendi')),
                    );
                  },
              child: const Text('Kaydet'),
            )
          ],
        ),
      ),
    );
  }
}

class _BmiInline extends StatefulWidget {
  const _BmiInline({required this.heightCtrl, required this.weightCtrl});
  final TextEditingController heightCtrl;
  final TextEditingController weightCtrl;
  @override
  State<_BmiInline> createState() => _BmiInlineState();
}

class _BmiInlineState extends State<_BmiInline> {
  double? _bmi;

  @override
  void initState() {
    super.initState();
    widget.heightCtrl.addListener(_recalc);
    widget.weightCtrl.addListener(_recalc);
    _recalc();
  }

  @override
  void dispose() {
    widget.heightCtrl.removeListener(_recalc);
    widget.weightCtrl.removeListener(_recalc);
    super.dispose();
  }

  void _recalc() {
    final h = double.tryParse(widget.heightCtrl.text);
    final w = double.tryParse(widget.weightCtrl.text);
    double? bmi;
    if (h != null && h > 0 && w != null && w > 0) {
      final m = h / 100.0;
      bmi = w / (m * m);
    }
    setState(() => _bmi = bmi);
  }

  @override
  Widget build(BuildContext context) {
    final text = _bmi == null ? 'BKİ: -' : 'BKİ: ${_bmi!.toStringAsFixed(1)}';
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(text, style: const TextStyle(color: Colors.grey)),
    );
  }
}
