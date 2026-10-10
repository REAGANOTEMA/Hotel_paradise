import React from 'react';
import manifest from './image-manifest.json';

export type ImageGroup =
  | 'dishes'
  | 'rooms'
  | 'gallery'
  | 'facilities'
  | 'site'
  | 'halls'
  | 'beds-exec'
  | 'beds-suit'
  | 'beds-triple'
  | 'beds-twin';

type Variant = {w: number; ext: string; h: number; file?: string};
type Entry = {ext: string; w: number; h: number; variants: Variant[]};

/** The folder a photo may actually live in. */
export type ImageHome = ImageGroup | 'food';

/** The folder each group of photographs lives in. */
export const IMAGE_DIR: Record<ImageHome, string> = {
  dishes: './images/dishes/',
  rooms: './images/rooms/',
  gallery: './images/gallery/',
  facilities: './images/facilities/',
  food: './images/food/',
  site: './images/',
  halls: './images/meeting-rooms/',
  'beds-exec': './images/executive-beds-images/',
  'beds-suit': './images/suit-beds-images/',
  'beds-triple': './images/triple-beds-images/',
  'beds-twin': './images/twin-bed-images/'
};

/** The poster a film slot waits on. It lives in the folder of the film. */
export type HeroPoster = {dir: string; file: string; ext: string; w: number; h: number};

/**
 * One slot of the home carousel.
 *
 * `dir` and `file` are the exact path to the bytes, because a slot may sit in
 * a subfolder and may be served straight from its widest narrow copy when no
 * full size original exists. `kind` marks the hotel film, which plays over
 * `poster` instead of fading in like a photograph.
 */
export type HeroShot = {
  slug: string;
  dir: string;
  file: string;
  ext: string;
  w: number;
  h: number;
  variants: Variant[];
  kind?: 'image' | 'video';
  poster?: HeroPoster;
};

/**
 * The hero list is the one place the manifest names the photograph, so that the
 * carousel can lay its slides out before anything is fetched. Every other group
 * is keyed by slug, which is why HeroShot carries the extra field.
 */
// The manifest is generated from whatever is on disk, so a group whose folder
// is empty or absent is simply missing from it. Partial says that honestly and
// keeps typecheck working even before the first build has rewritten the file,
// while every read below is already guarded with optional chaining.
const LIB = manifest as unknown as Partial<Record<ImageGroup, Record<string, Entry>>> & {
  hero: HeroShot[];
  food?: Record<string, Entry>;
};

/**
 * Finds the photograph for a slot and the folder it actually lives in.
 * The dish group keeps two folders on disk: /images/dishes (the files the menu
 * is built from) and /images/food (the kitchen's working copy). A dish that has
 * no plate in dishes is served from food, so a photo filed only once never
 * shows as an empty box. The other groups read from their own folder alone.
 */
function entryFor(group: ImageGroup, slug: string): {entry: Entry | null; dir: ImageHome} {
  const here = LIB[group]?.[slug] ?? null;
  if (here) return {entry: here, dir: group};
  if (group === 'dishes') {
    const filed = LIB.food?.[slug] ?? null;
    if (filed) return {entry: filed, dir: 'food'};
  }
  return {entry: null, dir: group};
}

/** What the build found in /images, already sorted into carousel order. */
export const heroShots: HeroShot[] = LIB.hero || [];

/**
 * Photographs dropped in after the last build. Each unknown slug is checked
 * once per session against the extensions we accept, and the answer is cached
 * so the 81 dish cards do not each fire their own set of requests.
 *
 * This only runs when the file hints are switched on. The build manifest is the
 * list of photographs the site actually ships, and a guest who loads the menu
 * should not pay for the guesses: probing asked the server about every missing
 * file five times over, which on this menu came to nearly a thousand 404s a
 * page and filled the console with noise. A photograph added after the last
 * build appears on the next build, and ?photos=1 picks it up straight away
 * while it is being prepared.
 */
const probed = new Map<string, Entry | null>();
const waiting = new Map<string, Array<(e: Entry | null) => void>>();

const EXTS = ['jpg', 'jpeg', 'png', 'webp', 'avif'];

/**
 * Whether to show the file name a photo slot is waiting for, and to let the
 * slots ask the server about photographs the build did not know about.
 *
 * Add ?photos=1 to any page. It is here so the kitchen can tell at a glance
 * which photographs are still outstanding, and so a new picture can be tried
 * before the site is rebuilt. Guests never see it.
 */
export function photoHintsEnabled(): boolean {
  try {
    return new URLSearchParams(location.search).get('photos') === '1';
  } catch {
    return false;
  }
}

function probe(group: ImageGroup, slug: string): Promise<Entry | null> {
  const hit = probed.get(slug);
  if (hit !== undefined) return Promise.resolve(hit);

  const queued = waiting.get(slug);
  if (queued) return new Promise(res => queued.push(res));

  const resolvers: Array<(e: Entry | null) => void> = [];
  waiting.set(slug, resolvers);

  const finish = (entry: Entry | null) => {
    probed.set(slug, entry);
    waiting.get(slug)?.forEach(r => r(entry));
    waiting.delete(slug);
  };

  const homes: ImageHome[] = group === 'dishes' ? ['dishes', 'food'] : [group];

  (async () => {
    for (const home of homes) {
      for (const ext of EXTS) {
        try {
          // HEAD keeps a missing photo out of the browser console entirely.
          const res = await fetch(IMAGE_DIR[home] + slug + '.' + ext, {method: 'HEAD'});
          if (res.ok) return finish({ext, w: 0, h: 0, variants: []});
        } catch {
          /* not published yet, try the next extension */
        }
      }
    }
    finish(null);
  })();

  return new Promise(res => resolvers.push(res));
}

