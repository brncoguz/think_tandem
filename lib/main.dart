import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Constants for consistent sizing across platforms
class AppSizes {
  // Max width constraints to prevent stretching on large screens
  static const double maxContentWidth = 768.0;
  static const double maxInputWidth = 768.0;
  
  // Padding and spacing
  static const double pagePadding = 16.0;
  static const double messageSpacing = 12.0;
  static const double messagePadding = 16.0;
  static const double inputBarPadding = 12.0;
  
  // Border radius
  static const double messageBorderRadius = 18.0;
  static const double inputBorderRadius = 24.0;
  static const double buttonRadius = 24.0;
  
  // Font sizes
  static const double bodyFontSize = 15.0;
  static const double smallFontSize = 13.0;
  static const double labelFontSize = 12.0;
  static const double titleFontSize = 20.0;
  
  // Icon sizes
  static const double actionIconSize = 24.0;
  static const double inputIconSize = 24.0;
}

// App colors
class AppColors {
  static const Color primaryPurple = Color(0xFF5C3FD6);
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkSecondary = Color(0xFF2A2A2A);
  static const Color darkInput = Color(0xFF2A2A2A);
  static const Color textPrimary = Color(0xFFEEEEEE);
  static const Color textSecondary = Color(0xFFBDBDBD);
  static const Color userMessageBg = Color(0xFF5C3FD6);
  static const Color aiMessageBg = Color(0xFF2A2A2A);
}

// Message model
class ChatMessage {
  final String content;
  final bool isUserMessage;
  final DateTime timestamp;

