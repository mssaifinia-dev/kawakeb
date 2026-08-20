import 'dart:math';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/star_field_background.dart';
import '../../../core/services/admin_service.dart';

const List<String> _tiers = ['free', 'gold', 'vip'];

const Map<String, String> _tierLabels = {
  'free': 'رایگان',
  'gold': 'طلایی',
  'vip': 'VIP',
};

const Map<String, Color> _tierColors = {
  'free': AppColors.textSecondary,
  'gold': AppColors.gold,
  'vip': Color(0xFF9C3EE0),
};

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _loading = true;
  bool _isAdmin = false;
  List<AdminUserRow> _users = [];
  List<PlanRow> _plans = [];
  List<SupportTicketRow> _tickets = [];
  List<FeatureAccessRow> _featureAccess = [];
  String _search = '';
  String _tierFilter = 'all'; // all | free | gold | vip

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String? _loadError;

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final isAdmin = await AdminService.isCurrentUserAdmin();
      if (!isAdmin) {
        if (!mounted) return;
        setState(() {
          _isAdmin = false;
          _loading = false;
        });
        return;
      }

      final users = await AdminService.getAllUsers();
      final plans = await AdminService.getPlans();
      final tickets = await AdminService.getAllTickets();
      final featureAccess = await AdminService.getFeatureAccess();
      if (!mounted) return;
      setState(() {
        _isAdmin = true;
        _users = users;
        _plans = plans;
        _tickets = tickets;
        _featureAccess = featureAccess;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _savePlan(String tier, int priceToman, int durationDays) async {
    await AdminService.updatePlan(tier, priceToman: priceToman, durationDays: durationDays);
    final plans = await AdminService.getPlans();
    if (!mounted) return;
    setState(() => _plans = plans);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ذخیره شد')),
      );
    }
  }

  Future<void> _changeTier(AdminUserRow user, String newTier) async {
    await AdminService.setUserTier(user.userId, newTier);
    await _load();
  }

  List<AdminUserRow> get _filteredUsers {
    var list = _users;
    if (_tierFilter != 'all') {
      list = list.where((u) => u.tier == _tierFilter).toList();
    }
    if (_search.trim().isNotEmpty) {
      final query = _search.trim().toLowerCase();
      list = list.where((u) {
        final email = (u.email ?? '').toLowerCase();
        final phone = (u.phone ?? '').toLowerCase();
        final name = (u.name ?? '').toLowerCase();
        return email.contains(query) || phone.contains(query) || name.contains(query);
      }).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('پنل مدیریت'),
        bottom: _isAdmin
            ? TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'کاربران'),
                  Tab(text: 'قیمت‌گذاری'),
                  Tab(text: 'پشتیبانی'),
                  Tab(text: 'دسترسی فال‌ها'),
                ],
              )
            : null,
      ),
      body: Stack(
        children: [
          const StarFieldBackground(),
          SafeArea(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
                : _loadError != null
                    ? _buildLoadError()
                    : !_isAdmin
                        ? _buildNotAdmin()
                        : TabBarView(
                            controller: _tabController,
                            children: [
                              _buildAdminPanel(),
                              _buildPlansTab(),
                              _buildTicketsTab(),
                              _buildFeatureAccessTab(),
                            ],
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: 16),
            Text('خطا در بارگیری اطلاعات', style: AppTextStyles.headlineSmall),
            const SizedBox(height: 8),
            Text(_loadError ?? '', style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _load, child: const Text('تلاش دوباره')),
          ],
        ),
      ),
    );
  }

  Widget _buildNotAdmin() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline, color: AppColors.error, size: 48),
            const SizedBox(height: 16),
            Text('دسترسی نداری', style: AppTextStyles.headlineSmall),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminPanel() {
    final stats = AdminService.computeStats(_users);
    return Column(
      children: [
        _buildStatsSection(stats),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: TextField(
            onChanged: (v) => setState(() => _search = v),
            textAlign: TextAlign.right,
            decoration: const InputDecoration(
              hintText: 'جستجو با اسم، شماره‌موبایل یا ایمیل',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        const SizedBox(height: 10),
        _buildTierFilterChips(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: Alignment.centerRight,
            child: Text('${_filteredUsers.length} کاربر', style: AppTextStyles.bodySmall),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _load,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredUsers.length,
              itemBuilder: (context, index) => _buildUserRow(_filteredUsers[index]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection(AdminStats stats) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _statCard('کل کاربران', stats.total.toString(), AppColors.textPrimary)),
              const SizedBox(width: 10),
              Expanded(child: _statCard('این هفته', '+${stats.newThisWeek}', AppColors.gold)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _statCard('رایگان', stats.free.toString(), _tierColors['free']!)),
              const SizedBox(width: 10),
              Expanded(child: _statCard('طلایی', stats.gold.toString(), _tierColors['gold']!)),
              const SizedBox(width: 10),
              Expanded(child: _statCard('VIP', stats.vip.toString(), _tierColors['vip']!)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.glassFill,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        children: [
          Text(value, style: AppTextStyles.headlineSmall.copyWith(color: color)),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }

  Widget _buildTierFilterChips() {
    final options = <String, String>{
      'all': 'همه',
      'free': 'رایگان',
      'gold': 'طلایی',
      'vip': 'VIP',
    };
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Wrap(
        spacing: 8,
        alignment: WrapAlignment.end,
        children: options.entries.map((e) {
          final selected = _tierFilter == e.key;
          return ChoiceChip(
            label: Text(e.value),
            selected: selected,
            onSelected: (_) => setState(() => _tierFilter = e.key),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildUserRow(AdminUserRow user) {
    final tierColor = _tierColors[user.tier] ?? AppColors.textSecondary;
    final title = user.name?.trim().isNotEmpty == true
        ? user.name!
        : (user.phone ?? user.email ?? user.userId);
    final subtitleParts = <String>[
      if (user.phone != null && user.phone!.isNotEmpty) user.phone!,
      if (user.email != null && user.email!.isNotEmpty) user.email!,
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.glassFill,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.cardLabel, maxLines: 1, overflow: TextOverflow.ellipsis),
                if (subtitleParts.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(subtitleParts.join(' · '),
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
                const SizedBox(height: 4),
                Text(_tierLabels[user.tier] ?? user.tier, style: AppTextStyles.bodySmall.copyWith(color: tierColor)),
              ],
            ),
          ),
          DropdownButton<String>(
            value: user.tier,
            dropdownColor: AppColors.surface,
            underline: const SizedBox(),
            items: _tiers
                .map((t) => DropdownMenuItem(value: t, child: Text(_tierLabels[t]!, style: AppTextStyles.bodySmall)))
                .toList(),
            onChanged: (newTier) {
              if (newTier != null) _changeTier(user, newTier);
            },
          ),
          IconButton(
            tooltip: 'ریست رمز عبور',
            icon: const Icon(Icons.key_outlined, size: 20, color: AppColors.textSecondary),
            onPressed: () => _showResetPasswordDialog(user),
          ),
          IconButton(
            tooltip: 'حذف کاربر',
            icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.error),
            onPressed: () => _showDeleteUserDialog(user),
          ),
        ],
      ),
    );
  }

  Widget _buildPlansTab() {
    final gold = _plans.firstWhere(
      (p) => p.tier == 'gold',
      orElse: () => const PlanRow(tier: 'gold', priceToman: 0, durationDays: 30),
    );
    final vip = _plans.firstWhere(
      (p) => p.tier == 'vip',
      orElse: () => const PlanRow(tier: 'vip', priceToman: 0, durationDays: 30),
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _PlanEditor(
          key: ValueKey('gold-${gold.priceToman}-${gold.durationDays}'),
          label: 'طلایی',
          color: _tierColors['gold']!,
          plan: gold,
          onSave: (price, days) => _savePlan('gold', price, days),
        ),
        const SizedBox(height: 16),
        _PlanEditor(
          key: ValueKey('vip-${vip.priceToman}-${vip.durationDays}'),
          label: 'VIP',
          color: _tierColors['vip']!,
          plan: vip,
          onSave: (price, days) => _savePlan('vip', price, days),
        ),
      ],
    );
  }
  Widget _buildTicketsTab() {
    if (_tickets.isEmpty) {
      return Center(
        child: Text('هنوز هیچ تیکتی نیست', style: AppTextStyles.bodySmall),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _tickets.length,
        itemBuilder: (context, index) => _buildTicketRow(_tickets[index]),
      ),
    );
  }

  Widget _buildTicketRow(SupportTicketRow ticket) {
    const statusColors = {
      'open': AppColors.gold,
      'answered': Color(0xFF1E8E7E),
      'closed': AppColors.textSecondary,
    };
    const statusLabels = {
      'open': 'در انتظار پاسخ',
      'answered': 'پاسخ داده شد',
      'closed': 'بسته شد',
    };
    final color = statusColors[ticket.status] ?? AppColors.textSecondary;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.glassFill,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                child: Text(statusLabels[ticket.status] ?? ticket.status,
                    style: AppTextStyles.bodySmall.copyWith(color: color, fontSize: 10)),
              ),
              const Spacer(),
              Text(ticket.userName ?? ticket.userPhone ?? ticket.userId,
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 6),
          Text(ticket.subject, style: AppTextStyles.cardLabel, textAlign: TextAlign.right),
          const SizedBox(height: 4),
          Text(ticket.message, style: AppTextStyles.bodySmall, textAlign: TextAlign.right),
          if (ticket.adminReply != null && ticket.adminReply!.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Divider(color: AppColors.glassBorder, height: 1),
            const SizedBox(height: 8),
            Text('پاسخ: ${ticket.adminReply}',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.gold), textAlign: TextAlign.right),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              if (ticket.status != 'closed')
                TextButton(
                  onPressed: () async {
                    await AdminService.setTicketStatus(ticket.id, 'closed');
                    await _load();
                  },
                  child: const Text('بستن'),
                ),
              const Spacer(),
              FilledButton(
                onPressed: () => _showReplyDialog(ticket),
                child: Text(ticket.adminReply == null ? 'پاسخ بده' : 'ویرایش پاسخ'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showReplyDialog(SupportTicketRow ticket) async {
    final controller = TextEditingController(text: ticket.adminReply ?? '');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('پاسخ به تیکت'),
        content: TextField(
          controller: controller,
          textAlign: TextAlign.right,
          maxLines: 5,
          decoration: const InputDecoration(hintText: 'پاسخت رو بنویس...'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('انصراف')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('ارسال پاسخ')),
        ],
      ),
    );

    if (confirmed != true || controller.text.trim().isEmpty || !mounted) return;
    await AdminService.replyToTicket(ticket.id, controller.text.trim());
    await _load();
  }

  Widget _buildFeatureAccessTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'مشخص کن هر فال برای کدوم سطح اشتراک بازه. اگه فالی تو لیست نباشه، پیش‌فرض رایگانه.',
          style: AppTextStyles.bodySmall,
          textAlign: TextAlign.right,
        ),
        const SizedBox(height: 14),
        _AddFeatureAccessForm(
          onAdd: (key, label, tier) async {
            await AdminService.upsertFeatureAccess(featureKey: key, label: label, tier: tier);
            await _load();
          },
        ),
        const SizedBox(height: 16),
        for (final feature in _featureAccess) _buildFeatureAccessRow(feature),
      ],
    );
  }

  Widget _buildFeatureAccessRow(FeatureAccessRow feature) {
    final tierColor = _tierColors[feature.tier] ?? AppColors.textSecondary;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.glassFill,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(feature.label, style: AppTextStyles.cardLabel),
                Text(feature.featureKey, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          DropdownButton<String>(
            value: feature.tier,
            dropdownColor: AppColors.surface,
            underline: const SizedBox(),
            items: _tiers
                .map((t) => DropdownMenuItem(value: t, child: Text(_tierLabels[t]!, style: AppTextStyles.bodySmall.copyWith(color: tierColor))))
                .toList(),
            onChanged: (newTier) async {
              if (newTier == null) return;
              await AdminService.upsertFeatureAccess(featureKey: feature.featureKey, label: feature.label, tier: newTier);
              await _load();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.textSecondary),
            onPressed: () async {
              await AdminService.deleteFeatureAccess(feature.featureKey);
              await _load();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteUserDialog(AdminUserRow user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('حذف کاربر'),
        content: Text(
          'مطمئنی می‌خوای حساب "${user.name ?? user.phone ?? user.email ?? user.userId}" رو کامل حذف کنی؟ این کار قابل بازگشت نیست.',
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('انصراف')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف کن'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    final error = await AdminService.deleteUser(user.userId);
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('کاربر حذف شد')));
      await _load();
    }
  }

  Future<void> _showResetPasswordDialog(AdminUserRow user) async {
    final controller = TextEditingController(text: _generateSimplePassword());

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('ریست رمز ${user.name ?? user.phone ?? user.email ?? ""}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: controller,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                labelText: 'رمز جدید',
                suffixIcon: IconButton(
                  tooltip: 'تولید تصادفی',
                  icon: const Icon(Icons.refresh),
                  onPressed: () => controller.text = _generateSimplePassword(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'این رمز رو باید خودت به کاربر اطلاع بدی (تماس/پیام).',
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.right,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('انصراف')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('ریست کن')),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    if (controller.text.trim().length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('رمز باید حداقل ۶ کاراکتر باشد')),
      );
      return;
    }

    final error = await AdminService.resetUserPassword(user.userId, controller.text.trim());
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error ?? 'رمز با موفقیت ریست شد: ${controller.text.trim()}')),
    );
  }

  String _generateSimplePassword() {
    final rand = Random();
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    return List.generate(8, (_) => chars[rand.nextInt(chars.length)]).join();
  }
}

