import React from 'react';
import {createRoot} from 'react-dom/client';
import './styles.css';
import {rooms, TopBar, PageNav, Footer, BedGlyph, roomImage, fmtPrice, withService, LOGO, HOTEL, CALL, telHref} from './shared';
import {heroShots, SmartImage, type HeroShot} from './SmartImage';

/**
 * What dining costs, worked out from the base figures so that the 3.5% the
 * hotel carries inside every price reaches this table as well.
 *
 * Each rate also carries the two ends of its own scale, in the same serviced
 * shillings the price is written in. Those are what the little bar under every
 * card is drawn from, so the four rates can be read against one another at a
 * glance rather than compared by arithmetic.
 */
const DINING_TOP = withService(100000);

type DineRate = {
 name: string;
 note: string;
 tag: string;
 icon: 'sun' | 'pot' | 'fork' | 'moon';
 from: number;
 to: number;
 priceText: string;
 unit: string;
 free?: boolean;
};

const dining: DineRate[] = [
 {name: 'Breakfast', tag: 'Included with every room', icon: 'sun',
  note: 'For non residents, or children above six years sharing a room with their parents.',
  from: withService(25000), to: withService(25000), priceText: fmtPrice(25000), unit: 'per person'},
 {name: 'Buffet meal', tag: 'Lunch and dinner', icon: 'pot',
  note: 'Served daily around lunch and dinner, a full table of hot dishes and salads.',
  from: withService(40000), to: withService(40000), priceText: fmtPrice(40000), unit: 'per person'},
 {name: 'A la carte menu', tag: '251 dishes', icon: 'fork',
  note: 'From light bites to full platters, served through the day and into the evening.',
  from: withService(6000), to: DINING_TOP, priceText: fmtPrice(6000) + ' – ' + withService(100000).toLocaleString(), unit: 'per dish'},
 {name: 'Baby cots', tag: 'On the house', icon: 'moon',
  note: 'Available on request for your little one, set up in your room before you arrive.',
  from: 0, to: 0, priceText: 'Free', unit: 'on request', free: true}
];

/** The small line drawing that heads each dining card. */
function dineIcon(name: DineRate['icon']) {
 const path: Record<DineRate['icon'], React.ReactElement> = {
  sun: <><circle cx="12" cy="12" r="4"/><path d="M12 2v2M12 20v2M4.2 4.2l1.4 1.4M18.4 18.4l1.4 1.4M2 12h2M20 12h2M4.2 19.8l1.4-1.4M18.4 5.6l1.4-1.4"/></>,
  pot: <><path d="M4 10h16v6a4 4 0 0 1-4 4H8a4 4 0 0 1-4-4z"/><path d="M2 10h20"/><path d="M9.5 6.5c0-1.4 1.2-1.4 1.2-3M14 6.5c0-1.4 1.2-1.4 1.2-3"/></>,
  fork: <><path d="M6 2v7a2.5 2.5 0 0 0 2.5 2.5V22"/><path d="M4 2v5M8.5 2v5"/><path d="M17 2c2.4 2.6 2.6 7.5.4 10.4V22"/></>,
  moon: <><path d="M20 14.5A8 8 0 0 1 9.5 4a8 8 0 1 0 10.5 10.5z"/></>
 };
 return <svg viewBox="0 0 24 24" aria-hidden="true">{path[name]}</svg>;
}

/**
 * The dining rates as a small chart: one card per rate, each with a bar drawn
 * on a shared scale so the cheapest and the dearest are obvious side by side.
 * The baby cot, which is free, is drawn full and blue rather than gold.
 */
function DiningBoard() {
 return (
  <div className="dineGrid">
   {dining.map(m => {
    const left = m.free ? 0 : Math.round((m.from / DINING_TOP) * 100);
    const width = m.free ? 100 : Math.max(6, Math.round(((m.to - m.from) / DINING_TOP) * 100));
    return (
     <article className={'dineCard reveal' + (m.free ? ' free' : '')} key={m.name}>
      <div className="dineTop">
       <span className="dineIco">{dineIcon(m.icon)}</span>
       <span className="dineTag">{m.tag}</span>
      </div>
      <h4>{m.name}</h4>
      <p className="dineNote">{m.note}</p>
      <div className="dineBar" aria-hidden="true">
       <span className="dineFill" style={{marginLeft: left + '%', width: width + '%'}}/>
      </div>
      <div className="dinePrice"><b>{m.priceText}</b><span>{m.unit}</span></div>
     </article>
    );
   })}
  </div>
 );
}

