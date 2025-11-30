import { defineConfig, loadEnv } from 'vite';
import react from '@vitejs/plugin-react'

// https://vite.dev/config/
export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), ['API_']);

  return {
    define: {
      'import.meta.env.API_URL': JSON.stringify(env.API_URL),
    },
    plugins: [react()],
  };
});