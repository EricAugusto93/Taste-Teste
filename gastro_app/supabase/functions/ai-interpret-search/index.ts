import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface SearchInterpretationRequest {
  input: string;
  options?: {
    maxTokens?: number;
    temperature?: number;
    includeConfidence?: boolean;
    provider?: 'openai' | 'claude' | 'cohere';
  };
}

interface SearchInterpretationResponse {
  tipo?: string;
  tags: string[];
  localizacao?: string;
  ambiente?: string;
  faixaPreco?: number;
  horario?: string;
  confianca: number;
  metadados: Record<string, any>;
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { input, options = {} }: SearchInterpretationRequest = await req.json()

    // Validate input
    if (!input || input.trim().length < 3) {
      return new Response(
        JSON.stringify({ 
          error: 'Input deve ter pelo menos 3 caracteres' 
        }),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Get API keys from environment (only accessible server-side)
    const openaiApiKey = Deno.env.get('OPENAI_API_KEY')
    const claudeApiKey = Deno.env.get('CLAUDE_API_KEY')
    const cohereApiKey = Deno.env.get('COHERE_API_KEY')

    // Determine which provider to use
    const provider = options.provider || 'openai'
    let interpretation: SearchInterpretationResponse

    switch (provider) {
      case 'openai':
        if (!openaiApiKey) {
          throw new Error('OpenAI API key not configured')
        }
        interpretation = await interpretWithOpenAI(input, openaiApiKey, options)
        break
      
      case 'claude':
        if (!claudeApiKey) {
          throw new Error('Claude API key not configured')
        }
        interpretation = await interpretWithClaude(input, claudeApiKey, options)
        break
      
      case 'cohere':
        if (!cohereApiKey) {
          throw new Error('Cohere API key not configured')
        }
        interpretation = await interpretWithCohere(input, cohereApiKey, options)
        break
      
      default:
        throw new Error(`Provider ${provider} not supported`)
    }

    // Log usage for analytics (optional)
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    // Save usage analytics (fire and forget)
    supabase
      .from('ai_usage_logs')
      .insert({
        input_text: input,
        provider: provider,
        confidence: interpretation.confianca,
        created_at: new Date().toISOString(),
      })
      .then()
      .catch(console.error)

    return new Response(
      JSON.stringify(interpretation),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )

  } catch (error) {
    console.error('Error in ai-interpret-search:', error)
    
    return new Response(
      JSON.stringify({ 
        error: error.message || 'Erro interno do servidor',
        fallback: await createFallbackInterpretation(req.json().then(data => data.input).catch(() => ''))
      }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  }
})

async function interpretWithOpenAI(
  input: string, 
  apiKey: string, 
  options: any
): Promise<SearchInterpretationResponse> {
  const systemPrompt = `Você é um assistente especializado em gastronomia brasileira. Interprete desejos gastronômicos de usuários e retorne JSON estruturado.

Tipos conhecidos: café, pizzaria, bar, restaurante, lanchonete, sorveteria, padaria, churrascaria, japonês, italiano, mexicano, árabe, vegetariano, vegano, fast-food.

Tags comuns: romântico, família, tranquilo, agitado, pet-friendly, wi-fi, música ao vivo, karaoke, vista, terraço, entrega, delivery, casual, fino, barato, caro, tradicional, moderno.

Retorne apenas JSON válido com esta estrutura:
{
  "tipo": "string opcional",
  "tags": ["array de strings"],
  "localizacao": "string opcional",
  "ambiente": "string opcional", 
  "faixaPreco": "number opcional",
  "horario": "string opcional",
  "confianca": "number de 0 a 1"
}`

  const response = await fetch('https://api.openai.com/v1/chat/completions', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${apiKey}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      model: options.model || 'gpt-3.5-turbo',
      messages: [
        { role: 'system', content: systemPrompt },
        { role: 'user', content: `Interprete: "${input}"` }
      ],
      max_tokens: options.maxTokens || 200,
      temperature: options.temperature || 0.3,
      response_format: { type: 'json_object' }
    }),
  })

  if (!response.ok) {
    const error = await response.json()
    throw new Error(`OpenAI API Error: ${error.error?.message || 'Unknown error'}`)
  }

  const data = await response.json()
  const content = data.choices?.[0]?.message?.content

  if (!content) {
    throw new Error('Invalid OpenAI response')
  }

  const parsed = JSON.parse(content)
  
  return {
    tipo: parsed.tipo,
    tags: Array.isArray(parsed.tags) ? parsed.tags : [],
    localizacao: parsed.localizacao,
    ambiente: parsed.ambiente,
    faixaPreco: parsed.faixaPreco,
    horario: parsed.horario,
    confianca: parsed.confianca || 0.8,
    metadados: {
      provider: 'openai',
      model: options.model || 'gpt-3.5-turbo',
      timestamp: new Date().toISOString(),
    }
  }
}

