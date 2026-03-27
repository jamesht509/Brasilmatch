# 🚀 BrasilMatch - Quick Start

## ⚡ Setup Rápido (5 minutos)

### 1. Configure Supabase
```bash
# 1. Crie projeto em supabase.com
# 2. Vá em SQL Editor
# 3. Cole conteúdo de: supabase/migrations/001_initial_schema.sql
# 4. Execute (RUN)
```

### 2. Configure .env
```bash
cd flutter_app
cp .env.example .env
# Edite .env com suas credenciais Supabase
```

### 3. Rode o App
```bash
# Instale dependências
flutter pub get

# Rode no seu iPhone (certifique-se que está conectado)
flutter run --host=0.0.0.0

# Ou use o script automático:
../scripts/run-dev.sh
```

**Pronto! O app está rodando!** 🎉

---

## 📂 Estrutura do Projeto

```
brasilmatch/
├── flutter_app/           # 📱 App Flutter
│   ├── lib/
│   │   ├── main.dart     # Entry point
│   │   ├── app.dart      # App config
│   │   ├── core/         # Tema, rotas, configs
│   │   ├── models/       # User, Match, Message
│   │   ├── services/     # Supabase services
│   │   ├── providers/    # Riverpod state
│   │   ├── screens/      # Todas as telas
│   │   └── widgets/      # Componentes reutilizáveis
│   ├── pubspec.yaml      # Dependências
│   └── .env              # Credenciais (você cria)
│
├── supabase/             # 🗄️ Database
│   └── migrations/
│       └── 001_initial_schema.sql  # Schema completo
│
├── scripts/              # 🛠️ Automação
│   ├── auto-update.sh   # Git pull automático
│   └── run-dev.sh       # Roda tudo de uma vez
│
└── docs/                 # 📚 Documentação
    ├── SETUP.md         # Guia completo
    ├── IAP_GUIDE.md     # In-App Purchase
    └── DEPLOYMENT.md    # Como publicar nas lojas
```

---

## ✨ Features Implementadas

### ✅ Autenticação
- Login/Signup com email
- Google Sign In
- Apple Sign In
- Logout
- Profile setup

### ✅ Core Features
- **Swipe:** Cards animados com like/nope/super like
- **Match:** Sistema automático (SQL trigger)
- **Chat:** Real-time com Supabase
- **Profile:** Upload fotos, bio, preferências
- **Credits:** Sistema de créditos + IAP preparado

### ✅ Compliance
- Age gate (18+)
- Report & Block
- Photo moderation (placeholder)
- Privacy controls
- Terms acceptance

### ✅ Design
- Tema Sunset Romance (coral + laranja)
- Animações fluidas
- Bottom navigation
- Material Design 3

---

## 🎯 Próximos Passos (TODO)

### Implementar (Você pode fazer):
1. **Photo Upload Real:**
   - Integrar com Supabase Storage
   - Atualmente usando paths mock

2. **IAP Real:**
   - Conectar com Apple/Google IAP
   - Arquivo: `services/iap_service.dart` (já estruturado)

3. **Video Call:**
   - Integrar Agora SDK
   - Botão já existe em chat

4. **Photo Moderation:**
   - Google Cloud Vision API
   - Ou moderação manual

5. **Admin Panel:**
   - Dashboard web (Vercel + Next.js)
   - Review reports, moderar fotos

---

## 🐛 Debug & Testing

### Ver logs:
```bash
flutter run -v
```

### Hot reload:
```
r  = hot reload
R  = hot restart
q  = quit
```

### Limpar cache:
```bash
flutter clean
flutter pub get
```

---

## 📱 Testar no iPhone

### Primeira vez (USB):
```bash
flutter run
```

### Wireless (depois):
```bash
flutter run --host=0.0.0.0
# Desplugue o cabo!
```

---

## 🔥 Auto-Update Workflow

1. Eu (Claude) faço mudanças no código
2. Commito no GitHub
3. Script detecta mudanças (30s)
4. Git pull automático
5. Hot reload no iPhone
6. **Você vê mudanças instantaneamente!**

---

## 💡 Comandos Úteis

```bash
# Ver devices conectados
flutter devices

# Rodar em device específico
flutter run -d <device-id>

# Build para produção
flutter build ios --release
flutter build appbundle --release

# Analisar tamanho do app
flutter build apk --analyze-size

# Verificar problemas
flutter doctor
```

---

## 📞 Suporte

Problemas? Leia:
- `docs/SETUP.md` - Setup detalhado
- `docs/IAP_GUIDE.md` - In-App Purchases
- `docs/DEPLOYMENT.md` - Deploy nas lojas

Ou me pergunte! Estou aqui pra ajudar.

---

## 🎨 Customizar

### Mudar cores:
`lib/core/theme/app_colors.dart`

### Mudar textos:
Procure nas screens individuais

### Adicionar feature:
Siga padrão:
```
screens/feature/
services/feature_service.dart
providers/feature_provider.dart
```

---

**Bora codar! 🚀🇧🇷**
