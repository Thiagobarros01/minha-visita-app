# Minha Visita Mobile (Flutter)

App simples para login + check-in/check-out com geolocalizacao.

## Como rodar

Antes de abrir o Flutter, suba o backend na raiz do projeto:

```powershell
mvn spring-boot:run
```

Depois rode o app mobile em outro terminal:

```bash
flutter create .
flutter pub get
flutter run
```

## Base URL

No `mobile/lib/main.dart` ajuste:

```
final _api = ApiClient('http://10.0.2.2:8081');
```

- Android Emulator: `10.0.2.2:8081`
- iOS Simulator: `http://localhost:8081`
- Dispositivo fisico: IP da sua maquina na rede local

## Permissoes de localizacao

Voce precisa adicionar as permissoes no Android e iOS do projeto Flutter real.
Como este e um esqueleto minimo, rode `flutter create .` dentro de `mobile` para gerar `android/` e `ios/`.
