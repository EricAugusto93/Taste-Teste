# Guia de Instalação Flutter - Windows

## 🚀 Opção 1: Instalação Rápida (Recomendada)

### Método 1: Via Chocolatey (Mais Fácil)
```powershell
# 1. Instalar Chocolatey (se não tiver)
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# 2. Instalar Flutter
choco install flutter

# 3. Verificar instalação
flutter --version
```

### Método 2: Download Manual
```bash
# 1. Baixar Flutter SDK
# Ir para: https://docs.flutter.dev/get-started/install/windows
# Baixar o zip da versão estável

# 2. Extrair para C:\flutter (ou outro local)

# 3. Adicionar ao PATH
# Windows Settings > System > Advanced > Environment Variables
# Adicionar C:\flutter\bin ao PATH

# 4. Verificar
flutter --version
```

## 📱 Configuração para Android

### Android Studio (Recomendado)
```bash
# 1. Baixar Android Studio
# https://developer.android.com/studio

# 2. Instalar e configurar SDK
# Tools > SDK Manager
# Instalar Android SDK Platform-Tools
# Instalar pelo menos API 33 (Android 13)

# 3. Configurar Flutter
flutter config --android-studio-dir="C:\Program Files\Android\Android Studio"

# 4. Aceitar licenças
flutter doctor --android-licenses
```

### Alternativa: Android SDK Command Line Tools
```bash
# Se não quiser Android Studio completo
# Baixar apenas Command Line Tools
# https://developer.android.com/studio#command-tools
```

## 🌐 Alternativas Sem Instalação

### Option 1: DartPad (Testar Código Dart)
```
https://dartpad.dev/
# Limitado para testar lógica, sem UI Flutter
```

### Option 2: Flutter Web Online
```
https://flutter.dev/web
# Pode testar alguns conceitos básicos
```

### Option 3: GitHub Codespaces
```bash
# Fork do projeto no GitHub
# Abrir em Codespaces
# Flutter já vem pré-instalado
```

## 🔧 Verificação Completa

### Executar Flutter Doctor
```bash
flutter doctor
```

### Resultado Esperado:
```
Doctor summary (to see all details, run flutter doctor -v):
[✓] Flutter (Channel stable, 3.16.x)
[✓] Windows Version (Installed version of Windows is version 10 or higher)
[✓] Android toolchain - develop for Android devices
[✓] Chrome - develop for the web
[✓] Visual Studio - develop for Windows
[✓] Android Studio (version 2022.3)
[✓] VS Code (version 1.84)
[✓] Connected device (1 available)
[✓] Network resources

• No issues found!
```

## 🚀 Executar o Gastro App

### Após instalação completa:
```bash
# 1. Navegar para o projeto
cd C:\Users\Eric\Desktop\APP\gastro_app

# 2. Instalar dependências
flutter pub get

# 3. Verificar dispositivos disponíveis
flutter devices

# 4. Executar no emulador Android
flutter run

# 5. Ou executar no Chrome (Web)
flutter run -d chrome

# 6. Ou criar build para release
flutter build apk --release
```

## 📱 Configurar Emulador Android

### Via Android Studio:
```
1. Abrir Android Studio
2. Tools > AVD Manager
3. Create Virtual Device
4. Escolher Pixel 6 Pro (ou similar)
5. Download API 33 (Android 13)
6. Finish e Start
```

### Via Command Line:
```bash
# Listar alvos disponíveis
flutter emulators

# Criar emulador
flutter emulators --create --name gastro_emulator

# Executar emulador
flutter emulators --launch gastro_emulator

# Executar app no emulador
flutter run
```

## 🐛 Solução de Problemas Comuns

### Problema: "cmdlet não reconhecido"
```powershell
# Verificar PATH
echo $env:PATH

# Adicionar Flutter ao PATH (temporário)
$env:PATH += ";C:\flutter\bin"

# Verificar novamente
flutter --version
```

### Problema: Android SDK não encontrado
```bash
# Configurar manualmente
flutter config --android-sdk "C:\Users\%USERNAME%\AppData\Local\Android\Sdk"
```

### Problema: Licenças Android
```bash
# Aceitar todas as licenças
flutter doctor --android-licenses
# Apertar 'y' para todas
```

### Problema: Dependências não instaladas
```bash
# Limpar cache
flutter clean

# Reinstalar dependências
flutter pub get

# Verificar pubspec.yaml
flutter pub deps
```

## 🔥 Executar Gastro App - Comandos Completos

### Setup Inicial (Uma vez apenas):
```bash
# 1. Clonar/baixar projeto
cd C:\Users\Eric\Desktop\APP\gastro_app

# 2. Instalar dependências
flutter pub get

# 3. Configurar .env (opcional para IA)
copy env.example .env
# Editar .env com suas chaves de API

# 4. Verificar configuração
flutter doctor

# 5. Listar dispositivos
flutter devices
```

### Executar App:
```bash
# Android Emulador
flutter run

# Chrome Web
flutter run -d chrome

# Windows Desktop (se disponível)
flutter run -d windows

# Hot Reload durante desenvolvimento
# Pressionar 'r' no terminal para reload
# Pressionar 'R' para restart completo
```

## 🌟 Dicas de Desenvolvimento

### VS Code Extensions:
```
- Flutter
- Dart
- Flutter Widget Snippets
- Bracket Pair Colorizer
```

### Android Studio Plugins:
```
- Flutter
- Dart
- Flutter Inspector
```

### Comandos Úteis:
```bash
# Criar novo widget
flutter create --template=package my_widget

# Analisar código
flutter analyze

# Executar testes
flutter test

# Build para produção
flutter build apk --release
flutter build appbundle --release
```

## 📞 Suporte

Se continuar com problemas:

1. **Flutter Doctor**: `flutter doctor -v` (output completo)
2. **Logs**: `flutter run --verbose`
3. **Documentação**: https://docs.flutter.dev/get-started/install/windows
4. **Community**: https://stackoverflow.com/questions/tagged/flutter

---

## ⚡ TL;DR - Comandos Rápidos

```powershell
# Instalar Flutter (Chocolatey)
choco install flutter

# Setup projeto
cd gastro_app
flutter pub get

# Executar
flutter run
``` 