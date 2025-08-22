'use client'

import { useState, useCallback } from 'react'

interface ErrorState {
  message: string | null
  type: 'network' | 'auth' | 'server' | 'general'
  timestamp: number
}

export function useErrorHandler() {
  const [error, setError] = useState<ErrorState | null>(null)

  const handleError = useCallback((error: any) => {
    console.error('🚨 Erro capturado pelo handler:', error)

    let message = 'Ocorreu um erro inesperado'
    let type: ErrorState['type'] = 'general'

    if (typeof error === 'string') {
      message = error
    } else if (error?.message) {
      message = error.message
    }

    // Categorizar o tipo de erro
    if (message.includes('conexão') || message.includes('internet') || message.includes('Failed to fetch')) {
      type = 'network'
    } else if (message.includes('sessão') || message.includes('login') || message.includes('token')) {
      type = 'auth'
    } else if (message.includes('servidor') || message.includes('configuração') || message.includes('CORS')) {
      type = 'server'
    }

    setError({
      message,
      type,
      timestamp: Date.now()
    })

    // Para erros de autenticação, redirecionar após um delay
    if (type === 'auth') {
      setTimeout(() => {
        if (typeof window !== 'undefined') {
          window.location.href = '/login'
        }
      }, 3000)
    }
  }, [])

  const clearError = useCallback(() => {
    setError(null)
  }, [])

  const retryOperation = useCallback(async (operation: () => Promise<any>) => {
    try {
      clearError()
      return await operation()
    } catch (error) {
      handleError(error)
      throw error
    }
  }, [handleError, clearError])

  return {
    error: error?.message || null,
    errorType: error?.type || null,
    hasError: !!error,
    handleError,
    clearError,
    retryOperation
  }
}

// Hook para verificar conectividade
export function useNetworkStatus() {
  const [isOnline, setIsOnline] = useState(true)
  const [lastChecked, setLastChecked] = useState(Date.now())

  const checkConnectivity = useCallback(async () => {
    try {
      const response = await fetch('/api/health', {
        method: 'HEAD',
        cache: 'no-cache'
      })
      const online = response.ok
      setIsOnline(online)
      setLastChecked(Date.now())
      return online
    } catch {
      setIsOnline(false)
      setLastChecked(Date.now())
      return false
    }
  }, [])

  return {
    isOnline,
    lastChecked,
    checkConnectivity
  }
}