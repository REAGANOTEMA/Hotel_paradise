import React from 'react';
import {createRoot} from 'react-dom/client';
import './styles.css';
import {ExploreMore, TopBar, PageNav, Footer, BackLink, apiUrl, CALL, telHref, HOTEL, useReveal, type HeroCoverFrame} from './shared';
import {MenuConcierge} from './concierge';

/*
 * The hotel's newsroom.
 *
 * Everything shown here was written in the console and read back through the
 * public API, so the page never holds a second copy of the hotel's words. The
 * list can be searched and filtered in the browser the moment it has arrived,
 * and any one story can be linked to directly - news.html#slug - which is how
 * the console's own "View on site" button and a colleague's email both reach it.
 */

type Reaction = 'like' | 'love' | 'applause';
type ReactionCounts = {like: number; love: number; applause: number};
type StoryComment = {
  id: number; parent_id: number | null; name: string; body: string; created_at: string;
};

type Post = {
  id: number; slug: string; title: string; category: string; category_label: string;
  excerpt: string; body: string; image: string; department: string; location: string;
  employment_type: string; salary: string; deadline: string; apply_email: string;
  apply_url: string; author_name: string; author_role: string; pinned: boolean;
  views: number; published: string; updated: string;
  reactions?: ReactionCounts; my_reaction?: string; comment_count?: number;
  comments?: StoryComment[];
};

type State = {posts: Post[]; cats: Record<string, string>} | null;

/**
 * The one story, with a chilled cocktail and fresh juice from the bar behind
 * it. Read from the finished hero copies like every other page cover, so it
 * never depends on the home carousel and stays the same on news whether or not
 * the same photograph turns in the slides up top.
 */
const NEWS_COVER: HeroCoverFrame[] = [
  {base: './images/hero/coctail-juice', ext: 'webp', widths: [640, 1024]}
];

/**
 * The photograph a story wears when the console has not attached one.
 *
 * Every post has been given a picture to open with, but a colleague writing in
 * a hurry can still publish without uploading one. Rather than leave a bare
 * block of colour, each category falls back to a photograph of the hotel that
 * suits it, so the newsroom is never a wall of grey type however quickly the
 * story was filed.
 */
const CATEGORY_IMAGE: Record<string, string> = {
  news: './images/hero/hotel-960.webp',
  update: './images/hero/wine-and-fried-chiken-960.webp',
  opportunity: './images/hero/food-spread-960.webp',
  recruitment: './images/hero/dinning-space.webp',
  employee: './images/hero/view-960.webp'
};
const FALLBACK_IMAGE = './images/hero/hotel-960.webp';

/** The picture a story is shown with: its own, or its category's stand-in. */
const storyImage = (p: Post): string => p.image || CATEGORY_IMAGE[p.category] || FALLBACK_IMAGE;

function HeroCover() {
  const f = NEWS_COVER[0];
  const fallback = f.base + '-' + f.widths[f.widths.length - 1] + '.' + f.ext;
  const srcset = f.widths.map(w => f.base + '-' + w + '.' + f.ext + ' ' + w + 'w').join(', ');
  return (
    <div className="pageHeroBg" aria-hidden="true">
      <img className="pageHeroBgImg on" src={fallback} srcSet={srcset} sizes="100vw" alt=""
       decoding="async" fetchPriority="high" draggable={false}/>
    </div>
  );
}

/** A date as it is printed beside a story, small and kind to read. */
const niceDate = (value: string): string => {
  const t = (value || '').replace(' ', 'T');
  if (!t) return '';
  const d = new Date(t);
  if (isNaN(d.getTime())) return value;
  return d.toLocaleDateString('en-GB', {day: 'numeric', month: 'long', year: 'numeric'});
};

/** A body written in the console is plain text: blank lines break paragraphs. */
const paragraphs = (body: string): string[] =>
  (body || '').split(/\n{2,}/).map(s => s.trim()).filter(Boolean);

