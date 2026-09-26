import React from 'react';
import manifest from './image-manifest.json';

export type ImageGroup = 'dishes' | 'rooms' | 'gallery';

type Variant = {w: number; ext: string; h: number};
type Entry = {ext: string; w: number; h: number; variants: Variant[]};

/** The folder each group of photographs lives in. */
export const IMAGE_DIR: Record<ImageGroup, string> = {
  dishes: './images/dishes/',
  rooms: './images/rooms/',
  gallery: './images/gallery/'
};

const LIB = manifest as Record<ImageGroup, Record<string, Entry>> & {hero: Entry[]};

export type HeroShot = {slug: string; ext: string; w: number; h: number; variants: Variant[]};

/** What the build found in /images, already sorted into carousel order. */
export const heroShots: HeroShot[] = LIB.hero || [];

/**
 * Photographs dropped in after the last build. Each unknown slug is checked
 * once per session against the extensions we accept, and the answer is cached
 * so the 81 dish cards do not each fire their own set of requests.
 */
const probed = new Map<string, Entry | null>();
const waiting = new Map<string, Array<(e: Entry | null) => void>>();

const EXTS = ['jpg', 'jpeg', 'png', 'webp', 'avif'];

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

  (async () => {
    for (const ext of EXTS) {
      try {
        // HEAD keeps a missing photo out of the browser console entirely.
        const res = await fetch(IMAGE_DIR[group] + slug + '.' + ext, {method: 'HEAD'});
        if (res.ok) return finish({ext, w: 0, h: 0, variants: []});
      } catch {
        /* not published yet, try the next extension */
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
 * Builds a srcset from the widths the photograph really has, so nothing is ever
 * asked to scale up. A missing derivative simply drops out of the list.
 */
function srcSetFor(entry: Entry, group: ImageGroup, slug: string, widths: number[]) {
  const candidates: Array<{file: string; w: number}> = [];
  for (const w of widths) {
    const variant = entry.variants.find(v => v.w >= w);
    if (variant) candidates.push({file: slug + '-' + variant.w + '.' + variant.ext, w});
  }
  // The original is the ceiling: never advertise a width it cannot fill.
  if (entry.w) candidates.push({file: slug + '.' + entry.ext, w: entry.w});

  const seen = new Set<number>();
  return candidates
    .filter(c => (seen.has(c.w) ? false : (seen.add(c.w), true)))
    .sort((a, b) => a.w - b.w)
    .map(c => IMAGE_DIR[group] + c.file + ' ' + c.w + 'w')
    .join(', ');
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
  const known = LIB[group]?.[slug];

  const [entry, setEntry] = React.useState<Entry | null | undefined>(known);
  const [failed, setFailed] = React.useState(false);

  // Known at build time: render straight away. Unknown: ask once.
  React.useEffect(() => {
    if (known || !slug) return;
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

  if (!slug || failed || entry === null || (!known && entry === undefined)) {
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

  const srcset = srcSetFor(entry, group, slug, w);
  const src = IMAGE_DIR[group] + slug + '.' + entry.ext;

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
