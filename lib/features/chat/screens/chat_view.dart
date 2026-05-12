import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:provider/provider.dart';

import '../../../theme/app_theme.dart';
import '../../../widgets/app_logo.dart';
import '../../transactions/providers/transactions_provider.dart';
import '../../goals/providers/goals_provider.dart';
import '../../transactions/data/category_catalog.dart';
import '../models/chat_message.dart';
import '../providers/chat_provider.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  bool _didInit = false;

  static const _suggestions = [
    'How can I reduce my expenses?',
    'Am I saving enough?',
    'Tips to reach my goals faster',
    'How to build an emergency fund?',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didInit) {
      _didInit = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        final chatProvider = context.read<ChatProvider>();
        final financialContext = _buildFinancialContext(context);
        chatProvider.initialize(financialContext: financialContext);
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _buildFinancialContext(BuildContext context) {
    final transactions = context.read<TransactionsProvider>();
    final goals = context.read<GoalsProvider>();

    final categorySpending = transactions.categorySpending;
    final categories = CategoryCatalog.categories;
    final categoryText = categorySpending.entries
        .map((e) {
          final cat = categories.firstWhere(
            (c) => c.id == e.key,
            orElse: () => categories.last,
          );
          return '${cat.name}: ₹${e.value.toStringAsFixed(0)}';
        })
        .join(', ');

    final savingsRate = transactions.monthlyIncome > 0
        ? ((transactions.monthlyIncome - transactions.monthlyExpenses) /
                  transactions.monthlyIncome *
                  100)
              .toStringAsFixed(1)
        : '0.0';

    return 'Here is my current financial summary for this month:\n'
        '- Income: ₹${transactions.monthlyIncome.toStringAsFixed(0)}\n'
        '- Expenses: ₹${transactions.monthlyExpenses.toStringAsFixed(0)}\n'
        '- Savings rate: $savingsRate%\n'
        '- Active savings goals: ${goals.goals.length}\n'
        '- Total goal target: ₹${goals.totalTarget.toStringAsFixed(0)}\n'
        '- Total saved toward goals: ₹${goals.totalSaved.toStringAsFixed(0)}\n'
        '${categoryText.isNotEmpty ? '- Spending by category: $categoryText' : ''}';
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    _textController.clear();
    final chatProvider = context.read<ChatProvider>();
    final financialContext = _buildFinancialContext(context);
    chatProvider.sendMessage(text, financialContext: financialContext);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.card,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.foreground),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const AppLogo(
                size: 36,
                padding: 6,
                backgroundColor: Colors.transparent,
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PennyWise AI',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.foreground,
                  ),
                ),
                Text(
                  'Financial Assistant',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.mutedForeground,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppTheme.border),
        ),
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, _) {
          if (chatProvider.isInitializing) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppTheme.primary),
                  SizedBox(height: 16),
                  Text(
                    'Starting AI assistant...',
                    style: TextStyle(color: AppTheme.mutedForeground),
                  ),
                ],
              ),
            );
          }

          if (chatProvider.errorMessage != null && !chatProvider.isReady) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.expense.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        color: AppTheme.expense,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'AI Not Configured',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      chatProvider.errorMessage!,
                      style: const TextStyle(color: AppTheme.mutedForeground),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.secondary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'In Firestore, create:\ncollection: app_config\ndocument: gemini\nfields: api_key, model',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          color: AppTheme.foreground,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _scrollToBottom(),
          );

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  itemCount: chatProvider.messages.length,
                  itemBuilder: (context, index) {
                    final msg = chatProvider.messages[index];
                    return _MessageBubble(message: msg);
                  },
                ),
              ),
              // Quick suggestions (only when no user messages yet)
              if (chatProvider.messages.length <= 1)
                _QuickSuggestions(
                  suggestions: _suggestions,
                  onTap: _sendMessage,
                ),
              _ChatInput(
                controller: _textController,
                isLoading: chatProvider.isLoading,
                onSend: _sendMessage,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    if (message.isLoading) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12, right: 60),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(18),
            ),
            border: Border.all(color: AppTheme.border),
          ),
          child: const _TypingIndicator(),
        ),
      );
    }

    final isUser = message.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          bottom: 12,
          left: isUser ? 60 : 0,
          right: isUser ? 0 : 60,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: isUser ? AppTheme.primaryGradient : null,
          color: isUser ? null : AppTheme.card,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 18),
          ),
          border: isUser ? null : Border.all(color: AppTheme.border),
          boxShadow: isUser
              ? [
                  const BoxShadow(
                    color: Color(0x2025B8A3),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: isUser
            ? Text(
                message.text,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  height: 1.5,
                ),
              )
            : _MarkdownMessage(
                data: message.text,
                textColor: AppTheme.foreground,
                mutedColor: AppTheme.mutedForeground,
              ),
      ),
    );
  }
}

