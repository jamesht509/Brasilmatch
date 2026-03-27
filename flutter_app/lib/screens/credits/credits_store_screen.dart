import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';

class CreditsStoreScreen extends ConsumerWidget {
  const CreditsStoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comprar Créditos'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Current Balance
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppColors.cardShadow,
              ),
              child: Column(
                children: [
                  const Text(
                    'Saldo Atual',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${user?.credits ?? 0}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const Text(
                    'créditos',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // What credits do
            Text(
              'O que você pode fazer com créditos?',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            _CreditFeature(
              icon: Icons.star,
              title: 'Super Like',
              description: 'Apareça no topo da fila',
              cost: '1 crédito',
            ),
            const SizedBox(height: 12),
            _CreditFeature(
              icon: Icons.visibility,
              title: 'Ver quem te deu like',
              description: 'Descubra quem se interessou por você',
              cost: '2 créditos',
            ),
            const SizedBox(height: 12),
            _CreditFeature(
              icon: Icons.rocket_launch,
              title: 'Boost',
              description: 'Seja visto por mais pessoas (1h)',
              cost: '5 créditos',
            ),
            const SizedBox(height: 12),
            _CreditFeature(
              icon: Icons.undo,
              title: 'Rewind',
              description: 'Desfaça o último swipe',
              cost: '10 créditos',
            ),
            
            const SizedBox(height: 32),
            
            // Credit Packages
            Text(
              'Pacotes de Créditos',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            _CreditPackage(
              credits: 20,
              price: '\$2.99',
              onPurchase: () {
                // TODO: Implement IAP purchase
                _showPurchaseDialog(context, 20, '\$2.99');
              },
            ),
            const SizedBox(height: 12),
            
            _CreditPackage(
              credits: 50,
              price: '\$5.99',
              isPopular: true,
              onPurchase: () {
                _showPurchaseDialog(context, 50, '\$5.99');
              },
            ),
            const SizedBox(height: 12),
            
            _CreditPackage(
              credits: 120,
              price: '\$9.99',
              bonus: '+20 bônus!',
              onPurchase: () {
                _showPurchaseDialog(context, 120, '\$9.99');
              },
            ),
            
            const SizedBox(height: 32),
            
            // Fine Print
            Text(
              '• Créditos nunca expiram\n'
              '• Pagamento via Apple/Google Pay\n'
              '• Sem renovação automática',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showPurchaseDialog(BuildContext context, int credits, String price) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar compra'),
        content: Text('Comprar $credits créditos por $price?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Process IAP purchase
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Compra realizada com sucesso!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Comprar'),
          ),
        ],
      ),
    );
  }
}

class _CreditFeature extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String cost;

  const _CreditFeature({
    required this.icon,
    required this.title,
    required this.description,
    required this.cost,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.textHint.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Text(
            cost,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CreditPackage extends StatelessWidget {
  final int credits;
  final String price;
  final String? bonus;
  final bool isPopular;
  final VoidCallback onPurchase;

  const _CreditPackage({
    required this.credits,
    required this.price,
    this.bonus,
    this.isPopular = false,
    required this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isPopular ? AppColors.primary : AppColors.textHint.withOpacity(0.2),
              width: isPopular ? 2 : 1,
            ),
            boxShadow: isPopular ? AppColors.cardShadow : null,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '$credits',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'créditos',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    if (bonus != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        bonus!,
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    price,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: onPurchase,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Comprar'),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (isPopular)
          Positioned(
            top: -12,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '🔥 MAIS POPULAR',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
