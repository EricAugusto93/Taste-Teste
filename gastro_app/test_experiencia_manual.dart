import 'dart:io';
import 'dart:convert';

void main() async {
  try {
    print('🔄 Testando conexão com Supabase...');
    
    final url = 'https://gnosarnyuiyrbcdwkfto.supabase.co';
    final anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdub3Nhcm55dWl5cmJjZHdrZnRvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE5ODU2MzcsImV4cCI6MjA2NzU2MTYzN30.AfNNIGkf9p1veM0LvZzYQbUW9QGn3UJNdI_HWW2RYYQ';
    
    // Teste de inserção direta via HTTP
    print('🔄 Testando inserção na tabela experiencias...');
    
    final dadosInsert = {
      'user_id': '0992709c-3c1a-49fd-898a-96a15bf78f9e',
      'restaurante_id': 'cf1fc862-2b42-48a9-8290-9ca1330954fe',
      'emoji': 'bom',
      'comentario': 'Teste de comentario direto via HTTP',
      'data_visita': DateTime.now().toIso8601String(),
    };
    
    print('📝 Dados para inserção: $dadosInsert');
    
    final client = HttpClient();
    
    try {
      final request = await client.postUrl(
        Uri.parse('$url/rest/v1/experiencias'),
      );
      
      request.headers.set('apikey', anonKey);
      request.headers.set('Authorization', 'Bearer $anonKey');
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Prefer', 'return=representation');
      
      request.write(jsonEncode(dadosInsert));
      
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      
      print('📊 Status da resposta: ${response.statusCode}');
      print('📄 Corpo da resposta: $responseBody');
      
      if (response.statusCode == 201) {
        print('✅ Experiência inserida com sucesso!');
      } else {
        print('❌ Erro ao inserir experiência. Status: ${response.statusCode}');
      }
      
    } catch (e) {
      print('❌ Erro na requisição HTTP: $e');
      
      // Teste de conexão básica
      print('🔍 Testando conexão básica...');
      try {
        final testRequest = await client.getUrl(
          Uri.parse('$url/rest/v1/'),
        );
        testRequest.headers.set('apikey', anonKey);
        
        final testResponse = await testRequest.close();
        print('✅ Conexão básica funcionando. Status: ${testResponse.statusCode}');
      } catch (e2) {
        print('❌ Erro na conexão básica: $e2');
      }
    } finally {
      client.close();
    }
    
  } catch (e) {
    print('❌ Erro geral: $e');
  }
  
  exit(0);
}