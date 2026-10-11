import React from 'react';
import {createRoot} from 'react-dom/client';
import './styles.css';
import {ExploreMore, TopBar, PageNav, Footer, BackLink, apiUrl, CALL, telHref, HOTEL, useReveal} from './shared';
import {heroShots} from './SmartImage';

/*
 * The hotel's newsroom.
 *
 * Everything shown here was written in the console and read back through the
 * public API, so the page never holds a second copy of the hotel's words. The
 * list can be searched and filtered in the browser the moment it has arrived,
 * and any one story can be linked to directly - news.html#slug - which is how
 * the console's own "View on site" button and a colleague's email both reach it.
 */

type Post = {
  id: number; slug: string; title: string; category: string; category_label: string;
  excerpt: string; body: string; image: string; department: string; location: string;
  employment_type: string; salary: string; deadline: string; apply_email: string;
  apply_url: string; author_name: string; author_role: string; pinned: boolean;
  views: number; published: string; updated: string;
};

type State = {posts: Post[]; cats: Record<string, string>} | null;

/** The one story, with the widest photograph the build found behind it. */
function HeroCover({slug}: {slug: string}) {
  const shot = heroShots.find(s => s.slug === slug);
  if (!shot) return <div className="pageHeroBg" aria-hidden="true"/>;
  const fallback = shot.dir + shot.file;
  const srcset = [
    `${fallback} ${shot.w}w`,
    ...shot.variants.map(v => `${shot.dir}${shot.slug}-${v.w}.${v.ext} ${v.w}w`)
  ].join(', ');
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
  const qs = new URLSearchParams(params).toString();
  try {
    const res = await fetch(qs ? `${base}&${qs}` : base, {headers: {Accept: 'application/json'}});
    return await res.json();
  } catch {
    return {ok: false, error: 'We could not reach the hotel right now. Please call ' + CALL + '.'};
  }
};

const Tag = ({children}: {children: React.ReactNode}) => <span className="newsTag">{children}</span>;

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
      <HeroCover slug="jinja-main-bridge-view-from-hotel-at-night"/>
      <div className="pageHeroInner">
        <BackLink label="Back" fallback="./index.html"/>
        <p className="eyebrow">NEWS, UPDATES, OPPORTUNITIES &amp; CAREERS</p>
        <h1>What is happening at the hotel.</h1>
        <p>Announcements and notices, opportunities for our community, and the roles we are hiring for. When we honour a colleague or open a vacancy, this is where the hotel says it first.</p>
      </div>
    </section>

    <section className="section newsWrap">
      {!open && (
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
            {open.image && (
              <figure className="newsArticleFig">
                <img src={open.image} alt={open.title} loading="eager" decoding="async"/>
              </figure>
            )}
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

            {rest.length > 0 && (
              <div className="newsMore">
                <h2>More from the hotel</h2>
                <div className="newsMoreGrid">
                  {posts.filter(p => p.slug !== open.slug).slice(0, 3).map(p => (
                    <button type="button" className="newsMini" key={p.slug} onClick={() => show(p)}>
                      {p.image && <img src={p.image} alt="" loading="lazy"/>}
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
                  {p.image && <span className="newsFeatureImg" style={{backgroundImage: `url('${p.image}')`}}/>}
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
              <span className="newsEotmBadge">Employee of the month</span>
              <span className="newsEotmBody">
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
                    {p.image
                      ? <img src={p.image} alt={p.title} loading="lazy" decoding="async"/>
                      : <span className="newsCardGlyph" aria-hidden="true"/>}
                  </span>
                  <span className="newsCardBody">
                    <Tag>{p.category_label}</Tag>
                    <b className="newsCardTitle">{p.title}</b>
                    <span className="newsCardText">{p.excerpt}</span>
                    <span className="newsCardFoot">
                      <span className="newsDate">{niceDate(p.published)}</span>
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

    <Footer/>
  </div>;
}

createRoot(document.getElementById('root')!).render(<NewsPage/>);
