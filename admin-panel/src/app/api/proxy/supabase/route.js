// API Proxy para contornar CORS entre Flutter e Supabase

// ⚠️ NUNCA HARDCODAR CREDENCIAIS! Usar variáveis de ambiente
const SUPABASE_URL = process.env.NEXT_PUBLIC_SUPABASE_URL || process.env.SUPABASE_URL
const SUPABASE_ANON_KEY = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || process.env.SUPABASE_ANON_KEY

if (!SUPABASE_URL || !SUPABASE_ANON_KEY) {
  console.error('❌ ERRO: Credenciais Supabase não configuradas nas variáveis de ambiente!')
}

// Configurar CORS Headers
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization, apikey, prefer',
  'Access-Control-Allow-Credentials': 'false',
}

export async function OPTIONS() {
  return new Response(null, {
    status: 200,
    headers: corsHeaders,
  })
}

export async function GET(request) {
  try {
    const { searchParams } = new URL(request.url)
    const path = searchParams.get('path') || 'restaurants'
    
    // Construir URL do Supabase
    const url = new URL(`${SUPABASE_URL}/rest/v1/${path}`)
    
    // Adicionar todos os query parameters
    searchParams.forEach((value, key) => {
      if (key !== 'path') {
        url.searchParams.append(key, value)
      }
    })
    
    console.log(`🔄 Proxy GET request: ${url.toString()}`)
    
    // Fazer requisição para Supabase
    const response = await fetch(url.toString(), {
      method: 'GET',
      headers: {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
        'Content-Type': 'application/json',
      },
    })
    
    const data = await response.text()
    console.log(`✅ Proxy response: ${response.status}`)
    
    // Retornar resposta com CORS
    return new Response(data, {
      status: response.status,
      headers: {
        ...corsHeaders,
        'Content-Type': 'application/json',
      },
    })
    
  } catch (error) {
    console.error('❌ Proxy error:', error)
    return new Response(JSON.stringify({ error: 'Proxy error', details: error.message }), {
      status: 500,
      headers: corsHeaders,
    })
  }
}

export async function POST(request) {
  try {
    const { searchParams } = new URL(request.url)
    const path = searchParams.get('path') || 'restaurants'
    const body = await request.text()
    
    // Construir URL do Supabase
    const url = new URL(`${SUPABASE_URL}/rest/v1/${path}`)
    
    // Adicionar query parameters
    searchParams.forEach((value, key) => {
      if (key !== 'path') {
        url.searchParams.append(key, value)
      }
    })
    
    console.log(`🔄 Proxy POST request: ${url.toString()}`)
    
    // Fazer requisição para Supabase
    const response = await fetch(url.toString(), {
      method: 'POST',
      headers: {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
        'Content-Type': 'application/json',
        'Prefer': 'return=representation',
      },
      body: body,
    })
    
    const data = await response.text()
    console.log(`✅ Proxy response: ${response.status}`)
    
    return new Response(data, {
      status: response.status,
      headers: {
        ...corsHeaders,
        'Content-Type': 'application/json',
      },
    })
    
  } catch (error) {
    console.error('❌ Proxy error:', error)
    return new Response(JSON.stringify({ error: 'Proxy error', details: error.message }), {
      status: 500,
      headers: corsHeaders,
    })
  }
}