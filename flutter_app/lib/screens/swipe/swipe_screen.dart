import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/supabase/swipe_service.dart';
import '../../widgets/swipe_card.dart';
import '../../widgets/draggable_swipe_card.dart';

// Provider para lista de usuários
final potentialMatchesProvider = FutureProvider<List<UserModel>>((ref) async {
  final authState = ref.watch(authProvider);
  if (authState.user == null) return [];
  
  final swipeService = SwipeService();
  return await swipeService.getPotentialMatches(authState.user!.id);
});

class SwipeScreen extends ConsumerStatefulWidget {
  const SwipeScreen({super.key});

  @override
  ConsumerState<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends ConsumerState<SwipeScreen> {
  final SwipeService _swipeService = SwipeService();
  final DraggableSwipeCardController _cardController = DraggableSwipeCardController();
  
  int _currentIndex = 0; // Índice do card atual
  bool _isProcessing = false;

  Future<void> _handleSwipe(UserModel user, String direction) async {
    if (_isProcessing) return;
    
    setState(() => _isProcessing = true);

    final currentUser = ref.read(authProvider).user;
    if (currentUser == null) return;

    // Record swipe
    await _swipeService.recordSwipe(
      swiperId: currentUser.id,
      swipedId: user.id,
      direction: direction,
    );

    // Check if it's a match (only for likes and super likes)
    if (direction == 'like' || direction == 'super_like') {
      final isMatch = await _swipeService.checkMatch(currentUser.id, user.id);
      
      if (isMatch && mounted) {
        _showMatchDialog(user);
      }
    }

    setState(() => _isProcessing = false);
  }
  
  /// Handler para swipe do card arrastável
  void _onCardSwiped(SwipeDirection direction, List<UserModel> users) {
    if (_currentIndex >= users.length) return;
    
    final user = users[_currentIndex];
    String swipeType;
    
    switch (direction) {
      case SwipeDirection.left:
        swipeType = 'nope';
        break;
      case SwipeDirection.right:
        swipeType = 'like';
        break;
      case SwipeDirection.up:
        swipeType = 'super_like';
        break;
      case SwipeDirection.none:
        return;
    }
    
    // Incrementar índice para próximo card
    setState(() {
      _currentIndex++;
    });
    
    // Processar swipe
    _handleSwipe(user, swipeType);
  }

  void _showMatchDialog(UserModel matchedUser) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: AppColors.matchGradient,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '💥',
                style: TextStyle(fontSize: 60),
              ),
              const SizedBox(height: 16),
              const Text(
                'É um Match!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Você e ${matchedUser.name} deram match!',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white, width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Continuar',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        context.go('/home/chat');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Enviar mensagem',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final potentialMatches = ref.watch(potentialMatchesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('BrasilMatch'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/home/settings'),
          ),
        ],
      ),
      body: potentialMatches.when(
        data: (users) {
          if (users.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.explore_off_outlined,
                    size: 80,
                    color: AppColors.textHint.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Sem mais perfis no momento',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Volte mais tarde para ver novos perfis',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Cards Stack
              Expanded(
                child: Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.height * 0.65,
                    child: _currentIndex >= users.length
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  size: 80,
                                  color: AppColors.success.withOpacity(0.5),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Você viu todos!',
                                  style: Theme.of(context).textTheme.headlineSmall,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Volte mais tarde para novos perfis',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                ),
                              ],
                            ),
                          )
                        : Stack(
                            children: [
                              // Card 2 atrás (background)
                              if (_currentIndex + 2 < users.length)
                                Positioned.fill(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 16),
                                    child: Opacity(
                                      opacity: 0.3,
                                      child: SwipeCard(user: users[_currentIndex + 2]),
                                    ),
                                  ),
                                ),
                              
                              // Card 1 atrás
                              if (_currentIndex + 1 < users.length)
                                Positioned.fill(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Opacity(
                                      opacity: 0.6,
                                      child: SwipeCard(user: users[_currentIndex + 1]),
                                    ),
                                  ),
                                ),
                              
                              // Card atual (draggable)
                              Positioned.fill(
                                child: DraggableSwipeCard(
                                  controller: _cardController,
                                  onSwipe: (direction) => _onCardSwiped(direction, users),
                                  child: SwipeCard(user: users[_currentIndex]),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              
              // Action Buttons
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Nope Button
                    _ActionButton(
                      icon: Icons.close,
                      color: AppColors.nope,
                      size: 60,
                      onPressed: _currentIndex < users.length
                          ? () => _cardController.nope()
                          : null,
                    ),
                    
                    // Super Like Button
                    _ActionButton(
                      icon: Icons.star,
                      color: AppColors.superLike,
                      size: 50,
                      onPressed: _currentIndex < users.length
                          ? () => _cardController.superLike()
                          : null,
                    ),
                    
                    // Like Button
                    _ActionButton(
                      icon: Icons.favorite,
                      color: AppColors.like,
                      size: 70,
                      onPressed: _currentIndex < users.length
                          ? () => _cardController.like()
                          : null,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Text('Erro ao carregar perfis: $error'),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final VoidCallback? onPressed; // Agora nullable

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.size,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Icon(
            icon,
            color: isEnabled ? color : AppColors.textHint,
            size: size * 0.5,
          ),
        ),
      ),
    );
  }
}