const facts = [
 {t: 'Rooms', d: '69 rooms spread across 3 floors', img: 'fact-rooms'},
 {t: 'Comfort', d: 'Every room furnished to standard, some air conditioned and others with fans', img: 'fact-comfort'},
 {t: 'Bathrooms', d: 'Private bathrooms with jacuzzis, bathtubs or shower cabinets', img: 'fact-bathrooms'},
 {t: 'In room', d: 'Direct dial telephones and 24 hour satellite television', img: 'fact-in-room'},
 {t: 'Functions', d: 'Conference facilities and gardens for parties', img: 'fact-functions'},
 {t: 'Wellness', d: 'Health club with a swimming pool', img: 'fact-wellness'}
];

const MAP_QUERY = HOTEL.shortName + ', ' + HOTEL.addressForMap;
const MAP_EMBED = 'https://www.google.com/maps?q=' + encodeURIComponent(MAP_QUERY) + '&output=embed';
const MAP_LINK = 'https://www.google.com/maps/search/?api=1&query=' + encodeURIComponent(MAP_QUERY);

const HERO_WIDTHS = [640, 1024, 1440, 1920, 2560];

/** The carousel turns over on this, and so does the zoom on each slide. */
const SLIDE_MS = 5000;

/** Only widths the file really has, so a 680px photo is never asked to fill 2560. */
const heroSrcSet = (shot: HeroShot) => {
  const picks: {file: string; w: number}[] = HERO_WIDTHS.map(w => {
    const v = shot.variants.find(x => x.w >= w);
    return v ? {file: v.file || shot.slug + '-' + v.w + '.' + v.ext, w: v.w} : null;
  }).filter(Boolean) as {file: string; w: number}[];
  if (shot.w) picks.push({file: shot.file, w: shot.w});
  const seen = new Set<number>();
  return picks
    .filter(p => (seen.has(p.w) ? false : (seen.add(p.w), true)))
    .sort((a, b) => a.w - b.w)
    .map(p => shot.dir + p.file + ' ' + p.w + 'w')
    .join(', ');
};

/**
 * Which part of the photograph to hold in frame.
 *
 * A landscape photograph held in a wide frame loses a little off the top and
 * the bottom, and a portrait one loses a great deal, so the anchor moves with
 * the shape of the file: wide pictures sit on their centre, squarer ones a
 * little above it, and portrait ones on the upper third, which keeps a horizon
 * or a skyline in shot instead of the empty foreground below it.
 */
const heroPosition = (shot: {w: number; h: number}) => {
  if (!shot.w || !shot.h) return '50% 50%';
  const r = shot.w / shot.h;
  if (r >= 1.45) return '50% 50%';
  if (r >= 1.0) return '50% 44%';
  return '50% 34%';
};

type HeroCopy = {
  eyebrow: string;
  title: string;
  text: string;
  primary: {label: string; href: string};
  secondary: {label: string; href: string};
};

/**
 * One piece of writing per slide, so the carousel never says the same thing
 * twice. The wording is about the hotel and what it offers rather than about
 * what a particular photograph happens to show, which keeps every slide
 * correct no matter how the pictures are later replaced.
 *
 * The list is read in the order the slides play, so adding or moving a
 * photograph means writing its paragraph here too.
 */
