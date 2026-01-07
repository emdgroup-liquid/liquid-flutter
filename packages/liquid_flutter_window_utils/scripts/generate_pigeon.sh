#!/bin/bash

# Script to regenerate Pigeon code
echo "Regenerating Pigeon code..."

# Check if pigeon is available
if ! command -v flutter &> /dev/null; then
    echo "Error: Flutter is not installed or not in PATH"
    exit 1
fi

# Run pigeon to generate code
flutter packages pub run pigeon --input pigeons/messages.dart

if [ $? -eq 0 ]; then
    echo "✅ Pigeon code generated successfully!"
else
    echo "❌ Error generating Pigeon code"
    exit 1
fi
