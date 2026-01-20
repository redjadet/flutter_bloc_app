# GenUI Demo - User Guide

## Overview

The GenUI Demo feature demonstrates AI-generated dynamic user interfaces using the GenUI SDK with Google Gemini. Users can enter natural language prompts, and the AI will generate interactive UI components in real-time.

## How to Access

### From the App

1. **Via Overflow Menu** (Recommended):
   - Open the app and navigate to the Counter/Home page
   - Tap the **three-dot menu** (⋮) in the top-right corner of the app bar
   - Select **"GenUI Demo"** from the overflow menu
   - The GenUI Demo page will open

2. **Via Direct Navigation**:
   - The route is available at `/genui-demo`
   - You can navigate programmatically using GoRouter:

     ```dart
     context.pushNamed(AppRoutes.genuiDemo);
     ```

### Prerequisites

Before using the GenUI Demo, you need to configure a Google Gemini API key:

1. **Get a Gemini API Key**:
   - Visit [Google AI Studio](https://makersuite.google.com/app/apikey)
   - Sign in with your Google account
   - Create a new API key

2. **Configure the API Key**:

   **Option A: Development (using secrets.json)**

   ```bash
   # Copy the sample file
   cp assets/config/secrets.sample.json assets/config/secrets.json

   # Edit secrets.json and add your key
   {
     "GEMINI_API_KEY": "your-actual-api-key-here"
   }

   # Run with asset secrets enabled
   flutter run --dart-define=ENABLE_ASSET_SECRETS=true
   ```

   **Option B: Production (using environment variables)**

   ```bash
   flutter run --dart-define=GEMINI_API_KEY=your-actual-api-key-here
   ```

   **Option C: Secure Storage (persisted)**
   - The app automatically saves the API key to secure storage (Keychain/Keystore)
   - Once configured, the key persists across app restarts

3. **Verify Configuration**:
   - If the API key is missing or invalid, the app will display an error message
   - The error message provides instructions on how to configure the key

## How to Use

1. **Open the GenUI Demo page** (see "How to Access" above)

2. **Wait for Initialization**:
   - The page will show a loading indicator while initializing
   - This typically takes 1-2 seconds

3. **Enter a Prompt**:
   - Type a natural language description of the UI you want to generate
   - Examples:
     - "Create a login form with email and password fields"
     - "Show me a card with a title, description, and button"
     - "Generate a list of items with checkboxes"
     - "Make a counter widget with increment and decrement buttons"

4. **Send the Message**:
   - Tap the **"Send"** button or press Enter
   - The button will show a loading indicator while processing

5. **View Generated UI**:
   - The AI-generated UI components will appear as interactive surfaces
   - Multiple surfaces can be generated from a single conversation
   - Each surface is a fully interactive Flutter widget

6. **Continue the Conversation**:
   - You can send additional messages to modify or extend the generated UI
   - The AI will update surfaces based on your new prompts

## Features

- **Real-time UI Generation**: Generate Flutter widgets from natural language
- **Interactive Components**: All generated UI is fully interactive
- **Multiple Surfaces**: Support for multiple UI surfaces in a single session
- **Error Handling**: Clear error messages if something goes wrong
- **Platform Adaptive**: UI adapts to Material and Cupertino design systems

## Troubleshooting

### "GEMINI_API_KEY not configured" Error

**Solution**: Configure your API key using one of the methods described in "Prerequisites" above.

### "Initialization failed" Error

**Possible causes**:

- Invalid API key
- Network connectivity issues
- API quota exceeded

**Solutions**:

- Verify your API key is correct
- Check your internet connection
- Verify your Google Cloud project has API access enabled
- Check API usage limits in Google AI Studio

### No UI Generated

**Possible causes**:

- Prompt too vague or unclear
- API rate limiting
- Network timeout

**Solutions**:

- Try a more specific prompt (e.g., "Create a button" instead of "Make something")
- Wait a few seconds and try again
- Check your internet connection

## Technical Details

- **SDK**: GenUI SDK 0.5.1 with Google Generative AI provider
- **Model**: Uses Google Gemini for content generation
- **Architecture**: Follows clean architecture with domain/data/presentation layers
- **State Management**: BLoC/Cubit pattern with Freezed states
- **Route**: `/genui-demo` (defined in `AppRoutes.genuiDemoPath`)

## Related Documentation

- [GenUI SDK Documentation](https://docs.flutter.dev/ai/genui/get-started)
- [Implementation Plan](genui_sdk_demo_implementation_plan.md)
- [Security & Secrets](security_and_secrets.md)
- [Feature Overview](feature_overview.md)