const slugFromUrl = (): string => {
  const hash = decodeURIComponent(window.location.hash.replace(/^#/, ''));
  if (hash) return hash;
  return new URLSearchParams(window.location.search).get('slug') || '';
};

/** Reads the published news, or one story when a slug is given. */
const getNews = async (params: Record<string, string> = {}): Promise<any> => {
  const base = await apiUrl('news');
  const qs = new URLSearchParams({...params, visitor: newsVisitor()}).toString();
  try {
    const res = await fetch(qs ? `${base}&${qs}` : base, {headers: {Accept: 'application/json'}});
    return await res.json();
  } catch {
    return {ok: false, error: 'We could not reach the hotel right now. Please call ' + CALL + '.'};
  }
};

/**
 * A random name for this browser, kept so a reaction or comment can be tied to
 * the same visitor without asking anyone to sign in. It carries no personal
 * detail, and the hotel stores only a hash of it. If storage is blocked the id
 * lasts for the visit instead.
 */
const VISITOR_KEY = 'hpn_news_visitor';
let fallbackVisitor = '';
const newsVisitor = (): string => {
  try {
    const saved = window.localStorage.getItem(VISITOR_KEY);
    if (saved) return saved;
    const c = window.crypto as Crypto & {randomUUID?: () => string};
    const id = c && typeof c.randomUUID === 'function'
      ? c.randomUUID()
      : Date.now().toString(36) + '-' + Math.random().toString(36).slice(2);
    window.localStorage.setItem(VISITOR_KEY, id);
    return id;
  } catch {
    if (!fallbackVisitor) {
      fallbackVisitor = 'visit-' + Date.now().toString(36) + '-' + Math.random().toString(36).slice(2);
    }
    return fallbackVisitor;
  }
};

/** Sends a reaction or a comment to the newsroom and reads the answer back. */
const newsPost = async (act: 'news_react' | 'news_comment', payload: Record<string, unknown>): Promise<any> => {
  const base = await apiUrl(act);
  try {
    const res = await fetch(base, {
      method: 'POST',
      headers: {'Content-Type': 'application/json', Accept: 'application/json'},
      body: JSON.stringify({...payload, visitor: newsVisitor()})
    });
    return await res.json();
  } catch {
    return {ok: false, error: 'We could not reach the hotel. Please check your connection and try again.'};
  }
};

const Tag = ({children}: {children: React.ReactNode}) => <span className="newsTag">{children}</span>;

const REACTION_LABELS: {key: Reaction; label: string}[] = [
  {key: 'like', label: 'Like'},
  {key: 'love', label: 'Love'},
  {key: 'applause', label: 'Applause'}
];

const EMPTY_REACTIONS: ReactionCounts = {like: 0, love: 0, applause: 0};

/** A small line icon for each reaction. */
function ReactionIcon({kind}: {kind: Reaction}) {
  if (kind === 'love') {
    return <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 20.2S4.4 15.6 4.4 10.3A4.1 4.1 0 0 1 12 7.6a4.1 4.1 0 0 1 7.6 2.7c0 5.3-7.6 9.9-7.6 9.9z"/></svg>;
  }
  if (kind === 'applause') {
    return <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M8 12V7M12 11V5M16 12V7"/><path d="M6 15c1.6 2.2 3.6 3.3 6 3.3s4.4-1.1 6-3.3"/><path d="M4 9l1.4-.8M20 9l-1.4-.8"/></svg>;
  }
  return <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M7 10.5V20H4a1 1 0 0 1-1-1v-7.5a1 1 0 0 1 1-1h3zM7 10.5l3.6-6.1A1.6 1.6 0 0 1 13.2 5v3.8h5.2a1.8 1.8 0 0 1 1.8 2.1l-1 6.3a1.8 1.8 0 0 1-1.8 1.5H7"/></svg>;
}

/**
 * The spotlight above the newsroom.
 *
 * The first three or four stories - pinned ones first, then the newest - turn
 * every four seconds. Every slide is already in the page as a real button, so
 * nothing is rebuilt as the turn happens and a slow photograph never leaves a
 * blank frame. It stops while a pointer or keyboard is on it, while the tab is
 * hidden, and entirely for a reader who has asked for less motion. The dots
 * and arrows are ordinary buttons, so it works without a mouse.
 */
function NewsSpotlight({posts, onOpen}: {posts: Post[]; onOpen: (p: Post) => void}) {
  const slides = React.useMemo(() => {
    const pinned = posts.filter(p => p.pinned).slice(0, 4);
    const rest = posts.filter(p => !p.pinned);
    return [...pinned, ...rest].slice(0, 4);
  }, [posts]);
  const [index, setIndex] = React.useState(0);
  const [hover, setHover] = React.useState(false);
  const [focus, setFocus] = React.useState(false);
  const [gone, setGone] = React.useState(false);
  const [still, setStill] = React.useState(false);

  React.useEffect(() => {
    const mq = window.matchMedia('(prefers-reduced-motion: reduce)');
    const sync = () => setStill(mq.matches);
    sync();
    mq.addEventListener?.('change', sync);
    return () => mq.removeEventListener?.('change', sync);
  }, []);

  React.useEffect(() => {
    const sync = () => setGone(document.hidden);
    sync();
    document.addEventListener('visibilitychange', sync);
    return () => document.removeEventListener('visibilitychange', sync);
  }, []);

  React.useEffect(() => {
    if (index >= slides.length) setIndex(0);
  }, [index, slides.length]);

  const paused = hover || focus || gone || still;
  React.useEffect(() => {
    if (paused || slides.length < 2) return;
    const timer = window.setInterval(() => setIndex(n => (n + 1) % slides.length), 4000);
    return () => window.clearInterval(timer);
  }, [paused, slides.length]);

  if (slides.length === 0) return null;

  const step = (by: number) => setIndex(n => (n + by + slides.length) % slides.length);

  return <section className="spotlight reveal" aria-roledescription="carousel"
    aria-label="Featured stories" onMouseEnter={() => setHover(true)} onMouseLeave={() => setHover(false)}
    onFocus={() => setFocus(true)} onBlur={() => setFocus(false)}>
    <div className="spotStage">
      {slides.map((p, n) => {
        const r = p.reactions || EMPTY_REACTIONS;
        const total = r.like + r.love + r.applause;
        return (
        <button type="button" key={p.slug} className={'spotSlide' + (n === index ? ' on' : '')}
          onClick={() => onOpen(p)} aria-hidden={n !== index} tabIndex={n === index ? 0 : -1}>
          <img src={storyImage(p)} alt="" loading={n === 0 ? 'eager' : 'lazy'} decoding="async"
            onError={e => {
              const img = e.currentTarget;
              if (img.dataset.fallback !== '1') { img.dataset.fallback = '1'; img.src = FALLBACK_IMAGE; }
            }}/>
          <span className="spotScrim" aria-hidden="true"/>
          <span className="spotBody">
            <Tag>{p.category_label}</Tag>
            <b>{p.title}</b>
            <span className="spotText">{p.excerpt}</span>
            <span className="spotMeta">
              <span>{niceDate(p.published)}</span>
              <span className="spotStats" aria-label={total + ' reactions, ' + (p.comment_count || 0) + ' comments'}>
                <span><ReactionIcon kind="like"/>{total}</span>
                <span><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M4 5.5A2.5 2.5 0 0 1 6.5 3h11A2.5 2.5 0 0 1 20 5.5v7A2.5 2.5 0 0 1 17.5 15H9l-4.5 4V5.5Z"/></svg>{p.comment_count || 0}</span>
              </span>
              <span className="spotRead">Read the story
                <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M5 12h14M13 6l6 6-6 6"/></svg>
              </span>
            </span>
          </span>
        </button>
        );
      })}

      <div className="spotRail">
        <button type="button" className="spotArrow" onClick={() => step(-1)} aria-label="Previous featured story">
          <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M15 5l-7 7 7 7"/></svg>
        </button>
        <div className="spotDots" role="group" aria-label="Choose a featured story">
          {slides.map((p, n) => (
            <button type="button" key={p.slug} className={'spotDot' + (n === index ? ' on' : '')}
              aria-label={'Story ' + (n + 1) + ' of ' + slides.length + ': ' + p.title}
              aria-current={n === index ? 'true' : undefined} onClick={() => setIndex(n)}/>
          ))}
        </div>
        <button type="button" className="spotArrow" onClick={() => step(1)} aria-label="Next featured story">
          <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M9 5l7 7-7 7"/></svg>
        </button>
      </div>

      {slides.length > 1 && !still && (
        <div className="spotProgress" aria-hidden="true">
          <span key={index} style={{animationPlayState: paused ? 'paused' : 'running'}}/>
        </div>
      )}
    </div>
    <span className="srOnly" aria-live="polite">Story {index + 1} of {slides.length}: {slides[index].title}</span>
  </section>;
}

/** Reactions and the comment thread under one story. */
function ArticleSocial({post}: {post: Post}) {
  const [counts, setCounts] = React.useState<ReactionCounts>(post.reactions || EMPTY_REACTIONS);
  const [mine, setMine] = React.useState(post.my_reaction || '');
  const [busy, setBusy] = React.useState<Reaction | ''>('');
  const [note, setNote] = React.useState('');

  React.useEffect(() => {
    setCounts(post.reactions || EMPTY_REACTIONS);
    setMine(post.my_reaction || '');
    setNote('');
  }, [post.slug, post.reactions, post.my_reaction]);

  const react = async (kind: Reaction) => {
    if (busy) return;
    const before = {counts, mine};
    const next = {...counts};
    if (mine === kind) {
      next[kind] = Math.max(0, next[kind] - 1);
      setMine('');
    } else {
      if (mine) next[mine as Reaction] = Math.max(0, next[mine as Reaction] - 1);
      next[kind] += 1;
      setMine(kind);
    }
    setCounts(next);
    setBusy(kind);
    setNote('');
    const d = await newsPost('news_react', {slug: post.slug, reaction: kind});
    setBusy('');
    if (d && d.ok) {
      setCounts(d.reactions || next);
      setMine(d.my_reaction || '');
    } else {
      setCounts(before.counts);
      setMine(before.mine);
      setNote((d && d.error) || 'Your reaction could not be saved. Please try again.');
    }
  };

  const [thread, setThread] = React.useState<StoryComment[]>(post.comments || []);
  const [name, setName] = React.useState('');
  const [email, setEmail] = React.useState('');
  const [text, setText] = React.useState('');
  const [trap, setTrap] = React.useState('');
  const [sending, setSending] = React.useState(false);
  const [formNote, setFormNote] = React.useState('');
  const [formError, setFormError] = React.useState('');

  React.useEffect(() => {
    setThread(post.comments || []);
  }, [post.slug, post.comments]);

  const send = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    if (sending) return;
    setFormError('');
    setFormNote('');
    const cleanName = name.trim();
    const cleanText = text.trim();
    if (cleanName.length < 2) { setFormError('Please write your name (2 to 80 characters).'); return; }
    if (cleanText.length < 2) { setFormError('Please write a comment before sending.'); return; }
    setSending(true);
    const d = await newsPost('news_comment', {
      slug: post.slug, name: cleanName, email: email.trim(), body: cleanText, website: trap
    });
    setSending(false);
    if (!d || !d.ok) {
      setFormError((d && d.error) || 'Your comment could not be sent. Please try again.');
      return;
    }
    setThread(prev => [...prev, d.comment as StoryComment]);
    setName('');
    setEmail('');
    setText('');
    setTrap('');
    setFormNote('Thank you. Your comment is now on the story.');
  };

  return <section className="articleSocial" aria-label="Reactions and comments">
    <div className="reactionBar">
      <div className="reactionLead">
        <b>A word from you</b>
        <span>Let the hotel know this story landed. One reaction each; tap again to take it back.</span>
      </div>
      <div className="reactionBtns" role="group" aria-label="React to this story">
        {REACTION_LABELS.map(r => (
          <button type="button" key={r.key} className={'reactBtn' + (mine === r.key ? ' on' : '')}
            aria-pressed={mine === r.key} aria-label={r.label + ', ' + counts[r.key]}
            title={r.label} onClick={() => react(r.key)} disabled={!!busy}>
            <ReactionIcon kind={r.key}/>
            <span>{r.label}</span>
            <em>{counts[r.key]}</em>
          </button>
        ))}
      </div>
      {note && <p className="reactNote" role="status">{note}</p>}
    </div>

    <div className="commentsBlock">
      <div className="commentsHead">
        <h2>Comments <span>{thread.length}</span></h2>
        <p>Thoughts are welcome from guests and neighbours alike. Keep them kind and on topic; comments appear as they are sent.</p>
      </div>

      {thread.length > 0 ? (
        <ol className="commentsList">
          {thread.map(c => (
            <li key={c.id}>
              <div className="commentWho">
                <b>{c.name}</b>
                <time dateTime={c.created_at}>{niceDate(c.created_at)}</time>
              </div>
              <p>{c.body}</p>
            </li>
          ))}
        </ol>
      ) : (
        <div className="commentsEmpty">
          <p>No comments yet. Be the first to write one.</p>
        </div>
      )}

      <form className="commentForm" onSubmit={send} noValidate>
        <div className="commentFields">
          <label>
            <span>Name</span>
            <input value={name} onChange={e => setName(e.target.value)} maxLength={80}
              autoComplete="name" required placeholder="Your name"/>
          </label>
          <label>
            <span>Email <em>optional, never shown</em></span>
            <input type="email" value={email} onChange={e => setEmail(e.target.value)} maxLength={160}
              autoComplete="email" placeholder="you@example.com"/>
          </label>
        </div>
        <label className="commentBody">
          <span>Comment</span>
          <textarea value={text} onChange={e => setText(e.target.value)} rows={5} maxLength={4000}
            required placeholder="Share a thought about this story…"/>
        </label>
        <div className="commentHoney" aria-hidden="true">
          <label>Website<input value={trap} onChange={e => setTrap(e.target.value)}
            tabIndex={-1} autoComplete="off"/></label>
        </div>
        {formError && <p className="commentError" role="alert">{formError}</p>}
        {formNote && <p className="commentSent" role="status">{formNote}</p>}
        <div className="commentFoot">
          <button type="submit" className={'btn' + (sending ? ' loading' : '')} disabled={sending}>
            {sending ? 'Sending…' : 'Post comment'}
          </button>
          <span>Your address is kept privately by the hotel and is never printed.</span>
        </div>
      </form>
    </div>
  </section>;
}

function NewsPage() {
  const [data, setData] = React.useState<State>(null);
  const [loading, setLoading] = React.useState(true);
  const [error, setError] = React.useState('');
  const [open, setOpen] = React.useState<Post | null>(null);
  const [q, setQ] = React.useState('');
  const [cat, setCat] = React.useState('');
  const detailRef = React.useRef<HTMLDivElement>(null);

  useReveal();

  React.useEffect(() => {
    let live = true;
    (async () => {
      const d = await getNews();
      if (!live) return;
      if (!d || !d.ok) {
        setError((d && d.error) || 'The newsroom could not be loaded. Please try again shortly.');
        setLoading(false);
        return;
      }
      setData({posts: (d.posts || []) as Post[], cats: (d.categories || {}) as Record<string, string>});
      setLoading(false);
      const wanted = slugFromUrl();
      if (wanted) {
        const found = (d.posts || []).find((p: Post) => p.slug === wanted);
        if (found) setOpen(found);
      }
    })();
    return () => { live = false; };
  }, []);

  // The address bar follows the open story, so it can be shared and the back
  // button steps out of an article rather than off the page.
  React.useEffect(() => {
    const onPop = () => {
      const s = slugFromUrl();
      if (!s) { setOpen(null); return; }
      setOpen(prev => {
        if (prev && prev.slug === s) return prev;
        const found = data?.posts.find(p => p.slug === s);
        return found ?? prev;
      });
    };
    window.addEventListener('popstate', onPop);
    return () => window.removeEventListener('popstate', onPop);
  }, [data]);

  const show = async (post: Post) => {
    setOpen(post);
    try { window.history.pushState({slug: post.slug}, '', '#' + post.slug); } catch {}
    // Ask for the story again so the read is counted and any edit is picked up.
    const d = await getNews({slug: post.slug});
    if (d && d.ok && d.post) {
      setOpen(d.post as Post);
      setData(prev => prev ? {...prev, posts: prev.posts.map(p => p.slug === post.slug ? d.post as Post : p)} : prev);
    }
    window.setTimeout(() => detailRef.current?.scrollIntoView({behavior: 'smooth', block: 'start'}), 40);
  };

  const close = () => {
    setOpen(null);
    try { window.history.pushState({}, '', window.location.pathname + window.location.search); } catch {}
  };

  const posts = data?.posts ?? [];
  const cats = data?.cats ?? {};
  const needle = q.trim().toLowerCase();
  const filtered = posts.filter(p => {
    if (cat && p.category !== cat) return false;
    if (!needle) return true;
    return [p.title, p.excerpt, p.body, p.department, p.location, p.author_name]
      .join(' ').toLowerCase().includes(needle);
  });
  const featured = filtered.filter(p => p.pinned);
  const rest = filtered.filter(p => !p.pinned);
  const eotm = posts.find(p => p.category === 'employee');

  return <div>
    <TopBar/>
    <PageNav onDark/>

    <section className="pageHero hasCover" id="main">
      <HeroCover/>
      <div className="pageHeroInner">
        <BackLink label="Back" fallback="./index.html"/>
        <p className="eyebrow">NEWS, UPDATES, OPPORTUNITIES &amp; CAREERS</p>
        <h1>What is happening at the hotel.</h1>
        <p>Announcements and notices, opportunities for our community, and the roles we are hiring for. When we honour a colleague or open a vacancy, this is where the hotel says it first.</p>
      </div>
    </section>

    <section className="section newsWrap">
      {!open && (
        <>
          {!loading && !error && <NewsSpotlight posts={posts} onOpen={show}/>}
          <div className="newsBar reveal">
            <div className="newsSearch">
              <svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="11" cy="11" r="7"/><path d="M20 20l-3.2-3.2"/></svg>
              <input type="search" value={q} onChange={e => setQ(e.target.value)}
                placeholder="Search news, notices, vacancies…" aria-label="Search the newsroom"/>
            </div>
            <div className="newsChips" role="tablist" aria-label="Filter by category">
              <button type="button" className={'newsChip' + (cat === '' ? ' on' : '')} onClick={() => setCat('')}>All</button>
              {Object.entries(cats).map(([key, label]) => (
                <button type="button" key={key} className={'newsChip' + (cat === key ? ' on' : '')}
                  onClick={() => setCat(key)}>{label}</button>
              ))}
            </div>
          </div>
        </>
      )}

      {loading && (
        <div className="newsGrid" aria-busy="true">
          {[0, 1, 2].map(i => <div className="newsCard newsSkel" key={i}><span className="skImg"/><span className="skLine"/><span className="skLine short"/></div>)}
        </div>
      )}

      {!loading && error && (
        <div className="newsEmpty">
          <h2>We could not open the newsroom</h2>
          <p>{error} You can also reach the front desk on <a className="footLink nileLine" href={telHref(CALL)}>{CALL}</a>.</p>
          <button className="btn" onClick={() => window.location.reload()}>Try again</button>
        </div>
      )}

      {!loading && !error && open && (
        <div className="newsDetail" ref={detailRef}>
          <button type="button" className="newsBackLink" onClick={close}>
            <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M15 5l-7 7 7 7"/></svg> All news
          </button>
          <article className="newsArticle reveal">
            <header className="newsArticleHead">
              <Tag>{open.category_label}</Tag>
              <h1>{open.title}</h1>
              <p className="newsMeta">
                {open.published && <span>{niceDate(open.published)}</span>}
                {open.author_name && <span>By {open.author_name}{open.author_role ? ', ' + open.author_role : ''}</span>}
                {(open.category === 'recruitment' || open.category === 'opportunity') && open.department && <span>{open.department}</span>}
                {open.location && <span>{open.location}</span>}
              </p>
            </header>
            <figure className="newsArticleFig">
              <img src={storyImage(open)} alt={open.title} loading="eager" decoding="async"/>
            </figure>
            <div className="newsArticleBody">
              {paragraphs(open.body || open.excerpt).map((p, i) => <p key={i}>{p}</p>)}
            </div>

            {(open.category === 'recruitment' || open.category === 'opportunity') && (
              <aside className="newsApply">
                <h2>{(open.category === 'recruitment') ? 'About this vacancy' : 'About this opportunity'}</h2>
                <dl>
                  {open.department && <><dt>Department</dt><dd>{open.department}</dd></>}
                  {open.location && <><dt>Location</dt><dd>{open.location}</dd></>}
                  {open.employment_type && <><dt>Type</dt><dd>{open.employment_type}</dd></>}
                  {open.salary && <><dt>Salary</dt><dd>{open.salary}</dd></>}
                  {open.deadline && <><dt>Apply by</dt><dd>{niceDate(open.deadline)}</dd></>}
                </dl>
                <div className="newsApplyGo">
                  {open.apply_url
                    ? <a className="btn" href={open.apply_url} target="_blank" rel="noopener noreferrer">Apply online</a>
                    : open.apply_email
                      ? <a className="btn" href={`mailto:${open.apply_email}?subject=${encodeURIComponent('Application: ' + open.title)}`}>Apply by email</a>
                      : <a className="btn" href={telHref(CALL)}>Call to apply</a>}
                  {open.apply_email && <a className="newsApplyMail" href={'mailto:' + open.apply_email}>{open.apply_email}</a>}
                </div>
              </aside>
            )}

            <ArticleSocial post={open}/>

            {rest.length > 0 && (
              <div className="newsMore">
                <h2>More from the hotel</h2>
                <div className="newsMoreGrid">
                  {posts.filter(p => p.slug !== open.slug).slice(0, 3).map(p => (
                    <button type="button" className="newsMini" key={p.slug} onClick={() => show(p)}>
                      <img src={storyImage(p)} alt="" loading="lazy"/>
                      <span className="newsMiniBody"><Tag>{p.category_label}</Tag><b>{p.title}</b></span>
                    </button>
                  ))}
                </div>
              </div>
            )}
          </article>
        </div>
      )}

      {!loading && !error && !open && (
        <>
          {featured.length > 0 && (
            <div className="newsFeatured">
              {featured.slice(0, 2).map((p, i) => (
                <button type="button" key={p.slug} className={'newsFeature reveal' + (i === 0 ? ' lead' : '')} onClick={() => show(p)}>
                  <span className="newsFeatureImg" style={{backgroundImage: `url('${storyImage(p)}')`}}/>
                  <span className="newsFeatureBody">
                    <Tag>{p.category_label}</Tag>
                    <b>{p.title}</b>
                    <span className="newsFeatureText">{p.excerpt}</span>
                    <span className="newsDate">{niceDate(p.published)}</span>
                  </span>
                </button>
              ))}
            </div>
          )}

          {eotm && cat === '' && !needle && (
            <button type="button" className="newsEotm reveal" onClick={() => show(eotm)}>
              <span className="newsEotmImg" aria-hidden="true">
                <img src={storyImage(eotm)} alt="" loading="lazy"/>
              </span>
              <span className="newsEotmBody">
                <span className="newsEotmBadge">Employee of the month</span>
                <b>{eotm.title}</b>
                <span>{eotm.excerpt}</span>
              </span>
              <span className="newsEotmGo">Read the story
                <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M5 12h14M13 6l6 6-6 6"/></svg>
              </span>
            </button>
          )}

          {filtered.length === 0 ? (
            <div className="newsEmpty">
              <h2>Nothing here yet</h2>
              <p>{needle || cat ? 'No story matches that search. Try another word, or clear the filter.' : 'The hotel has not published anything yet. Please check back soon.'}</p>
              {(needle || cat) && <button className="btn ghost2" onClick={() => {setQ(''); setCat('');}}>Clear filters</button>}
            </div>
          ) : (
            <div className="newsGrid">
              {rest.map(p => (
                <button type="button" className="newsCard reveal" key={p.slug} onClick={() => show(p)}>
                  <span className="newsCardImg">
                    <img src={storyImage(p)} alt={p.title} loading="lazy" decoding="async"/>
                  </span>
                  <span className="newsCardBody">
                    <Tag>{p.category_label}</Tag>
                    <b className="newsCardTitle">{p.title}</b>
                    <span className="newsCardText">{p.excerpt}</span>
                    <span className="newsCardFoot">
                      <span className="newsCardMeta">
                        <span className="newsDate">{niceDate(p.published)}</span>
                        <span className="newsCardStats" aria-label={((p.reactions?.like || 0) + (p.reactions?.love || 0) + (p.reactions?.applause || 0)) + ' reactions, ' + (p.comment_count || 0) + ' comments'}>
                          <span><ReactionIcon kind="like"/>{((p.reactions?.like || 0) + (p.reactions?.love || 0) + (p.reactions?.applause || 0))}</span>
                          <span><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M4 5.5A2.5 2.5 0 0 1 6.5 3h11A2.5 2.5 0 0 1 20 5.5v7A2.5 2.5 0 0 1 17.5 15H9l-4.5 4V5.5Z"/></svg>{p.comment_count || 0}</span>
                        </span>
                      </span>
                      <span className="newsRead">Read
                        <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M5 12h14M13 6l6 6-6 6"/></svg>
                      </span>
                    </span>
                  </span>
                </button>
              ))}
            </div>
          )}

          <div className="newsCta reveal">
            <div>
              <h3>Looking for work, or offering a hand?</h3>
              <p>Vacancies, internships and community opportunities are published here first. To speak to our human resource team directly, call or email the front desk.</p>
            </div>
            <div className="newsApplyGo">
              <a className="btn" href={'mailto:' + HOTEL.email + '?subject=Careers enquiry'}>Email the hotel</a>
              <a className="btn ghost2" href={telHref(CALL)}>Call {CALL}</a>
            </div>
          </div>
        </>
      )}
    </section>

    <ExploreMore current="news"/>

    <MenuConcierge sections={[]}/>

    <Footer/>
  </div>;
}

createRoot(document.getElementById('root')!).render(<NewsPage/>);
