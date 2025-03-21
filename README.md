# ThinkTandem
ThinkTandem is a Flutter-based AI assistant designed to enhance critical thinking skills rather than simply providing answers. Unlike conventional AI assistants that focus on delivering direct solutions, ThinkTandem is built to develop users' cognitive abilities through guided collaboration and intentional scaffolding.

<img src="https://github.com/user-attachments/assets/ffc364d5-82d5-45c9-8d25-0082e6e06ad1" width="50%">


## 🧠 Philosophy
**ThinkTandem follows a unique educational philosophy:**

- Enhance rather than replace human thinking.
- Value productive struggle as essential to cognitive development.
- Guide through collaboration instead of providing instant answers.
- Make thinking processes visible and explicit.
- Gradually reduce assistance as skills develop.

## ✨ Features

- Guided Critical Thinking: Prompts users to articulate their current understanding before providing assistance.
- Collaborative Learning: Intentionally leaves strategic gaps in responses for users to complete.
- Metacognition Coaching: Helps users reflect on their thinking patterns and processes.
- Beautiful UI: Clean, responsive Claude-inspired interface that works across all screen sizes.
- Enter to Send: Press Enter to send messages, Shift+Enter to create a new line.
- Message Persistence: Conversations are saved and restored between sessions.
- Responsive Design: Works seamlessly on mobile, tablet, desktop, and web platforms.
- Dark Mode: Easy on the eyes with a modern dark interface.

## 🛠️ Technical Implementation
**ThinkTandem is built with:**

- Flutter: For cross-platform UI development
- OpenAI API (GPT-4o): For AI-powered conversation capabilities
- Provider: For state management
- SharedPreferences: For local message persistence

## 🚀 Getting Started
**Prerequisites**

- Flutter SDK (2.12.0 or later)
- OpenAI API key
- Dart (2.15.0 or later)

## Installation
**1. Clone the repository**
```
git clone https://github.com/yourusername/think-tandem.git
cd think-tandem
```

**2. Clone the repository**
```
flutter pub get
```

**3. Configure OpenAI API Key**
- Open lib/main.dart
- Find the ApiConfig class
- Replace REPLACE_WITH_YOUR_API_KEY with your actual OpenAI API key

**4. Run the application**
```
flutter run
```

## 🎮 Usage

- Start Typing: Use the input field at the bottom to ask questions or start a conversation
- Send Message: Press Enter or tap the send button
- New Line: Press Shift+Enter for multi-line input
- Clear Chat: Tap the trash icon in the app bar to clear the conversation history

## 💡 How ThinkTandem Helps You Learn
**ThinkTandem uses several educational techniques:**

- Thought Journal: Encourages you to articulate your current understanding before providing assistance
- Collaborative Completion: Leaves strategic gaps in responses for you to complete
- Metacognition Coaching: Helps you notice your thinking patterns and processes
- Calibrated Scaffolding: Provides just enough support to enable progress without removing necessary challenge

## 🤝 Contributing
Contributions are welcome! Please feel free to submit a Pull Request.

#### Note: ThinkTandem requires an OpenAI API key to function. Usage of the OpenAI API incurs costs based on your usage. Be sure to monitor your API usage through OpenAI's dashboard.
