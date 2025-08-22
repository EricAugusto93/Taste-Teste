const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');
const cors = require('cors');

const app = express();
const PORT = 8080;

// Configuração CORS liberal para desenvolvimento
app.use(cors({
  origin: ['http://localhost:3000', 'http://localhost:61593', 'http://127.0.0.1:61593'],
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS', 'PATCH'],
  allowedHeaders: [
    'Content-Type', 
    'Authorization', 
    'X-Requested-With',
    'apikey',
    'Prefer',
    'Accept',
    'Accept-Encoding',
    'Accept-Language',
    'Cache-Control',
    'Connection',
    'Content-Length',
    'Host',
    'Origin',
    'Referer',
    'Sec-Fetch-Dest',
    'Sec-Fetch-Mode',
    'Sec-Fetch-Site',
    'User-Agent',
    'x-client-info'
  ]
}));

// Middleware de logging
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.url}`);
  next();
});

// Proxy para Supabase
app.use('/api/supabase', createProxyMiddleware({
  target: 'https://msjzktnkvyycwahpalhb.supabase.co',
  changeOrigin: true,
  pathRewrite: {
    '^/api/supabase': '',
  },
  onProxyReq: (proxyReq, req, res) => {
    // Adicionar headers necessários
    proxyReq.setHeader('Access-Control-Allow-Origin', '*');
    proxyReq.setHeader('Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE,OPTIONS');
    proxyReq.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization, Content-Length, X-Requested-With, apikey');
    
    console.log('Proxy request to:', proxyReq.getHeader('host') + proxyReq.path);
  },
  onProxyRes: (proxyRes, req, res) => {
    // Adicionar headers CORS na resposta
    proxyRes.headers['Access-Control-Allow-Origin'] = '*';
    proxyRes.headers['Access-Control-Allow-Methods'] = 'GET,PUT,POST,DELETE,OPTIONS';
    proxyRes.headers['Access-Control-Allow-Headers'] = 'Content-Type, Authorization, Content-Length, X-Requested-With, apikey';
    proxyRes.headers['Access-Control-Allow-Credentials'] = 'true';
    
    console.log('Proxy response status:', proxyRes.statusCode);
  },
  onError: (err, req, res) => {
    console.error('Proxy error:', err.message);
    res.writeHead(500, {
      'Content-Type': 'text/plain',
      'Access-Control-Allow-Origin': '*'
    });
    res.end('Proxy error: ' + err.message);
  }
}));

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    timestamp: new Date().toISOString(),
    message: 'CORS Proxy Server is running'
  });
});

app.listen(PORT, () => {
  console.log(`🚀 CORS Proxy Server running on http://localhost:${PORT}`);
  console.log(`📡 Proxying requests to Supabase: https://msjzktnkvyycwahpalhb.supabase.co`);
  console.log(`🔗 Use http://localhost:${PORT}/api/supabase as your base URL`);
});