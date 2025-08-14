import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Sistema de ícones consistente para o aplicativo Taste
class AppIcons {
  // Privado para evitar instanciação
  AppIcons._();
  
  // ==========================================
  // NAVEGAÇÃO E INTERFACE
  // ==========================================
  
  /// Ícones de navegação principal
  static const IconData home = LucideIcons.home;
  static const IconData search = LucideIcons.search;
  static const IconData favorites = LucideIcons.heart;
  static const IconData profile = LucideIcons.user;
  static const IconData menu = LucideIcons.menu;
  static const IconData back = LucideIcons.arrowLeft;
  static const IconData close = LucideIcons.x;
  static const IconData more = LucideIcons.moreHorizontal;
  
  /// Ícones de ação
  static const IconData add = LucideIcons.plus;
  static const IconData edit = LucideIcons.edit;
  static const IconData delete = LucideIcons.trash2;
  static const IconData share = LucideIcons.share;
  static const IconData filter = LucideIcons.filter;
  static const IconData sort = LucideIcons.arrowUpDown;
  static const IconData refresh = LucideIcons.refreshCw;
  static const IconData settings = LucideIcons.settings;
  
  // ==========================================
  // RESTAURANTES E COMIDA
  // ==========================================
  
  /// Ícones relacionados a restaurantes
  static const IconData restaurant = LucideIcons.utensils;
  static const IconData chef = LucideIcons.chefHat;
  static const IconData menu_card = LucideIcons.bookOpen;
  static const IconData plate = LucideIcons.circle;
  static const IconData cooking = LucideIcons.flame;
  
  /// Ícones de categorias de comida
  static const IconData pizza = LucideIcons.pizza;
  static const IconData coffee = LucideIcons.coffee;
  static const IconData wine = LucideIcons.wine;
  static const IconData cake = LucideIcons.cake;
  static const IconData soup = LucideIcons.soup;
  
  // ==========================================
  // LOCALIZAÇÃO E MAPAS
  // ==========================================
  
  /// Ícones de localização
  static const IconData location = LucideIcons.mapPin;
  static const IconData currentLocation = LucideIcons.locateFixed;
  static const IconData map = LucideIcons.map;
  static const IconData directions = LucideIcons.navigation;
  static const IconData distance = LucideIcons.ruler;
  
  // ==========================================
  // AVALIAÇÕES E FEEDBACK
  // ==========================================
  
  /// Ícones de avaliação
  static const IconData star = LucideIcons.star;
  static const IconData starFilled = LucideIcons.star;
  static const IconData thumbsUp = LucideIcons.thumbsUp;
  static const IconData thumbsDown = LucideIcons.thumbsDown;
  static const IconData review = LucideIcons.messageSquare;
  static const IconData rating = LucideIcons.award;
  
  // ==========================================
  // FAVORITOS E LISTAS
  // ==========================================
  
  /// Ícones de favoritos
  static const IconData heartEmpty = LucideIcons.heart;
  static const IconData heartFilled = LucideIcons.heart;
  static const IconData bookmark = LucideIcons.bookmark;
  static const IconData bookmarkFilled = LucideIcons.bookmark;
  static const IconData list = LucideIcons.list;
  static const IconData grid = LucideIcons.grid;
  
  // ==========================================
  // COMUNICAÇÃO E CONTATO
  // ==========================================
  
  /// Ícones de contato
  static const IconData phone = LucideIcons.phone;
  static const IconData phoneCall = LucideIcons.phoneCall;
  static const IconData message = LucideIcons.messageCircle;
  static const IconData email = LucideIcons.mail;
  static const IconData website = LucideIcons.globe;
  static const IconData whatsapp = LucideIcons.messageCircle;
  static const IconData instagram = LucideIcons.instagram;
  
  // ==========================================
  // TEMPO E HORÁRIO
  // ==========================================
  
  /// Ícones de tempo
  static const IconData clock = LucideIcons.clock;
  static const IconData calendar = LucideIcons.calendar;
  static const IconData time = LucideIcons.timer;
  static const IconData schedule = LucideIcons.calendarDays;
  
  // ==========================================
  // STATUS E ESTADOS
  // ==========================================
  
  /// Ícones de status
  static const IconData loading = LucideIcons.loader2;
  static const IconData success = LucideIcons.checkCircle;
  static const IconData error = LucideIcons.alertCircle;
  static const IconData warning = LucideIcons.alertTriangle;
  static const IconData info = LucideIcons.info;
  static const IconData offline = LucideIcons.wifiOff;
  static const IconData online = LucideIcons.wifi;
  
  // Aliases para compatibilidade
  static const IconData alertCircle = LucideIcons.alertCircle;
  static const IconData wifiOff = LucideIcons.wifiOff;
  static const IconData server = LucideIcons.server;
  static const IconData searchOff = LucideIcons.searchX;
  
