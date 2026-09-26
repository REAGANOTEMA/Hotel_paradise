import {defineConfig} from 'vite';
import react from '@vitejs/plugin-react';
import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
import {buildImageManifest} from './imageLibrary.mjs';

const here = path.dirname(fileURLToPath(import.meta.url));
const IMAGES = path.resolve(here, '..', 'images');
const MANIFEST = path.join(here, 'src', 'image-manifest.json');

/**
 * Refreshes src/image-manifest.json before every build and dev start so the
 * pages always know which photographs are on disk.
 */
function imageManifest() {
  const write = () => {
    const next = buildImageManifest(IMAGES);
    const body = JSON.stringify(next, null, 2) + '\n';
    const current = fs.existsSync(MANIFEST) ? fs.readFileSync(MANIFEST, 'utf8') : '';
    if (current !== body) fs.writeFileSync(MANIFEST, body);
  };
  return {
    name: 'hotel-image-manifest',
    buildStart: write,
    configureServer: write
  };
}

/** Copies /images into the build so dist can be uploaded on its own. */
function copyImages() {
  return {
    name: 'hotel-copy-images',
    closeBundle() {
      const to = path.join(here, 'dist', 'images');
      fs.rmSync(to, {recursive: true, force: true});
      fs.cpSync(IMAGES, to, {recursive: true});
    }
  };
}

export default defineConfig({
  plugins: [react(), imageManifest(), copyImages()],
  base: './',
  build: {
    outDir: 'dist',
    assetsDir: 'assets',
    rollupOptions: {
      input: {
        home: 'index.html',
        rooms: 'rooms.html',
        menu: 'menu.html'
      }
    }
  }
});
