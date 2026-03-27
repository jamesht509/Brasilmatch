#!/bin/bash
# Script principal de desenvolvimento - roda Flutter + Auto-update

echo "🚀 BrasilMatch - Modo Desenvolvedor"
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter não encontrado. Instale primeiro:"
    echo "   https://docs.flutter.dev/get-started/install"
    exit 1
fi

# Check if in correct directory
if [ ! -f "pubspec.yaml" ]; then
    echo "⚠️  Execute este script dentro de flutter_app/"
    echo "   cd flutter_app"
    echo "   ../scripts/run-dev.sh"
    exit 1
fi

# Check if .env exists
if [ ! -f ".env" ]; then
    echo "⚠️  Arquivo .env não encontrado!"
    echo "   Copie .env.example para .env e configure suas credenciais"
    echo "   cp .env.example .env"
    exit 1
fi

echo "✅ Ambiente verificado"
echo ""

# Install dependencies
echo "📦 Instalando dependências..."
flutter pub get
echo ""

# Check for connected devices
echo "📱 Verificando devices conectados..."
flutter devices
echo ""

# Ask user to confirm device
echo "Digite o nome do device (ou pressione Enter para usar o primeiro):"
read DEVICE

# Start auto-update in background
echo "🔄 Iniciando auto-update em background..."
cd ..
chmod +x scripts/auto-update.sh
./scripts/auto-update.sh &
AUTO_UPDATE_PID=$!
cd flutter_app

# Start Flutter
echo ""
echo "🎯 Iniciando app Flutter..."
echo "   Hot reload: pressione 'r'"
echo "   Hot restart: pressione 'R'"
echo "   Quit: pressione 'q'"
echo ""

if [ -z "$DEVICE" ]; then
    flutter run --host=0.0.0.0
else
    flutter run --host=0.0.0.0 -d "$DEVICE"
fi

# Cleanup on exit
echo ""
echo "🛑 Parando auto-update..."
kill $AUTO_UPDATE_PID 2>/dev/null

echo "✨ Desenvolvimento encerrado"
