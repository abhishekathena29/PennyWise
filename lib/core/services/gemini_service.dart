import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  GeminiService(this._firestore);

  final FirebaseFirestore _firestore;

  GenerativeModel? _model;
  bool _initialized = false;
  bool _initializing = false;
  String? _initError;

  bool get isInitialized => _initialized;
  String? get initError => _initError;

  /// Fetches API key and model name from Firestore `app_config/gemini`
  /// and initializes the GenerativeModel. Safe to call multiple times.
  Future<void> ensureInitialized() async {
    if (_initialized || _initializing) return;
    _initializing = true;
    try {
      final doc = await _firestore
          .collection('app_config')
          .doc('gemini')
          .get();

      if (!doc.exists) {
        _initError =
            'Gemini config not found. Add api_key and model fields to Firestore at app_config/gemini.';
        return;
      }

      final data = doc.data()!;
      final apiKey = data['api_key'] as String?;
      final modelName = (data['model'] as String?) ?? 'gemini-1.5-flash';

      if (apiKey == null || apiKey.isEmpty) {
        _initError = 'Gemini API key is missing in Firestore at app_config/gemini.';
        return;
      }

      _model = GenerativeModel(
        model: modelName,
        apiKey: apiKey,
        systemInstruction: Content.system(
          'You are PennyWise AI, a friendly and knowledgeable personal finance assistant. '
          'You help users understand their finances, manage expenses, plan savings, and '
          'achieve their financial goals. Always respond concisely and practically. '
          'Format all currency values in Indian Rupees (₹). '
          'Be encouraging and supportive. Keep responses under 200 words unless more detail is truly needed.',
        ),
      );
      _initialized = true;
      _initError = null;
    } catch (e) {
      _initError = 'Failed to initialize AI assistant: $e';
    } finally {
      _initializing = false;
    }
  }

  /// Sends a chat message with optional prior conversation history.
  Future<String> sendChatMessage(
    String userMessage, {
    String? financialContext,
    List<({String role, String text})> history = const [],
  }) async {
    if (_model == null) {
      throw Exception(_initError ?? 'Gemini AI is not initialized.');
    }

    final chatHistory = <Content>[];

    // Prepend financial context as the first exchange
    if (financialContext != null && financialContext.isNotEmpty) {
      chatHistory.add(Content.text(financialContext));
      chatHistory.add(
        Content.model([
          TextPart(
            'Got it! I have your financial summary. How can I help you today?',
          ),
        ]),
      );
    }

    // Add prior conversation messages
    for (final msg in history) {
      if (msg.role == 'user') {
        chatHistory.add(Content.text(msg.text));
      } else {
        chatHistory.add(Content.model([TextPart(msg.text)]));
      }
    }

    final chat = _model!.startChat(history: chatHistory);
    final response = await chat.sendMessage(Content.text(userMessage));
    return response.text ?? 'Sorry, I could not generate a response.';
  }

  /// Generates AI insights for the analytics page.
  Future<String> analyzeTransactions({
    required double monthlyIncome,
    required double monthlyExpenses,
    required Map<String, double> categorySpending,
  }) async {
    if (_model == null) {
      throw Exception(_initError ?? 'Gemini AI is not initialized.');
    }

    final savingsRate = monthlyIncome > 0
        ? ((monthlyIncome - monthlyExpenses) / monthlyIncome * 100)
            .toStringAsFixed(1)
        : '0.0';

    final categoryText = categorySpending.entries
        .map((e) => '${e.key}: ₹${e.value.toStringAsFixed(0)}')
        .join(', ');

    final prompt =
        'Analyze this month\'s financial data and give 3 short, actionable insights:\n\n'
        '- Monthly Income: ₹${monthlyIncome.toStringAsFixed(0)}\n'
        '- Monthly Expenses: ₹${monthlyExpenses.toStringAsFixed(0)}\n'
        '- Savings Rate: $savingsRate%\n'
        '- Spending by category: $categoryText\n\n'
        'Format as a numbered list. Each insight should be 1-2 sentences, specific and practical.';

    final response = await _model!.generateContent([Content.text(prompt)]);
    return response.text ?? 'Unable to generate insights.';
  }

  /// Generates AI recommendations for savings goals tracking.
  Future<String> analyzeGoals({
    required List<Map<String, dynamic>> goals,
    required double monthlyIncome,
    required double monthlyExpenses,
  }) async {
    if (_model == null) {
      throw Exception(_initError ?? 'Gemini AI is not initialized.');
    }

    final availableForSavings = monthlyIncome - monthlyExpenses;
    final goalsText = goals.isEmpty
        ? 'No goals set yet.'
        : goals
            .map(
              (g) =>
                  '- ${g['name']}: Target ₹${g['target']}, Saved ₹${g['current']}, '
                  'Deadline: ${g['deadline']}, Priority: ${g['priority']}',
            )
            .join('\n');

    final prompt =
        'Review these savings goals and give 2-3 smart, actionable recommendations:\n\n'
        'Financial snapshot:\n'
        '- Monthly income: ₹${monthlyIncome.toStringAsFixed(0)}\n'
        '- Monthly expenses: ₹${monthlyExpenses.toStringAsFixed(0)}\n'
        '- Available for savings: ₹${availableForSavings.toStringAsFixed(0)}\n\n'
        'Goals:\n$goalsText\n\n'
        'Give specific advice on prioritization, contribution amounts, or strategies to reach these goals faster. '
        'Format as a numbered list with 1-2 sentences per point.';

    final response = await _model!.generateContent([Content.text(prompt)]);
    return response.text ?? 'Unable to analyze goals.';
  }
}
