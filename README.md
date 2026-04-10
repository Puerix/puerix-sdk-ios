<p align="center">
  <img src="https://raw.githubusercontent.com/Puerix/puerix-sdk-ios/main/PuerixAuth.xcframework/ios-arm64/PuerixAuth.framework/puerix_mark.png" width="80" />
</p>

<h1 align="center">PuerixSDK — iOS</h1>

<p align="center">
  <img src="https://img.shields.io/badge/platform-iOS%2013%2B-blue" />
  <img src="https://img.shields.io/badge/swift-5.7-orange" />
  <img src="https://img.shields.io/badge/version-0.1.0-green" />
  <img src="https://img.shields.io/badge/license-Proprietary-red" />
</p>

<p align="center">
  SDK nativo iOS para verificação de idade com detecção de vida (liveness) e captura de documentos.
</p>

---

## Funcionalidades

- **Liveness Detection** — Verificação facial com rastreamento de rosto e movimentos da cabeça
- **Captura de Documento** — Frente e verso com guia visual e verificação de qualidade
- **OCR** — Extração automática do CPF via reconhecimento de texto
- **Integração com API** — Sessão, upload de frames, validação de documento
- **UI nativa** — Telas prontas em UIKit, com branding Puerix

---

## Instalação

### CocoaPods

```ruby
# Podfile
pod 'PuerixSDK', :git => 'https://github.com/Puerix/puerix-sdk-ios.git', :tag => '0.1.0'
```

Depois execute:

```bash
pod install
```

### Swift Package Manager

No Xcode: **File > Add Package Dependencies** e insira:

```
https://github.com/Puerix/puerix-sdk-ios.git
```

> **Nota:** Google ML Kit não suporta SPM. Instale separadamente via CocoaPods:
> ```ruby
> pod 'GoogleMLKit/FaceDetection', '~> 6.0'
> ```

---

## Uso rápido

```swift
import PuerixAuth
```

### 1. Inicializar o SDK

Chame uma vez, idealmente no `AppDelegate`:

```swift
PuerixSDK.shared.initialize(config: PuerixConfig(
    apiKey: "SUA_API_KEY",
    environment: .production,  // ou .development
    enableLogging: true        // false em produção
))
```

### 2. Verificação completa (recomendado)

Inicia o fluxo completo: sessão → liveness → upload → documento (se necessário) → resultado.

```swift
PuerixSDK.shared.startVerification(
    from: viewController,
    subject: "user-123",
    ageLimit: 18
) { result in
    if result.isApproved {
        print("Aprovado! Session: \(result.sessionId)")
    } else {
        print("Não aprovado: \(result.status)")
        if let error = result.errorMessage {
            print("Erro: \(error)")
        }
    }
}
```

### 3. Apenas liveness (sem API)

Se quiser usar só a detecção facial sem integração com a API:

```swift
PuerixSDK.shared.startLiveness(from: viewController) { result in
    if result.isComplete {
        print("Capturas: \(result.captures.keys)")
        // result.captureData["lookAtCamera"] → Data (JPEG)
    }
}
```

---

## Referência da API

### PuerixConfig

| Parâmetro | Tipo | Padrão | Descrição |
|-----------|------|--------|-----------|
| `apiKey` | `String` | — | Chave de API (obrigatório) |
| `environment` | `.production` / `.development` | `.production` | Ambiente da API |
| `baseUrl` | `String?` | `nil` | URL customizada (usa o padrão do environment) |
| `timeout` | `TimeInterval` | `30` | Timeout de rede em segundos |
| `enableLogging` | `Bool` | `false` | Habilita logs no console |

### startVerification

```swift
func startVerification(
    from viewController: UIViewController,
    subject: String,               // Identificador do usuário
    ageLimit: Int = 18,            // Idade mínima (10-21)
    steps: [PuerixLivenessStep],   // Passos do liveness
    stepDuration: TimeInterval = 3,// Duração por passo
    callbackUrl: String? = nil,    // URL de callback (opcional)
    cancelUrl: String? = nil,      // URL de cancelamento (opcional)
    completion: @escaping (PuerixVerificationResult) -> Void
)
```

### PuerixVerificationResult

| Propriedade | Tipo | Descrição |
|-------------|------|-----------|
| `sessionId` | `String` | ID da sessão no backend |
| `status` | `String` | `approved`, `denied`, `requires_doc`, `cancelled` |
| `isApproved` | `Bool` | Se a verificação foi aprovada |
| `errorMessage` | `String?` | Mensagem de erro (se houver) |

### PuerixLivenessStep

| Step | Descrição |
|------|-----------|
| `.lookAtCamera` | Olhar para a câmera |
| `.turnHeadLeft` | Virar a cabeça para a esquerda |
| `.turnHeadRight` | Virar a cabeça para a direita |

### PuerixLivenessResult

| Propriedade | Tipo | Descrição |
|-------------|------|-----------|
| `isComplete` | `Bool` | Se completou todos os passos |
| `isApproved` | `Bool` | Se o backend aprovou |
| `captures` | `[String: UIImage]` | Fotos capturadas por step |
| `captureData` | `[String: Data]` | JPEG data por step |

---

## Fluxo de verificação

```
┌─────────────┐     ┌──────────┐     ┌──────────────┐     ┌──────────────┐
│  Iniciar    │────>│ Liveness │────>│   Upload     │────>│  Resultado   │
│ Verificação │     │ (3 steps)│     │   Frames     │     │  approved/   │
└─────────────┘     └──────────┘     └──────┬───────┘     │  denied      │
                                            │              └──────────────┘
                                            │ requires_doc
                                            v
                                     ┌──────────────┐     ┌──────────────┐
                                     │  Documento   │────>│  Validação   │
                                     │ (frente+verso│     │  CPF + foto  │
                                     │  + OCR CPF)  │     └──────────────┘
                                     └──────────────┘
```

---

## Permissões

Adicione ao `Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>Necessário para verificação de identidade</string>
```

---

## Troubleshooting

| Erro | Causa | Solução |
|------|-------|---------|
| `401 Unauthorized` | API key inválida | Verifique a chave no painel Puerix |
| `403 Forbidden` | Limite atingido ou conta bloqueada | Verifique seu plano |
| `Session token não disponível` | `startVerification` sem `initialize` | Chame `initialize()` primeiro |
| Camera permission denied | Usuário negou acesso | Adicione `NSCameraUsageDescription` |

---

## Requisitos

- iOS 13.0+
- Xcode 14+
- Swift 5.7+
- API key — solicite em [puerix.com](https://puerix.com)

---

## Changelog

### 0.1.0
- Liveness detection (3 steps: olhar, virar esquerda, virar direita)
- Captura de documento com OCR (CPF)
- Verificação de qualidade de imagem
- Integração completa com API Puerix
- Distribuição via XCFramework (closed-source)

---

## Licença

Copyright (c) 2026 Puerix. Todos os direitos reservados. Licença proprietária.
