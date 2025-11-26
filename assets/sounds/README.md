# Sons de Alarme

Esta pasta contém os arquivos de áudio para os alarmes de medicamentos.

## Sons Padrão Recomendados

Adicione os seguintes arquivos de áudio nesta pasta:

### 1. gentle_bell.mp3
- Tom suave de sino
- Duração: 3-5 segundos
- Volume: Moderado
- **Padrão do aplicativo**

### 2. chime.mp3
- Som de carrilhão delicado
- Duração: 2-3 segundos
- Volume: Suave

### 3. beep.mp3
- Bipe eletrônico simples
- Duração: 1-2 segundos
- Volume: Alto

### 4. alarm_clock.mp3
- Som de despertador tradicional
- Duração: 3-4 segundos
- Volume: Alto

### 5. notification.mp3
- Tom de notificação suave
- Duração: 1-2 segundos
- Volume: Moderado

## Requisitos dos Arquivos

- **Formato**: MP3 ou WAV
- **Taxa de bits**: 128-320 kbps (MP3)
- **Taxa de amostragem**: 44.1kHz ou 48kHz
- **Canais**: Mono ou Estéreo
- **Tamanho máximo**: 500KB por arquivo

## Fontes Gratuitas de Sons

- **Freesound.org**: https://freesound.org
- **Zapsplat.com**: https://www.zapsplat.com
- **Soundbible.com**: http://soundbible.com

## Licença

Certifique-se de usar apenas sons com licença compatível:
- CC0 (Domínio Público)
- CC BY (Com atribuição)
- Licenças comerciais gratuitas

## Integração

Os arquivos devem ser referenciados no código como:
```dart
'assets/sounds/nome_do_arquivo.mp3'
```

## Android

Para Android, os sons também precisam estar em `android/app/src/main/res/raw/`
para notificações nativas. Copie os arquivos (sem extensão) para essa pasta.

Por exemplo:
- `assets/sounds/gentle_bell.mp3` → `android/app/src/main/res/raw/gentle_bell`

## iOS

Para iOS, os sons funcionam diretamente da pasta assets.

## Placeholder

NOTA: Esta é uma pasta placeholder. Você precisa adicionar os arquivos de áudio reais
para que os alarmes funcionem com som personalizado. Enquanto isso, o sistema usará
o som de notificação padrão do dispositivo.
