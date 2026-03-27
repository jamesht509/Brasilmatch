#!/bin/bash
# Build script para Android Production

echo "🚀 Building BrasilMatch for Android (Production)"
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
    echo "  SUPABASE_URL=... SUPABASE_ANON_KEY=... ./build-android-production.sh"
    exit 1
fi

echo "✅ Credenciais configuradas"
echo "   URL: ${SUPABASE_URL:0:30}..."
echo ""

# Clean
echo "🧹 Limpando builds anteriores..."
flutter clean
flutter pub get

# Build Android App Bundle
echo "📱 Building Android App Bundle..."
flutter build appbundle --release \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY \
  --dart-define=ENV=production

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Build Android completo!"
    echo "📦 Arquivo gerado:"
    echo "   build/app/outputs/bundle/release/app-release.aab"
    echo ""
    echo "📤 Upload para Google Play Console"
else
    echo ""
    echo "❌ Build falhou!"
    exit 1
fi