export type SmartImageProps = {
  group: ImageGroup;
  /** The photo to look for, with or without its extension. */
  name: string;
  alt: string;
  /** CSS aspect-ratio for the reserved box, so the layout never jumps. */
  ratio?: string;
  /** srcset candidates. Only widths the file really has are ever offered. */
  widths?: number[];
  sizes?: string;
  /** Keeps the subject in frame: '50% 30%' pulls a face away from the top edge. */
  position?: string;
  /** Set on the first hero slide so it is fetched before it is needed. */
  priority?: boolean;
  className?: string;
  imgClassName?: string;
  /** Shown while unknown, and permanently if the photograph never arrives. */
  placeholder?: React.ReactNode;
  /** Gentle grow on hover, for cards. */
  zoom?: boolean;
  /** Laid over the photograph, on its own legibility scrim. */
  children?: React.ReactNode;
};

const bare = (name: string) =>
  name
    .toLowerCase()
    .replace(/\.[^.]+$/, '')
    .replace(/&/g, 'and')
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '');

/**
 * The files a photograph may be served as, smallest first.
 *
 * Only widths the file really has are offered, so nothing is ever asked to
 * scale up. The original joins the list only when it is not wildly larger than
 * the widest copy the layout can use: a 6000px camera plate must never be
 * picked to fill a 460px card just because it is the only file wider than the
 * phone, which would quietly undo every small copy the build made. Where that
 * ceiling is passed the derivatives carry the load on their own.
 */
function candidatesFor(entry: Entry, slug: string, widths: number[]): Array<{file: string; w: number}> {
  const out: Array<{file: string; w: number}> = [];
  const seen = new Set<string>();
  const add = (file: string, w: number) => {
    if (!seen.has(file)) { seen.add(file); out.push({file, w}); }
  };

  for (const target of widths) {
    const variant = entry.variants.find(v => v.w >= target);
    if (variant) add(slug + '-' + variant.w + '.' + variant.ext, variant.w);
  }

  const ceiling = widths.length ? Math.max(...widths) : 0;
  if (entry.w && entry.w <= ceiling * 1.6) add(slug + '.' + entry.ext, entry.w);

  return out.sort((a, b) => a.w - b.w);
}

export function SmartImage({
  group,
  name,
  alt,
  ratio,
  widths,
  sizes,
  position = '50% 50%',
  priority = false,
  className = '',
  imgClassName = '',
  placeholder,
  zoom = false,
  children
}: SmartImageProps) {
  const slug = bare(name);
  const {entry: known, dir: home} = slug ? entryFor(group, slug) : {entry: undefined, dir: group};

  const [entry, setEntry] = React.useState<Entry | null | undefined>(known);
  const [failed, setFailed] = React.useState(false);

  // Known at build time: render straight away. Unknown: ask once, and only
  // when the file hints are on, so a normal page load makes no guesses.
  React.useEffect(() => {
    if (known || !slug || !photoHintsEnabled()) return;
    let alive = true;
    probe(group, slug).then(found => {
      if (alive) setEntry(found);
    });
    return () => {
      alive = false;
    };
  }, [group, slug, known]);

  const w = widths ?? [320, 480, 640, 960, 1280];
  // Exposed as a custom property rather than an inline aspect-ratio, so a
  // media query can still change the crop on a narrow screen.
  const box = ratio ? ({'--r': ratio} as React.CSSProperties) : undefined;

  // entry is the photograph the build found, null when it has been proved
  // missing, and undefined only while an unknown slug is still being asked
  // about. Anything but a real Entry means show the waiting box.
  if (!slug || failed || !entry) {
    return (
      <div
        className={'photoBox isEmpty ' + className}
        style={box}
        role={placeholder ? undefined : 'img'}
        aria-label={placeholder ? undefined : alt}
      >
        {placeholder}
        {children && <div className="photoOverlay">{children}</div>}
      </div>
    );
  }

  const candidates = candidatesFor(entry, slug, w);
  const srcset = candidates.map(c => IMAGE_DIR[home] + c.file + ' ' + c.w + 'w').join(', ');
  // With derivatives on disk the fallback is the widest of them, never the
  // multi megabyte original behind them.
  const src = IMAGE_DIR[home] + (candidates.length
    ? candidates[candidates.length - 1].file
    : slug + '.' + entry.ext);

  return (
    <div className={'photoBox ' + className + (zoom ? ' zooms' : '')} style={box}>
      <img
        className={'photoImg ' + imgClassName}
        src={src}
        srcSet={srcset || undefined}
        sizes={srcset ? sizes : undefined}
        alt={alt}
        width={entry.w || undefined}
        height={entry.h || undefined}
        style={{objectPosition: position}}
        loading={priority ? 'eager' : 'lazy'}
        decoding={priority ? 'sync' : 'async'}
        fetchPriority={priority ? 'high' : 'auto'}
        draggable={false}
        onError={() => {
          // A build can go stale against a folder that changed on disk.
          probed.set(slug, null);
          setFailed(true);
        }}
      />
      {children && <div className="photoOverlay">{children}</div>}
    </div>
  );
}
