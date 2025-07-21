const { createClient } = require('@supabase/supabase-js')
require('dotenv').config({ path: '.env.local' })

// Debug das variáveis de ambiente
console.log('🔍 Verificando variáveis de ambiente...')
console.log('NEXT_PUBLIC_SUPABASE_URL:', process.env.NEXT_PUBLIC_SUPABASE_URL)

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL || 'https://gnosarnyuiyrbcdwkfto.supabase.co'
const supabaseServiceKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdub3Nhcm55dWl5cmJjZHdrZnRvIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTczNjQ3NDQ3MSwiZXhwIjoyMDUyMDUwNDcxfQ.Ru4OOIhMEvJKzqMbpTe1BFWFEn6fGnPqYDCdOIvDJ0s'

console.log('🌐 Usando URL:', supabaseUrl)

const supabaseAdmin = createClient(supabaseUrl, supabaseServiceKey, {
  auth: {
    autoRefreshToken: false,
    persistSession: false
  }
})

async function recreateAdminUser() {
  try {
    console.log('🔄 Removendo usuário admin existente...')
    
    // Remove usuário existente se houver
    await supabaseAdmin.auth.admin.deleteUser('admin@gastroapp.com')
    
    console.log('✅ Usuário anterior removido')
    
    console.log('🔄 Criando novo usuário admin...')
    
    // Cria novo usuário admin
    const { data: user, error: createError } = await supabaseAdmin.auth.admin.createUser({
      email: 'admin@gastroapp.com',
      password: '123456789',
      email_confirm: true,
      user_metadata: {
        role: 'admin'
      }
    })

    if (createError) {
      console.error('❌ Erro ao criar usuário:', createError)
      return
    }

    console.log('✅ Usuário criado com sucesso:', user.user.email)

    // Adiciona à tabela admins
    console.log('🔄 Adicionando à tabela admins...')
    
    const { error: adminError } = await supabaseAdmin
      .from('admins')
      .upsert({ 
        email: 'admin@gastroapp.com',
        created_at: new Date().toISOString()
      })

    if (adminError) {
      console.error('❌ Erro ao adicionar à tabela admins:', adminError)
      return
    }

    console.log('✅ Usuário admin recriado com sucesso!')
    console.log('📧 Email: admin@gastroapp.com')
    console.log('🔑 Senha: 123456789')
    
  } catch (error) {
    console.error('❌ Erro geral:', error)
  }
}

recreateAdminUser() 