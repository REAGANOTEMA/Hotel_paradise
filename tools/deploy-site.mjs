// Copies frontend-react/dist onto the served site, then removes the bundles
// that are no longer referenced.
//
// The site is served straight out of the project directory, so the pages land in
// the project root beside backend-php. That matters beyond tidiness: it is what
// puts the PHP API at a known address relative to the pages, which is how the
// site finds it. Anything left behind in assets/ is dead weight the browser
// will never ask for again, so it is removed rather than left to grow.
import {cpSync, existsSync, mkdirSync, readFileSync, readdirSync, rmSync} from 'node:fs';
import {join} from 'node:path';

const root = process.argv[2] || process.cwd();
const dist = join(root, 'frontend-react', 'dist');
const site = root;

if (!existsSync(dist)) throw new Error(`no build to deploy: ${dist} is missing`);

// Every page the build produces, listed so that a page's own bundle is kept.
// pay.html and account.html used to be missing from this list, which meant
// their scripts were counted as dead weight and deleted on every deploy - the
// page then loaded a script that was no longer there.
const html = ['index.html', 'menu.html', 'rooms.html', 'pay.html', 'account.html', 'events.html', 'facilities.html'];
const referenced = new Set();
for (const page of html) {
  const file = join(dist, page);
  if (!existsSync(file)) throw new Error(`the build has no ${page}`);
  for (const m of readFileSync(file, 'utf8').matchAll(/assets\/[\w.-]+/g)) referenced.add(m[0]);
}

mkdirSync(site, {recursive: true});
for (const name of readdirSync(dist)) cpSync(join(dist, name), join(site, name), {recursive: true});

const kept = new Set([...referenced].map(p => p.replace('assets/', '')));
const assets = join(site, 'assets');
const removed = [];
for (const name of readdirSync(assets)) {
  if (!kept.has(name)) {
    rmSync(join(assets, name));
    removed.push(name);
  }
}

console.log(`deployed ${html.length} pages to ${site}`);
console.log(`  assets in use:     ${[...kept].sort().join(', ')}`);
console.log(`  assets removed:    ${removed.length ? removed.join(', ') : 'none'}`);

const missing = [...referenced].filter(p => !existsSync(join(site, p)));
if (missing.length) throw new Error(`the pages point at files that were not copied: ${missing.join(', ')}`);
