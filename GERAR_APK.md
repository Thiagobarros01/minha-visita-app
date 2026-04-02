# 📱 GERAR APK - Guia Final

## ✅ Mobile está pronto!

✅ Porta: 8080  
✅ IP GCP: 34.95.224.29  
✅ Apontando correto: `http://34.95.224.29:8080`

---

## 🚀 Gerar APK Release

Na pasta `mobile/`:

```bash
cd mobile
flutter clean
flutter pub get
flutter build apk --release
```

---

## 📍 Onde o APK fica:

```
mobile/build/app/outputs/flutter-apk/app-release.apk
```

---

## 📲 Instalar em Device:

```bash
flutter install -v
# Ou via adb:
adb install -r mobile/build/app/outputs/flutter-apk/app-release.apk
```

---

## 🔧 Se precisar mudar IP:

No arquivo `mobile/lib/main.dart`, linha ~30:

```dart
const String GCP_IP = '34.95.224.29'; // Mude aqui
```

Depois recompile.

---

## 🧑‍💼 Controle de Acesso:

**Superadmin (criado automaticamente):**
```
admin@admin.com / 123
```

**Usuários de teste (criar via API ou app):**
```
admin@nevt.com.br / 123 (ADMIN)
operador@nevt.com.br / 123 (OPERADOR)
```

---

## ✅ Checklist Antes de Compilar:

- [ ] Backend rodando em http://34.95.224.29:8080
- [ ] Firewall porta 8080 aberto no GCP
- [ ] `flutter --version` mostra versão recente
- [ ] `flutter pub get` sem erros
- [ ] Emulator ou device conectado

---

**Pronto pra gerar APK! 🎉**