const HERO_COPY: HeroCopy[] = [
  {
    eyebrow: 'HEALTH CLUB AND POOL',
    title: 'Golden afternoons by the pool.',
    text: 'Cool off in our sparkling swimming pool, framed by sun loungers, lush gardens and the gentle sound of the Nile. Pure relaxation, just for you.',
    primary: {label: 'See the facilities', href: '#facilities'},
    secondary: {label: 'Check availability', href: '#book'}
  },
  {
    eyebrow: 'EXECUTIVE COMFORT',
    title: 'Rest like you truly deserve.',
    text: 'Our executive rooms wrap you in crisp linen, soft lighting and quiet luxury, so every night ends beautifully and every morning starts easy.',
    primary: {label: 'See the rooms', href: './rooms.html'},
    secondary: {label: 'Check availability', href: '#book'}
  },
  {
    eyebrow: 'FROM THE GRILL',
    title: 'Burgers worth crossing town for.',
    text: 'Juicy, flame grilled and stacked high, our signature burgers arrive with golden fries and all the trimmings. One bite and you will be back for more.',
    primary: {label: 'Open the menu', href: './menu.html'},
    secondary: {label: 'Send an order', href: './menu.html#order'}
  },
  {
    eyebrow: 'STEAK NIGHT',
    title: 'Perfectly grilled, every time.',
    text: 'Tender steak seared to your liking and served sizzling with crisp potato wedges and a rich sauce. This is dinner done the way it should be.',
    primary: {label: 'Open the menu', href: './menu.html'},
    secondary: {label: 'Send an order', href: './menu.html#order'}
  },
  {
    eyebrow: 'FRESHLY PRESSED',
    title: 'A splash of tropical sunshine.',
    text: 'Bright, refreshing and full of flavour, our juices are pressed to order from ripe local fruit. The freshest way to begin or end your day.',
    primary: {label: 'Open the menu', href: './menu.html'},
    secondary: {label: 'Send an order', href: './menu.html#order'}
  },
  {
    eyebrow: 'FROM THE BAR',
    title: 'Raise a glass to the evening.',
    text: 'A carefully chosen wine list and a relaxed riverside bar turn every night into a celebration. Come for dinner, stay for the golden hour.',
    primary: {label: 'Open the menu', href: './menu.html'},
    secondary: {label: 'See the rates', href: '#rates'}
  },
  {
    eyebrow: 'TAKE THE TOUR',
    title: 'See Paradise before you arrive.',
    text: 'A look around the rooms, the pool and the gardens on the banks of the Nile. Book online in a moment, or call the front desk and let us welcome you.',
    primary: {label: 'Book your stay', href: './rooms.html'},
    secondary: {label: 'Call ' + CALL, href: telHref(CALL)}
  },
  {
    eyebrow: 'DINING AND BAR',
    title: 'A great dinner, a fine table.',
    text: 'Beef from the grill and a glass of wine, with the Nile a few steps from your table. Dinner is served every evening until eleven.',
    primary: {label: 'Open the menu', href: './menu.html'},
    secondary: {label: 'Send an order', href: './menu.html#order'}
  },
  {
    eyebrow: 'THE SUITE',
    title: 'Space to unwind and celebrate.',
    text: 'Our suites offer room to breathe, a place to gather and a bed that promises deep, restful sleep. Ideal for families and longer stays.',
    primary: {label: 'See the rooms', href: './rooms.html'},
    secondary: {label: 'Check availability', href: '#book'}
  },
  {
    eyebrow: 'FRESH FROM THE NILE',
    title: 'Catch of the day, served with pride.',
    text: 'Fresh tilapia and river fish, seasoned and grilled to perfection by our chefs. A true taste of Jinja, straight from the water to your plate.',
    primary: {label: 'Open the menu', href: './menu.html'},
    secondary: {label: 'Send an order', href: './menu.html#order'}
  },
  {
    eyebrow: 'FROM THE PIZZA OVEN',
    title: 'A proper margherita.',
    text: 'Juicy tomato, mozzarella and basil on a thin, floury crust, pulled hot from the oven in the same kitchen that serves the rest of the menu.',
    primary: {label: 'Open the menu', href: './menu.html'},
    secondary: {label: 'Send an order', href: './menu.html#order'}
  }
];