class _MarkdownMessage extends StatelessWidget {
  const _MarkdownMessage({
    required this.data,
    required this.textColor,
    required this.mutedColor,
  });

  final String data;
  final Color textColor;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    final document = md.Document(extensionSet: md.ExtensionSet.gitHubFlavored);
    final nodes = document.parse(data);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < nodes.length; index++) ...[
          _MarkdownBlock(
            node: nodes[index],
            textColor: textColor,
            mutedColor: mutedColor,
          ),
          if (index < nodes.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _MarkdownBlock extends StatelessWidget {
  const _MarkdownBlock({
    required this.node,
    required this.textColor,
    required this.mutedColor,
  });

  final md.Node node;
  final Color textColor;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    final baseStyle = TextStyle(fontSize: 14, color: textColor, height: 1.5);

    if (node is md.Text) {
      return RichText(
        text: TextSpan(style: baseStyle, text: node.textContent),
      );
    }

    if (node is! md.Element) {
      return const SizedBox.shrink();
    }

    final element = node as md.Element;

    switch (element.tag) {
      case 'p':
        return RichText(
          text: TextSpan(
            style: baseStyle,
            children: _buildInlineSpans(
              element.children,
              baseStyle,
              mutedColor,
            ),
          ),
        );
      case 'h1':
      case 'h2':
      case 'h3':
        return RichText(
          text: TextSpan(
            style: baseStyle.copyWith(
              fontSize: element.tag == 'h1'
                  ? 20
                  : element.tag == 'h2'
                  ? 18
                  : 16,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
            children: _buildInlineSpans(
              element.children,
              baseStyle.copyWith(fontWeight: FontWeight.w700),
              mutedColor,
            ),
          ),
        );
      case 'blockquote':
        return Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: BoxDecoration(
            color: AppTheme.secondary,
            borderRadius: BorderRadius.circular(12),
            border: Border(left: BorderSide(color: AppTheme.primary, width: 3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (
                var index = 0;
                index < (element.children?.length ?? 0);
                index++
              ) ...[
                _MarkdownBlock(
                  node: element.children![index],
                  textColor: textColor,
                  mutedColor: mutedColor,
                ),
                if (index < (element.children!.length - 1))
                  const SizedBox(height: 6),
              ],
            ],
          ),
        );
      case 'pre':
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F6F6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.border),
          ),
          child: Text(
            element.textContent.trimRight(),
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 13,
              color: textColor,
              height: 1.45,
            ),
          ),
        );
      case 'ul':
      case 'ol':
        final items = element.children ?? const <md.Node>[];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var index = 0; index < items.length; index++) ...[
              _MarkdownListItem(
                node: items[index],
                marker: element.tag == 'ol' ? '${index + 1}.' : '•',
                textColor: textColor,
                mutedColor: mutedColor,
              ),
              if (index < items.length - 1) const SizedBox(height: 6),
            ],
          ],
        );
      case 'hr':
        return Divider(height: 1, color: AppTheme.border);
      default:
        return RichText(
          text: TextSpan(
            style: baseStyle,
            children: _buildInlineSpans(
              element.children,
              baseStyle,
              mutedColor,
            ),
          ),
        );
    }
  }
}

