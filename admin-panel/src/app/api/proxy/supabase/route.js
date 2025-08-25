// API Proxy para contornar CORS entre Flutter e Supabase

const SUPABASE_URL = 'https://msjzktnkvyycwahpalhb.supabase.co'
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1zanprdG5rdnl5Y3dhaHBhbGhiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQzNDEyNzAsImV4cCI6MjA2OTkxNzI3MH0.Gn9H8darziz1nln79wvNhzKwo6GF0O-3uBJ-IDha9ns'

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