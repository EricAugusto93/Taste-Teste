import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

/// Serviço para gerenciar listas persistentes do usuário
class UserListsService {
  static const String _wantToKnowKey = 'want_to_know_items';
  static const String _notSureReturnKey = 'not_sure_return_items';

  /// Obtém items da lista "Quero conhecer"
  static Future<List<WantToKnowItem>> getWantToKnowItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_wantToKnowKey);
      
      if (jsonString == null) {
        return _getDefaultWantToKnowItems();
      }
      
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => WantToKnowItem.fromJson(json)).toList();
    } catch (e) {
      debugPrint('❌ Erro ao carregar lista "Quero conhecer": $e');
      return _getDefaultWantToKnowItems();
    }
  }

  /// Salva items da lista "Quero conhecer"
  static Future<bool> saveWantToKnowItems(List<WantToKnowItem> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = items.map((item) => item.toJson()).toList();
      final jsonString = json.encode(jsonList);
      
      return await prefs.setString(_wantToKnowKey, jsonString);
    } catch (e) {
      debugPrint('❌ Erro ao salvar lista "Quero conhecer": $e');
      return false;
    }
  }

  /// Remove item da lista "Quero conhecer"
  static Future<bool> removeWantToKnowItem(String itemId) async {
    try {
      final items = await getWantToKnowItems();
      items.removeWhere((item) => item.id == itemId);
      return await saveWantToKnowItems(items);
    } catch (e) {
      debugPrint('❌ Erro ao remover item "Quero conhecer": $e');
      return false;
    }
  }

  /// Adiciona item à lista "Quero conhecer"
  static Future<bool> addWantToKnowItem(WantToKnowItem item) async {
    try {
      final items = await getWantToKnowItems();
      
      // Verifica se o item já existe
      if (items.any((existingItem) => existingItem.id == item.id)) {
        return true; // Item já existe, considera como sucesso
      }
      
      items.add(item);
      return await saveWantToKnowItems(items);
    } catch (e) {
      debugPrint('❌ Erro ao adicionar item "Quero conhecer": $e');
      return false;
    }
  }

  /// Obtém items da lista "Não sei se eu volto"
  static Future<List<NotSureReturnItem>> getNotSureReturnItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_notSureReturnKey);
      
      if (jsonString == null) {
        return _getDefaultNotSureReturnItems();
      }
      
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => NotSureReturnItem.fromJson(json)).toList();
    } catch (e) {
      debugPrint('❌ Erro ao carregar lista "Não sei se eu volto": $e');
      return _getDefaultNotSureReturnItems();
    }
  }

  /// Salva items da lista "Não sei se eu volto"
  static Future<bool> saveNotSureReturnItems(List<NotSureReturnItem> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = items.map((item) => item.toJson()).toList();
      final jsonString = json.encode(jsonList);
      
      return await prefs.setString(_notSureReturnKey, jsonString);
    } catch (e) {
      debugPrint('❌ Erro ao salvar lista "Não sei se eu volto": $e');
      return false;
    }
  }

  /// Remove item da lista "Não sei se eu volto"
  static Future<bool> removeNotSureReturnItem(String itemId) async {
    try {
      final items = await getNotSureReturnItems();
      items.removeWhere((item) => item.id == itemId);
      return await saveNotSureReturnItems(items);
    } catch (e) {
      debugPrint('❌ Erro ao remover item "Não sei se eu volto": $e');
      return false;
    }
  }

  /// Adiciona item à lista "Não sei se eu volto"
  static Future<bool> addNotSureReturnItem(NotSureReturnItem item) async {
    try {
      final items = await getNotSureReturnItems();
      
      // Verifica se o item já existe
      if (items.any((existingItem) => existingItem.id == item.id)) {
        return true; // Item já existe, considera como sucesso
      }
      
      items.add(item);
      return await saveNotSureReturnItems(items);
    } catch (e) {
      debugPrint('❌ Erro ao adicionar item "Não sei se eu volto": $e');
      return false;
    }
  }

  /// Limpa todas as listas
  static Future<bool> clearAllLists() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_wantToKnowKey);
      await prefs.remove(_notSureReturnKey);
      return true;
    } catch (e) {
      debugPrint('❌ Erro ao limpar listas: $e');
      return false;
    }
  }

  /// Items padrão para "Quero conhecer" (quando não há dados salvos)
  static List<WantToKnowItem> _getDefaultWantToKnowItems() {
    return [
      WantToKnowItem(
        id: '1',
        name: 'Restaurante Italiano Nonna',
        category: 'Italiana',
        location: 'Vila Madalena, São Paulo',
        imageUrl: 'https://via.placeholder.com/300x200',
        addedDate: DateTime.now().subtract(const Duration(days: 2)),
      ),
      WantToKnowItem(
        id: '2',
        name: 'Sushi Bar Yamamoto',
        category: 'Japonesa',
        location: 'Liberdade, São Paulo',
        imageUrl: 'https://via.placeholder.com/300x200',
        addedDate: DateTime.now().subtract(const Duration(days: 5)),
      ),
      WantToKnowItem(
        id: '3',
        name: 'Churrascaria Gaúcha',
        category: 'Brasileira',
        location: 'Moema, São Paulo',
        imageUrl: 'https://via.placeholder.com/300x200',
        addedDate: DateTime.now().subtract(const Duration(days: 10)),
      ),
    ];
  }

  /// Items padrão para "Não sei se eu volto" (quando não há dados salvos)
  static List<NotSureReturnItem> _getDefaultNotSureReturnItems() {
    return [
      NotSureReturnItem(
        id: '1',
        name: 'Restaurante do Centro',
        category: 'Brasileira',
        location: 'Centro, São Paulo',
        imageUrl: 'https://via.placeholder.com/300x200',
        visitDate: DateTime.now().subtract(const Duration(days: 15)),
        reason: 'Atendimento demorado e comida fria',
        rating: 2,
      ),
      NotSureReturnItem(
        id: '2',
        name: 'Pizzaria da Esquina',
        category: 'Italiana',
        location: 'Vila Olímpia, São Paulo',
        imageUrl: 'https://via.placeholder.com/300x200',
        visitDate: DateTime.now().subtract(const Duration(days: 30)),
        reason: 'Pizza muito salgada, ambiente barulhento',
        rating: 2,
      ),
      NotSureReturnItem(
        id: '3',
        name: 'Lanchonete Express',
        category: 'Fast Food',
        location: 'Paulista, São Paulo',
        imageUrl: 'https://via.placeholder.com/300x200',
        visitDate: DateTime.now().subtract(const Duration(days: 7)),
        reason: 'Preço alto para a qualidade oferecida',
        rating: 2,
      ),
    ];
  }
}

