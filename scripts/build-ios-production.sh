#!/bin/bash
# Build script para iOS Production

echo "🚀 Building BrasilMatch for iOS (Production)"
echo ""

# Verificar se as variáveis foram passadas
if [ -z "$SUPABASE_URL" ] || [ -z "$SUPABASE_ANON_KEY" ]; then
    echo "❌ Erro: Credenciais não configuradas!"
    echo ""
    echo "Configure as variáveis de ambiente:"
    echo "  export SUPABASE_URL=https://seu-projeto.supabase.co"
    echo "  export SUPABASE_ANON_KEY=sua-chave-anon"
    echo ""
    echo "Ou passe diretamente:"
    echo "  SUPABASE_URL=... SUPABASE_ANON_KEY=... ./build-ios-production.sh"
    exit 1
fi

echo "✅ Credenciais configuradas"
echo "   URL: ${SUPABASE_URL:0:30}..."
echo ""

# Clean
echo "🧹 Limpando builds anteriores..."
flutter clean
flutter pub get

# Build iOS
echo "📱 Building iOS Release..."
flutter build ios --release \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY \
  --dart-define=ENV=production

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Build iOS completo!"
    echo "📦 Próximo passo: Abra Xcode e faça Archive"
    echo "   Arquivo: ios/Runner.xcworkspace"
else
    echo ""
    echo "❌ Build falhou!"
    exit 1
fi
