import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: ListView(
        children: [
          // Account Section
          _SectionHeader(title: 'Conta'),
          _SettingsTile(
            icon: Icons.person_outline,
            title: 'Editar Perfil',
            onTap: () {
              // TODO: Navigate to edit profile
            },
          ),
          _SettingsTile(
            icon: Icons.verified_outlined,
            title: 'Verificação',
            subtitle: user?.isVerified ?? false
                ? 'Verificado ✓'
                : 'Não verificado',
            onTap: () {
              // TODO: Navigate to verification
            },
          ),
          
          const Divider(),
          
          // Preferences Section
          _SectionHeader(title: 'Preferências'),
          _SettingsTile(
            icon: Icons.tune,
            title: 'Preferências de Match',
            subtitle: 'Idade, distância, gênero',
            onTap: () {
              // TODO: Navigate to match preferences
            },
          ),
          _SettingsTile(
            icon: Icons.notifications_outlined,
            title: 'Notificações',
            onTap: () {
              // TODO: Navigate to notifications settings
            },
          ),
          
          const Divider(),
          
          // Credits Section
          _SectionHeader(title: 'Créditos'),
          _SettingsTile(
            icon: Icons.payment,
            title: 'Comprar Créditos',
            subtitle: '${user?.credits ?? 0} créditos disponíveis',
            onTap: () {
              context.push('/home/credits');
            },
          ),
          _SettingsTile(
            icon: Icons.history,
            title: 'Histórico de Transações',
            onTap: () {
              // TODO: Navigate to transaction history
            },
          ),
          
          const Divider(),
          
          // Support Section
          _SectionHeader(title: 'Suporte'),
          _SettingsTile(
            icon: Icons.help_outline,
            title: 'Central de Ajuda',
            onTap: () {
              // TODO: Open help center
            },
          ),
          _SettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacidade e Segurança',
            onTap: () {
              // TODO: Navigate to privacy settings
            },
          ),
          _SettingsTile(
            icon: Icons.description_outlined,
            title: 'Termos de Uso',
            onTap: () {
              // TODO: Open terms
            },
          ),
          
          const Divider(),
          
          // Danger Zone
          _SectionHeader(title: 'Conta'),
          _SettingsTile(
            icon: Icons.logout,
            title: 'Sair',
            textColor: AppColors.error,
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Sair'),
                  content: const Text('Tem certeza que deseja sair?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        'Sair',
                        style: TextStyle(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                await ref.read(authProvider.notifier).signOut();
                if (context.mounted) {
                  context.go('/login');
                }
              }
            },
          ),
          _SettingsTile(
            icon: Icons.delete_outline,
            title: 'Deletar Conta',
            textColor: AppColors.error,
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Deletar Conta'),
                  content: const Text(
                    'Esta ação é permanente e não pode ser desfeita. '
                    'Todos os seus dados serão deletados.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        'Deletar',
                        style: TextStyle(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                // TODO: Implement account deletion
              }
            },
          ),
          
          const SizedBox(height: 24),
          
          // App Version
          Center(
            child: Text(
              'BrasilMatch v1.0.0',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.textHint,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Color? textColor;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: textColor ?? AppColors.textPrimary,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(subtitle!)
          : null,
      trailing: Icon(
        Icons.chevron_right,
        color: AppColors.textHint,
      ),
      onTap: onTap,
    );
  }
}
