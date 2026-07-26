import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/models/chat_message.dart';
import '../../../core/design_system/widgets/chat_bubble.dart';
import '../providers/chat_provider.dart';
import '../widgets/chat_welcome.dart';
import '../widgets/suggestion_chips.dart';
import '../widgets/chat_input_bar.dart';

class ChatPage extends ConsumerStatefulWidget {
  final String sessionId;

  const ChatPage({super.key, required this.sessionId});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    ref.read(messagesProvider.notifier).sendMessage(text);
    _controller.clear();
    setState(() {});
    Future.microtask(() => _scrollToBottom());
  }

  void _onSuggestionTap(String suggestion) {
    _controller.text = suggestion;
    _sendMessage();
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

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(messagesProvider);

    ref.listen<List<ChatMessage>>(messagesProvider, (_, next) {
      if (next.length > (ref.read(messagesProvider).length - 1)) {
        Future.microtask(() => _scrollToBottom());
      }
    });

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: AppSpacing.stackSm),
            if (messages.isEmpty)
              const Expanded(child: ChatWelcome())
            else
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.containerPadding,
                    vertical: AppSpacing.stackSm,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (_, index) {
                    final msg = messages[index];
                    final isLast = index == messages.length - 1;
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: isLast ? AppSpacing.stackMd : AppSpacing.stackSm,
                      ),
                      child: msg.role == 'assistant'
                          ? ChatBubbleAi(message: msg.content)
                          : ChatBubbleUser(message: msg.content),
                    );
                  },
                ),
              ),
            if (messages.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.stackMd),
                child: SuggestionChips(
                  suggestions: [
                    'Suggest a dinner',
                    "What's in my fridge?",
                    'Meal prep tips',
                  ],
                  onTap: _onSuggestionTap,
                ),
              ),
            ChatInputBar(
              controller: _controller,
              onSend: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.containerPadding,
        vertical: AppSpacing.stackMd,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.pets, size: 24, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.stackSm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Poco AI',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
              ),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Ready to help',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
