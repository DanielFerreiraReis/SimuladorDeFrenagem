# Simulador de Frenagem

Aplicativo em Flutter que acompanha o trabalho de Física I (UFPA, Campus de Tucuruí):
dois robôs freiam lado a lado, um **convencional** (rodas travadas, atrito cinético) e
outro com **ABS** (rodas rolando, atrito estático máximo), integrados pelo **método de Euler**.

## O que dá para fazer na tela

- Escolher **pista seca**, **gelo** ou **livre** (você ajusta μe e μc).
- Mover o **obstáculo** e ver a **colisão**, com velocidade e energia no impacto.
- Trocar o **passo de tempo** (0,1 / 0,01 / 0,001 s) e ver o erro do Euler contra a solução analítica.
- **Arrastar a linha do tempo**, pausar, reiniciar e mudar a velocidade da animação.
- Alternar o gráfico entre **velocidade** e **distância**.
- Ver a roda **travada** (convencional) × **rolando** (ABS) e as marcas de pneu.

## Estrutura de pastas

```
simulador_frenagem/
├── lib/
│   ├── main.dart                     ponto de entrada
│   ├── app.dart                      MaterialApp e tema
│   ├── core/                         Dart puro (sem Flutter)
│   │   ├── simulacao.dart            núcleo: Euler + freio convencional x ABS (Quadro 3 do trabalho)
│   │   ├── analise.dart              interpolação, impacto, distância analítica
│   │   ├── cenarios.dart             pistas (seca, gelo, livre)
│   │   └── formatacao.dart           números com vírgula
│   ├── state/
│   │   └── simulador_controller.dart parâmetros, resultados e relógio da animação
│   └── ui/
│       ├── tema.dart                 paleta de cores
│       ├── tela_inicial.dart         layout responsivo (2 colunas no desktop)
│       ├── widgets/                  painéis, cartões e controles
│       └── pintores/                 pista animada e gráfico (CustomPainter)
├── test/                             testes automáticos
├── tool/verificar.dart               verificação do núcleo (roda sem Flutter)
├── setup_windows.bat                 gera o .exe com duplo clique
└── .github/workflows/                gera o .exe na nuvem (GitHub Actions)
```

## Rodar no computador

```bash
flutter create --platforms=windows --project-name simulador_frenagem .   # só na primeira vez
flutter pub get
flutter run -d windows
```

Para conferir o núcleo sem abrir a tela: `dart tool/verificar.dart`.

## Gerar o .exe para o professor

**Opção 1: duplo clique (precisa do Flutter e do Visual Studio no seu PC).**
Dê duplo clique em `setup_windows.bat`. Ele cria a pasta `windows`, compila em release e gera
`SimuladorFrenagem_Windows.zip`. O executável fica em
`build\windows\x64\runner\Release\simulador_frenagem.exe`.

**Opção 2: comandos manuais.**

```bash
flutter create --platforms=windows --project-name simulador_frenagem .
flutter pub get
flutter build windows --release
```

**Opção 3: na nuvem, sem instalar nada.** Envie esta pasta para um repositório no GitHub.
Em **Actions > Gerar executável do Windows > Run workflow**, espere terminar e baixe o artefato
`SimuladorFrenagem_Windows`.

### Como entregar

O `.exe` **não funciona sozinho**: ele precisa da pasta inteira (`.dll` e `data`).
Mande o **zip** (`SimuladorFrenagem_Windows.zip`). O professor extrai e abre
`simulador_frenagem.exe`, sem instalar o Flutter. Funciona no Windows 10 ou 11 de 64 bits.

## Problemas comuns

| Sintoma | O que fazer |
|---|---|
| `flutter` não é reconhecido | Instale o Flutter e coloque a pasta `bin` no PATH |
| Erro de compilador C++ | Visual Studio 2022 com a carga "Desenvolvimento para desktop com C++" (`flutter doctor`) |
| Janela abre e fecha | Rode `flutter run -d windows` e leia o erro no terminal |
| O professor não consegue abrir | Ele precisa extrair o zip completo antes de abrir o `.exe` |

## Modelo físico

Massa 10 kg, velocidade inicial 5 m/s, força de frenagem 150 N, g = 9,8 m/s². A cada passo Δt:
`distância += velocidade · Δt` e `velocidade += aceleração · Δt`, com `aceleração = −atrito / massa`.
O atrito é o cinético (rodas travadas) ou o estático máximo (ABS ideal). Os coeficientes μe e μc
de seca e gelo são os da Etapa 2 do trabalho.