/// Modelo para itens da lista "Quero conhecer" com serialização
class WantToKnowItem {
  final String id;
  final String name;
  final String category;
  final String location;
  final String imageUrl;
  final DateTime addedDate;

  WantToKnowItem({
    required this.id,
    required this.name,
    required this.category,
    required this.location,
    required this.imageUrl,
    required this.addedDate,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'location': location,
    'image_url': imageUrl,
    'added_date': addedDate.toIso8601String(),
  };

  factory WantToKnowItem.fromJson(Map<String, dynamic> json) => WantToKnowItem(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    category: json['category'] ?? '',
    location: json['location'] ?? '',
    imageUrl: json['image_url'] ?? '',
    addedDate: DateTime.tryParse(json['added_date'] ?? '') ?? DateTime.now(),
  );
}

/// Modelo para itens da lista "Não sei se eu volto" com serialização
class NotSureReturnItem {
  final String id;
  final String name;
  final String category;
  final String location;
  final String imageUrl;
  final DateTime visitDate;
  final String reason;
  final int rating;

  NotSureReturnItem({
    required this.id,
    required this.name,
    required this.category,
    required this.location,
    required this.imageUrl,
    required this.visitDate,
    required this.reason,
    required this.rating,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'location': location,
    'image_url': imageUrl,
    'visit_date': visitDate.toIso8601String(),
    'reason': reason,
    'rating': rating,
  };

  factory NotSureReturnItem.fromJson(Map<String, dynamic> json) => NotSureReturnItem(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    category: json['category'] ?? '',
    location: json['location'] ?? '',
    imageUrl: json['image_url'] ?? '',
    visitDate: DateTime.tryParse(json['visit_date'] ?? '') ?? DateTime.now(),
    reason: json['reason'] ?? '',
    rating: json['rating'] ?? 0,
  );
}