'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { signInWithEmail, isAdmin } from '@/lib/auth'
import { useErrorHandler } from '@/hooks/useErrorHandler'
import ErrorNotification from '@/components/ErrorNotification'
import { supabase } from '@/lib/supabase'

export default function LoginPage() {
  const [email, setEmail] = useState('admin@gastroapp.com')
  const [password, setPassword] = useState('admin123')
  const [loading, setLoading] = useState(false)
  const router = useRouter()
  const { error, handleError, clearError } = useErrorHandler()

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)
    clearError()

    try {
      // Tentar fazer login primeiro
      let { data, error: authError } = await signInWithEmail(email, password)
      
      // Se o usuário não existe e são as credenciais padrão, criar o usuário
      if (authError && email === 'admin@gastroapp.com' && password === 'admin123') {
        console.log('🔧 Tentando criar usuário admin automaticamente...')
        
        // Tentar criar usuário
        const { data: signUpData, error: signUpError } = await supabase.auth.signUp({
          email: email,
          password: password,
        })
        
        if (!signUpError && signUpData.user) {
          console.log('✅ Usuário admin criado com sucesso')
          // Tentar fazer login novamente
          const loginResult = await signInWithEmail(email, password)
          data = loginResult.data
          authError = loginResult.error
        }
      }
      
      if (authError) {
        throw new Error(`Erro de autenticação: ${authError.message}`)
      }

      if (!data.user) {
        throw new Error('Usuário não encontrado')
      }

      console.log('👤 Verificando se usuário é admin:', data.user.email)

      // Verificar se é admin
      const isAdminUser = await isAdmin(data.user.email!)
      
      if (!isAdminUser) {
        throw new Error('Acesso negado: usuário não é administrador')
      }
      
      console.log('✅ Login de admin aprovado para:', data.user.email)

      // Salvar sessão no localStorage como backup
      localStorage.setItem('admin-session', JSON.stringify({
        email: data.user.email,
        id: data.user.id,
        timestamp: Date.now(),
        session: data.session
      }))
      
      // Aguardar um pouco para garantir que os cookies sejam definidos
      setTimeout(() => {
        router.push('/dashboard')
      }, 500)
      
    } catch (err: any) {
      handleError(err)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="min-h-screen bg-orange-50 flex items-center justify-center py-12 px-4 sm:px-6 lg:px-8">
      <div className="max-w-md w-full space-y-8">
        <div className="bg-white shadow-xl rounded-2xl p-8 border border-orange-200">
          <div className="text-center mb-8">
            <div className="mx-auto h-24 w-auto mb-6 flex items-center justify-center">
              <img 
                src="/taste-test-logo.png" 
                alt="Logo" 
                className="h-24 w-auto object-contain"
              />
            </div>
            <p className="text-blue-600/60 text-sm font-medium">
              Painel Administrativo
            </p>
          </div>

          <form onSubmit={handleLogin} className="space-y-6">

            <div>
              <label htmlFor="email" className="block text-sm font-semibold text-blue-600 mb-2">
                Email do Administrador
              </label>
              <input
                id="email"
                name="email"
                type="email"
                required
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                className="w-full px-4 py-3 border border-orange-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-600 focus:border-blue-600 transition-all duration-200 bg-white text-blue-600 placeholder-blue-600/40"
                placeholder="admin@gastroapp.com"
              />
            </div>

            <div>
              <label htmlFor="password" className="block text-sm font-semibold text-blue-600 mb-2">
                Senha
              </label>
              <input
                id="password"
                name="password"
                type="password"
                required
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                className="w-full px-4 py-3 border border-orange-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-600 focus:border-blue-600 transition-all duration-200 bg-white text-blue-600 placeholder-blue-600/40"
                placeholder="••••••••"
              />
            </div>

            <button
              type="submit"
              disabled={loading}
              className="w-full px-6 py-3 bg-blue-600 text-white rounded-xl font-semibold hover:bg-blue-700 transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2 shadow-lg hover:shadow-xl transform hover:scale-105 active:scale-95"
            >
              {loading ? (
                <>
                  <div className="animate-spin rounded-full h-4 w-4 border-2 border-white border-t-transparent"></div>
                  Entrando...
                </>
              ) : (
                <>
                  🔐 Entrar no Painel
                </>
              )}
            </button>


          </form>

          <div className="mt-6 text-center">
            <p className="text-xs text-blue-600/50">
              Apenas administradores autorizados podem acessar
            </p>
          </div>
        </div>
      </div>
      
      <ErrorNotification 
        error={error} 
        onClose={clearError} 
      />
    </div>
  )
}