async function interpretWithClaude(
  input: string, 
  apiKey: string, 
  options: any
): Promise<SearchInterpretationResponse> {
  const prompt = `Você é um assistente especializado em gastronomia brasileira. Interprete o seguinte desejo gastronômico e retorne apenas um JSON válido:

Input: "${input}"

Retorne JSON com: tipo, tags, localizacao, ambiente, faixaPreco, horario, confianca (0-1).`

  const response = await fetch('https://api.anthropic.com/v1/messages', {
    method: 'POST',
    headers: {
      'x-api-key': apiKey,
      'Content-Type': 'application/json',
      'anthropic-version': '2023-06-01'
    },
    body: JSON.stringify({
      model: options.model || 'claude-3-haiku-20240307',
      max_tokens: options.maxTokens || 200,
      messages: [
        { role: 'user', content: prompt }
      ]
    }),
  })

  if (!response.ok) {
    const error = await response.json()
    throw new Error(`Claude API Error: ${error.error?.message || 'Unknown error'}`)
  }

  const data = await response.json()
  const content = data.content?.[0]?.text

  if (!content) {
    throw new Error('Invalid Claude response')
  }

  // Extract JSON from response
  const jsonMatch = content.match(/\{.*\}/s)
  if (!jsonMatch) {
    throw new Error('No JSON found in Claude response')
  }

  const parsed = JSON.parse(jsonMatch[0])
  
  return {
    tipo: parsed.tipo,
    tags: Array.isArray(parsed.tags) ? parsed.tags : [],
    localizacao: parsed.localizacao,
    ambiente: parsed.ambiente,
    faixaPreco: parsed.faixaPreco,
    horario: parsed.horario,
    confianca: parsed.confianca || 0.8,
    metadados: {
      provider: 'claude',
      model: options.model || 'claude-3-haiku-20240307',
      timestamp: new Date().toISOString(),
    }
  }
}

async function interpretWithCohere(
  input: string, 
  apiKey: string, 
  options: any
): Promise<SearchInterpretationResponse> {
  const prompt = `Você é um assistente gastronômico. Interprete "${input}" e retorne JSON com: tipo, tags, localizacao, ambiente, faixaPreco, horario, confianca.`

  const response = await fetch('https://api.cohere.ai/v1/generate', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${apiKey}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      model: options.model || 'command-light',
      prompt: prompt,
      max_tokens: options.maxTokens || 200,
      temperature: options.temperature || 0.3,
    }),
  })

  if (!response.ok) {
    const error = await response.json()
    throw new Error(`Cohere API Error: ${error.message || 'Unknown error'}`)
  }

  const data = await response.json()
  const content = data.generations?.[0]?.text

  if (!content) {
    throw new Error('Invalid Cohere response')
  }

  // Extract JSON from response
  const jsonMatch = content.match(/\{.*\}/s)
  if (!jsonMatch) {
    throw new Error('No JSON found in Cohere response')
  }

  const parsed = JSON.parse(jsonMatch[0])
  
  return {
    tipo: parsed.tipo,
    tags: Array.isArray(parsed.tags) ? parsed.tags : [],
    localizacao: parsed.localizacao,
    ambiente: parsed.ambiente,
    faixaPreco: parsed.faixaPreco,
    horario: parsed.horario,
    confianca: parsed.confianca || 0.7,
    metadados: {
      provider: 'cohere',
      model: options.model || 'command-light',
      timestamp: new Date().toISOString(),
    }
  }
}

async function createFallbackInterpretation(input: string): Promise<SearchInterpretationResponse> {
  const inputLower = input.toLowerCase()
  
  // Simple keyword matching fallback
  const typeMap: Record<string, string> = {
    'café': 'café',
    'pizza': 'pizzaria',
    'bar': 'bar',
    'sushi': 'japonês',
    'hambúrguer': 'lanchonete'
  }
  
  const tagMap: Record<string, string[]> = {
    'romântico': ['romântico'],
    'família': ['família'],
    'tranquilo': ['tranquilo'],
    'pet': ['pet-friendly'],
    'barato': ['casual'],
    'caro': ['premium']
  }
  
  let tipo: string | undefined
  const tags: string[] = []
  
  // Detect type
  for (const [keyword, type] of Object.entries(typeMap)) {
    if (inputLower.includes(keyword)) {
      tipo = type
      break
    }
  }
  
  // Detect tags
  for (const [keyword, tagList] of Object.entries(tagMap)) {
    if (inputLower.includes(keyword)) {
      tags.push(...tagList)
    }
  }
  
  return {
    tipo,
    tags,
    confianca: 0.5,
    metadados: {
      provider: 'fallback',
      method: 'keyword_matching',
      timestamp: new Date().toISOString(),
    }
  }
} 