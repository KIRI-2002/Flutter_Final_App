
import 'package:flutter/material.dart';
import 'package:y3s1_final/services/commerce_api.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;

  const _ChatMessage({
    required this.text,
    required this.isUser,
    required this.time,
  });
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController =
      TextEditingController();

  final ScrollController _scrollController =
      ScrollController();

  final List<_ChatMessage> _messages = [];

  static const Color purple = Color(0xFF8B5CF6);

  bool _isTyping = false;
  bool _isLoadingHistory = true;
  bool _isClearingHistory = false;

  bool get _busy =>
      _isTyping || _isLoadingHistory || _isClearingHistory;

  final List<String> _suggestions = [
    'Do you have iPhone 18?',
    'Show me laptops under \$500',
    'Show my orders',
    'What products do you have?',
  ];

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
    _loadChatHistory();
  }

  void _addWelcomeMessage() {
    _messages.add(
      _ChatMessage(
        text:
            'Hello! 👋 Welcome to SmartCommerce.\n\n'
            'I am your shopping assistant. '
            'Ask me about products, prices, stock, '
            'recommendations, orders, or delivery.\n\n'
            'How can I help you today?',
        isUser: false,
        time: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // =====================================================
  // SCROLL TO BOTTOM
  // =====================================================

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  // =====================================================
  // LOAD CHAT HISTORY
  // =====================================================

  Future<void> _loadChatHistory() async {
    try {
      final history = await CommerceApi.instance.chatHistory();

      if (!mounted) return;

      setState(() {
        if (history.isNotEmpty) {
          _messages.clear();

          for (final item in history) {
            final role = item['role']?.toString() ?? '';
            final content = item['content']?.toString() ?? '';

            if (content.trim().isEmpty) continue;

            _messages.add(
              _ChatMessage(
                text: content,
                isUser: role == 'user',
                time: DateTime.tryParse(
                      item['created_at']?.toString() ?? '',
                    ) ??
                    DateTime.now(),
              ),
            );
          }

          if (_messages.isEmpty) {
            _addWelcomeMessage();
          }
        }

        _isLoadingHistory = false;
      });

      _scrollToBottom();
    } catch (error) {
      debugPrint('Chat history error: $error');

      if (!mounted) return;

      setState(() {
        _isLoadingHistory = false;
      });
    }
  }

  // =====================================================
  // CHATBOT RESPONSE
  // =====================================================

  Future<String> _getChatbotResponse(String message) async {
    final String reply =
        await CommerceApi.instance.sendConversationMessage(message);

    if (reply.trim().isEmpty) {
      throw Exception('Chatbot returned an empty response.');
    }

    return reply;
  }

  // =====================================================
  // SEND MESSAGE
  // =====================================================

  Future<void> _sendMessage([String? suggestedMessage]) async {
    if (_busy) return;

    final String message =
        (suggestedMessage ?? _messageController.text).trim();

    if (message.isEmpty) return;

    _messageController.clear();

    FocusManager.instance.primaryFocus?.unfocus();

    setState(() {
      _messages.add(
        _ChatMessage(
          text: message,
          isUser: true,
          time: DateTime.now(),
        ),
      );

      _isTyping = true;
    });

    _scrollToBottom();

    try {
      final response = await _getChatbotResponse(message);

      if (!mounted) return;

      setState(() {
        _messages.add(
          _ChatMessage(
            text: response,
            isUser: false,
            time: DateTime.now(),
          ),
        );

        _isTyping = false;
      });
    } catch (error) {
      debugPrint('Chatbot error: $error');

      if (!mounted) return;

      setState(() {
        _messages.add(
          _ChatMessage(
            text:
                'Sorry, I could not connect to '
                'SmartCommerce right now.\n\n'
                'Please check your Laravel server '
                'and try again.',
            isUser: false,
            time: DateTime.now(),
          ),
        );

        _isTyping = false;
      });
    }

    _scrollToBottom();
  }

  // =====================================================
  // CLEAR CONVERSATION
  // =====================================================

  Future<void> _clearConversation() async {
    if (_busy) return;

    setState(() {
      _isClearingHistory = true;
    });

    try {
      await CommerceApi.instance.clearChatHistory();

      if (!mounted) return;

      setState(() {
        _messages.clear();
        _addWelcomeMessage();
        _isClearingHistory = false;
      });

      _scrollToBottom();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Conversation cleared successfully.'),
        ),
      );
    } catch (error) {
      debugPrint('Clear chat error: $error');

      if (!mounted) return;

      setState(() {
        _isClearingHistory = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to clear conversation. Please try again.',
          ),
        ),
      );
    }
  }

  // =====================================================
  // FORMAT TIME
  // =====================================================

  String _formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }

  // =====================================================
  // BOT AVATAR
  // =====================================================

  Widget _botAvatar(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: purple,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.smart_toy_rounded,
        color: Colors.white,
        size: 21,
      ),
    );
  }

  // =====================================================
  // MESSAGE BUBBLE
  // =====================================================

  Widget _buildMessage(_ChatMessage message) {
    final isUser = message.isUser;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 6,
      ),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            _botAvatar(context),
            const SizedBox(width: 8),
          ],

          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.sizeOf(context).width * 0.76,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 13,
              ),
              decoration: BoxDecoration(
                color: isUser
                    ? purple
                    : colors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 5),
                  bottomRight: Radius.circular(isUser ? 5 : 18),
                ),
                border: isUser
                    ? null
                    : Border.all(
                        color: colors.outlineVariant,
                        width: 0.6,
                      ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: dark ? 0.12 : 0.04,
                    ),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: SelectableText(
                      message.text,
                      style: TextStyle(
                        color: isUser
                            ? Colors.white
                            : colors.onSurface,
                        fontSize: 14,
                        height: 1.55,
                      ),
                    ),
                  ),

                  const SizedBox(height: 7),

                  Text(
                    _formatTime(message.time),
                    style: TextStyle(
                      color: isUser
                          ? Colors.white70
                          : colors.onSurfaceVariant,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.person_rounded,
                color: colors.primary,
                size: 22,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // =====================================================
  // TYPING INDICATOR
  // =====================================================

  Widget _buildTypingIndicator() {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 8,
      ),
      child: Row(
        children: [
          _botAvatar(context),
          const SizedBox(width: 8),

          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 13,
              ),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: colors.outlineVariant,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: purple,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Flexible(
                    child: Text(
                      'SmartCommerce is typing...',
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.onSurfaceVariant,
                      ),
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

  // =====================================================
  // SUGGESTED QUESTIONS
  // =====================================================

  Widget _buildSuggestions() {
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 5,
        ),
        itemCount: _suggestions.length,
        separatorBuilder: (_, index) =>
            const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final suggestion = _suggestions[index];

          return ActionChip(
            onPressed: _busy
                ? null
                : () => _sendMessage(suggestion),
            backgroundColor: colors.surface,
            disabledColor: colors.surfaceContainerHighest,
            side: BorderSide(
              color: colors.outlineVariant,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            label: Text(
              suggestion,
              style: TextStyle(
                color: colors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        },
      ),
    );
  }

  // =====================================================
  // MESSAGE INPUT AREA
  // =====================================================

  Widget _buildInputArea() {
    final colors = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      bottom: true,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          14,
          10,
          14,
          10,
        ),
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border(
            top: BorderSide(
              color: colors.outlineVariant,
              width: 0.6,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                enabled: !_busy,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.send,
                minLines: 1,
                maxLines: 4,
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  hintText: 'Ask me anything...',
                  hintStyle: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: colors.primary,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: colors.surfaceContainerHighest,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 13,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(26),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(26),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(26),
                    borderSide: BorderSide(
                      color: colors.primary,
                      width: 1.2,
                    ),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(26),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 10),

            SizedBox(
              width: 48,
              height: 48,
              child: FilledButton(
                onPressed: _busy ? null : () => _sendMessage(),
                style: FilledButton.styleFrom(
                  backgroundColor: purple,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      colors.surfaceContainerHighest,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Icon(
                  Icons.send_rounded,
                  size: 21,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // MAIN SCREEN
  // =====================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: theme.scaffoldBackgroundColor,

      // =====================================================
      // APP BAR
      // =====================================================

      appBar: AppBar(
        elevation: 0,
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: colors.primaryContainer,
              child: Icon(
                Icons.smart_toy_rounded,
                color: colors.onPrimaryContainer,
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SmartCommerce AI',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colors.onSurface,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    'Your shopping assistant',
                    style: TextStyle(
                      fontSize: 11,
                      color: colors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Clear conversation',
            onPressed: _busy ? null : _clearConversation,
            icon: Icon(
              Icons.refresh_rounded,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(width: 5),
        ],
      ),

      // =====================================================
      // BODY
      // =====================================================

      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: dark
                ? [
                    const Color(0xFF171522),
                    const Color(0xFF201A32),
                    const Color(0xFF171C29),
                  ]
                : [
                    const Color(0xFFF8F5FF),
                    const Color(0xFFF0ECFF),
                    const Color(0xFFEDF6FF),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: Column(
          children: [
            // MESSAGE LIST
            Expanded(
              child: _isLoadingHistory
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: purple,
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.only(
                        top: 12,
                        bottom: 12,
                      ),
                      itemCount:
                          _messages.length + (_isTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _messages.length) {
                          return _buildTypingIndicator();
                        }

                        return _buildMessage(_messages[index]);
                      },
                    ),
            ),

            // SUGGESTED QUESTIONS
            _buildSuggestions(),

            // INPUT AREA
            _buildInputArea(),
          ],
        ),
      ),
    );
  }
}
