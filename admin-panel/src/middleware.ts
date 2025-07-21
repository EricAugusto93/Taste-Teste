import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'

export async function middleware(req: NextRequest) {
  console.log('🔍 Middleware chamado para:', req.nextUrl.pathname)
  
  // Redireciona para dashboard se estiver na página inicial
  if (req.nextUrl.pathname === '/') {
    console.log('➡️ Redirecionando / para /dashboard')
    return NextResponse.redirect(new URL('/dashboard', req.url))
  }

  // Verifica autenticação para dashboard
  if (req.nextUrl.pathname.startsWith('/dashboard')) {
    const token = req.cookies.get('supabase-auth-token')
    console.log('🔑 Cookie de auth:', token ? 'presente' : 'ausente')
    
    if (!token) {
      console.log('❌ Sem token, redirecionando para login')
      return NextResponse.redirect(new URL('/login', req.url))
    }
    
    console.log('✅ Token encontrado, permitindo acesso ao dashboard')
  }

  return NextResponse.next()
}

export const config = {
  matcher: ['/dashboard/:path*', '/']
} 