function Hero() {
  const slides: HeroShot[] = heroShots.length
    ? heroShots
    : [{slug: '', dir: './images/', file: '', ext: '', w: 0, h: 0, variants: [], kind: 'image'}];
  const count = slides.length;
  const [i, setI] = React.useState(0);
  // Held for either reason, a pointer resting on it or a key inside it.
  const [hover, setHover] = React.useState(false);
  const [focus, setFocus] = React.useState(false);
  // Someone who has asked for less motion gets the slides, but not the
  // carousel moving under them.
  const [still, setStill] = React.useState(false);
  const [gone, setGone] = React.useState(false);

  // The film slot is only ever played while it is the slide on screen, and
  // only then rewound, so the tour starts from the beginning each time it
  // comes round rather than from wherever it was left.
  const films = React.useRef<Array<HTMLVideoElement | null>>([]);

  React.useEffect(() => {
    const mq = window.matchMedia('(prefers-reduced-motion: reduce)');
    const sync = () => setStill(mq.matches);
    sync();
    if (mq.addEventListener) mq.addEventListener('change', sync);
    else if (mq.addListener) mq.addListener(sync);
    return () => { if (mq.removeEventListener) mq.removeEventListener('change', sync); else if (mq.removeListener) mq.removeListener(sync); };
  }, []);

  React.useEffect(() => {
    if (hover || focus || still || gone || count < 2) return;
    const t = window.setInterval(() => setI(v => (v + 1) % count), SLIDE_MS);
    return () => window.clearInterval(t);
  }, [hover, focus, still, gone, count]);

  // A carousel must not keep turning while its tab is in the background.
  React.useEffect(() => {
    const onVis = () => setGone(document.hidden);
    document.addEventListener('visibilitychange', onVis);
    return () => document.removeEventListener('visibilitychange', onVis);
  }, []);

  React.useEffect(() => {
    const stop: HTMLVideoElement[] = [];
    slides.forEach((shot, n) => {
      if (shot.kind !== 'video') return;
      const v = films.current[n];
      if (!v) return;
      if (n === i && !still && !gone) {
        const played = v.play();
        if (played && played.catch) played.catch(() => { /* autoplay refused, the poster holds the frame */ });
      } else {
        v.pause();
        try { v.currentTime = 0; } catch { /* not seekable until its metadata arrives */ }
        stop.push(v);
      }
    });
    return () => { stop.forEach(v => v.pause()); films.current.forEach(v => v && v.pause()); };
  }, [i, still, gone, slides]);

  const step = (d: number) => setI(v => (v + d + count) % count);
  const onKey = (e: React.KeyboardEvent) => {
    if (e.key === 'ArrowRight') { e.preventDefault(); step(1); }
    else if (e.key === 'ArrowLeft') { e.preventDefault(); step(-1); }
  };

  return (
   <section
    className="hero"
    id="main"
    aria-roledescription="carousel"
    aria-label="Hotel Paradise on the Nile"
    tabIndex={0}
    onKeyDown={onKey}
    onMouseEnter={() => setHover(true)}
    onMouseLeave={() => setHover(false)}
    onFocus={() => setFocus(true)}
    onBlur={() => setFocus(false)}
   >
    <div className="heroShots">
     {slides.map((shot, n) => {
      if (!shot.file) return null;
      const on = n === i;
      // Every slide eases the other way to the one before it, in and out of
      // its own crop, so the eye never sees the same move twice running.
      const cls = 'heroSlide ' + (n % 2 ? 'zoomIn' : 'zoomOut') + (on ? ' active' : '');
      const box = {objectPosition: heroPosition(shot)};
      if (shot.kind === 'video') {
       return (
        <video
         key={shot.slug}
         className={cls + ' heroFilm'}
         ref={el => { films.current[n] = el; }}
         src={shot.dir + shot.file}
         poster={shot.poster ? shot.poster.dir + shot.poster.file : undefined}
         muted
         loop
         playsInline
         preload="metadata"
         aria-hidden={!on}
         style={box}
         tabIndex={-1}
        />
       );
      }
      return (
       <img
        key={shot.slug}
        className={cls}
        src={shot.dir + shot.file}
        srcSet={heroSrcSet(shot) || undefined}
        sizes="100vw"
        alt=""
        width={shot.w || undefined}
        height={shot.h || undefined}
        style={box}
        loading={n === 0 ? 'eager' : 'lazy'}
        fetchPriority={n === 0 ? 'high' : 'auto'}
        decoding="async"
        draggable={false}
       />
      );
     })}
    </div>
    <div className="heroShade"/>

    {/* Every slide's writing is stacked in the same grid cell, so the block
        keeps one height and the carousel never jumps as the words change. */}
    <div className="heroCopy">
     {slides.map((_, n) => {
      const c = HERO_COPY[n % HERO_COPY.length];
      const on = n === i;
      return (
       <div className={'heroPanel' + (on ? ' on' : '')} key={n} aria-hidden={!on}>
        <div className="heroLogo"><img src={LOGO} alt="Hotel Paradise on the Nile logo"/></div>
        <p className="eyebrow">{c.eyebrow}</p>
        <h1 className="heroTitle">{c.title}</h1>
        <p className="heroText">{c.text}</p>
        <div className="heroBtns">
         <a className="btn" href={c.primary.href} tabIndex={on ? undefined : -1}>{c.primary.label}</a>
         <a className="btn ghost2" href={c.secondary.href} tabIndex={on ? undefined : -1}>{c.secondary.label}</a>
        </div>
       </div>
      );
     })}
    </div>

    {count > 1 && <div className="heroDots" role="tablist" aria-label="Choose a slide">
     {slides.map((shot, n) => (
      <button
       key={shot.slug || n}
       className={'dot' + (n === i ? ' on' : '')}
       onClick={() => setI(n)}
       role="tab"
       aria-selected={n === i}
       aria-label={'Slide ' + (n + 1) + ' of ' + count + ': ' + HERO_COPY[n % HERO_COPY.length].title}
      />
     ))}
    </div>}
   </section>
  );
}

