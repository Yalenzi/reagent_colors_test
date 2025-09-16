#!/bin/bash

# Run Flutter app with Gemini API Key
# Usage: ./run_with_api_key.sh [flutter_mode]
# Examples: 
#   ./run_with_api_key.sh debug (default)
#   ./run_with_api_key.sh release
#   ./run_with_api_key.sh profile

# Your Gemini API Key
GEMINI_API_KEY="AIzaSyAqzCV-NRbR0xn2t0ZtY9T0ofdOTebCviM"

# Get mode (default to debug)
MODE=${1:-debug}

echo "🚀 Running Flutter app in $MODE mode with Gemini AI..."
echo "📱 API Key: ${GEMINI_API_KEY:0:8}..."

# Run Flutter with API key
flutter run --$MODE --dart-define=GEMINI_API_KEY=$GEMINI_API_KEY 