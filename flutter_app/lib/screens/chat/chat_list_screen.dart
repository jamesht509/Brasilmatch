import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../models/match_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/supabase/chat_service.dart';
import '../../services/supabase/match_service.dart';
import 'package:intl/intl.dart';

// Provider para lista de chats
final chatListProvider = FutureProvider<List<MatchModel>>((ref) async {
  final authState = ref.watch(authProvider);
  if (authState.user == null) return [];
  
  final chatService = ChatService();
  return await chatService.getChatList(authState.user!.id);
});

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatList = ref.watch(chatListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mensagens'),
      ),
      body: chatList.when(
        data: (matches) {
          if (matches.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 80,
                    color: AppColors.textHint.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhuma conversa ainda',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Seus matches aparecem aqui',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            itemCount: matches.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              return _ChatListItem(match: matches[index]);
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Text('Erro ao carregar conversas: $error'),
        ),
      ),
    );
  }
}

class _ChatListItem extends ConsumerStatefulWidget {
  final MatchModel match;

  const _ChatListItem({required this.match});

  @override
  ConsumerState<_ChatListItem> createState() => _ChatListItemState();
}

class _ChatListItemState extends ConsumerState<_ChatListItem> {
  UserModel? _otherUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOtherUser();
  }

  Future<void> _loadOtherUser() async {
    final currentUser = ref.read(authProvider).user;
    if (currentUser == null) return;

    final otherId = widget.match.getOtherUserId(currentUser.id);
    final matchService = MatchService();
    final user = await matchService.getUser(otherId);

    if (mounted) {
      setState(() {
        _otherUser = user;
        _isLoading = false;
      });
    }
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return DateFormat.Hm().format(dateTime);
    } else if (difference.inDays == 1) {
      return 'Ontem';
    } else if (difference.inDays < 7) {
      return DateFormat.E('pt_BR').format(dateTime);
    } else {
      return DateFormat.yMd('pt_BR').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _otherUser == null) {
      return const ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.surfaceVariant,
        ),
        title: Text('Carregando...'),
      );
    }

    return ListTile(
      onTap: () {
        context.push('/home/chat/${widget.match.id}');
      },
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundImage: _otherUser!.avatarUrl != null
                ? CachedNetworkImageProvider(_otherUser!.avatarUrl!)
                : null,
            backgroundColor: AppColors.surfaceVariant,
            child: _otherUser!.avatarUrl == null
                ? const Icon(Icons.person)
                : null,
          ),
          if (widget.match.unreadCount != null && widget.match.unreadCount! > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
                child: Text(
                  '${widget.match.unreadCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              _otherUser!.name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (_otherUser!.isVerified)
            const Icon(
              Icons.verified,
              size: 16,
              color: AppColors.primary,
            ),
        ],
      ),
      subtitle: Text(
        widget.match.lastMessagePreview ?? 'Envie uma mensagem',
        style: TextStyle(
          color: widget.match.unreadCount != null && widget.match.unreadCount! > 0
              ? AppColors.textPrimary
              : AppColors.textSecondary,
          fontWeight: widget.match.unreadCount != null && widget.match.unreadCount! > 0
              ? FontWeight.w600
              : FontWeight.normal,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        _formatTime(widget.match.lastMessageAt),
        style: TextStyle(
          fontSize: 12,
          color: AppColors.textHint,
        ),
      ),
    );
  }
}
