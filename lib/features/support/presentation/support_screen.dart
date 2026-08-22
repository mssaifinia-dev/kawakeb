import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/star_field_background.dart';
import '../../../core/services/support_service.dart';

const Map<String, String> _statusLabels = {
  'open': 'در انتظار پاسخ',
  'answered': 'پاسخ داده شد',
  'closed': 'بسته شد',
};

const Map<String, Color> _statusColors = {
  'open': AppColors.gold,
  'answered': Color(0xFF1E8E7E),
  'closed': AppColors.textSecondary,
};

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isSubmitting = false;
  bool _loading = true;
  List<SupportTicket> _tickets = [];

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadTickets() async {
    final tickets = await SupportService.getMyTickets();
    if (!mounted) return;
    setState(() {
      _tickets = tickets;
      _loading = false;
    });
    await SupportService.markAllRepliesRead();
  }

  Future<void> _submit() async {
    if (_subjectController.text.trim().isEmpty || _messageController.text.trim().isEmpty) return;

    setState(() => _isSubmitting = true);
    try {
      await SupportService.submitTicket(
        subject: _subjectController.text.trim(),
        message: _messageController.text.trim(),
      );
      _subjectController.clear();
      _messageController.clear();
      await _loadTickets();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('پیامت ارسال شد، به‌زودی پاسخ داده می‌شه')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطا در ارسال: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('پشتیبانی')),
      body: Stack(
        children: [
          const StarFieldBackground(),
          SafeArea(
            child: RefreshIndicator(
              onRefresh: _loadTickets,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildNewTicketForm(),
                  const SizedBox(height: 24),
                  Text('پیام‌های قبلی', style: AppTextStyles.cardLabel),
                  const SizedBox(height: 10),
                  if (_loading)
                    const Center(child: CircularProgressIndicator(color: AppColors.gold))
                  else if (_tickets.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Text('هنوز پیامی نفرستادی', style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
                    )
                  else
                    for (final ticket in _tickets) _buildTicketCard(ticket),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewTicketForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.glassFill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('پیام جدید به پشتیبانی', style: AppTextStyles.cardLabel.copyWith(color: AppColors.gold)),
          const SizedBox(height: 12),
          TextField(
            controller: _subjectController,
            textAlign: TextAlign.right,
            decoration: const InputDecoration(hintText: 'موضوع'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _messageController,
            textAlign: TextAlign.right,
            maxLines: 4,
            decoration: const InputDecoration(hintText: 'پیامت رو بنویس...'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _isSubmitting ? null : _submit,
            child: _isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textOnGold),
                  )
                : const Text('ارسال'),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketCard(SupportTicket ticket) {
    final statusColor = _statusColors[ticket.status] ?? AppColors.textSecondary;
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
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(_statusLabels[ticket.status] ?? ticket.status,
                    style: AppTextStyles.bodySmall.copyWith(color: statusColor, fontSize: 10)),
              ),
              const Spacer(),
              Text(ticket.subject, style: AppTextStyles.cardLabel, maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
          const SizedBox(height: 8),
          Text(ticket.message, style: AppTextStyles.bodySmall, textAlign: TextAlign.right),
          if (ticket.adminReply != null && ticket.adminReply!.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Divider(color: AppColors.glassBorder, height: 1),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.support_agent, size: 14, color: AppColors.gold),
                const SizedBox(width: 6),
                Text('پاسخ پشتیبانی', style: AppTextStyles.bodySmall.copyWith(color: AppColors.gold)),
              ],
            ),
            const SizedBox(height: 6),
            Text(ticket.adminReply!, style: AppTextStyles.bodySmall, textAlign: TextAlign.right),
          ],
        ],
      ),
    );
  }
}