const List<(String, String)> _knownFeatures = [
  ('tarot', 'تاروت'),
  ('hafez', 'فال حافظ'),
  ('istikhara', 'استخاره'),
  ('sar_ketab', 'سرکتاب'),
  ('dream_interpretation', 'تعبیر خواب'),
  ('love', 'فال عشق'),
  ('coffee', 'فال قهوه'),
  ('candle', 'فال شمع'),
  ('numerology', 'کتاب سرنوشت'),
  ('zodiac', 'طالع‌بینی کامل'),
  ('chinese_zodiac', 'طالع‌بینی چینی'),
  ('rashi', 'طالع‌بینی هندی'),
  ('finance', 'فال مالی'),
  ('career', 'فال شغلی'),
  ('angel', 'فال فرشتگان'),
  ('gypsy', 'فال کولی'),
  ('abjad', 'اذکار و ابجد'),
  ('saad_nahs', 'سعد و نحس ایام'),
  ('qamar_aqrab', 'قمر در عقرب'),
  ('jafr', 'جفر'),
];

class _AddFeatureAccessForm extends StatefulWidget {
  final Future<void> Function(String key, String label, String tier) onAdd;
  const _AddFeatureAccessForm({required this.onAdd});

  @override
  State<_AddFeatureAccessForm> createState() => _AddFeatureAccessFormState();
}

