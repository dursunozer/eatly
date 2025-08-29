import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Kullanıcı bilgileri - gerçek uygulamada SharedPreferences'tan gelecek
  String _name = 'Kullanıcı';
  int _age = 25;
  double _weight = 70; // kg
  double _height = 170; // cm
  String _gender = 'Erkek';
  String _activityLevel = 'Orta Aktif';
  String _goal = 'Kilo Koruma';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Profilim'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              _showSettingsDialog();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(),
            _buildStatsSection(),
            _buildGoalsSection(),
            _buildAchievementsSection(),
            _buildSettingsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
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
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: Text(
                _name.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _name,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            '$_age yaşında • $_gender',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildInfoChip(Icons.monitor_weight, '$_weight kg'),
              const SizedBox(width: 16),
              _buildInfoChip(Icons.height, '$_height cm'),
              const SizedBox(width: 16),
              _buildInfoChip(Icons.local_fire_department, '${_calculateBMR()} kcal'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.primaryColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vücut İstatistikleri',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildStatRow('BMI (Vücut Kitle İndeksi)', _calculateBMI().toStringAsFixed(1), _getBMIStatus()),
                  const Divider(height: 24),
                  _buildStatRow('Bazal Metabolizma Hızı', '${_calculateBMR()} kcal/gün', ''),
                  const Divider(height: 24),
                  _buildStatRow('Günlük Kalori İhtiyacı', '${_calculateDailyCalories()} kcal', _activityLevel),
                  const Divider(height: 24),
                  _buildStatRow('Hedef', _goal, _getGoalDescription()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, String status) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
              if (status.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    color: _getStatusColor(status),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildGoalsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Haftalık İlerleme',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildWeeklyProgressChart(),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildProgressStat('7', 'Ardışık Gün'),
                      _buildProgressStat('21', 'Toplam Gün'),
                      _buildProgressStat('%85', 'Hedef Başarısı'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyProgressChart() {
    return SizedBox(
      height: 150,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const days = ['P', 'S', 'Ç', 'P', 'C', 'C', 'P'];
                  return Text(
                    days[value.toInt()],
                    style: const TextStyle(fontSize: 12),
                  );
                },
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: const [
                FlSpot(0, 1950),
                FlSpot(1, 2100),
                FlSpot(2, 1980),
                FlSpot(3, 2050),
                FlSpot(4, 1900),
                FlSpot(5, 2000),
                FlSpot(6, 2020),
              ],
              isCurved: true,
              color: AppTheme.primaryColor,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: Colors.white,
                    strokeWidth: 2,
                    strokeColor: AppTheme.primaryColor,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: AppTheme.primaryColor.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementsSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Başarılar',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _buildAchievementBadge(Icons.local_fire_department, 'Ateşli 7', Colors.orange),
                  _buildAchievementBadge(Icons.calendar_month, '30 Gün', Colors.blue),
                  _buildAchievementBadge(Icons.trending_up, 'İstikrarlı', Colors.green),
                  _buildAchievementBadge(Icons.star, 'Süper Kullanıcı', Colors.purple),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementBadge(IconData icon, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ayarlar',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('Profil Bilgileri'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showEditProfileDialog(),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.notifications_outlined),
                  title: const Text('Bildirimler'),
                  trailing: Switch(
                    value: true,
                    onChanged: (value) {},
                    activeColor: AppTheme.primaryColor,
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: const Text('Gizlilik'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: const Text('Yardım'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _calculateBMI() {
    return _weight / ((_height / 100) * (_height / 100));
  }

  String _getBMIStatus() {
    final bmi = _calculateBMI();
    if (bmi < 18.5) return 'Zayıf';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Fazla Kilolu';
    return 'Obez';
  }

  int _calculateBMR() {
    if (_gender == 'Erkek') {
      return (10 * _weight + 6.25 * _height - 5 * _age + 5).round();
    } else {
      return (10 * _weight + 6.25 * _height - 5 * _age - 161).round();
    }
  }

  int _calculateDailyCalories() {
    final bmr = _calculateBMR();
    switch (_activityLevel) {
      case 'Hareketsiz':
        return (bmr * 1.2).round();
      case 'Az Aktif':
        return (bmr * 1.375).round();
      case 'Orta Aktif':
        return (bmr * 1.55).round();
      case 'Çok Aktif':
        return (bmr * 1.725).round();
      case 'Aşırı Aktif':
        return (bmr * 1.9).round();
      default:
        return (bmr * 1.55).round();
    }
  }

  String _getGoalDescription() {
    switch (_goal) {
      case 'Kilo Verme':
        return '500 kcal açık';
      case 'Kilo Alma':
        return '500 kcal fazla';
      case 'Kilo Koruma':
        return 'Dengeli beslenme';
      default:
        return '';
    }
  }

  Color _getStatusColor(String status) {
    if (status == 'Normal') return Colors.green;
    if (status.contains('Fazla') || status.contains('Zayıf')) return Colors.orange;
    return Colors.red;
  }

  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Profil Düzenle'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'İsim'),
                controller: TextEditingController(text: _name),
                onChanged: (value) => _name = value,
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(labelText: 'Yaş'),
                controller: TextEditingController(text: _age.toString()),
                keyboardType: TextInputType.number,
                onChanged: (value) => _age = int.tryParse(value) ?? _age,
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(labelText: 'Kilo (kg)'),
                controller: TextEditingController(text: _weight.toString()),
                keyboardType: TextInputType.number,
                onChanged: (value) => _weight = double.tryParse(value) ?? _weight,
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(labelText: 'Boy (cm)'),
                controller: TextEditingController(text: _height.toString()),
                keyboardType: TextInputType.number,
                onChanged: (value) => _height = double.tryParse(value) ?? _height,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hedef ve Aktivite'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _goal,
              decoration: const InputDecoration(labelText: 'Hedef'),
              items: ['Kilo Verme', 'Kilo Alma', 'Kilo Koruma']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) => setState(() => _goal = value!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _activityLevel,
              decoration: const InputDecoration(labelText: 'Aktivite Seviyesi'),
              items: ['Hareketsiz', 'Az Aktif', 'Orta Aktif', 'Çok Aktif', 'Aşırı Aktif']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) => setState(() => _activityLevel = value!),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {});
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }
}
