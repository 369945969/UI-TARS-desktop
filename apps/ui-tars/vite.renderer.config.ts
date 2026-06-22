/**
 * Copyright (c) 2025 Bytedance, Inc. and its affiliates.
 * SPDX-License-Identifier: Apache-2.0
 */
import { resolve } from 'node:path';

import react from '@vitejs/plugin-react';
import { defineConfig } from 'vite';
import tsconfigPaths from 'vite-tsconfig-paths';
import tailwindcss from '@tailwindcss/vite';

import pkg from './package.json';

export default defineConfig({
  root: 'src/renderer',
  build: {
    outDir: 'dist/renderer',
    rollupOptions: {
      input: {
        main: resolve('./src/renderer/index.html'),
      },
    },
  },
  css: {
    preprocessorOptions: {
      scss: {
        api: 'modern',
      },
    },
  },
  plugins: [react(), tsconfigPaths(), tailwindcss()],
  server: {
    port: Number(process.env.PORT) || 31212,
    host: process.env.HOST || '0.0.0.0',
  },
  define: {
    APP_VERSION: JSON.stringify(pkg.version),
  },
  resolve: {
    alias: {
      crypto: resolve(__dirname, 'src/renderer/src/polyfills/crypto.ts'),
    },
  },
});
