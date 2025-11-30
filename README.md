# Audio Mixer App

O Audio Mixer App é uma aplicação nativa para macOS desenvolvida em
SwiftUI que permite misturar dois ficheiros de áudio: uma faixa de fundo
(Original) e uma faixa de voz (Voz). A funcionalidade principal é o
ducking inteligente, que reduz automaticamente o volume da faixa de
fundo quando a voz é detetada na faixa de voz, garantindo que a voz se
destaque na mistura final.

## ⚙️ Requisitos

Para compilar e executar o projeto, necessita das seguintes versões
mínimas:

  -------------- -----------------
  Requisito      Versão Mínima

  Sistema        macOS 14.0
  Operativo      (Sonoma)

  Xcode          15.0

  Swift          5.9
  -------------- -----------------

## 🚀 Instalação

Siga os passos abaixo para configurar o projeto localmente.

1.Clonar o Repositório

git clone https://github.com/carlneto/audio-mixer-app.git
cd audio-mixer-app

2.Abrir no Xcode

open AudioMixerApp.xcodeproj

3.Compilar e Executar

Selecione o seu destino (por exemplo, \"My Mac\" ) e clique em Run (ou
⌘R) para iniciar a aplicação.

## 🎙️ Uso

A interface de utilizador é simples e direta:

1.Selecionar Original: Clique em \"Selecionar Original\" para escolher o
ficheiro de áudio de fundo (música, efeitos, etc.).

2.Selecionar Voz: Clique em \"Selecionar Voz\" para escolher o ficheiro
de áudio com a voz (narração, diálogo, etc.).

3.Selecionar Destino & Misturar Áudios: Clique neste botão para escolher
a localização onde o ficheiro de áudio misturado será guardado e iniciar
o processo de mistura.

O processo de mistura é assíncrono e a aplicação irá notificar o
utilizador quando estiver concluído ou se ocorrer um erro.

## 📂 Estrutura do Projeto

O projeto segue uma estrutura modular típica de aplicações SwiftUI.

  --------------------- ------------------------------------------------------
  Ficheiro/Pasta        Descrição

  AudioMixerApp.swift   O ponto de entrada principal da aplicação, definindo a
                        estrutura da App.

  ContentView.swift     A vista principal da aplicação, contendo a interface
                        de utilizador para seleção de ficheiros e início da
                        mistura.

  MixerEngine.swift     (Implícito na ContentView) Contém a lógica de mistura
                        de áudio, utilizando AVFoundation para composição e
                        exportação.

  Resources/            Pasta para quaisquer assets da aplicação (ícones,
                        imagens, etc.).
  --------------------- ------------------------------------------------------

## ✨ Funcionalidades Principais

•Seleção de Ficheiros: Suporte para seleção de ficheiros de áudio comuns
(.aiff, .m4a, .mp3, .wav).

•Mistura de Áudio: Combinação de duas faixas de áudio usando
AVMutableComposition.

•Ducking Inteligente: Ajuste de volume dinâmico na faixa \"Original\"
com base na deteção de voz na faixa \"Voz\". O volume é reduzido para
0.05 quando a voz é detetada.

•Exportação: Exportação do resultado final para o formato .m4a.

### Exemplo de Lógica de Ducking (em mixAudioFilesWithVolumeAdjustment)

// Define the volume to apply to the original track when voice is detected
let detectedVolume: Float = 0.05 
// Define the volume to apply when no voice is detected
let normalVolume: Float = 1.0
// Define the threshold (in dB) below which audio is considered silence
let silenceThreshold: Float = -50.0

// ... (AVAssetReader setup)

// Iterate through audio samples to detect voice
while assetReader.status == .reading {
    // ... (read sample buffer and calculate RMS/dB)
    
    if db > silenceThreshold {
        // Voice detected: duck the original track volume
        parameters.setVolume(detectedVolume, at: currentTime)
    } else {
        // Silence: restore original track volume
        parameters.setVolume(normalVolume, at: currentTime)
    }
    // ... (update currentTime)
}

## ⚖️ Licença

Este projeto está coberto por uma Licença de Utilização Restrita.

Resumo da Licença:

•Proibições: É estritamente proibida a modificação, engenharia inversa,
distribuição, sublicenciamento, partilha pública ou privada, e qualquer
utilização comercial do software sem autorização expressa por escrito do
autor.

•Propriedade Intelectual: O software e o seu código-fonte são
propriedade exclusiva do autor. Não é concedida qualquer licença
implícita.

•Utilização Permitida: Apenas é permitida a utilização estritamente
pessoal, privada e não comercial, com o único propósito de avaliação e
testes. Qualquer outro uso requer autorização escrita.

•Isenção de Garantias: O software é fornecido \"tal como está\" (\"AS
IS\"), sem garantias de qualquer tipo.

•Limitação de Responsabilidade: O autor não é responsável por quaisquer
danos diretos ou indiretos resultantes da utilização ou impossibilidade
de utilização do software.

Para os termos completos, consulte o ficheiro LICENSE (não fornecido,
mas implícito).

## ✍️ Créditos/Autores

•Autor: carlneto

•Ano: 2025

•Tecnologias: Swift, SwiftUI, AVFoundation
