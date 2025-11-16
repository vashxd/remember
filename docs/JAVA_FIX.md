# Como Resolver o Problema do Java 25 no Android

## Problema

Você tem o **Java 25.0.1** instalado, mas o Kotlin (usado pelo Gradle/Android) não suporta esta versão ainda. O erro que aparece é:

```
FAILURE: Build failed with an exception.
* What went wrong:
25.0.1
```

## Solução: Instalar Java 21 LTS

### Passo 1: Baixar Java 21 LTS

1. Acesse: https://adoptium.net/temurin/releases/?version=21
2. Selecione:
   - **Version**: 21 - LTS
   - **Operating System**: Windows
   - **Architecture**: x64
   - **Package Type**: JDK
3. Clique em `.msi` para baixar o instalador

### Passo 2: Instalar Java 21

1. Execute o arquivo `.msi` baixado
2. **IMPORTANTE**: Durante a instalação, marque a opção:
   - ☑ **Set JAVA_HOME variable**
   - ☑ **Add to PATH**
3. Complete a instalação

### Passo 3: Verificar Instalação

Abra um **novo** terminal (PowerShell ou CMD) e execute:

```bash
java -version
```

Deve mostrar algo como:
```
openjdk version "21.0.x" 2024-xx-xx LTS
```

### Passo 4: Configurar o Projeto para Usar Java 21

Há 3 opções:

#### Opção A: Trocar Java Padrão do Sistema (Mais Simples)

Se você não usa Java 25 para outros projetos, pode desinstalar ou mudar a variável de ambiente:

1. Pressione `Win + R`
2. Digite `sysdm.cpl` e pressione Enter
3. Vá em **Variáveis de Ambiente**
4. Em **Variáveis do Sistema**, procure por `JAVA_HOME`
5. Edite para apontar para: `C:\Program Files\Eclipse Adoptium\jdk-21.x.x-hotspot`
6. Salve e **reinicie o terminal**

#### Opção B: Configurar Apenas Para Este Projeto

Edite o arquivo `android/gradle.properties` e adicione:

```properties
org.gradle.java.home=C:\\Program Files\\Eclipse Adoptium\\jdk-21.0.x-hotspot
```

(Substitua `21.0.x` pela versão exata instalada)

#### Opção C: Usar Variável Temporária (Para Testar)

No terminal, antes de rodar o Flutter:

```bash
set JAVA_HOME=C:\Program Files\Eclipse Adoptium\jdk-21.0.x-hotspot
set PATH=%JAVA_HOME%\bin;%PATH%
flutter run -d adb-0081786006-hA0DPM._adb-tls-connect._tcp
```

### Passo 5: Limpar Cache e Rodar

```bash
cd C:\Users\hscjr\Documents\remember
flutter clean
flutter pub get
flutter run -d adb-0081786006-hA0DPM._adb-tls-connect._tcp
```

## Por Que Java 25 Não Funciona?

- **Java 25** é uma versão **muito nova** (lançada em outubro/2025)
- **Kotlin** (linguagem usada pelo Android) ainda não tem suporte oficial
- **Gradle** e as ferramentas do Android foram testadas até Java 21
- **Java 21 LTS** é a versão **recomendada oficialmente** pela Google para Android

## Verificar Se Funcionou

Após seguir os passos acima, execute:

```bash
flutter run -d adb-0081786006-hA0DPM._adb-tls-connect._tcp
```

Você deve ver:
```
✓ Built build\app\outputs\flutter-apk\app-debug.apk
```

E o app deve instalar no seu celular!

## Alternativa: Manter Ambas as Versões

Se você precisa do Java 25 para outros projetos:

1. Instale Java 21 **sem** alterar JAVA_HOME global
2. Use a **Opção B** acima (configurar no projeto)
3. Ou crie um script `.bat` para trocar entre versões:

```bat
@echo off
set JAVA_HOME=C:\Program Files\Eclipse Adoptium\jdk-21.0.x-hotspot
set PATH=%JAVA_HOME%\bin;%PATH%
echo Java configurado para versão 21
java -version
```

Salve como `use-java21.bat` e execute antes de rodar o Flutter.

## Resumo Rápido

```bash
# 1. Baixar e instalar Java 21 LTS de https://adoptium.net
# 2. Verificar
java -version

# 3. Configurar projeto (escolha UMA opção)
# Opção A: Mudar JAVA_HOME global
# Opção B: Editar android/gradle.properties
# Opção C: Set temporário no terminal

# 4. Limpar e rodar
flutter clean
flutter run -d adb-0081786006-hA0DPM._adb-tls-connect._tcp
```

## Precisa de Ajuda?

Se ainda não funcionar após seguir os passos:

1. Verifique qual Java está sendo usado:
   ```bash
   java -version
   echo %JAVA_HOME%
   ```

2. Verifique o caminho do Java 21 instalado:
   ```bash
   dir "C:\Program Files\Eclipse Adoptium"
   ```

3. Tente limpar o cache do Gradle:
   ```bash
   cd android
   gradlew clean
   cd ..
   ```
