# ⚡ SETUP RÁPIDO - 30 MINUTOS

## ✅ CHECKLIST:

### □ PASSO 1: Supabase (5 min)
1. [ ] Acesse https://supabase.com
2. [ ] Clique em "New Project"
3. [ ] Nome: BrasilMatch
4. [ ] Password: [crie uma senha forte]
5. [ ] Region: East US
6. [ ] Aguarde 2 minutos
7. [ ] SQL Editor > New Query
8. [ ] Copie TUDO de: `supabase/migrations/001_initial_schema.sql`
9. [ ] Cole no editor
10. [ ] Clique RUN
11. [ ] Deve aparecer: "Success" ✅

### □ PASSO 2: Credenciais (2 min)
1. [ ] Settings > API
2. [ ] Copie "Project URL"
3. [ ] Copie "anon public" key
4. [ ] Abra: `flutter_app/.env`
5. [ ] Cole as credenciais
6. [ ] Salve o arquivo

### □ PASSO 3: Teste (5 min)
1. [ ] `flutter run`
2. [ ] Criar conta (email + senha)
3. [ ] Completar perfil
4. [ ] Ver tela de swipe
5. [ ] App conectado ao Supabase! ✅

---

## 📝 COMANDOS:

```bash
# Terminal 1 - Rodar app
cd Brasilmatch/flutter_app
flutter run -d chrome

# Terminal 2 - Ver logs
flutter logs
```

---

## 🎯 RESULTADO ESPERADO:

Depois desses 3 passos:

✅ App rodando  
✅ Backend conectado  
✅ Pode criar usuários  
✅ Pode testar features  

**Pronto para usar!** 🎉

---

## 🐛 TROUBLESHOOTING:

### "Connection failed"
- Verifique se SUPABASE_URL está correto
- Deve começar com https://

### "Invalid API key"
- Verifique se copiou a chave "anon public"
- Ela deve começar com "eyJ..."

### "SQL execution failed"
- Certifique-se que copiou TODO o SQL
- O arquivo tem ~350 linhas

---

## 💡 DICA:

Use 2 terminais:
- Terminal 1: `flutter run` (deixe rodando)
- Terminal 2: Comandos diversos

Hot reload funciona! Só apertar 'r' após mudanças.

---

**Vamos fazer isso agora?** 🚀
