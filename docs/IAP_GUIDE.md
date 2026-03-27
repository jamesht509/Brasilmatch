# 💳 In-App Purchase (IAP) - Guia de Implementação

Este guia cobre a implementação completa de compras de créditos no app.

## 📋 Overview

**Produtos:**
- `brasil_match_credits_20` - 20 créditos - $2.99
- `brasil_match_credits_50` - 50 créditos - $5.99  
- `brasil_match_credits_120` - 120 créditos - $9.99

**Tipo:** Consumable (podem comprar infinitas vezes)

---

## 🍎 Setup Apple (App Store Connect)

### 1. Create App in App Store Connect

1. Acesse [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
2. **My Apps** > **+** > **New App**
3. Preencha informações básicas

### 2. Configure In-App Purchases

1. Vá em **Features** > **In-App Purchases**
2. Clique em **+** para cada produto:

#### Produto 1: 20 Créditos
```
Product ID: brasil_match_credits_20
Reference Name: 20 Credits
Type: Consumable
Price: $2.99 (Tier 2)
Display Name: 20 Créditos
Description: Pacote de 20 créditos para usar no app
```

#### Produto 2: 50 Créditos
```
Product ID: brasil_match_credits_50
Reference Name: 50 Credits
Type: Consumable
Price: $5.99 (Tier 5)
Display Name: 50 Créditos
Description: Pacote de 50 créditos (melhor valor!)
```

#### Produto 3: 120 Créditos
```
Product ID: brasil_match_credits_120
Reference Name: 120 Credits
Type: Consumable
Price: $9.99 (Tier 9)
Display Name: 120 Créditos + 20 Bônus
Description: Pacote de 120 créditos com 20 de bônus!
```

### 3. Submit for Review

Após criar os produtos, submeta para revisão da Apple.

---

## 🤖 Setup Android (Google Play Console)

### 1. Create App in Play Console

1. Acesse [play.google.com/console](https://play.google.com/console)
2. **Create app**
3. Preencha informações básicas

### 2. Configure In-App Products

1. Vá em **Monetize** > **Products** > **In-app products**
2. **Create product** para cada um:

#### Produto 1: 20 Créditos
```
Product ID: brasil_match_credits_20
Name: 20 Créditos
Description: Pacote de 20 créditos
Price: $2.99
```

Repita para os outros produtos com os mesmos IDs.

---

## 💻 Implementação Flutter

### 1. Adicione Dependência (Já está no pubspec.yaml)

```yaml
dependencies:
  in_app_purchase: ^3.1.13
```

### 2. Crie IAP Service

`lib/services/iap_service.dart`:

```dart
import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class IAPService {
  final InAppPurchase _iap = InAppPurchase.instance;
  final SupabaseClient _supabase = Supabase.instance.client;
  
  // Product IDs
  static const String credits20 = 'brasil_match_credits_20';
  static const String credits50 = 'brasil_match_credits_50';
  static const String credits120 = 'brasil_match_credits_120';
  
  static const List<String> _productIds = [
    credits20,
    credits50,
    credits120,
  ];
  
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  
  /// Initialize IAP
  Future<void> initialize() async {
    final available = await _iap.isAvailable();
    if (!available) {
      throw Exception('Store não disponível');
    }
    
    // Listen to purchase updates
    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () => _subscription?.cancel(),
      onError: (error) => print('Purchase error: $error'),
    );
  }
  
  /// Get available products
  Future<List<ProductDetails>> getProducts() async {
    final response = await _iap.queryProductDetails(_productIds.toSet());
    
    if (response.error != null) {
      throw Exception('Erro ao carregar produtos: ${response.error}');
    }
    
    return response.productDetails;
  }
  
  /// Purchase a product
  Future<void> buyProduct(ProductDetails product) async {
    final purchaseParam = PurchaseParam(productDetails: product);
    await _iap.buyConsumable(purchaseParam: purchaseParam);
  }
  
  /// Handle purchase updates
  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) async {
    for (final purchase in purchaseDetailsList) {
      if (purchase.status == PurchaseStatus.purchased) {
        // Verify purchase with backend
        await _verifyPurchase(purchase);
        
        // Complete purchase
        await _iap.completePurchase(purchase);
      } else if (purchase.status == PurchaseStatus.error) {
        // Handle error
        print('Purchase error: ${purchase.error}');
      }
    }
  }
  
  /// Verify purchase and award credits
  Future<void> _verifyPurchase(PurchaseDetails purchase) async {
    try {
      // Determine credits amount
      int credits = 0;
      switch (purchase.productID) {
        case credits20:
          credits = 20;
          break;
        case credits50:
          credits = 50;
          break;
        case credits120:
          credits = 140; // 120 + 20 bonus
          break;
      }
      
      // Get current user
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;
      
      // Award credits (via Supabase Edge Function or direct update)
      await _supabase.rpc('award_credits', params: {
        'user_id': userId,
        'amount': credits,
        'transaction_type': 'purchase',
        'reference_id': purchase.purchaseID,
      });
    } catch (e) {
      print('Error verifying purchase: $e');
    }
  }
  
  /// Restore purchases
  Future<void> restorePurchases() async {
    await _iap.restorePurchases();
  }
  
  /// Dispose
  void dispose() {
    _subscription?.cancel();
  }
}
```

### 3. Crie Supabase Function para Award Credits

`supabase/functions/award_credits.sql`:

```sql
CREATE OR REPLACE FUNCTION award_credits(
  user_id UUID,
  amount INTEGER,
  transaction_type TEXT,
  reference_id TEXT
)
RETURNS VOID AS $$
BEGIN
  -- Add credits to user
  UPDATE users
  SET credits = credits + amount
  WHERE id = user_id;
  
  -- Record transaction
  INSERT INTO credits_transactions (user_id, amount, type, reference_id)
  VALUES (user_id, amount, transaction_type, reference_id);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### 4. Use no CreditsStoreScreen

Já implementado em `screens/credits/credits_store_screen.dart`!

Você só precisa substituir os `TODO` pelos métodos reais do `IAPService`.

---

## 🧪 Testando IAP

### iOS (Sandbox)

1. **App Store Connect** > **Users and Access** > **Sandbox Testers**
2. Crie um tester
3. No iPhone: **Settings** > **App Store** > **Sandbox Account**
4. Faça login com o tester
5. Rode o app e teste compras (são grátis no sandbox!)

### Android (Test)

1. **Play Console** > **Setup** > **License Testing**
2. Adicione seu email
3. Rode o app
4. Compras são grátis para testers!

---

## ✅ Compliance Checklist

Antes de submeter:

- ✅ Produtos criados em App Store Connect
- ✅ Produtos criados em Google Play Console
- ✅ Produtos aprovados (pode demorar alguns dias)
- ✅ IAP implementado no app
- ✅ Testado em sandbox (iOS) e test mode (Android)
- ✅ Restore purchases implementado
- ✅ Política de Privacidade atualizada
- ✅ Termos de Uso mencionam compras in-app

---

## 💰 Revenue

**Com comissão das lojas:**

| Preço | Apple/Google | Você recebe |
|-------|--------------|-------------|
| $2.99 | -$0.90 (30%) | $2.09       |
| $5.99 | -$1.80 (30%) | $4.19       |
| $9.99 | -$3.00 (30%) | $6.99       |

**Se faturar <$1M/ano: comissão cai para 15%!**

---

## 🚨 Problemas Comuns

### "Products not found"
- Aguarde aprovação dos produtos (até 24h)
- Verifique Product IDs exatos
- Teste em device físico (não emulador)

### "Cannot connect to iTunes Store" (iOS)
- Certifique-se que está em sandbox
- Logout e login novamente no sandbox account
- Use device físico, não simulator

### "Purchase failed"
- Verifique se o produto está ativo
- Teste com sandbox tester
- Verifique conexão internet

---

## 📊 Analytics Recomendadas

Track esses eventos:

- `credits_store_viewed` - Usuário abriu loja
- `credits_package_clicked` - Clicou em um pacote
- `purchase_initiated` - Iniciou compra
- `purchase_completed` - Compra finalizada
- `purchase_failed` - Compra falhou
- `purchase_restored` - Restaurou compras

Use Mixpanel, Amplitude ou Firebase Analytics.

---

**Próximo passo:** Implementar e testar! 🚀
