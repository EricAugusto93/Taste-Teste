# 🚀 RESTART - Guia de Reinicialização do Aplicativo Taste

Este arquivo contém os comandos para reiniciar o aplicativo Flutter após qualquer prompt finalizado.

## 📋 Comandos de Reinicialização

### 1. Parar Aplicativo Atual (se estiver rodando)
```bash
# Localizar e matar processos do Flutter
tasklist /FI "IMAGENAME eq flutter.exe" /FO TABLE
taskkill /F /IM flutter.exe
```

### 2. Navegar para o Diretório
```bash
cd "C:\Users\Eric\Desktop\Taste-Oficial\taste_app"
```

### 3. Limpar Cache (Opcional)
```bash
flutter clean
flutter pub get
```

### 4. Iniciar Aplicativo
```bash
flutter run -d chrome --dart-define=ENVIRONMENT=development --web-port=8004
```

## 🌐 Links de Acesso

Após executar os comandos acima, o aplicativo estará disponível em:
- **URL Principal**: http://localhost:8004
- **DevTools**: Será exibido no terminal após inicialização

## 📝 Notas Importantes

- **Porta**: Usar sempre uma porta diferente (8004, 8005, etc.) para evitar conflitos
- **Ambiente**: Sempre usar `ENVIRONMENT=development` para desenvolvimento
- **Browser**: Chrome é o navegador padrão configurado
- **Hot Reload**: Use `r` para hot reload, `R` para hot restart no terminal

## 🔧 Solução de Problemas

### Se a porta estiver ocupada:
```bash
# Verificar processos na porta
netstat -ano | findstr :8004
# Matar processo específico
taskkill /F /PID <PID_NUMBER>
```

### Se houver erro de dependências:
```bash
flutter clean
flutter pub get
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### Se o Google Maps não carregar:
- Verificar se `.env.development` existe
- Confirmar se `GOOGLE_MAPS_API_KEY` está configurada
- Testar se há conectividade com internet

## ✅ Checklist de Verificação

Após reiniciar, verificar se:
- [ ] Aplicativo carrega sem erros
- [ ] Google Maps funciona
- [ ] Restaurants aparecem no mapa com emojis corretos
- [ ] Coordenadas dos restaurantes estão corretas
- [ ] Sistema de reviews funciona (múltiplos comentários permitidos)
- [ ] Não há duplicação de comentários

## 📞 Contato de Suporte

Em caso de problemas persistentes:
1. Verificar logs no terminal
2. Verificar console do browser (F12)
3. Consultar documentação no CLAUDE.md