function AvailabilityStrip() {
 const [st, setSt] = React.useState({cin: '', cout: '', adults: '2', type: ''});
 const f = (k: keyof typeof st) => ((e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => setSt({...st, [k]: e.target.value}));
 const go = () => {
  const q = new URLSearchParams();
  if (st.cin) q.set('check_in', st.cin);
  if (st.cout) q.set('check_out', st.cout);
  if (st.adults) q.set('adults', st.adults);
  if (st.type) q.set('type', st.type);
  window.location.href = './rooms.html' + (q.toString() ? '?' + q.toString() : '');
 };
 return (
  <section className="booking" id="book">
   <div><label>Check in</label><input type="date" value={st.cin} onChange={f('cin')}/></div>
   <div><label>Check out</label><input type="date" value={st.cout} onChange={f('cout')}/></div>
   <div><label>Guests</label><select value={st.adults} onChange={f('adults')}><option>1</option><option>2</option><option>3</option><option>4</option><option>5</option></select></div>
   <div><label>Room type</label><select value={st.type} onChange={f('type')}><option value="">Any available</option>{rooms.map(r => <option key={r.id}>{r.type}</option>)}</select></div>
   <button className="btn" onClick={go}>Choose your room</button>
  </section>
 );
}

function Rates() {
 const [cur, setCur] = React.useState<'UGX' | 'USD'>('UGX');
 // The dearest room the hotel publishes, used only to scale the little bar in
 // each row so a guest can see the range of rates without reading every figure.
 const maxRate = Math.max(...rooms.filter(x => x.price > 0).map(x => x.price), 1);
 return (
   <section className="section band rates hasBackdrop" id="rates" style={{'--bg': "url('./images/hero/bed-executive-1920.webp')"} as unknown as React.CSSProperties}>
    <div className="bandInner">
    <div className="center reveal">
     <p className="eyebrow">ROOM RATES AND POLICIES</p>
     <h2>Rates and policies</h2>
      <p className="intro">Current tariffs for a night at Hotel Paradise on the Nile. Choose your currency, every rate is quoted in Uganda Shillings and in US dollars, includes breakfast and the local hotel tax, and is subject to change without notice.</p>
     <div className="curToggle" role="group" aria-label="Choose the currency you want to see">
      <button type="button" className={cur === 'UGX' ? 'on' : ''} aria-pressed={cur === 'UGX'} onClick={() => setCur('UGX')}>UGX</button>
      <button type="button" className={cur === 'USD' ? 'on' : ''} aria-pressed={cur === 'USD'} onClick={() => setCur('USD')}>USD</button>
     </div>
    </div>
    <div className="ratesWrap">
     <div className="rateCard reveal">
      {rooms.map(r => {
       const priced = r.price > 0;
       const pct = priced ? Math.max(8, Math.round((r.price / maxRate) * 100)) : 100;
       return (
        <div className={'rateRow' + (priced ? '' : ' onRequest')} key={r.type}>
         <div>
          <h4>{r.type}</h4>
          <small>{priced ? 'Classic comfort, breakfast and taxes included' : 'A well equipped single room, contact the hotel for the Uganda Shilling rate'}</small>
          <div className="rateBar" aria-hidden="true"><span style={{width: pct + '%'}}/></div>
         </div>
         <b>{cur === 'UGX'
           ? (priced ? <>{fmtPrice(r.price)}<span>per night</span></> : <>On request<span>contact the hotel</span></>)
           : <>US$ {r.usd}<span>per night</span></>}</b>
        </div>
       );
      })}
     </div>
     <div className="policy reveal">
      <h4>GOOD TO KNOW</h4>
      <p><b>Check in</b> is from 12 noon and <b>check out</b> is 10 am.</p>
      <p>Rooms held up to 6 pm are charged at 75% of the applicable rate. After 6 pm the full rate applies.</p>
      <p>All rates quoted include the local hotel tax of UGX 2,000 per room per day, and every rate includes breakfast.</p>
      <p>US dollar rates are quoted for international guests and carry the same breakfast, tax and timing terms as the Uganda Shilling rates.</p>
       <p>Baby cots are free, and children above six years sharing a room with their parents pay for breakfast only at {fmtPrice(25000)}.</p>
      <p>Lunch is served from 12 noon to 3 pm, and dinner from 7 pm to 11 pm.</p>
      <a className="btn" href="./rooms.html" style={{marginTop: 12}}>Choose your room</a>
     </div>
    </div>
    </div>
   </section>
 );
}

/**
 * Anything marked `.reveal` rises into place the first time it is scrolled
 * past, and is then left alone. Everything is shown the moment the browser
 * cannot do this, so the page never holds its writing back from a guest.
 */
function useReveal() {
  React.useEffect(() => {
    const nodes = Array.from(document.querySelectorAll<HTMLElement>('.reveal'));
    if (!('IntersectionObserver' in window)) {
      nodes.forEach(n => n.classList.add('in'));
      return;
    }
    const io = new IntersectionObserver(
      entries => entries.forEach(e => {
        if (!e.isIntersecting) return;
        e.target.classList.add('in');
        io.unobserve(e.target);
      }),
      {threshold: 0.12, rootMargin: '0px 0px -6% 0px'}
    );
    nodes.forEach(n => io.observe(n));
    return () => io.disconnect();
  }, []);
}

function Home() {
  useReveal();
  return <div>
   <TopBar/>
   <PageNav onDark/>
   <Hero/>

   <AvailabilityStrip/>

   <p className="stripNote reveal">Your room has its own page. When you choose below, you will see the bed clearly and you are free to change your mind before booking.</p>

   <section className="section hasTint" id="rooms" style={{'--bg': "url('./images/hero/bed-twin-1920.webp')"} as unknown as React.CSSProperties}>
    <div className="center reveal">
     <p className="eyebrow">STAY IN PARADISE</p>
     <h2>Rooms and beds</h2>
     <p className="intro">Eight welcoming room types with honest rates in Uganda Shillings and US dollars. Open any room to see the bed clearly, choose it, or pick another one before you book. Every rate includes breakfast and the local hotel tax.</p>
    </div>
    <div className="grid">
     {rooms.filter(r => r.featured || r.id === 6).map(r => (
      <article className="card reveal" key={r.id}>
       <SmartImage
        group="rooms"
        name={roomImage(r.type)}
        alt={r.type}
        ratio="16 / 10"
        widths={[320, 480, 640, 960]}
        sizes="(max-width:900px) 100vw, (max-width:1400px) 400px, 460px"
        position="50% 45%"
        zoom
        className="photo"
        placeholder={<BedGlyph size={84}/>}
       />
       <div className="cardBody">
        <p className="pill">{r.pillow}</p>
        <h3>{r.type}</h3>
        <p>{r.text}</p>
        <strong>{r.rate} <span>per night</span><span className="usdLine">US$ {r.usd} per night</span></strong>
        <a className="btn" href={'./rooms.html?room=' + encodeURIComponent(r.type)}>View this bed</a>
       </div>
      </article>
     ))}
    </div>
    <div className="center reveal" style={{marginTop: 46}}>
     <a className="btn ghost2" href="./rooms.html">See all rooms and beds</a>
    </div>
   </section>

   <Rates/>


  <section className="section hasTint" id="dining" style={{'--bg': "url('./images/hero/food-fruit-1920.webp')"} as unknown as React.CSSProperties}>
   <div className="center reveal">
    <p className="eyebrow">DINING AND BAR</p>
    <h2>Good food, great moments</h2>
    <p className="intro">Meals are served with the warmth Jinja is known for. Walk ins are always welcome, or open the full menu to browse every dish and send your order to the kitchen. Breakfast is included in every room rate.</p>
   </div>
   <div className="menuWrap">
    <DiningBoard/>
   </div>
   <div className="center reveal" style={{marginTop: 40}}>
    <a className="btn" href="./menu.html">See the full menu and order</a>
   </div>
  </section>

  <section className="section hasTint" id="facilities" style={{'--bg': "url('./images/Hotel-Paradise-on-the-Nile-Conferences-Weddings-cover.jpg')"} as unknown as React.CSSProperties}>
   <div className="center reveal">
    <p className="eyebrow">THE HOTEL</p>
    <h2>Everything you need, in one place</h2>
     <p className="intro">Hotel Paradise on the Nile sits right on the banks of the River Nile, about a three hour drive from Entebbe Airport and only five minutes from the centre of Jinja town.</p>
   </div>
   <div className="factsGrid">
    {facts.map((f, i) => (
     <article className="fact reveal" key={f.t}>
      <SmartImage
       group="facilities"
       name={f.img}
       alt={f.t}
       ratio="auto"
       widths={[480, 960, 1440, 1920]}
       sizes="(max-width:768px) 100vw, (max-width:1050px) 50vw, 33vw"
       position="50% 50%"
       zoom
       className="factPhoto"
      />
      <div className="factScrim" aria-hidden="true"/>
      <div className="factBody">
       <span className="factIdx" aria-hidden="true">{String(i + 1).padStart(2, '0')}</span>
       <h4>{f.t}</h4>
       <p>{f.d}</p>
      </div>
     </article>
    ))}
   </div>
  </section>

  <section className="section band contact hasBackdrop" id="contact" style={{'--bg': "url('./images/hero/view-1920.webp')"} as unknown as React.CSSProperties}>
   <div className="bandInner">
   <div className="center reveal">
    <p className="eyebrow">BOOKINGS AND ENQUIRIES</p>
    <h2>How to reach us</h2>
     <p className="intro">We are at Plot 12, 19 &amp; 25 Kiira Lane, a few minutes from the river. Call, write or email the front desk to confirm availability, check in times and current rates.</p>
    </div>
    <div className="contactWrap">
     <div className="contactCard reveal">
      <div className="contactRow"><b>HOTEL</b><span>{HOTEL.legalName}</span></div>
      <div className="contactRow"><b>ADDRESS</b><span>{HOTEL.address}</span></div>
      <div className="contactRow"><b>POST</b><span>{HOTEL.poBox}</span></div>
      <div className="contactRow"><b>TELEPHONE</b><span>{HOTEL.phones.map((p, i) => <React.Fragment key={p}>{i > 0 && <><br/></>}<a className="footLink" href={telHref(p)}>{p}</a></React.Fragment>)}</span></div>
      <div className="contactRow"><b>EMAIL</b><span><a className="footLink" href={'mailto:' + HOTEL.email}>{HOTEL.email}</a></span></div>
      <div className="contactRow"><b>WEBSITE</b><span><a className="footLink" href={'https://' + HOTEL.website} target="_blank" rel="noopener noreferrer">{HOTEL.website}</a></span></div>
      <div className="contactRow"><b>STANDARD</b><span>{HOTEL.certification}</span></div>
      <div className="contactRow"><b>FRONT DESK</b><span>Open every day, 24 hours</span></div>
     </div>
     <div className="mapBox reveal">
      <iframe title="Hotel Paradise on the Nile on Google Maps" src={MAP_EMBED} loading="lazy" referrerPolicy="no-referrer-when-downgrade" allowFullScreen/>
      <p>{HOTEL.address}. <a href={MAP_LINK} target="_blank" rel="noreferrer">Open in Google Maps</a></p>
     </div>
    </div>
   </div>
  </section>

  <Footer/>
 </div>;
}

createRoot(document.getElementById('root')!).render(<Home/>);