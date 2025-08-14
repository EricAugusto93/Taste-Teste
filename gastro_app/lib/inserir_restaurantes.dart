import 'package:gastro_app/services/restaurante_service.dart';
import 'package:gastro_app/services/supabase_service.dart';

void main() async {
  print('🔧 Iniciando inserção de restaurantes de teste...');
  
  try {
    // Inicializar Supabase
    await SupabaseService.inicializar();
    print('✅ Supabase inicializado');
    
    // Inserir restaurantes de teste
    await RestauranteService.inserirRestaurantesTeste();
    print('✅ Restaurantes inseridos com sucesso!');
    
  } catch (e) {
    print('❌ Erro: $e');
  }
}