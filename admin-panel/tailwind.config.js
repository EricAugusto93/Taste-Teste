/** @type {import('tailwindcss').Config} */
module.exports = {
  darkMode: ["class"],
  content: [
    './pages/**/*.{ts,tsx}',
    './components/**/*.{ts,tsx}',
    './app/**/*.{ts,tsx}',
    './src/**/*.{ts,tsx}',
  ],
  prefix: "",
  theme: {
    container: {
      center: true,
      padding: "2rem",
      screens: {
        "2xl": "1400px",
      },
    },
    extend: {
      colors: {
        border: "hsl(var(--border))",
        input: "hsl(var(--input))",
        ring: "hsl(var(--ring))",
        background: "hsl(var(--background))",
        foreground: "hsl(var(--foreground))",
        primary: {
          DEFAULT: "hsl(var(--primary))",
          foreground: "hsl(var(--primary-foreground))",
          50: "var(--primary-50)",
          100: "var(--primary-100)",
          200: "var(--primary-200)",
          300: "var(--primary-300)",
          400: "var(--primary-400)",
          500: "var(--primary-500)",
          600: "var(--primary-600)",
          700: "var(--primary-700)",
        },
        secondary: {
          DEFAULT: "hsl(var(--secondary))",
          foreground: "hsl(var(--secondary-foreground))",
          50: "var(--secondary-50)",
          100: "var(--secondary-100)",
          200: "var(--secondary-200)",
          300: "var(--secondary-300)",
          400: "var(--secondary-400)",
          500: "var(--secondary-500)",
          600: "var(--secondary-600)",
          700: "var(--secondary-700)",
        },
        destructive: {
          DEFAULT: "hsl(var(--destructive))",
          foreground: "hsl(var(--destructive-foreground))",
        },
        muted: {
          DEFAULT: "hsl(var(--muted))",
          foreground: "hsl(var(--muted-foreground))",
        },
        accent: {
          DEFAULT: "hsl(var(--accent))",
          foreground: "hsl(var(--accent-foreground))",
        },
        popover: {
          DEFAULT: "hsl(var(--popover))",
          foreground: "hsl(var(--popover-foreground))",
        },
        card: {
          DEFAULT: "hsl(var(--card))",
          foreground: "hsl(var(--card-foreground))",
        },
        // ==== CORES PERSONALIZADAS DA NOVA PALETA ====
        'azul-profundo': {
          DEFAULT: '#2c3985',
          50: '#f8f9ff',
          100: '#e3e7f1',
          200: '#c7d0e3',
          300: '#4a5ba6',
          400: '#3d4a9a',
          500: '#2c3985',
          600: '#242f73',
          700: '#1c2561',
        },
        'amarelo-mostarda': {
          DEFAULT: '#ee9d21',
          50: '#fff9e6',
          100: '#fff3cc',
          200: '#ffe699',
          300: '#f5c547',
          400: '#f2b347',
          500: '#ee9d21',
          600: '#cc7a0a',
          700: '#b8730a',
        },
        'vermelho-telha': {
          DEFAULT: '#d9502b',
          light: '#e67a5a',
          dark: '#b83e1f',
        },
        'areia-clara': {
          DEFAULT: '#fbe9d2',
          light: '#fef4e8',
          dark: '#f0dcc4',
        },
        // ==== CORES AUXILIARES ====
        success: '#4CAF50',
        warning: '#ee9d21',
        info: '#2c3985',
        light: '#fbe9d2',
        dark: '#2c3985',
      },
      borderRadius: {
        lg: "var(--radius)",
        md: "calc(var(--radius) - 2px)",
        sm: "calc(var(--radius) - 4px)",
      },
      keyframes: {
        "accordion-down": {
          from: { height: "0" },
          to: { height: "var(--radix-accordion-content-height)" },
        },
        "accordion-up": {
          from: { height: "var(--radix-accordion-content-height)" },
          to: { height: "0" },
        },
        // ==== NOVAS ANIMAÇÕES SUAVES ====
        "hover-lift": {
          "0%": { transform: "translateY(0)" },
          "100%": { transform: "translateY(-2px)" },
        },
        "glow": {
          "0%, 100%": { boxShadow: "0 0 5px rgba(238, 157, 33, 0.2)" },
          "50%": { boxShadow: "0 0 20px rgba(238, 157, 33, 0.4)" },
        },
        "pulse-primary": {
          "0%, 100%": { boxShadow: "0 0 0 0 rgba(44, 57, 133, 0.4)" },
          "50%": { boxShadow: "0 0 0 8px rgba(44, 57, 133, 0)" },
        },
      },
      animation: {
        "accordion-down": "accordion-down 0.2s ease-out",
        "accordion-up": "accordion-up 0.2s ease-out",
        "hover-lift": "hover-lift 0.2s ease-in-out",
        "glow": "glow 2s ease-in-out infinite",
        "pulse-primary": "pulse-primary 1.5s ease-in-out infinite",
      },
      boxShadow: {
        'primary': '0 4px 14px 0 rgba(44, 57, 133, 0.25)',
        'secondary': '0 4px 14px 0 rgba(238, 157, 33, 0.25)',
        'danger': '0 4px 14px 0 rgba(217, 80, 43, 0.25)',
        'soft': '0 2px 8px rgba(0, 0, 0, 0.08)',
        'medium': '0 4px 16px rgba(0, 0, 0, 0.12)',
        'elegant': '0 8px 25px rgba(44, 57, 133, 0.15)',
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
      },
    },
  },
  plugins: [require("tailwindcss-animate")],
} 