  // ==========================================
  // AUTENTICAÇÃO E USUÁRIO
  // ==========================================
  
  /// Ícones de usuário
  static const IconData user = LucideIcons.user;
  static const IconData userPlus = LucideIcons.userPlus;
  static const IconData login = LucideIcons.logIn;
  static const IconData logout = LucideIcons.logOut;
  static const IconData lock = LucideIcons.lock;
  static const IconData unlock = LucideIcons.unlock;
  static const IconData eye = LucideIcons.eye;
  static const IconData eyeOff = LucideIcons.eyeOff;
  
  // ==========================================
  // MÍDIA E CONTEÚDO
  // ==========================================
  
  /// Ícones de mídia
  static const IconData image = LucideIcons.image;
  static const IconData camera = LucideIcons.camera;
  static const IconData gallery = LucideIcons.image;
  static const IconData video = LucideIcons.video;
  static const IconData play = LucideIcons.play;
  static const IconData pause = LucideIcons.pause;
  
  // ==========================================
  // CONFIGURAÇÕES E PREFERÊNCIAS
  // ==========================================
  
  /// Ícones de configuração
  static const IconData preferences = LucideIcons.sliders;
  static const IconData theme = LucideIcons.palette;
  static const IconData language = LucideIcons.languages;
  static const IconData notifications = LucideIcons.bell;
  static const IconData notificationsOff = LucideIcons.bellOff;
  static const IconData privacy = LucideIcons.shield;
  static const IconData help = LucideIcons.helpCircle;
  
  // ==========================================
  // MÉTODOS UTILITÁRIOS
  // ==========================================
  
  /// Retorna ícone de estrela baseado no estado (preenchida ou vazia)
  static IconData getStarIcon(bool filled) {
    return filled ? starFilled : star;
  }
  
  /// Retorna ícone de coração baseado no estado (preenchido ou vazio)
  static IconData getHeartIcon(bool filled) {
    return filled ? heartFilled : heartEmpty;
  }
  
  /// Retorna ícone de bookmark baseado no estado (preenchido ou vazio)
  static IconData getBookmarkIcon(bool filled) {
    return filled ? bookmarkFilled : bookmark;
  }
  
  /// Retorna ícone de visibilidade baseado no estado
  static IconData getVisibilityIcon(bool visible) {
    return visible ? eye : eyeOff;
  }
  
  /// Retorna ícone de notificação baseado no estado
  static IconData getNotificationIcon(bool enabled) {
    return enabled ? notifications : notificationsOff;
  }
  
  /// Retorna ícone de conectividade baseado no estado
  static IconData getConnectivityIcon(bool connected) {
    return connected ? online : offline;
  }
  
  /// Retorna ícone de categoria de comida baseado no tipo
  static IconData getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'pizza':
        return pizza;
      case 'coffee':
      case 'café':
        return coffee;
      case 'wine':
      case 'vinho':
        return wine;
      case 'cake':
      case 'sobremesa':
      case 'doce':
        return cake;
      case 'soup':
      case 'sopa':
        return soup;
      case 'restaurant':
      case 'restaurante':
      default:
        return restaurant;
    }
  }
  
  /// Retorna ícone de status baseado no tipo
  static IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'success':
      case 'sucesso':
        return success;
      case 'error':
      case 'erro':
        return error;
      case 'warning':
      case 'aviso':
        return warning;
      case 'info':
      case 'informação':
        return info;
      case 'loading':
      case 'carregando':
        return loading;
      default:
        return info;
    }
  }
}

/// Extensão para facilitar o uso de ícones com cores e tamanhos
extension AppIconsExtension on IconData {
  /// Cria um widget Icon com cor primária
  Widget primary({double? size}) {
    return Icon(
      this,
      color: const Color(0xFFFF6B35), // AppColors.primary
      size: size,
    );
  }
  
  /// Cria um widget Icon com cor secundária
  Widget secondary({double? size}) {
    return Icon(
      this,
      color: const Color(0xFF6BB6FF), // AppColors.secondary
      size: size,
    );
  }
  
  /// Cria um widget Icon com cor de texto primária
  Widget textPrimary({double? size}) {
    return Icon(
      this,
      color: const Color(0xFF2D3748), // AppColors.textPrimary
      size: size,
    );
  }
  
  /// Cria um widget Icon com cor de texto secundária
  Widget textSecondary({double? size}) {
    return Icon(
      this,
      color: const Color(0xFF718096), // AppColors.textSecondary
      size: size,
    );
  }
  
  /// Cria um widget Icon com cor personalizada
  Widget colored(Color color, {double? size}) {
    return Icon(
      this,
      color: color,
      size: size,
    );
  }
}

/// Tamanhos padrão para ícones
class AppIconSizes {
  static const double small = 16.0;
  static const double medium = 24.0;
  static const double large = 32.0;
  static const double extraLarge = 48.0;
  static const double huge = 64.0;
}