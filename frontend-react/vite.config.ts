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
        menu: 'menu.html',
        pay: 'pay.html',
        account: 'account.html',
        events: 'events.html',
        facilities: 'facilities.html',
        terms: 'terms.html',
        privacy: 'privacy.html',
        cookies: 'cookies.html'
      },
      // The file name of a bundle is not its content hash.
      //
      // A hash in the name means every deploy renames every file, and a deploy
      // deletes the bundles nothing points at any more. A page a browser still
      // holds - from a tab left open, a back/forward cache, a service worker, a
      // proxy - then asks for a file that is gone and the site fails to load
      // with a 404 on its own script. Naming the files after what they are
      // keeps one name per file for the life of the site: a stale page finds
      // today's file, and the only thing a deploy has to get right is that the
      // file is written before the old one is taken away.
      output: {
        entryFileNames: 'assets/[name].js',
        chunkFileNames: 'assets/[name].js',
        assetFileNames: 'assets/[name][extname]'
      }
    }
  }
});
