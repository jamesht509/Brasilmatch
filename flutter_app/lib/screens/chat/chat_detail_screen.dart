import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../models/message_model.dart';
import '../../models/match_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/supabase/chat_service.dart';
import '../../services/supabase/match_service.dart';
import 'package:intl/intl.dart';

class ChatDetailScreen extends ConsumerStatefulWidget {
  final String matchId;

  const ChatDetailScreen({
    super.key,
    required this.matchId,
  });

  @override
  ConsumerState<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends ConsumerState<ChatDetailScreen> {
  final ChatService _chatService = ChatService();
  final MatchService _matchService = MatchService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  UserModel? _otherUser;
  MatchModel? _match;
  List<MessageModel> _messages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChatData();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadChatData() async {
    final currentUser = ref.read(authProvider).user;
    if (currentUser == null) return;

    // Load messages
    final messages = await _chatService.getMessages(widget.matchId);
    
    // Load match to get other user ID
    final matchResponse = await _matchService.getMatches(currentUser.id);
    final match = matchResponse.firstWhere(
      (m) => m.id == widget.matchId,
      orElse: () => matchResponse.first,
    );
    
    // Load other user profile
    final otherId = match.getOtherUserId(currentUser.id);
    final otherUser = await _matchService.getUser(otherId);

    if (mounted) {
      setState(() {
        _messages = messages;
        _match = match;
        _otherUser = otherUser;
        _isLoading = false;
      });
      
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    
    final currentUser = ref.read(authProvider).user;
    if (currentUser == null || _otherUser == null) return;

    final content = _messageController.text.trim();
    _messageController.clear();

    final message = await _chatService.sendMessage(
      matchId: widget.matchId,
      senderId: currentUser.id,
      receiverId: _otherUser!.id,
      content: content,
    );

    if (message != null && mounted) {
      setState(() {
        _messages.add(message);
      });
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_otherUser == null) {
      return const Scaffold(
        body: Center(
          child: Text('Erro ao carregar conversa'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: _otherUser!.avatarUrl != null
                  ? CachedNetworkImageProvider(_otherUser!.avatarUrl!)
                  : null,
              backgroundColor: AppColors.surfaceVariant,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          _otherUser!.name,
                          style: const TextStyle(fontSize: 16),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (_otherUser!.isVerified) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.verified,
                          size: 14,
                          color: AppColors.primary,
                        ),
                      ],
                    ],
                  ),
                  Text(
                    '${_otherUser!.city}, ${_otherUser!.state}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam_outlined),
            onPressed: () {
              // TODO: Start video call
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // TODO: Show options menu
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.waving_hand,
                          size: 60,
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Diga olá para ${_otherUser!.name}!',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final currentUser = ref.read(authProvider).user;
                      if (currentUser == null) return const SizedBox();
                      
                      return _MessageBubble(
                        message: _messages[index],
                        isSentByMe: _messages[index].isSentByMe(currentUser.id),
                      );
                    },
                  ),
          ),
          
          // Message Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Digite uma mensagem...',
                        filled: true,
                        fillColor: AppColors.background,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: AppColors.buttonShadow,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isSentByMe;

  const _MessageBubble({
    required this.message,
    required this.isSentByMe,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isSentByMe) const SizedBox(width: 50),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                gradient: isSentByMe ? AppColors.primaryGradient : null,
                color: isSentByMe ? null : AppColors.surfaceVariant,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isSentByMe ? 20 : 4),
                  bottomRight: Radius.circular(isSentByMe ? 4 : 20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: TextStyle(
                      color: isSentByMe ? Colors.white : AppColors.textPrimary,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat.Hm().format(message.sentAt),
                    style: TextStyle(
                      color: isSentByMe
                          ? Colors.white.withOpacity(0.7)
                          : AppColors.textHint,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isSentByMe) const SizedBox(width: 50),
        ],
      ),
    );
  }
}
