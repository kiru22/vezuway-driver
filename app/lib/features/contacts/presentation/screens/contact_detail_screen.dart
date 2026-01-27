import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/pill_tab_bar.dart';
import '../../../packages/presentation/widgets/package_card_v2.dart';
import '../../data/models/contact_model.dart';
import '../../domain/providers/contact_provider.dart';
import '../widgets/contact_stats_card.dart';

class ContactDetailScreen extends ConsumerStatefulWidget {
  final String contactId;

  const ContactDetailScreen({
    super.key,
    required this.contactId,
  });

  @override
  ConsumerState<ContactDetailScreen> createState() =>
      _ContactDetailScreenState();
}

class _ContactDetailScreenState extends ConsumerState<ContactDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final contactAsync = ref.watch(contactDetailProvider(widget.contactId));

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.textPrimary),
          onPressed: () => context.go('/contacts'),
        ),
        title: Text(
          l10n.contacts_detail,
          style: TextStyle(color: colors.textPrimary),
        ),
        actions: [
          contactAsync.whenOrNull(
                data: (contact) => IconButton(
                  icon: Icon(Icons.more_vert, color: colors.textPrimary),
                  onPressed: () => _showActionsBottomSheet(context, contact),
                ),
              ) ??
              const SizedBox.shrink(),
        ],
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          // Tab bar
          PillTabBar(
            controller: _tabController,
            labels: [l10n.contacts_tabHistory, l10n.contacts_tabDetails],
          ),
          const SizedBox(height: 16),
          // Content
          Expanded(
            child: contactAsync.when(
              data: (contact) => TabBarView(
                controller: _tabController,
                children: [
                  _buildHistoryTab(),
                  _buildDetailsTab(contact),
                ],
              ),
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.common_error,
                      style: TextStyle(color: colors.textPrimary),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref
                          .invalidate(contactDetailProvider(widget.contactId)),
                      child: Text(l10n.common_retry),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showActionsBottomSheet(BuildContext context, ContactModel contact) {
    final l10n = context.l10n;
    final colors = context.colors;

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text(l10n.contacts_edit),
              onTap: () {
                Navigator.pop(context);
                _showEditDialog(contact);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.error),
              title: Text(
                l10n.common_delete,
                style: const TextStyle(color: AppColors.error),
              ),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab() {
    final packagesAsync = ref.watch(contactPackagesProvider(widget.contactId));

    return packagesAsync.when(
      data: (packages) {
        if (packages.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 80,
                  color: Theme.of(context).disabledColor,
                ),
                const SizedBox(height: 16),
                Text(
                  context.l10n.contacts_noPackages,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.contacts_noPackagesDesc,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: packages.length,
          itemBuilder: (context, index) {
            final package = packages[index];
            return PackageCardV2(
              package: package,
              onTap: () => context.push('/packages/${package.id}'),
              onExpand: () => context.push('/packages/${package.id}'),
              onStatusChange: (status) {
                // No action needed here - this is view-only
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text(
            '${context.l10n.contacts_errorLoadingPackages}: ${error.toString()}'),
      ),
    );
  }

  Widget _buildDetailsTab(ContactModel contact) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ContactStatsCard(contact: contact),
          const SizedBox(height: 24),

          // Notas del contacto
          if (contact.notes != null && contact.notes!.isNotEmpty)
            _buildInfoSection(
              title: context.l10n.contacts_notes,
              icon: Icons.note_outlined,
              child: Text(
                contact.notes!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  void _showEditDialog(ContactModel contact) {
    final nameController = TextEditingController(text: contact.name);
    final emailController = TextEditingController(text: contact.email ?? '');
    final phoneController = TextEditingController(text: contact.phone ?? '');
    final notesController = TextEditingController(text: contact.notes ?? '');

    final l10n = context.l10n;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(32),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Título
                Text(
                  l10n.contacts_edit,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 24),

                // Campos del formulario
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: l10n.contacts_nameLabel,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: l10n.contacts_emailLabel,
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: l10n.contacts_phoneLabel,
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  decoration: InputDecoration(
                    labelText: l10n.contacts_notesLabel,
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 32),

                // Botones de acción
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                      ),
                      child: Text(l10n.common_cancel),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () async {
                        if (nameController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.contacts_nameRequired)),
                          );
                          return;
                        }

                        try {
                          await ref
                              .read(contactsProvider.notifier)
                              .updateContact(
                            widget.contactId,
                            {
                              'name': nameController.text.trim(),
                              if (emailController.text.trim().isNotEmpty)
                                'email': emailController.text.trim(),
                              if (phoneController.text.trim().isNotEmpty)
                                'phone': phoneController.text.trim(),
                              if (notesController.text.trim().isNotEmpty)
                                'notes': notesController.text.trim(),
                            },
                          );

                          // Invalidar el provider para recargar datos
                          ref.invalidate(
                              contactDetailProvider(widget.contactId));

                          if (mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.contacts_updated)),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      '${l10n.common_error}: ${e.toString()}')),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMd),
                        ),
                      ),
                      child: Text(l10n.common_save),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation() {
    final l10n = context.l10n;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.contacts_deleteTitle),
        content: Text(l10n.contacts_deleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.common_cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await ref
                    .read(contactsProvider.notifier)
                    .deleteContact(widget.contactId);

                if (mounted) {
                  Navigator.pop(context); // Cerrar diálogo
                  context.pop(); // Volver a lista de contactos
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.contacts_deleted)),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('${l10n.common_error}: ${e.toString()}')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.common_delete),
          ),
        ],
      ),
    );
  }
}
