/// <reference types="vitest" />
import { defineConfig, loadEnv } from 'vite'
import react from '@vitejs/plugin-react'

const assetsUrl = process.env.ASSETS_URL || 'http://localhost:5173'

export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), '')

  return {
    base: assetsUrl + '/',
    plugins: [react()],
    server: {
      origin: assetsUrl,
    },
    define: {
      __API_URL__: JSON.stringify(env.API_URL || 'http://localhost:4000/api/graphql/'),
      __WS_URL__: JSON.stringify(env.WS_URL || 'ws://localhost:4000/socket'),
    },

    build: {
      outDir: '../priv/static',
      emptyOutDir: true,
      manifest: true,
      rollupOptions: {
        input: 'src/main.tsx',
        output: {
          entryFileNames: 'assets/index.js',
          chunkFileNames: 'assets/[name].js',
          assetFileNames: 'assets/[name][extname]',
        },
      },
    },
    test: {
      globals: true,
      environment: 'jsdom',
      teardownTimeout: 1000,
      setupFiles: './src/test/setup.ts',
      minWorkers: 1,
    },
  }
})
