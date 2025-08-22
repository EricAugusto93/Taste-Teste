'use client'

import { useState, useEffect } from 'react'

interface ErrorNotificationProps {
  error: string | null
  onClose: () => void
}

export default function ErrorNotification({ error, onClose }: ErrorNotificationProps) {
  const [isVisible, setIsVisible] = useState(false)

  useEffect(() => {
    if (error) {
      setIsVisible(true)
      // Auto-hide após 5 segundos
      const timer = setTimeout(() => {
        setIsVisible(false)
        setTimeout(onClose, 300) // Aguarda animação
      }, 5000)

      return () => clearTimeout(timer)
    }
  }, [error, onClose])

  if (!error) return null

  const getErrorIcon = (errorMessage: string) => {
    if (errorMessage.includes('conexão') || errorMessage.includes('internet')) {
      return '🌐'
    }
    if (errorMessage.includes('sessão') || errorMessage.includes('login')) {
      return '🔐'
    }
    if (errorMessage.includes('servidor') || errorMessage.includes('configuração')) {
      return '⚙️'
    }
    return '❌'
  }

  const getErrorColor = (errorMessage: string) => {
    if (errorMessage.includes('conexão') || errorMessage.includes('internet')) {
      return 'bg-yellow-50 border-yellow-200 text-yellow-800'
    }
    if (errorMessage.includes('sessão') || errorMessage.includes('login')) {
      return 'bg-blue-50 border-blue-200 text-blue-800'
    }
    return 'bg-red-50 border-red-200 text-red-800'
  }

  return (
    <div className={`fixed top-4 right-4 z-50 transition-all duration-300 transform ${
      isVisible ? 'translate-x-0 opacity-100' : 'translate-x-full opacity-0'
    }`}>
      <div className={`max-w-md p-4 rounded-xl border shadow-lg ${
        getErrorColor(error)
      }`}>
        <div className="flex items-start gap-3">
          <span className="text-xl flex-shrink-0">
            {getErrorIcon(error)}
          </span>
          <div className="flex-1">
            <h4 className="font-semibold text-sm mb-1">
              Ops! Algo deu errado
            </h4>
            <p className="text-sm opacity-90">
              {error}
            </p>
          </div>
          <button
            onClick={() => {
              setIsVisible(false)
              setTimeout(onClose, 300)
            }}
            className="text-lg hover:opacity-70 transition-opacity flex-shrink-0"
          >
            ×
          </button>
        </div>
        
        {error.includes('conexão') && (
          <div className="mt-3 pt-3 border-t border-current border-opacity-20">
            <p className="text-xs opacity-75">
              💡 Dica: Verifique sua conexão com a internet e tente novamente
            </p>
          </div>
        )}
        
        {error.includes('sessão') && (
          <div className="mt-3 pt-3 border-t border-current border-opacity-20">
            <p className="text-xs opacity-75">
              💡 Dica: Você será redirecionado para a página de login
            </p>
          </div>
        )}
      </div>
    </div>
  )
}