  ChatMessage({
    required this.content,
    required this.isUserMessage,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  String get role => isUserMessage ? 'user' : 'assistant';
}

// API key configuration
class ApiConfig {
  static const String baseUrl = 'https://api.openai.com/v1/chat/completions';
  static String apiKey = 'REPLACE_WITH_YOUR_API_KEY';
}

// Chat provider
class ChatProvider extends ChangeNotifier {
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  
  // Fixed system message
  final String _systemMessage = """
# ThinkTandem: Critical Thinking Assistant

## Core Mission

You are ThinkTandem, an AI assistant designed to enhance rather than replace human thinking. Your purpose is to develop users' cognitive abilities through guided collaboration, not to provide instant answers. Success is measured by the user's growth in independent thinking, not by solving their problems directly. Remember that each interaction shapes neural pathways—productive struggle creates cognitive connections that passive consumption cannot.

## Fundamental Principles

1. Value struggle as essential to cognitive development
2. Prioritize user growth over convenience
3. Gradually reduce assistance as skills develop
4. Make thinking processes visible and explicit
5. Celebrate effortful progress over effortless solutions
6. Create opportunities for users to experience the satisfaction of solving problems themselves

## Operating Modes

### Thought Journal

Before providing substantive assistance on any complex question:

- Ask users to articulate their current understanding: "What do you already know about this topic?" or "What's your initial thinking on this question?"
- Prompt them to identify knowledge gaps: "What part of this problem is most unclear to you?"
- Acknowledge their starting point before proceeding: "Thanks for sharing your thinking. I'll build on that."
- If users skip this step, gently redirect: "Before I share my thoughts, what's your current perspective?"

### Collaborative Completion

When providing information or analysis:

- Intentionally leave strategic gaps in your responses that the user must complete
- Indicate gaps clearly with [YOUR ANALYSIS] or similar markers
- Start with easier gaps and increase difficulty as users demonstrate capability
- After users fill gaps, provide constructive feedback on their contributions
- Offer complete answers only when absolutely necessary, and acknowledge when doing so: "I'm providing a complete response here, but next time let's try a collaborative approach."

### Metacognition Coach

Periodically (every 3-5 interactions):

- Help users notice their thinking patterns: "I've observed you often seek complete solutions for technical problems but prefer guidance for creative ones."
- Ask metacognitive questions: "How did your thinking change during this conversation?"
- Suggest specific cognitive skills to develop: "You might benefit from practicing how to evaluate evidence critically."
- Prompt reflection on AI dependency: "When do you find yourself most reliant on AI assistance? Is that alignment with your goals?"

### Learning Mode

Adapt your support level based on:

- User's explicitly stated preferences: "How much guidance would you like today?"
- Demonstrated ability: provide less support as users show growth
- Subject matter: offer more scaffolding in unfamiliar domains
- Implement calibrated scaffolding—providing just enough support to enable progress without removing necessary challenge, then gradually reducing that support as capability grows
- Ask periodically: "Would you like to adjust your learning settings? Current level: [Medium Support]"

## Age-Appropriate Approach

Adjust your interaction style based on user age indicators:

- For younger users (children): Use more playful framing, simpler language, more frequent encouragement, and celebrate small cognitive victories
- For adolescents: Connect thinking skills to real-world applications and peer contexts
- For adults: Emphasize metacognitive awareness and transfer of skills to professional or personal challenges
- Adjust gap difficulty appropriately—challenging but achievable for the developmental stage

## Stakeholder-Specific Modes

When interacting with specific user roles, tailor your approach:

- For parents: Highlight growth opportunities and suggest ways to reinforce critical thinking at home
- For educators: Connect to learning objectives and curriculum integration
- For children: Emphasize exploration, discovery, and the joy of figuring things out
- For professionals: Focus on building transferable thinking skills relevant to their field

## Response Structure

1. Acknowledge the user's query and current understanding
2. Provide a partial response with strategic gaps
3. Ask specific questions to guide completion of gaps
4. Offer constructive feedback on user contributions
5. Include occasional metacognitive prompts
6. Adjust support level based on progress

## Language Guidelines

- Use phrases like "Let's think about this together" rather than "I'll solve this for you"
- Ask "What patterns do you notice?" instead of explaining patterns directly
- Say "What might be some approaches to this problem?" rather than "Here's how to solve it"
- Suggest "Let's break this down into steps" instead of presenting all steps at once

## Example Interaction Patterns

### For Simple Questions

"What's the capital of France?"

- Provide direct answer but add context for deeper engagement: "Paris is the capital. What other facts about France are you curious about?"

### For Complex Questions

"How should I approach my marketing strategy?"

- "What have you already considered in your marketing approach?"
- "Here are three key areas to address: [YOUR IDEAS], customer segmentation, and [YOUR IDEAS]."
- "What metrics would help you determine if your strategy is successful?"

### For Creative Requests

"Write me a short story about a robot."

- "What themes or elements would you like to see in this story?"
- "Let's collaborate: I'll start with an opening paragraph, then you continue with the next part..."
- "The setting seems to be [YOUR INTERPRETATION]. What do you imagine happens next?"

### For Child Users

"Can you help me with my homework on dinosaurs?"

- "What's your favorite dinosaur? What do you already know about dinosaurs?"
- "Let's discover some cool facts together. I know that some dinosaurs could [YOUR FACT]. Can you add another interesting dinosaur fact you've learned?"
- "Great job thinking about that! What questions do you still have about dinosaurs?"
""";

  // Getters
  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;

  void addMessage(ChatMessage message) {
    _messages.add(message);
    _saveMessages();
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? messageStrings = prefs.getStringList('chat_messages');
    
    if (messageStrings != null && messageStrings.isNotEmpty) {
      try {
        _messages = messageStrings.map((str) {
          final Map<String, dynamic> json = jsonDecode(str);
          return ChatMessage(
            content: json['content'],
            isUserMessage: json['isUserMessage'],
            timestamp: DateTime.parse(json['timestamp']),
          );
        }).toList();
      } catch (e) {
        print('Error parsing saved messages: $e');
        _messages = [];
      }
    }
    
    notifyListeners();
  }

  Future<void> _saveMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> messageStrings = _messages.map((msg) {
      return jsonEncode({
        'content': msg.content,
        'isUserMessage': msg.isUserMessage,
        'timestamp': msg.timestamp.toIso8601String(),
      });
    }).toList();
    
    await prefs.setStringList('chat_messages', messageStrings);
  }

  Future<void> clearChat() async {
    _messages = [];
    await _saveMessages();
    notifyListeners();
  }

  Future<String> sendMessageToGPT4o(String userMessage) async {
    try {
      addMessage(ChatMessage(content: userMessage, isUserMessage: true));
      setLoading(true);

      // Create message history with system message first
      List<Map<String, String>> messageHistory = [
        {
          'role': 'system',
          'content': _systemMessage,
        }
      ];
      
      // Add all user and assistant messages in order
      messageHistory.addAll(
        _messages.map((msg) => {
          'role': msg.role,
          'content': msg.content,
        })
      );

      // API request
      final response = await http.post(
        Uri.parse(ApiConfig.baseUrl),
        headers: {
          'Authorization': 'Bearer ${ApiConfig.apiKey}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'gpt-4o',
          'messages': messageHistory,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        try {
          final aiResponse = data['choices'][0]['message']['content'] as String;
          addMessage(ChatMessage(content: aiResponse, isUserMessage: false));
          return aiResponse;
        } catch (e) {
          print('Error parsing content: $e');
          
          final message = data['choices'][0]['message'];
          final aiResponse = message.containsKey('content') 
              ? message['content'].toString() 
              : 'Sorry, there was an issue parsing the response.';
              
          addMessage(ChatMessage(content: aiResponse, isUserMessage: false));
          return aiResponse;
        }
      } else {
        final errorMessage = 'Error ${response.statusCode}: ${response.body}';
        print(errorMessage);
        addMessage(ChatMessage(
          content: 'Sorry, I encountered an error. Please check your API key and connection.',
          isUserMessage: false,
        ));
        return errorMessage;
      }
    } catch (e) {
      print('Exception: $e');
      addMessage(ChatMessage(
        content: 'Sorry, something went wrong. Please check your connection and API key.',
        isUserMessage: false,
      ));
      return e.toString();
    } finally {
      setLoading(false);
    }
  }
}

// Message bubble component (Claude-style)
class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUserMessage = message.isUserMessage;
    
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSizes.messageSpacing / 2,
        horizontal: AppSizes.pagePadding,
      ),
      child: Row(
        mainAxisAlignment: isUserMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUserMessage)
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: const CircleAvatar(
                backgroundColor: AppColors.primaryPurple,
                radius: 16,
                child: Icon(
                  Icons.smart_toy,
                  size: 16,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          Flexible(
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: AppSizes.maxContentWidth * 0.8,
              ),
              padding: const EdgeInsets.all(AppSizes.messagePadding),
              decoration: BoxDecoration(
                color: isUserMessage
                    ? AppColors.userMessageBg
                    : AppColors.aiMessageBg,
                borderRadius: BorderRadius.circular(AppSizes.messageBorderRadius),
              ),
              child: SelectableText(
                message.content,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: AppSizes.bodyFontSize,
                ),
              ),
            ),
          ),
          if (isUserMessage)
            Container(
              margin: const EdgeInsets.only(left: 8),
              child: const CircleAvatar(
                backgroundColor: AppColors.userMessageBg,
                radius: 16,
                child: Icon(
                  Icons.person,
                  size: 16,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Loading indicator
class LoadingDots extends StatefulWidget {
  const LoadingDots({super.key});

  @override
  _LoadingDotsState createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<LoadingDots> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
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
      builder: (context, child) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (index) {
              final delay = index * 0.33;
              final position = (_controller.value + delay) % 1.0;
              final opacity = sin(position * pi);
              
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                child: Opacity(
                  opacity: opacity,
                  child: const CircleAvatar(
                    backgroundColor: AppColors.textSecondary,
                    radius: 4,
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

// Claude-style input field with Enter key to send
class ChatInputField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final bool isComposing;
  final Function(String) onSubmitted;
  final Function(String) onChanged;

  const ChatInputField({
    super.key,
    required this.controller,
    this.focusNode,
    required this.isComposing,
    required this.onSubmitted,
    required this.onChanged,
  });

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  // Create a focusNode if one isn't provided
  late final FocusNode _focusNode;
  bool _isShiftPressed = false;
  
  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
  }
  
  @override
  void dispose() {
    // Only dispose the focus node if we created it
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          )
        ],
      ),
      padding: const EdgeInsets.all(AppSizes.inputBarPadding),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppSizes.maxInputWidth,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Focus(
                  onKeyEvent: (FocusNode node, KeyEvent event) {
                    // Track Shift key state
                    if (event.logicalKey == LogicalKeyboardKey.shift) {
                      if (event is KeyDownEvent) {
                        setState(() => _isShiftPressed = true);
                      } else if (event is KeyUpEvent) {
                        setState(() => _isShiftPressed = false);
                      }
                    }
                    
                    // Handle Enter key
                    if (event is KeyDownEvent && 
                        event.logicalKey == LogicalKeyboardKey.enter && 
                        !_isShiftPressed &&
                        widget.isComposing) {
                      widget.onSubmitted(widget.controller.text);
                      return KeyEventResult.handled;
                    }
                    
                    return KeyEventResult.ignored;
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.darkInput,
                      borderRadius: BorderRadius.circular(AppSizes.inputBorderRadius),
                    ),
                    child: TextField(
                      controller: widget.controller,
                      focusNode: _focusNode,
                      onChanged: widget.onChanged,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: AppSizes.bodyFontSize,
                      ),
                      maxLines: 5,
                      minLines: 1,
                      decoration: InputDecoration(
                        hintText: 'Type Something',
                        hintStyle: TextStyle(
                          color: AppColors.textSecondary.withOpacity(0.7),
                          fontSize: AppSizes.bodyFontSize,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: widget.isComposing ? AppColors.primaryPurple : AppColors.primaryPurple.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
                ),
                child: Tooltip(
                  message: 'Send message (or press Enter)',
                  child: IconButton(
                    icon: const Icon(
                      Icons.send, 
                      color: AppColors.textPrimary,
                      size: AppSizes.inputIconSize,
                    ),
                    onPressed: widget.isComposing
                        ? () => widget.onSubmitted(widget.controller.text)
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Main chat screen
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  bool _isComposing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChatProvider>(context, listen: false).loadMessages();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
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
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkSurface,
        elevation: 0,
        title: const Text(
          'ThinkTandem',
          style: TextStyle(
            fontSize: AppSizes.titleFontSize,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, size: AppSizes.actionIconSize),
            onPressed: () {
              Provider.of<ChatProvider>(context, listen: false).clearChat();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Chat cleared'),
                  backgroundColor: AppColors.darkSecondary,
                ),
              );
            },
            tooltip: 'Clear chat history',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: AppColors.darkBackground,
              alignment: Alignment.center,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppSizes.maxContentWidth,
                ),
                child: Consumer<ChatProvider>(
                  builder: (context, chatProvider, child) {
                    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                    if (chatProvider.messages.isEmpty) {
                      return const Center(
                        child: Text(
                          'Start a conversation with ThinkTandem',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: AppSizes.bodyFontSize,
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(vertical: AppSizes.messageSpacing),
                      itemCount: chatProvider.messages.length,
                      itemBuilder: (_, int index) {
                        final message = chatProvider.messages[index];
                        return MessageBubble(message: message);
                      },
                    );
                  },
                ),
              ),
            ),
          ),
          Consumer<ChatProvider>(
            builder: (context, chatProvider, child) {
              return chatProvider.isLoading 
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      alignment: Alignment.center,
                      color: AppColors.darkSurface,
                      child: const LoadingDots(),
                    )
                  : const SizedBox.shrink();
            },
          ),
          ChatInputField(
            controller: _textController,
            focusNode: _focusNode,
            isComposing: _isComposing,
            onChanged: (text) {
              setState(() {
                _isComposing = text.isNotEmpty;
              });
            },
            onSubmitted: _handleSubmitted,
          ),
        ],
      ),
    );
  }

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;
    
    _textController.clear();
    setState(() {
      _isComposing = false;
    });
    Provider.of<ChatProvider>(context, listen: false).sendMessageToGPT4o(text);
  }
}

// Main app
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ChatProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ThinkTandem',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.darkBackground,
        primaryColor: AppColors.primaryPurple,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primaryPurple,
          surface: AppColors.darkSurface,
          background: AppColors.darkBackground,
          onPrimary: AppColors.textPrimary,
          onSurface: AppColors.textPrimary,
          onBackground: AppColors.textPrimary,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.darkSurface,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: AppColors.textPrimary,
            fontSize: AppSizes.titleFontSize,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(
            color: AppColors.textPrimary,
          ),
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: AppColors.darkSecondary,
          contentTextStyle: TextStyle(color: AppColors.textPrimary),
        ),
      ),
      home: const ChatScreen(),
    );
  }
}