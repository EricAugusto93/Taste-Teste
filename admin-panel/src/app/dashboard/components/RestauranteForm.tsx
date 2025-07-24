'use client'

import { useState, useEffect } from 'react'
import { restaurantesAPI, storage, type Restaurante } from '@/lib/supabase'

interface RestauranteFormProps {
  restaurante?: Restaurante | null
  onSubmit: () => void
  onCancel: () => void
}

export default function RestauranteForm({ restaurante, onSubmit, onCancel }: RestauranteFormProps) {
  const [formData, setFormData] = useState({
    nome: '',
    tipo: '',
    descricao: '',
    latitude: 0,
    longitude: 0,
    tags: [] as string[],
    imagem_url: ''
  })
  const [tagInput, setTagInput] = useState('')
  const [loading, setLoading] = useState(false)
  const [uploadingImage, setUploadingImage] = useState(false)
  const [error, setError] = useState('')

  // Tipos de restaurante predefinidos
  const tiposRestaurante = [
    'Brasileira', 'Italiana', 'Japonesa', 'Chinesa', 'Mexicana', 'Indiana',
    'Fast Food', 'Pizzaria', 'Churrascaria', 'Vegetariana', 'Vegana',
    'Frutos do Mar', 'Hambúrguer', 'Café', 'Padaria', 'Sorveteria', 'Outro'
  ]

  useEffect(() => {
    if (restaurante) {
      setFormData({
        nome: restaurante.nome,
        tipo: restaurante.tipo,
        descricao: restaurante.descricao,
        latitude: restaurante.latitude,
        longitude: restaurante.longitude,
        tags: restaurante.tags,
        imagem_url: restaurante.imagem_url || ''
      })
    }
  }, [restaurante])

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => {
    const { name, value } = e.target
    setFormData(prev => ({
      ...prev,
      [name]: name === 'latitude' || name === 'longitude' ? parseFloat(value) || 0 : value
    }))
  }

  const handleAddTag = () => {
    if (tagInput.trim() && !formData.tags.includes(tagInput.trim())) {
      setFormData(prev => ({
        ...prev,
        tags: [...prev.tags, tagInput.trim()]
      }))
      setTagInput('')
    }
  }

  const handleRemoveTag = (tagToRemove: string) => {
    setFormData(prev => ({
      ...prev,
      tags: prev.tags.filter(tag => tag !== tagToRemove)
    }))
  }

  const removeTag = (index: number) => {
    setFormData(prev => ({
      ...prev,
      tags: prev.tags.filter((_, i) => i !== index)
    }))
  }

  const handleImageUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0]
    if (!file) return

    try {
      setUploadingImage(true)
      const imageUrl = await storage.uploadImage(file)
      setFormData(prev => ({ ...prev, imagem_url: imageUrl }))
    } catch (error) {
      console.error('Erro ao fazer upload da imagem:', error)
      setError('Erro ao fazer upload da imagem')
    } finally {
      setUploadingImage(false)
    }
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)
    setError('')

    try {
      // Validações
      if (!formData.nome.trim()) {
        throw new Error('Nome é obrigatório')
      }
      if (!formData.tipo.trim()) {
        throw new Error('Tipo é obrigatório')
      }
      if (!formData.descricao.trim()) {
        throw new Error('Descrição é obrigatória')
      }
      if (formData.latitude === 0 || formData.longitude === 0) {
        throw new Error('Coordenadas são obrigatórias')
      }

      const dados = {
        nome: formData.nome.trim(),
        tipo: formData.tipo.trim(),
        descricao: formData.descricao.trim(),
        latitude: formData.latitude,
        longitude: formData.longitude,
        tags: formData.tags,
        imagem_url: formData.imagem_url || undefined
      }

      if (restaurante) {
        // Atualizar restaurante existente
        await restaurantesAPI.update(restaurante.id, dados)
      } else {
        // Criar novo restaurante
        await restaurantesAPI.create(dados)
      }

      onSubmit()
    } catch (err: any) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="min-h-screen bg-orange-50">
      <div className="max-w-4xl mx-auto py-8 px-6 sm:px-8 lg:px-12">
        <div className="bg-white rounded-2xl shadow-xl border border-orange-200 overflow-hidden">
          <div className="px-8 py-6 max-h-[80vh] overflow-y-auto">
            {/* Header Elegante */}
            <div className="flex justify-between items-center mb-6 pb-4 border-b border-orange-200">
              <div>
                <h3 className="text-xl font-bold text-blue-600">
                  {restaurante ? 'Editar Restaurante' : 'Adicionar Novo Restaurante'}
                </h3>
                <p className="text-sm text-blue-600/60 mt-1">
                  {restaurante ? 'Atualize as informações do restaurante' : 'Preencha os dados do novo restaurante'}
                </p>
              </div>
              <button
                onClick={onCancel}
                className="text-blue-600/40 hover:text-blue-600 transition-all duration-200 p-2 rounded-lg hover:bg-orange-100"
              >
                <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                </svg>
              </button>
            </div>

            <form onSubmit={handleSubmit} className="space-y-6">
              {/* Nome - Campo Principal */}
              <div>
                <label htmlFor="nome" className="block text-sm font-semibold text-blue-600 mb-2">
                  Nome do Restaurante *
                </label>
                <input
                  type="text"
                  id="nome"
                  name="nome"
                  value={formData.nome}
                  onChange={handleInputChange}
                  className="w-full px-4 py-3 border border-orange-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-600 focus:border-blue-600 transition-all duration-200 bg-white text-blue-600 placeholder-blue-600/40"
                  placeholder="Digite o nome do restaurante"
                  required
                />
              </div>

              {/* Tipo - Seleção Elegante */}
              <div>
                <label htmlFor="tipo" className="block text-sm font-semibold text-blue-600 mb-2">
                  Tipo de Cozinha *
                </label>
                <select
                  id="tipo"
                  name="tipo"
                  value={formData.tipo}
                  onChange={handleInputChange}
                  className="w-full px-4 py-3 border border-orange-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-600 focus:border-blue-600 transition-all duration-200 bg-white text-blue-600"
                  required
                >
                  <option value="" className="text-blue-600/60">Selecione o tipo</option>
                  {tiposRestaurante.map(tipo => (
                    <option key={tipo} value={tipo} className="text-blue-600">{tipo}</option>
                  ))}
                </select>
              </div>

              {/* Descrição */}
              <div>
                <label htmlFor="descricao" className="block text-sm font-semibold text-blue-600 mb-2">
                  Descrição *
                </label>
                <textarea
                  id="descricao"
                  name="descricao"
                  value={formData.descricao}
                  onChange={handleInputChange}
                  rows={4}
                  className="w-full px-4 py-3 border border-orange-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-600 focus:border-blue-600 transition-all duration-200 bg-white text-blue-600 placeholder-blue-600/40 resize-none"
                  placeholder="Descreva o restaurante, sua especialidade, ambiente..."
                  required
                />
              </div>

              {/* Coordenadas - Layout em Grid */}
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label htmlFor="latitude" className="block text-sm font-semibold text-blue-600 mb-2">
                    Latitude *
                  </label>
                  <input
                    type="number"
                    id="latitude"
                    name="latitude"
                    value={formData.latitude || ''}
                    onChange={handleInputChange}
                    step="any"
                    className="w-full px-4 py-3 border border-orange-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-600 focus:border-blue-600 transition-all duration-200 bg-white text-blue-600 placeholder-blue-600/40"
                    placeholder="Ex: -30.0342"
                    required
                  />
                </div>
                <div>
                  <label htmlFor="longitude" className="block text-sm font-semibold text-blue-600 mb-2">
                    Longitude *
                  </label>
                  <input
                    type="number"
                    id="longitude"
                    name="longitude"
                    value={formData.longitude || ''}
                    onChange={handleInputChange}
                    step="any"
                    className="w-full px-4 py-3 border border-orange-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-600 focus:border-blue-600 transition-all duration-200 bg-white text-blue-600 placeholder-blue-600/40"
                    placeholder="Ex: -51.2173"
                    required
                  />
                </div>
              </div>

              {/* Tags */}
              <div>
                <label className="block text-sm font-semibold text-blue-600 mb-2">
                  Tags e Características
                </label>
                <div className="space-y-3">
                  <div className="flex gap-2">
                    <input
                      type="text"
                      value={tagInput}
                      onChange={(e) => setTagInput(e.target.value)}
                      onKeyDown={(e) => {
                        if (e.key === 'Enter') {
                          e.preventDefault()
                          handleAddTag()
                        }
                      }}
                      className="flex-1 px-4 py-3 border border-orange-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-600 focus:border-blue-600 transition-all duration-200 bg-white text-blue-600 placeholder-blue-600/40"
                      placeholder="Digite uma tag e pressione Enter"
                    />
                    <button
                      type="button"
                      onClick={handleAddTag}
                      className="px-4 py-3 bg-blue-600 text-white rounded-xl hover:bg-blue-700 transition-all duration-200 font-medium whitespace-nowrap"
                    >
                      ➕ Adicionar
                    </button>
                  </div>
                  
                  {formData.tags.length > 0 && (
                    <div className="flex flex-wrap gap-2">
                      {formData.tags.map((tag, index) => (
                        <span
                          key={index}
                          className="inline-flex items-center gap-1 px-3 py-2 bg-orange-100 text-blue-600 rounded-lg text-sm font-medium"
                        >
                          {tag}
                          <button
                            type="button"
                            onClick={() => removeTag(index)}
                                                         className="text-blue-600/60 hover:text-red-600 transition-colors"
                          >
                            ✕
                          </button>
                        </span>
                      ))}
                    </div>
                  )}
                </div>
              </div>

              {/* Upload de Imagem */}
              <div>
                <label className="block text-sm font-semibold text-blue-600 mb-2">
                  Imagem do Restaurante
                </label>
                <div className="space-y-3">
                  <input
                    type="file"
                    accept="image/*"
                    onChange={handleImageUpload}
                    className="w-full px-4 py-3 border border-orange-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-600 focus:border-blue-600 transition-all duration-200 bg-white text-blue-600 file:mr-4 file:py-2 file:px-4 file:rounded-lg file:border-0 file:text-sm file:font-medium file:bg-orange-100 file:text-blue-600 hover:file:bg-orange-200"
                    disabled={uploadingImage}
                  />
                  
                  {formData.imagem_url && (
                    <div className="relative">
                      <img
                        src={formData.imagem_url}
                        alt="Preview"
                        className="w-full h-48 object-cover rounded-xl border border-orange-200"
                      />
                      <button
                        type="button"
                        onClick={() => setFormData(prev => ({ ...prev, imagem_url: '' }))}
                                                 className="absolute top-2 right-2 bg-red-500 text-white p-2 rounded-lg hover:bg-red-600 transition-colors"
                      >
                        🗑️
                      </button>
                    </div>
                  )}
                </div>
              </div>

              {/* Mensagem de Erro */}
              {error && (
                                 <div className="p-4 bg-red-50 border border-red-200 rounded-xl">
                   <p className="text-red-800 text-sm font-medium">❌ {error}</p>
                </div>
              )}

              {/* Botões de Ação */}
              <div className="flex flex-col sm:flex-row gap-3 pt-6">
                <button
                  type="button"
                  onClick={onCancel}
                                     className="flex-1 px-6 py-3 border border-orange-300 text-blue-600 rounded-xl font-semibold hover:bg-orange-50 transition-all duration-200"
                >
                  ↩️ Cancelar
                </button>
                <button
                  type="submit"
                  disabled={loading || uploadingImage}
                                     className="flex-1 px-6 py-3 bg-blue-600 text-white rounded-xl font-semibold hover:bg-blue-700 transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2"
                >
                  {loading ? (
                    <>
                      <div className="animate-spin rounded-full h-4 w-4 border-2 border-white/20 border-t-white"></div>
                      Salvando...
                    </>
                  ) : (
                    <>
                      {restaurante ? '✏️ Atualizar' : '✨ Criar'}
                    </>
                  )}
                </button>
              </div>
            </form>
          </div>
        </div>
      </div>
    </div>
  )
} 