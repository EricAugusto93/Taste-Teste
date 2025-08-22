#!/usr/bin/env node

/**
 * Script para configurar o storage do Supabase
 */

const { createClient } = require('@supabase/supabase-js');
require('dotenv').config({ path: './admin-panel/.env.local' });

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseAnonKey) {
  console.error('❌ Configurações do Supabase não encontradas.');
  process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseAnonKey);

async function setupStorage() {
  console.log('📦 Configurando storage do Supabase...\n');
  
  try {
    // Verificar se o bucket 'images' já existe
    const { data: buckets, error: listError } = await supabase.storage.listBuckets();
    
    if (listError) {
      console.error('❌ Erro ao listar buckets:', listError.message);
      return;
    }
    
    const imagesBucket = buckets.find(bucket => bucket.name === 'images');
    
    if (imagesBucket) {
      console.log('✅ Bucket "images" já existe');
    } else {
      console.log('📁 Criando bucket "images"...');
      
      const { data, error } = await supabase.storage.createBucket('images', {
        public: true,
        allowedMimeTypes: ['image/png', 'image/jpeg', 'image/gif', 'image/webp'],
        fileSizeLimit: 1024 * 1024 * 5 // 5MB
      });
      
      if (error) {
        console.error('❌ Erro ao criar bucket:', error.message);
        console.log('\n💡 Dica: Crie o bucket "images" manualmente no dashboard do Supabase');
        console.log('   - Acesse: https://supabase.com/dashboard/project/[your-project]/storage/buckets');
        console.log('   - Clique em "New bucket"');
        console.log('   - Nome: images');
        console.log('   - Público: sim');
      } else {
        console.log('✅ Bucket "images" criado com sucesso');
      }
    }
    
    console.log('\n📝 Storage configurado!');
    console.log('\n🚀 Próximos passos:');
    console.log('1. Execute "flutter pub get" no taste_app');
    console.log('2. Execute "npm install" no admin-panel');
    console.log('3. Execute "npm run dev" no admin-panel');
    console.log('4. Execute "flutter run -d chrome" no taste_app');
    
  } catch (error) {
    console.error('💥 Erro durante configuração:', error.message);
  }
}

setupStorage();