class _MarkdownListItem extends StatelessWidget {
  const _MarkdownListItem({
    required this.node,
    required this.marker,
    required this.textColor,
    required this.mutedColor,
  });

  final md.Node node;
  final String marker;
  final Color textColor;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    final children = node is md.Element ? (node as md.Element).children : null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 20,
          child: Text(
            marker,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var index = 0; index < (children?.length ?? 0); index++) ...[
                _MarkdownBlock(
                  node: children![index],
                  textColor: textColor,
                  mutedColor: mutedColor,
                ),
                if (index < (children.length - 1)) const SizedBox(height: 6),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

List<InlineSpan> _buildInlineSpans(
  List<md.Node>? nodes,
  TextStyle style,
  Color mutedColor,
) {
  if (nodes == null || nodes.isEmpty) {
    return const [];
  }

  final spans = <InlineSpan>[];

  for (final node in nodes) {
    if (node is md.Text) {
      spans.add(TextSpan(text: node.text));
      continue;
    }

    if (node is! md.Element) {
      continue;
    }

    switch (node.tag) {
      case 'strong':
        spans.add(
          TextSpan(
            style: style.copyWith(fontWeight: FontWeight.w700),
            children: _buildInlineSpans(node.children, style, mutedColor),
          ),
        );
      case 'em':
        spans.add(
          TextSpan(
            style: style.copyWith(fontStyle: FontStyle.italic),
            children: _buildInlineSpans(node.children, style, mutedColor),
          ),
        );
      case 'del':
        spans.add(
          TextSpan(
            style: style.copyWith(decoration: TextDecoration.lineThrough),
            children: _buildInlineSpans(node.children, style, mutedColor),
          ),
        );
      case 'code':
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F6F6),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppTheme.border),
              ),
              child: Text(
                node.textContent,
                style: style.copyWith(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  height: 1.2,
                ),
              ),
            ),
          ),
        );
      case 'a':
        spans.add(
          TextSpan(
            text: node.textContent,
            style: style.copyWith(
              color: AppTheme.primary,
              decoration: TextDecoration.underline,
              decorationColor: AppTheme.primary,
            ),
          ),
        );
      case 'br':
        spans.add(const TextSpan(text: '\n'));
      default:
        spans.addAll(_buildInlineSpans(node.children, style, mutedColor));
    }
  }

  return spans;
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final delay = index / 3;
            final value = ((_controller.value - delay) % 1.0).clamp(0.0, 1.0);
            final opacity = value < 0.5 ? value * 2 : (1.0 - value) * 2;
            return Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.3 + opacity * 0.7),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }
}

class _QuickSuggestions extends StatelessWidget {
  const _QuickSuggestions({required this.suggestions, required this.onTap});

  final List<String> suggestions;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      margin: const EdgeInsets.only(bottom: 4),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: suggestions.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => onTap(suggestions[index]),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.secondary,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                suggestions[index],
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ChatInput extends StatelessWidget {
  const _ChatInput({
    required this.controller,
    required this.isLoading,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool isLoading;
  final ValueChanged<String> onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      decoration: BoxDecoration(
        color: AppTheme.card,
        border: const Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                enabled: !isLoading,
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: onSend,
                decoration: InputDecoration(
                  hintText: 'Ask about your finances...',
                  hintStyle: const TextStyle(
                    color: AppTheme.mutedForeground,
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: AppTheme.muted,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: isLoading ? null : () => onSend(controller.text),
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: isLoading ? null : AppTheme.primaryGradient,
                  color: isLoading ? AppTheme.muted : null,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.send_rounded,
                  color: isLoading ? AppTheme.mutedForeground : Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
