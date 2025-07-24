import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'

export async function middleware(req: NextRequest) {
  console.log('🔍 Middleware chamado para:', req.nextUrl.pathname)
  
  // Verifica autenticação apenas para dashboard
  if (req.nextUrl.pathname.startsWith('/dashboard')) {
    
    // Por enquanto, vamos apenas logar e permitir acesso para debug
    const cookies = req.cookies.getAll()
    console.log('🍪 Todos os cookies:', cookies.map(c => c.name).join(', '))
    
    // Verificar se há localStorage através de uma verificação menos restritiva
    const hasAnyAuth = cookies.some(cookie => 
      cookie.name.includes('auth') || 
      cookie.name.includes('supabase') || 
      cookie.name.includes('sb-')
    )
    
    console.log('🔐 Tem algum cookie de auth:', hasAnyAuth)
    
    // Temporariamente, vamos ser mais permissivos para debug
    if (!hasAnyAuth) {
      console.log('⚠️ Sem cookies de auth detectados, mas permitindo acesso para debug')
      // return NextResponse.redirect(new URL('/login', req.url))
    }

    console.log('✅ Permitindo acesso ao dashboard')
  }

  return NextResponse.next()
}

export const config = {
  matcher: ['/dashboard/:path*']
} 