# ✅ CHECKLIST FINAL - Deployment Completo

## ✅ Fase 1: Backend (COMPLETA)

- ✅ Docker build bem-sucedido
- ✅ Containers rodando (2x Up)
- ✅ Spring Boot iniciado em 13.2 segundos
- ✅ PostgreSQL healthy
- ✅ Porta 8080 escutando
- ✅ Database inicializado

**Status:** 🟢 PRONTO

---

## ⏳ Fase 2: Firewall (PENDENTE)

**O que fazer:**

1. Abra: https://console.cloud.google.com/networking/firewalls
2. **CREATE FIREWALL RULE**
3. Preencha exatamente:
   - Name: `allow-minhavisita`
   - Direction: **Ingress**
   - Target: **All instances in the network**
   - Source IP ranges: `0.0.0.0/0`
   - Protocols and ports: **TCP: 8080**
4. **CREATE**

⏱️ Espere 1-2 minutos para a regra ser aplicada

---

## ⏳ Fase 3: Validação (PENDENTE)

**No seu PC (PowerShell ou Terminal):**

```bash
# Testar acesso remoto
curl http://34.95.224.29:8080/actuator/health

# Esperado: {"status":"UP"}
```

Se retornar erro `Connection refused`, firewall ainda não está pronto. Espere mais.

---

## ⏳ Fase 4: Mobile (PENDENTE)

**Instalar APK no device:**

```bash
adb install -r mobile/build/app/outputs/flutter-apk/app-release.apk
```

**OU no GCP terminal:**

```bash
flutter install -v
```

---

## ⏳ Fase 5: Teste Final (PENDENTE)

**No app mobile:**

1. Aguarde carregar
2. Preencha:
   - Email: `admin@nevt.com.br`
   - Senha: `123`
3. Clique: **Entrar**

✅ Se login funcionar = **SUCESSO!**

---

## 📋 Resumo de Status

| Fase | Status | Ação |
|------|--------|------|
| Backend | ✅ Online | Nada (já feito) |
| Firewall | ⏳ Pendente | Criar no GCP Console |
| Validação | ⏳ Pendente | Testar curl |
| Mobile | ⏳ Pendente | Instalar APK |
| Login | ⏳ Pendente | Fazer teste |

---

## 🚨 Se algo não funcionar:

**Firewall não funciona mesmo após 5 min:**

```bash
# No GCP terminal, deletar regra antiga
gcloud compute firewall-rules delete allow-minhavisita

# Recriar
gcloud compute firewall-rules create allow-minhavisita \
  --allow=tcp:8080 \
  --source-ranges=0.0.0.0/0

# Verificar
gcloud compute firewall-rules describe allow-minhavisita
```

**Backend para de responder:**

```bash
docker-compose restart backend
```

**APK não conecta mesmo com firewall aberto:**

Verificar IP no GCP:
```bash
curl -s ifconfig.me
# Se não for 34.95.224.29, atualizar em mobile/lib/main.dart
```

---

## ✅ Próximas Ações

1. ⏳ Abrir firewall
2. ⏳ Testar curl
3. ⏳ Instalar APK
4. ⏳ Fazer login
5. ✅ Pronto!

---

**Me avisa quando cada fase ficar pronta!** 🚀
