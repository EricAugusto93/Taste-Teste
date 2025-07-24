import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'

export async function middleware(req: NextRequest) {
  console.log('🔍 Middleware chamado para:', req.nextUrl.pathname)
  
  // Verifica autenticação apenas para dashboard
  if (req.nextUrl.pathname.startsWith('/dashboard')) {
    
    const cookies = req.cookies.getAll()
    console.log('🍪 Todos os cookies:', cookies.map(c => c.name).join(', '))
    
    // Procurar especificamente pelos cookies do Supabase (vários formatos possíveis)
    const supabaseTokens = cookies.filter(cookie => 
      cookie.name.includes('sb-gnosarnyuiyrbcdwkfto') ||
      cookie.name.includes('supabase-auth-token') ||
      cookie.name.includes('sb-') ||
      cookie.name.includes('auth-token')
    )
    
    console.log('🔐 Tokens Supabase encontrados:', supabaseTokens.length)
    console.log('📝 Nomes dos tokens:', supabaseTokens.map(t => t.name))
    
    // Se tem tokens específicos do Supabase, permitir acesso
    if (supabaseTokens.length > 0) {
      console.log('✅ Tokens Supabase encontrados, permitindo acesso')
      return NextResponse.next()
    }
    
    // Verificar se há localStorage session (via header ou referrer)
    const hasLocalStorageHint = req.headers.get('referer')?.includes('/login')
    
    if (hasLocalStorageHint) {
      console.log('🟡 Vindo do login, permitindo acesso para verificar localStorage')
      return NextResponse.next()
    }
    
    console.log('⚠️ Permitindo acesso temporariamente para debug completo')
    console.log('🔧 Login está funcionando, middleware será permissivo por enquanto')
    
    // Permitir acesso temporariamente - remover quando tudo estiver funcionando
    return NextResponse.next()
    
    // Quando quiser ativar redirecionamento:
    // console.log('❌ Nenhum token encontrado, redirecionando para login')
    // return NextResponse.redirect(new URL('/login', req.url))
  }

  return NextResponse.next()
}

export const config = {
  matcher: ['/dashboard/:path*']
} 