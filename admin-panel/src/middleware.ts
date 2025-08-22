import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'

export async function middleware(req: NextRequest) {
  const url = req.nextUrl.clone()
  
  console.log('🔍 Middleware: Verificando rota', url.pathname)
  
  // Verifica autenticação apenas para dashboard
  if (req.nextUrl.pathname.startsWith('/dashboard')) {
    const cookies = req.cookies.getAll()
    console.log('🍪 Middleware: Cookies encontrados:', cookies.length)
    
    // Procurar especificamente pelos cookies do Supabase (vários formatos possíveis)
    const supabaseTokens = cookies.filter(cookie => 
      cookie.name.includes('sb-msjzktnkvyycwahpalhb') ||
      cookie.name.includes('supabase-auth-token') ||
      cookie.name.includes('sb-') ||
      cookie.name.includes('auth-token') ||
      cookie.name.includes('access_token') ||
      cookie.name.includes('refresh_token')
    )
    
    console.log('🔑 Middleware: Tokens do Supabase encontrados:', supabaseTokens.length)
    
    // Se tem tokens específicos do Supabase, permitir acesso
    if (supabaseTokens.length > 0) {
      console.log('✅ Middleware: Token encontrado, permitindo acesso ao dashboard')
      return NextResponse.next()
    }
    
    // Verificar autorização via header (útil para SPAs)
    const authHeader = req.headers.get('authorization')
    if (authHeader && authHeader.startsWith('Bearer ')) {
      console.log('✅ Middleware: Bearer token encontrado no header')
      return NextResponse.next()
    }
    
    // Verificar se há localStorage session (via header ou referrer)
    const hasLocalStorageHint = req.headers.get('referer')?.includes('/login')
    const hasAuthQuery = url.searchParams.has('authenticated')
    
    if (hasLocalStorageHint || hasAuthQuery) {
      console.log('✅ Middleware: Hint de localStorage ou query auth encontrado')
      return NextResponse.next()
    }
    
    // Para desenvolvimento, permitir bypass se vindo do login
    if (process.env.NODE_ENV === 'development') {
      const isFromLogin = req.headers.get('referer')?.includes('/login')
      if (isFromLogin) {
        console.log('🔓 Middleware: Modo desenvolvimento - bypass do login')
        return NextResponse.next()
      }
    }
    
    console.log('🚫 Middleware: Sem autenticação válida, redirecionando para login')
    return NextResponse.redirect(new URL('/login', req.url))
  }

  // Verificar se usuário já está autenticado tentando acessar login
  if (req.nextUrl.pathname === '/login') {
    const cookies = req.cookies.getAll()
    const supabaseTokens = cookies.filter(cookie => 
      cookie.name.includes('sb-msjzktnkvyycwahpalhb') ||
      cookie.name.includes('supabase-auth-token') ||
      cookie.name.includes('sb-')
    )
    
    if (supabaseTokens.length > 0) {
      console.log('🔄 Middleware: Usuário já autenticado, redirecionando para dashboard')
      return NextResponse.redirect(new URL('/dashboard', req.url))
    }
  }

  console.log('✅ Middleware: Rota pública, prosseguindo')
  return NextResponse.next()
}

export const config = {
  matcher: [
    '/dashboard/:path*',
    '/login'
  ]
} 