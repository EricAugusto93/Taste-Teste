# 🚀 Como Instalar o Flutter - Gastro App

## 📱 **Opção 1: Instalação Automática (5 minutos)**

### Via Chocolatey (Recomendado)
```powershell
# 1. Instalar Chocolatey (se não tiver)
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# 2. Instalar Flutter
choco install flutter

# 3. Verificar instalação
flutter --version
flutter doctor
```

### Via Winget (Windows 11)
```powershell
winget install --id=Google.Flutter
```

---

## 📥 **Opção 2: Download Manual (10 minutos)**

### 1. Baixar Flutter
- Acesse: https://docs.flutter.dev/get-started/install/windows
- Baixe o arquivo ZIP da versão estável
- **OU** use este link direto: https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.16.9-stable.zip

### 2. Extrair e Configurar
```powershell
# Extrair para C:\flutter
# Adicionar C:\flutter\bin ao PATH do sistema

# Verificar instalação
C:\flutter\bin\flutter.bat doctor
```

### 3. Configurar PATH Permanente
1. **Windows Settings** → **System** → **Advanced** → **Environment Variables**
2. Em **User Variables**, selecione **Path** → **Edit**
3. Clique **New** e adicione: `C:\flutter\bin`
4. **OK** em todas as janelas
5. **Reinicie o PowerShell**

---

## 🎨 **Testar Nova Identidade Visual**

### Depois de instalar o Flutter:

```powershell
# 1. Navegar para o projeto
cd gastro_app

# 2. Instalar dependências
flutter pub get

# 3. Executar o app (com nova identidade visual!)
flutter run
```

### 🌟 **O que você verá:**
- ✅ **Fundo em Areia Clara** (#FBE9D2)
- ✅ **AppBar Branca** com texto Azul Profundo
- ✅ **Botões Azul Profundo** (#2C3985)
- ✅ **Destaques Amarelo Mostarda** (#EE9D21)
- ✅ **Erros Vermelho Telha** (#D9502B)
- ✅ **Material Design 3** completo
- ✅ **Tipografia moderna** e acessível

---

## 🎯 **Alternativas Enquanto Instala**

### 1. Demo HTML (Funcionando Agora!)
A demo HTML já está aberta no seu navegador mostrando:
- ✨ Nova paleta de cores
- 🎨 Componentes interativos
- 📱 Interface responsiva

### 2. Visual Studio Code
- Instale a extensão **Flutter**
- Abra o projeto `gastro_app`
- Veja todos os arquivos da nova identidade visual

### 3. Showcase de Componentes
```dart
// Arquivo já criado: lib/widgets/design_showcase.dart
Navigator.push(context, MaterialPageRoute(
  builder: (context) => const DesignShowcase(),
));
```

---

## 🐛 **Solucionando Problemas**

### Flutter não reconhecido
```powershell
# Verificar PATH
echo $env:PATH

# Adicionar temporariamente
$env:PATH += ";C:\flutter\bin"

# Testar
flutter --version
```

### Problemas de Permissão
```powershell
# Permitir execução de scripts
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Android Studio não encontrado
```powershell
# Instalar Android Studio
choco install androidstudio

# OU baixar manualmente
# https://developer.android.com/studio
```

---

## ✅ **Checklist de Instalação**

- [ ] Flutter baixado e extraído
- [ ] PATH configurado corretamente  
- [ ] `flutter --version` funcionando
- [ ] `flutter doctor` sem erros críticos
- [ ] Projeto `gastro_app` abrindo
- [ ] `flutter pub get` executado
- [ ] App rodando com nova identidade visual

---

## 🎉 **Status da Nova Identidade Visual**

### ✅ **Já Implementado:**
- 🎨 Sistema de cores completo
- ✍️ Tipografia Material 3
- 🏗️ Tema global atualizado
- 📱 Todos os componentes estilizados
- 📚 Documentação completa
- 🧪 Showcase interativo

### 🔥 **Benefícios Imediatos:**
- **Experiência consistente** em todo o app
- **Acessibilidade WCAG 2.1** compliance
- **Material Design 3** nativo
- **Manutenção centralizada** 
- **Performance otimizada**

---

## 📞 **Precisa de Ajuda?**

1. **Demo HTML**: Já funcionando no navegador
2. **Documentação**: `docs/IDENTIDADE_VISUAL.md`
3. **Showcase**: `lib/widgets/design_showcase.dart`
4. **Exemplos**: `lib/examples/nova_identidade_exemplo.dart`

---

**🚀 A nova identidade visual está 100% pronta! Basta instalar o Flutter para ver tudo funcionando no app real.** 