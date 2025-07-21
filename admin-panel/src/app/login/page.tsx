'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { auth, checkAdminAccess } from '@/lib/supabase'

export default function LoginPage() {
  const [email, setEmail] = useState('admin@gastroapp.com')
  const [password, setPassword] = useState('admin123')
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')
  const router = useRouter()

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)
    setError('')

    try {
      console.log('🚀 Iniciando login...', { email, password: password.length + ' chars' })
      
      // Fazer login no Supabase
      const { data, error: authError } = await auth.signIn(email, password)
      
      console.log('📝 Resultado do auth.signIn:', { data: data?.user?.email, error: authError?.message })
      
      if (authError) {
        console.log('❌ Erro de autenticação:', authError)
        throw new Error(authError.message)
      }

      if (!data.user?.email) {
        console.log('❌ Email não encontrado no retorno')
        throw new Error('Email não encontrado')
      }

      console.log('✅ Login bem-sucedido, verificando admin...')
      
      // Verificar se é admin
      const isAdmin = await checkAdminAccess(data.user.email)
      
      console.log('📝 Resultado do checkAdminAccess:', isAdmin)
      
      if (!isAdmin) {
        console.log('❌ Não é admin, fazendo logout...')
        await auth.signOut()
        throw new Error('Acesso negado. Este email não está autorizado.')
      }

      if (isAdmin) {
        console.log('✅ Admin verificado, salvando sessão...')
        
        // Salvar no localStorage
        const sessionData = {
          email: data.user.email,
          id: data.user.id,
          timestamp: Date.now()
        }
        localStorage.setItem('admin-session', JSON.stringify(sessionData))
        
        // Criar cookie para o middleware
        document.cookie = `supabase-auth-token=${data.user.id}; path=/; max-age=86400; secure; samesite=strict`
        
        console.log('💾 Sessão salva no localStorage:', sessionData)
        console.log('🔄 Redirecionando para dashboard...')
        
        // Redirecionamento com delay para garantir que o cookie seja definido
        setTimeout(() => {
          router.push('/dashboard')
        }, 100)
        
        return
      }
      
    } catch (err: any) {
      console.log('❌ Erro no handleLogin:', err)
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-gray-50 to-gray-100 py-6 px-4 sm:py-12 sm:px-6 lg:px-8">
      <div className="max-w-md w-full space-y-6 sm:space-y-8">
        {/* Logo Taste Test - Responsivo */}
        <div className="flex justify-center mb-4 sm:mb-6">
          <div className="text-center transform hover:scale-105 transition-transform duration-300">
            <div className="text-3xl sm:text-4xl font-bold bg-gradient-to-r from-orange-500 to-red-500 bg-clip-text text-transparent">
              Taste Test
            </div>
            <div className="text-xs sm:text-sm text-gray-500 mt-1 font-medium tracking-wider">
              GASTRO EXPERIENCE
            </div>
          </div>
        </div>
        
        <div className="text-center">
          <h2 className="mt-4 sm:mt-6 text-2xl sm:text-3xl font-extrabold text-gray-900">
            Painel Administrativo
          </h2>
          <p className="mt-2 text-sm text-gray-600">
            Gastro App - Acesso restrito
          </p>
        </div>
        
        <form className="mt-6 sm:mt-8 space-y-4 sm:space-y-6" onSubmit={handleLogin}>
          <div className="bg-white rounded-xl shadow-lg p-6 sm:p-8 space-y-4 sm:space-y-6">
            <div>
              <label htmlFor="email" className="block text-sm font-medium text-gray-700 mb-2">
                Email
              </label>
              <input
                id="email"
                name="email"
                type="email"
                autoComplete="email"
                required
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                className="appearance-none relative block w-full px-4 py-3 border border-gray-300 placeholder-gray-400 text-gray-900 rounded-lg focus:outline-none focus:ring-2 focus:ring-orange-500 focus:border-orange-500 transition-all duration-200 sm:text-sm hover:border-gray-400"
                placeholder="Digite seu email"
                aria-label="Campo de email para login"
              />
            </div>
            
            <div>
              <label htmlFor="password" className="block text-sm font-medium text-gray-700 mb-2">
                Senha
              </label>
              <input
                id="password"
                name="password"
                type="password"
                autoComplete="current-password"
                required
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                className="appearance-none relative block w-full px-4 py-3 border border-gray-300 placeholder-gray-400 text-gray-900 rounded-lg focus:outline-none focus:ring-2 focus:ring-orange-500 focus:border-orange-500 transition-all duration-200 sm:text-sm hover:border-gray-400"
                placeholder="Digite sua senha"
                aria-label="Campo de senha para login"
              />
            </div>
          </div>

          {error && (
            <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg animate-in slide-in-from-top-2 duration-300">
              <div className="font-semibold flex items-center">
                <span className="mr-2">⚠️</span>
                Erro de Login:
              </div>
              <div className="text-sm mt-1">{error}</div>
            </div>
          )}

          {loading && (
            <div className="bg-blue-50 border border-blue-200 text-blue-700 px-4 py-3 rounded-lg animate-in slide-in-from-top-2 duration-300">
              <div className="flex items-center">
                <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-blue-600 mr-2"></div>
                <span>Processando login...</span>
              </div>
            </div>
          )}

          <div className="pt-2">
            <button
              type="submit"
              disabled={loading}
              className="group relative w-full flex justify-center py-3 px-4 border border-transparent text-sm font-medium rounded-lg text-white bg-gradient-to-r from-orange-600 to-red-600 hover:from-orange-700 hover:to-red-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-orange-500 disabled:opacity-50 disabled:cursor-not-allowed transform hover:scale-[1.02] active:scale-[0.98] transition-all duration-200 shadow-lg hover:shadow-xl"
              aria-label="Botão para fazer login no sistema"
            >
              {loading ? (
                <div className="flex items-center">
                  <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
                  Entrando...
                </div>
              ) : (
                <div className="flex items-center">
                  <span className="mr-2">🔐</span>
                  Entrar no Sistema
                </div>
              )}
            </button>
          </div>
        </form>

        <div className="text-center space-y-2">
          <p className="text-xs text-gray-500">
            Apenas administradores autorizados podem acessar este painel.
          </p>
          <button
            type="button"
            onClick={() => {
              console.clear()
              console.log('🧹 Console limpo - pronto para debug')
            }}
            className="text-xs text-gray-400 hover:text-gray-600 underline"
          >
            Limpar Console (F12 para ver logs)
          </button>
        </div>
      </div>
    </div>
  )
} 