<p align="center">
  <img src="https://raw.githubusercontent.com/Puerix/puerix-sdk-ios/main/PuerixAuth.xcframework/ios-arm64/PuerixAuth.framework/puerix_mark.png" width="80" />
</p>

<h1 align="center">PuerixSDK — iOS</h1>

<p align="center">
  <img src="https://img.shields.io/badge/platform-iOS%2013%2B-blue" />
  <img src="https://img.shields.io/badge/swift-5.7-orange" />
  <img src="https://img.shields.io/badge/version-0.2.0-green" />
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
- **Tema personalizável** — Adeque as cores das telas à identidade visual do seu app (ver [Customização visual](#customização-visual))

---

## Instalação

### CocoaPods

```ruby
# Podfile
pod 'PuerixSDK', :git => 'https://github.com/Puerix/puerix-sdk-ios.git', :tag => '0.2.0'
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

> **Nota:** o SDK não tem dependências de terceiros — a detecção facial e o OCR usam
> o framework **Vision** da Apple. Não é preciso instalar nada além do pacote, e o
> binário roda em simuladores Apple Silicon (incl. iOS 26 / iPhone 17) sem workarounds.

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

---

## Customização visual

As telas nativas usam a **paleta Puerix por padrão**. Para adequá-las à identidade visual do seu app, defina `PuerixTheme.active` **antes** do `initialize`. Use `PuerixTheme.default` para reaproveitar as cores que não quiser sobrescrever:

```swift
PuerixTheme.active = PuerixTheme(
    primary:    UIColor(red: 0.85, green: 0.11, blue: 0.38, alpha: 1), // ações primárias
    accent:     UIColor(red: 1.00, green: 0.43, blue: 0.00, alpha: 1), // destaque / "detectando"
    success:    UIColor(red: 0.00, green: 0.78, blue: 0.33, alpha: 1), // sucesso / step OK
    text:       PuerixTheme.default.text,        // mantém o padrão Puerix
    background: PuerixTheme.default.background    // mantém o padrão Puerix
)

PuerixSDK.shared.initialize(config: PuerixConfig(apiKey: "SUA_API_KEY"))
```

### Tokens de cor

| Token | Default Puerix | Onde aparece |
|-------|----------------|--------------|
| `primary` | `#2C7DA0` | Ações primárias, captura de documento |
| `accent` | `#61C0BF` | Borda "detectando", destaques |
| `success` | `#468C8B` | Borda OK, steps concluídos, textos de sucesso |
| `text` | `#1A3B5D` | Labels escuros sobre fundo claro |
| `background` | `#F4F7F6` | Fundos claros |

> Sem definir `PuerixTheme.active`, as telas mantêm o visual Puerix padrão.

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

> As versões 0.1.x foram retiradas de distribuição por motivos de segurança. Use sempre 0.2.0+.

### 0.2.0
- **Detecção facial migrada para o Apple Vision** (sem Google ML Kit) — o binário passa a incluir o slice de **simulador arm64**, rodando em simuladores Apple Silicon, incluindo **iOS 26 / iPhone 17**, sem o workaround `EXCLUDED_ARCHS`. O SPM funciona sem dependências externas.
- **Botão de fechar (`✕`) na primeira tela** — permite voltar ao app a qualquer momento, inclusive antes de iniciar a verificação.
- **Verificação de qualidade da foto do documento mais robusta** — fotos desfocadas são rejeitadas com muito mais precisão (medida de foco por variância do Laplaciano).
- **Correção de crash da câmera de documento** em ciclos repetidos de captura/nova tentativa.
- **Removida a API pública de liveness standalone** (`startLiveness`) — a verificação facial roda apenas dentro do fluxo de verificação; o app integrador não recebe mais as fotos do usuário. Use `startVerification`.
- **Tema personalizável** via `PuerixTheme` — cores das telas nativas adequáveis à identidade visual do app (paleta Puerix como padrão)
- Correção de layout: botão de fechar (`✕`) sobreposto à logo na tela de verificação

### 0.1.0
- Liveness detection (3 steps: olhar, virar esquerda, virar direita)
- Captura de documento com OCR (CPF)
- Verificação de qualidade de imagem
- Integração completa com API Puerix
- Distribuição via XCFramework (closed-source)

---

## Licença

Copyright (c) 2026 Puerix. Todos os direitos reservados. Licença proprietária.
