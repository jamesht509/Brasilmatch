# 🔐 Gerenciamento de Credenciais - Guia Completo

Este guia explica como as credenciais funcionam em **desenvolvimento** e **produção**.

---

## 📋 **RESUMO RÁPIDO:**

```
Desenvolvimento (seu Mac):
  └─ flutter_app/.env (local, não vai pro Git)

Produção (App Store/Play Store):
  └─ Compilado no app via --dart-define
```

**Credenciais NUNCA vão pro GitHub!** ✅

---

## 🏠 **DESENVOLVIMENTO LOCAL**

### **1. Crie seu arquivo .env:**

```bash
cd Brasilmatch/flutter_app
cp .env.example .env
```

### **2. Edite com suas credenciais:**

```bash
# Abra no editor
nano .env
# ou
code .env
```

**Conteúdo:**
```env
SUPABASE_URL=https://seu-projeto-aqui.supabase.co
SUPABASE_ANON_KEY=sua-chave-anon-aqui
AGORA_APP_ID=seu-agora-id-aqui
ENV=development
```

### **3. Como pegar as credenciais Supabase:**

1. Acesse [supabase.com](https://supabase.com)
2. Abra seu projeto
3. Vá em **Settings** > **API**
4. Copie:
   - **Project URL** → `SUPABASE_URL`
   - **anon public** → `SUPABASE_ANON_KEY`

### **4. Rode normalmente:**

```bash
flutter run
# O app pega credenciais do .env automaticamente!
```

---

## 🚀 **PRODUÇÃO (App nas Lojas)**

### **Como funciona:**

Quando você faz **build para produção**, as credenciais são passadas via **flags** e compiladas DENTRO do app:

```bash
flutter build ios --release \
  --dart-define=SUPABASE_URL=https://seu-projeto.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=sua-chave \
  --dart-define=ENV=production
```

**Resultado:**
- ✅ Credenciais ficam "escondidas" no binário compilado
- ✅ Não aparecem no código-fonte
- ✅ Seguras

---

## 🛠️ **USANDO OS SCRIPTS DE BUILD:**

Criamos scripts que facilitam o build de produção:

### **iOS:**

```bash
# Configure as credenciais (UMA VEZ)
export SUPABASE_URL=https://seu-projeto.supabase.co
export SUPABASE_ANON_KEY=sua-chave-anon

# Build
cd Brasilmatch
chmod +x scripts/build-ios-production.sh
./scripts/build-ios-production.sh
```

### **Android:**

```bash
# Configure as credenciais (UMA VEZ)
export SUPABASE_URL=https://seu-projeto.supabase.co
export SUPABASE_ANON_KEY=sua-chave-anon

# Build
chmod +x scripts/build-android-production.sh
./scripts/build-android-production.sh
```

---

## 🔒 **SEGURANÇA - O QUE VAI/NÃO VAI PRO GITHUB:**

### ✅ **Vai pro GitHub (Seguro):**

```
✅ .env.example          (template sem credenciais)
✅ .gitignore            (.env está listado aqui)
✅ app_config.dart       (código que LÊ credenciais)
✅ build scripts         (scripts que USAM credenciais)
✅ Todo código-fonte
```

### ❌ **NÃO vai pro GitHub (Credenciais):**

```
❌ .env                  (suas credenciais reais)
❌ key.properties        (keystore Android)
❌ *.jks                 (keystore Android)
```

**Verificação:**

```bash
# Confira o .gitignore:
cat .gitignore | grep -E "\.env|key.properties|\.jks"

# Deve aparecer:
.env
.env.local
.env.production
**/android/key.properties
*.jks
```

---

## 🔄 **FLUXO COMPLETO:**

### **Desenvolvimento:**

```
1. Você cria .env local
2. Adiciona credenciais Supabase
3. Roda: flutter run
4. App conecta ao Supabase
   └─ Lê de: .env
```

### **Produção:**

```
1. Você roda: ./scripts/build-ios-production.sh
2. Script passa credenciais via --dart-define
3. Flutter compila app
4. Credenciais ficam NO BINÁRIO (não no código)
5. Upload pra App Store
6. Usuários baixam
7. App conecta ao Supabase
   └─ Lê de: dart-define (compilado)
```

---

## 💡 **BOAS PRÁTICAS:**

### **1. NUNCA commite o .env:**

```bash
# Antes de commitar, sempre verifique:
git status

# Se aparecer .env, PARE!
# Adicione ao .gitignore (já está, mas confira):
echo ".env" >> .gitignore
```

### **2. Use .env.example como template:**

```bash
# .env.example (vai pro Git - SEM credenciais)
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
AGORA_APP_ID=your-agora-app-id
ENV=development
```

### **3. Credenciais diferentes por ambiente:**

```bash
# Desenvolvimento
SUPABASE_URL=https://dev-project.supabase.co

# Produção (só no build script)
SUPABASE_URL=https://prod-project.supabase.co
```

### **4. Guarde credenciais com segurança:**

- ✅ Password manager (1Password, Bitwarden)
- ✅ Arquivo criptografado local
- ✅ Variáveis de ambiente do sistema
- ❌ Nunca em email, Slack, texto plano

---

## 🧪 **TESTANDO:**

### **Verificar se .env está funcionando:**

```bash
cd flutter_app
flutter run

# No console, deve aparecer:
📱 BrasilMatch Config:
   Environment: development
   Supabase URL: https://seu-projeto.supabase...
   Has Anon Key: true
```

### **Verificar se .env NÃO vai pro Git:**

```bash
git add .
git status

# .env NÃO deve aparecer na lista!
```

---

## 🚨 **E SE EU COMMITAR .ENV POR ENGANO?**

**CUIDADO! Se isso acontecer:**

```bash
# 1. PARE! Não faça push ainda

# 2. Remova do commit:
git reset HEAD .env
git checkout -- .env

# 3. Adicione ao .gitignore (se não tiver):
echo ".env" >> .gitignore
git add .gitignore
git commit -m "Adiciona .env ao gitignore"

# 4. Se JÁ FEZ PUSH:
# - CRITICAL: Troque TODAS as credenciais no Supabase!
# - Delete e recrie as chaves
# - Atualize seu .env local
```

---

## 📊 **VARIÁVEIS DISPONÍVEIS:**

| Variável | Descrição | Obrigatório |
|----------|-----------|-------------|
| `SUPABASE_URL` | URL do projeto Supabase | ✅ Sim |
| `SUPABASE_ANON_KEY` | Chave pública Supabase | ✅ Sim |
| `AGORA_APP_ID` | ID do Agora (video call) | ❌ Opcional |
| `ENV` | Ambiente (development/production) | ❌ Auto-detectado |

---

## 🎯 **CHECKLIST PRÉ-DEPLOY:**

Antes de fazer build para produção:

- [ ] .env está no .gitignore
- [ ] .env NÃO foi commitado
- [ ] Credenciais Supabase estão corretas
- [ ] Testou localmente com .env
- [ ] Configurou variáveis para build script
- [ ] Build script funcionou
- [ ] App conecta ao Supabase em produção

---

## 💻 **EXEMPLO PRÁTICO COMPLETO:**

```bash
# DIA 1: Setup inicial
git clone https://github.com/jamesht509/Brasilmatch.git
cd Brasilmatch/flutter_app
cp .env.example .env
nano .env  # Adiciona credenciais
flutter pub get
flutter run  # Testa local

# DURANTE DESENVOLVIMENTO:
# - Usa .env local
# - git push não envia .env (está no .gitignore)

# QUANDO FOR LANÇAR:
export SUPABASE_URL=https://prod.supabase.co
export SUPABASE_ANON_KEY=prod-key-here
./scripts/build-ios-production.sh

# Resultado: App com credenciais compiladas!
```

---

**Resumo:** Desenvolvimento usa `.env` local, Produção usa `--dart-define` no build. Credenciais NUNCA vão pro Git! ✅
