import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moodlyy_application/common/l10n_etx.dart';
import 'package:moodlyy_application/features/journal/domain/journal_entry.dart';
import 'package:moodlyy_application/features/journal/vm/journal_vm.dart';
import 'package:provider/provider.dart';

class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  final TextEditingController _controller = TextEditingController();
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await _loadInitialEntry();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<JournalVM>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.journal_title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (!_showLoading(vm) && vm.latestEntry != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: context.l10n.journal_action_delete,
              onPressed: () => _confirmDelete(vm.latestEntry!),
            ),
        ],
      ),
      body: _showLoading(vm)
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    context.l10n.journal_subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Expanded(child: _buildWriterArea(colorScheme)),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: vm.isSaving ? null : () => _handleSave(vm),
                    icon: vm.isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save_rounded),
                    label: Text(context.l10n.journal_save),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildWriterArea(ColorScheme scheme) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant.withOpacity(0.4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: TextField(
          controller: _controller,
          expands: true,
          minLines: null,
          maxLines: null,
          keyboardType: TextInputType.multiline,
          decoration: InputDecoration(
            hintText: context.l10n.journal_hint,
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Future<void> _handleSave(JournalVM vm) async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final error = await vm.saveEntry(text);
    if (!mounted) return;

    if (error == JournalVM.notAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.journal_login_required)),
      );
      return;
    }

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    } else {
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.done_status)),
      );
    }
  }

  Future<void> _confirmDelete(JournalEntry entry) async {
    final vm = context.read<JournalVM>();
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.journal_action_delete),
        content: Text(context.l10n.journal_delete_confirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(context.l10n.btn_cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(context.l10n.delete_button_title),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      final error = await vm.deleteEntry(entry.id);
      if (!mounted) return;
      if (error == JournalVM.notAuthenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.journal_login_required)),
        );
      } else if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      } else {
        _controller.clear();
      }
    }
  }

  bool _showLoading(JournalVM vm) => vm.isLoading && !_initialized;

  Future<void> _loadInitialEntry() async {
    final vm = context.read<JournalVM>();
    final error = await vm.loadEntries();
    if (!mounted) return;
    _initialized = true;
    if (error == null && vm.latestEntry != null) {
      _controller.text = vm.latestEntry!.content;
    }
    setState(() {});
  }
}