class _AddFeatureAccessFormState extends State<_AddFeatureAccessForm> {
  String _selectedKey = _knownFeatures.first.$1;
  String _tier = 'gold';
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.glassFill,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('تعیین سطح یک فال', style: AppTextStyles.cardLabel.copyWith(color: AppColors.gold)),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _selectedKey,
            dropdownColor: AppColors.surface,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'انتخاب فال'),
            items: _knownFeatures
                .map((f) => DropdownMenuItem(value: f.$1, child: Text(f.$2)))
                .toList(),
            onChanged: (v) {
              if (v != null) setState(() => _selectedKey = v);
            },
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _tier,
            dropdownColor: AppColors.surface,
            decoration: const InputDecoration(labelText: 'سطح دسترسی'),
            items: _tiers
                .map((t) => DropdownMenuItem(value: t, child: Text(_tierLabels[t]!)))
                .toList(),
            onChanged: (v) {
              if (v != null) setState(() => _tier = v);
            },
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _saving
                ? null
                : () async {
                    setState(() => _saving = true);
                    final label = _knownFeatures.firstWhere((f) => f.$1 == _selectedKey).$2;
                    await widget.onAdd(_selectedKey, label, _tier);
                    if (mounted) setState(() => _saving = false);
                  },
            child: const Text('ذخیره'),
          ),
        ],
      ),
    );
  }
}

class _PlanEditor extends StatefulWidget {
  final String label;
  final Color color;
  final PlanRow plan;
  final void Function(int priceToman, int durationDays) onSave;

  const _PlanEditor({
    super.key,
    required this.label,
    required this.color,
    required this.plan,
    required this.onSave,
  });

  @override
  State<_PlanEditor> createState() => _PlanEditorState();
}

class _PlanEditorState extends State<_PlanEditor> {
  late final TextEditingController _priceController =
      TextEditingController(text: widget.plan.priceToman.toString());
  late final TextEditingController _daysController =
      TextEditingController(text: widget.plan.durationDays.toString());

  @override
  void dispose() {
    _priceController.dispose();
    _daysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.glassFill,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('اشتراک ${widget.label}',
              style: AppTextStyles.cardLabel.copyWith(color: widget.color)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(labelText: 'قیمت (تومان)'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _daysController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(labelText: 'مدت (روز)'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              final price = int.tryParse(_priceController.text.trim()) ?? 0;
              final days = int.tryParse(_daysController.text.trim()) ?? 30;
              widget.onSave(price, days);
            },
            child: const Text('ذخیره'),
          ),
        ],
      ),
    );
  }
}
