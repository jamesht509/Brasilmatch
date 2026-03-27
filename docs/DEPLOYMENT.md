# 🚀 Deployment - App Store & Google Play

Guia completo para publicar BrasilMatch nas lojas.

---

## 📱 iOS - App Store

### 1. Preparação

#### Crie Conta Apple Developer
- Custo: $99/ano
- [developer.apple.com](https://developer.apple.com)

#### Configure App ID
```bash
# Em Xcode:
# 1. Abra ios/Runner.xcworkspace
# 2. Selecione Runner > Signing & Capabilities
# 3. Configure Team
# 4. Bundle ID: com.brasilmatch.app
```

### 2. Build para Produção

```bash
cd flutter_app

# Clean
flutter clean
flutter pub get

# Build iOS Release
flutter build ios --release
```

### 3. Archive no Xcode

1. Abra `ios/Runner.xcworkspace` no Xcode
2. Selecione **Any iOS Device (arm64)**
3. **Product** > **Archive**
4. Aguarde build completar

### 4. Upload para App Store Connect

1. No Xcode Organizer (abre após archive)
2. Selecione o archive
3. **Distribute App**
4. **App Store Connect**
5. **Upload**
6. Aguarde processamento (10-30 min)

### 5. Complete App Store Connect

1. Acesse [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
2. Vá em seu app
3. **App Information:**
   - Nome: BrasilMatch
   - Categoria: Lifestyle > Dating
   - Age Rating: 17+ (relacionamento)
   
4. **Pricing:**
   - Grátis
   - Disponível em: USA (inicialmente)
   
5. **App Privacy:**
   - Data Collected: Nome, Email, Localização, Fotos
   - Usage: Funcionalidade do app
   - Linked to User: Sim
   
6. **Version Information:**
   - Screenshots (5-6 por tamanho)
   - App Preview (opcional)
   - Description
   - Keywords: "brasileiros, dating, match, relacionamento, exterior"
   - Support URL
   - Privacy Policy URL
   
7. **Build:**
   - Selecione o build que você uploadou
   
8. **Submit for Review**

### 6. Screenshots Necessários

Tamanhos obrigatórios:
- iPhone 6.7" (1290x2796) - iPhone 14 Pro Max
- iPhone 6.5" (1284x2778) - iPhone 13 Pro Max  
- iPad Pro 12.9" (2048x2732)

Dica: Use ferramentas como [screenshots.pro](https://screenshots.pro)

---

## 🤖 Android - Google Play

### 1. Preparação

#### Crie Conta Google Play Console
- Custo: $25 (único)
- [play.google.com/console](https://play.google.com/console)

#### Configure Keystore

```bash
# Gere keystore (UMA VEZ APENAS!)
keytool -genkey -v -keystore ~/brasilmatch-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias brasilmatch

# GUARDE AS SENHAS EM LUGAR SEGURO!
```

#### Configure android/key.properties

```
storePassword=SUA_SENHA
keyPassword=SUA_SENHA
keyAlias=brasilmatch
storeFile=/Users/seu-usuario/brasilmatch-key.jks
```

**NUNCA commite este arquivo! Adicione ao .gitignore**

### 2. Build para Produção

```bash
cd flutter_app

# Build App Bundle (recomendado)
flutter build appbundle --release

# Ou APK
flutter build apk --release
```

Arquivo gerado:
- App Bundle: `build/app/outputs/bundle/release/app-release.aab`
- APK: `build/app/outputs/flutter-apk/app-release.apk`

### 3. Upload para Play Console

1. Acesse [play.google.com/console](https://play.google.com/console)
2. Selecione seu app
3. **Production** > **Create new release**
4. Upload do `.aab` file
5. Preencha **Release notes**
6. **Review release**
7. **Start rollout to Production**

### 4. Complete Store Listing

1. **App details:**
   - Nome: BrasilMatch
   - Descrição curta (80 chars)
   - Descrição completa
   - Categoria: Dating
   - Tags: brasileiros, relacionamento, match
   
2. **Graphics:**
   - Icon (512x512)
   - Feature Graphic (1024x500)
   - Screenshots (min 2, max 8) - 1080x1920 ou maior
   
3. **Contact details:**
   - Email
   - Website (opcional)
   - Phone (opcional)
   
4. **Privacy Policy:**
   - URL da sua policy

### 5. Content Rating

Responda questionário:
- Dating/Social Networking: Sim
- User-generated content: Sim
- Faixa etária: 18+

### 6. Pricing & Distribution

- Grátis
- Países: United States (inicialmente)

### 7. Submit for Review

Revisão demora 1-3 dias (geralmente).

---

## 📋 Checklist Pré-Launch

### Compliance
- ✅ Privacy Policy URL ativa
- ✅ Terms of Service URL ativa
- ✅ Support email configurado
- ✅ Age gate (18+) implementado
- ✅ Report & Block funciona
- ✅ Photo moderation ativa

### Features
- ✅ Todas as telas testadas
- ✅ IAP funcionando (sandbox)
- ✅ Chat real-time OK
- ✅ Match logic OK
- ✅ Swipe smooth
- ✅ Sem crashes

### Assets
- ✅ App Icon (1024x1024)
- ✅ Screenshots iOS (todos tamanhos)
- ✅ Screenshots Android (min 2)
- ✅ Feature Graphic Android
- ✅ App Preview Video (opcional)

### Backend
- ✅ Supabase production setup
- ✅ Database otimizado (índices)
- ✅ RLS policies ativas
- ✅ Storage configurado
- ✅ Backup automático

---

## 🎯 Estratégia de Launch

### Soft Launch (Recomendado)

1. **Semana 1:** Miami apenas
   - Limite geográfico no app
   - Evento presencial
   - Feedback intensivo
   
2. **Semana 2-3:** + NYC, Boston
   - Se Miami validou (50+ usuários ativos)
   
3. **Mês 2:** USA completo
   - Expandir gradualmente

### Marketing Inicial

- Instagram ads (brasileiros em Miami)
- Parcerias com restaurantes brasileiros
- Influencers locais
- Grupos de Facebook de brasileiros

---

## 📊 Post-Launch

### Monitore

- Crash rate (Firebase Crashlytics)
- Daily Active Users
- Retention (Day 1, Day 7, Day 30)
- IAP conversion rate
- Match rate
- Chat engagement

### Iterate

- Bugs críticos: fix em 24h
- Features baseado em feedback
- A/B tests (preços IAP, onboarding)

---

## 🚨 Rejection Comum (Evitar)

### iOS
- ❌ Mencionar outras plataformas (Android)
- ❌ Screenshots com devices Android
- ❌ Pedir review antes de usar o app
- ❌ Features quebradas
- ❌ Crashes

### Android
- ❌ Conteúdo adulto não declarado
- ❌ Missing privacy policy
- ❌ Spam keywords
- ❌ Misleading screenshots

---

## 💡 Dicas Finais

1. **Teste TUDO antes de submeter**
   - Device físico, não emulador
   - Connections lentas
   - Edge cases
   
2. **App Store Review demora ~1-3 dias (iOS)**
   - Google Play: 1-3 dias
   - Planeje launch com antecedência
   
3. **Primeiro rejection é normal**
   - Não desanime
   - Corrija e resubmeta
   
4. **TestFlight (iOS) para beta**
   - Convide 10-20 usuários antes do launch
   - Encontre bugs antes da Apple
   
5. **Internal Testing (Android)**
   - Similar ao TestFlight
   - Teste com amigos primeiro

---

**Boa sorte no launch! 🚀🇧🇷**
