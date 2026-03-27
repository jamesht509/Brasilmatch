# 🚀 Guia Rápido: Pegar Credenciais Supabase (3 minutos)

## 📋 PASSO 1: Criar Projeto Supabase

1. **Acesse:** https://supabase.com
2. **Login** (ou crie conta grátis)
3. Clique em **"New Project"**

```
┌─────────────────────────────────────┐
│  New Project                        │
├─────────────────────────────────────┤
│  Name: BrasilMatch                  │
│  Database Password: [senha forte]   │
│  Region: East US (Closer to you)    │
│  Pricing Plan: Free                 │
│                                     │
│         [Create new project]        │
└─────────────────────────────────────┘
```

4. Aguarde ~2 minutos (criação do banco)

---

## 📋 PASSO 2: Executar Schema SQL

1. No dashboard do projeto, vá em: **SQL Editor** (menu lateral)
2. Clique em **"New Query"**
3. Abra o arquivo: `Brasilmatch/supabase/migrations/001_initial_schema.sql`
4. **Copie TODO o conteúdo** (Cmd+A / Ctrl+A)
5. **Cole** no SQL Editor do Supabase
6. Clique em **"Run"** (botão verde, canto inferior direito)

```
┌────────────────────────────────────────────┐
│ SQL Editor                           [Run] │
├────────────────────────────────────────────┤
│                                            │
│ -- BrasilMatch Database Schema            │
│ CREATE TABLE IF NOT EXISTS public.users...│
│ [todo o SQL aqui]                          │
│                                            │
│                                            │
└────────────────────────────────────────────┘
```

7. Deve aparecer: **"Success. No rows returned"** ✅

---

## 📋 PASSO 3: Copiar Credenciais (IMPORTANTE!)

1. Vá em: **Settings** (⚙️ menu lateral) > **API**

2. **Copie estas 2 informações:**

```
┌─────────────────────────────────────────────────┐
│ Project API                                     │
├─────────────────────────────────────────────────┤
│                                                 │
│ Project URL:                                    │
│ ┌─────────────────────────────────────────┐   │
│ │ https://xyzabc123.supabase.co           │ ← COPIE ISTO
│ └─────────────────────────────────────────┘   │
│                                                 │
│ API Keys:                                       │
│                                                 │
│ anon public                                     │
│ ┌─────────────────────────────────────────┐   │
│ │ eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVC...   │ ← COPIE ISTO
│ └─────────────────────────────────────────┘   │
│                                                 │
└─────────────────────────────────────────────────┘
```

**IMPORTANTE:**
- ✅ Copie a chave **"anon public"** (NÃO a "service_role")
- ✅ A chave começa com `eyJ...` e é LONGA (~200+ caracteres)

---

## 📋 PASSO 4: Colar no .env

1. Abra: `Brasilmatch/flutter_app/.env` (que acabei de criar)

2. **Encontre estas linhas:**

```env
SUPABASE_URL=https://seu-projeto-id-aqui.supabase.co
SUPABASE_ANON_KEY=sua-chave-anon-publica-aqui
```

3. **Substitua com o que você copiou:**

```env
# ANTES (placeholder):
SUPABASE_URL=https://seu-projeto-id-aqui.supabase.co
SUPABASE_ANON_KEY=sua-chave-anon-publica-aqui

# DEPOIS (suas credenciais reais):
SUPABASE_URL=https://xyzabc123.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh5emFiYzEyMyIsInJvbGUiOiJhbm9uIiwiaWF0IjoxNjQwMDAwMDAwLCJleHAiOjE5NTU1NzYwMDB9.xxxxxxxxxxxxxxxxxxxx
```

4. **Salve o arquivo** (Cmd+S / Ctrl+S)

---

## 📋 PASSO 5: Testar Conexão

```bash
cd Brasilmatch/flutter_app
flutter pub get
flutter run
```

**Deve aparecer no console:**

```
📱 BrasilMatch Config:
   Environment: development
   Supabase URL: https://xyzabc123.supabase...
   Has Anon Key: true
   Has Agora ID: false
```

✅ **Se apareceu isso = FUNCIONOU!**

---

## 🚨 ERROS COMUNS:

### ❌ "SUPABASE_URL não configurado"
**Solução:** Verifique se você colou o URL no .env

### ❌ "Connection failed"
**Solução:** 
- Verifique se o URL está COMPLETO (https://...)
- Verifique se o projeto Supabase está ativo (não pausado)

### ❌ "Invalid API key"
**Solução:**
- Verifique se copiou a chave **"anon public"** (não service_role)
- Verifique se copiou a chave COMPLETA (ela é LONGA!)

---

## ✅ CHECKLIST:

- [ ] Criei projeto no Supabase
- [ ] Executei o SQL schema (001_initial_schema.sql)
- [ ] SQL retornou "Success"
- [ ] Copiei Project URL
- [ ] Copiei anon public key (começa com eyJ...)
- [ ] Colei ambos no .env
- [ ] Salvei o arquivo .env
- [ ] Rodei `flutter run`
- [ ] App conectou ao Supabase ✅

---

## 📸 ONDE ENCONTRAR NO SUPABASE:

```
Dashboard Supabase:
├── Home
├── Table Editor
├── SQL Editor          ← PASSO 2: Execute SQL aqui
├── Database
├── Storage
├── Authentication
├── Edge Functions
└── Settings
    ├── General
    ├── API             ← PASSO 3: Copie credenciais aqui
    │   ├── Project URL
    │   └── API Keys
    │       └── anon public  ← COPIE ESTA!
    ├── Database
    └── Billing
```

---

**Tempo total:** ~3-5 minutos

**Dúvidas?** Me avise!
