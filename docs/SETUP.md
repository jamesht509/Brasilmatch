# 📱 BrasilMatch - Guia Completo de Setup

Este guia vai te ajudar a configurar e rodar o app BrasilMatch localmente.

## 📋 Pré-requisitos

### 1. Flutter & Dart
```bash
# macOS (via Homebrew)
brew install flutter

# Verificar instalação
flutter doctor
```

### 2. Xcode (para iOS)
- Baixe do App Store
- Instale Command Line Tools:
```bash
xcode-select --install
```

### 3. CocoaPods (para iOS)
```bash
sudo gem install cocoapods
```

### 4. Conta Supabase
- Crie uma conta em [supabase.com](https://supabase.com)
- Crie um novo projeto

---

## 🚀 Setup Passo a Passo

### 1. Clone o Repositório
```bash
git clone https://github.com/seu-usuario/brasilmatch.git
cd brasilmatch
```

### 2. Configure o Supabase

#### 2.1. Execute o Schema SQL
1. Acesse seu projeto no Supabase Dashboard
2. Vá em **SQL Editor**
3. Copie o conteúdo de `supabase/migrations/001_initial_schema.sql`
4. Cole no editor e clique em **Run**

#### 2.2. Configure Storage
O schema já criou o bucket `profile-photos` automaticamente.

#### 2.3. Pegue suas Credenciais
1. Vá em **Settings** > **API**
2. Copie:
   - `Project URL`
   - `anon/public key`

### 3. Configure Variáveis de Ambiente

```bash
cd flutter_app
cp .env.example .env
```

Edite `.env` com suas credenciais:
```
SUPABASE_URL=https://seu-projeto.supabase.co
SUPABASE_ANON_KEY=sua-chave-anon-aqui
AGORA_APP_ID=seu-agora-app-id (opcional por enquanto)
ENV=development
```

### 4. Instale Dependências

```bash
flutter pub get
```

### 5. Configure iOS

```bash
cd ios
pod install
cd ..
```

---

## 🎯 Rodando o App

### Opção 1: Usando o Script Automático (Recomendado)

```bash
cd flutter_app
../scripts/run-dev.sh
```

Este script:
- ✅ Verifica dependências
- ✅ Inicia auto-update (git pull automático)
- ✅ Roda Flutter no device
- ✅ Hot reload automático

### Opção 2: Manual

#### Terminal 1 - Flutter
```bash
cd flutter_app
flutter run --host=0.0.0.0
```

#### Terminal 2 - Auto-Update (Opcional)
```bash
chmod +x scripts/auto-update.sh
./scripts/auto-update.sh
```

---

## 📱 Testando no iPhone

### Primeira Vez (USB)

1. Conecte iPhone via cabo USB
2. Confie no computador (iPhone vai pedir)
3. Rode:
```bash
flutter devices
```
4. Seu iPhone deve aparecer na lista
5. Rode o app:
```bash
flutter run
```

### Wireless (Depois da Primeira Vez)

1. Certifique-se que iPhone e Mac estão na mesma WiFi
2. Rode com `--host=0.0.0.0`:
```bash
flutter run --host=0.0.0.0
```
3. Desplugue o cabo!
4. App continua rodando via WiFi

**Hot Reload funciona wireless!** 🔥

---

## 🔄 Workflow de Desenvolvimento

### Quando eu (Claude) atualizo o código:

1. Eu faço commit no GitHub
2. Seu script `auto-update.sh` detecta (30 segundos)
3. Git pull automático
4. Flutter hot reload automático
5. **Você vê as mudanças no iPhone instantaneamente!**

### Para testar manualmente:

```bash
# Hot reload (quick)
r

# Hot restart (full restart)
R

# Quit
q
```

---

## 🐛 Troubleshooting

### "Command not found: flutter"
```bash
# Adicione ao PATH (macOS/Linux)
export PATH="$PATH:/path/to/flutter/bin"

# Ou reinstale via Homebrew
brew install flutter
```

### "No devices found"
```bash
# iOS Simulator
open -a Simulator

# Listar devices
flutter devices

# Device físico não aparece?
# - Reconecte USB
# - Confie no computador
# - Verifique em Xcode > Window > Devices
```

### "CocoaPods not installed"
```bash
sudo gem install cocoapods
cd ios
pod install
```

### ".env file not found"
```bash
cd flutter_app
cp .env.example .env
# Edite .env com suas credenciais
```

### "Supabase connection failed"
- Verifique se copiou URL e ANON_KEY corretamente
- Teste a conexão em [seu-projeto.supabase.co](https://supabase.com)
- Confirme que o schema SQL foi executado

### "Hot reload not working"
```bash
# Reinicie com --host
flutter run --host=0.0.0.0

# Se ainda não funcionar, hot restart
R
```

---

## 📚 Próximos Passos

Após setup completo:

1. ✅ **Teste o fluxo completo:**
   - Criar conta
   - Completar perfil
   - Fazer swipe
   - Ver matches

2. ✅ **Adicione fotos de teste:**
   - Use URLs públicas temporariamente
   - Ou configure upload real no Supabase Storage

3. ✅ **Teste features:**
   - Chat real-time
   - Match system
   - Credits (mock por enquanto)

---

## 🎨 Customização

### Mudar cores:
Edite `lib/core/theme/app_colors.dart`

### Adicionar features:
Siga a estrutura:
```
lib/
  screens/nova_feature/
  services/nova_feature_service.dart
  providers/nova_feature_provider.dart
```

### Debug:
```bash
# Logs detalhados
flutter run -v

# Performance overlay
flutter run --profile
```

---

## 📞 Suporte

Problemas? Me pergunte! Estou aqui para ajudar.

**Happy coding!** 🚀🇧🇷
