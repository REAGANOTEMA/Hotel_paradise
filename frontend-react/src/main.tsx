import React from 'react';
import {createRoot} from 'react-dom/client';
import './styles.css';
import {rooms, TopBar, PageNav, Footer, BedGlyph, roomImage, fmt, API, LOGO} from './shared';
import {heroShots, SmartImage} from './SmartImage';

const dining = [
 {name: 'Breakfast', price: 'UGX 25,000', note: 'For non residents, or children above six years sharing a room with their parents'},
 {name: 'Buffet meal', price: 'UGX 40,000', note: 'Served daily around lunch and dinner'},
 {name: 'A la carte menu', price: 'UGX 10,000 to 45,000', note: 'A wide selection, from light bites to full plates'},
 {name: 'Baby cots', price: 'Free', note: 'Available on request for your little one'}
];

const facts = [
 {t: 'Rooms', d: '69 rooms spread across 3 floors'},
 {t: 'Comfort', d: 'Every room furnished to standard, some air conditioned and others with fans'},
 {t: 'Bathrooms', d: 'Private bathrooms with jacuzzis, bathtubs or shower cabinets'},
 {t: 'In room', d: 'Direct dial telephones and 24 hour satellite television'},
 {t: 'Functions', d: 'Conference facilities and gardens for parties'},
 {t: 'Wellness', d: 'Health club with a swimming pool'}
];

const MAP_EMBED = 'https://www.google.com/maps?q=' + encodeURIComponent('Hotel Paradise on the Nile, 19 Kiira Rd, Jinja, Uganda') + '&output=embed';
const MAP_LINK = 'https://www.google.com/maps/search/?api=1&query=' + encodeURIComponent('Hotel Paradise on the Nile, 19 Kiira Rd, Jinja, Uganda');

const HERO_WIDTHS = [640, 1024, 1440, 1920, 2560];

/** Only widths the file really has, so a 680px photo is never asked to fill 2560. */
const heroSrcSet = (shot: {ext: string; w: number; variants: {w: number; ext: string}[]}) => {
  const picks: {file: string; w: number}[] = HERO_WIDTHS.map(w => {
    const v = shot.variants.find(x => x.w >= w);
    return v ? {file: shot.slug + '-' + v.w + '.' + v.ext, w: v.w} : null;
  }).filter(Boolean) as {file: string; w: number}[];
  if (shot.w) picks.push({file: shot.slug + '.' + shot.ext, w: shot.w});
  const seen = new Set<number>();
  return picks
    .filter(p => (seen.has(p.w) ? false : (seen.add(p.w), true)))
    .sort((a, b) => a.w - b.w)
    .map(p => './images/' + p.file + ' ' + p.w + 'w')
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
 */
const HERO_COPY: HeroCopy[] = [
  {
    eyebrow: 'HOTEL PARADISE ON THE NILE',
    title: 'Where luxury meets the Nile.',
    text: 'A calm, refined stay in the heart of Jinja, right beside the river.',
    primary: {label: 'Book your stay', href: './rooms.html'},
    secondary: {label: 'Order food', href: './menu.html'}
  },
  {
    eyebrow: 'ROOMS AND BEDS',
    title: 'Eight ways to sleep well.',
    text: 'From a quiet single to a suite made for the whole family. Every room is furnished to the same standard, and breakfast is included.',
    primary: {label: 'See the rooms', href: './rooms.html'},
    secondary: {label: 'Check availability', href: '#book'}
  },
  {
    eyebrow: 'DINING AND BAR',
    title: 'Good food, generous plates.',
    text: 'An a la carte menu of Ugandan classics and international favourites, served through the day and into the evening.',
    primary: {label: 'Open the menu', href: './menu.html'},
    secondary: {label: 'Send an order', href: './menu.html#order'}
  },
  {
    eyebrow: 'JINJA, UGANDA',
    title: 'Five minutes from the centre of Jinja.',
    text: 'On the banks of the River Nile, and about three hours by road from Entebbe Airport.',
    primary: {label: 'Find us', href: '#contact'},
    secondary: {label: 'See the facilities', href: '#facilities'}
  },
  {
    eyebrow: 'THE HOTEL',
    title: 'A health club, a pool and gardens.',
    text: 'Sixty nine rooms over three floors, a health club with a swimming pool, and gardens and conference space for functions.',
    primary: {label: 'Explore the hotel', href: '#facilities'},
    secondary: {label: 'Book your stay', href: './rooms.html'}
  },
  {
    eyebrow: 'RATES AND POLICIES',
    title: 'Breakfast included, every night.',
    text: 'Rates in Uganda Shillings and in US dollars, with breakfast and the local hotel tax already worked into the price.',
    primary: {label: 'See the rates', href: '#rates'},
    secondary: {label: 'Check availability', href: '#book'}
  },
  {
    eyebrow: 'BOOK DIRECT',
    title: 'Your room is waiting.',
    text: 'Book online in a moment, or call the front desk. Someone answers the phone at every hour of the day.',
    primary: {label: 'Book your stay', href: './rooms.html'},
    secondary: {label: 'Call +256 759 504 928', href: 'tel:+256759504928'}
  }
];

function Hero() {
  const slides = heroShots.length ? heroShots : [{slug: '', ext: '', w: 0, h: 0, variants: []}];
  const count = slides.length;
  const [i, setI] = React.useState(0);
  // Held for either reason, a pointer resting on it or a key inside it.
  const [hover, setHover] = React.useState(false);
  const [focus, setFocus] = React.useState(false);
  // Someone who has asked for less motion gets the slides, but not the
  // carousel moving under them.
  const [still, setStill] = React.useState(false);
  const [gone, setGone] = React.useState(false);

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
    const t = window.setInterval(() => setI(v => (v + 1) % count), 6500);
    return () => window.clearInterval(t);
  }, [hover, focus, still, gone, count]);

  // A carousel must not keep turning while its tab is in the background.
  React.useEffect(() => {
    const onVis = () => setGone(document.hidden);
    document.addEventListener('visibilitychange', onVis);
    return () => document.removeEventListener('visibilitychange', onVis);
  }, []);

  const step = (d: number) => setI(v => (v + d + count) % count);
  const onKey = (e: React.KeyboardEvent) => {
    if (e.key === 'ArrowRight') { e.preventDefault(); step(1); }
    else if (e.key === 'ArrowLeft') { e.preventDefault(); step(-1); }
  };

  return (
   <section
    className="hero"
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
     {slides.map((shot, n) => (
      <img
       key={shot.slug || 'blank'}
       className={'heroSlide' + (n === i ? ' active' : '')}
       src={'./images/' + shot.slug + '.' + shot.ext}
       srcSet={heroSrcSet(shot) || undefined}
       sizes="100vw"
       alt=""
       width={shot.w || undefined}
       height={shot.h || undefined}
       style={{objectPosition: heroPosition(shot)}}
       loading={n === 0 ? 'eager' : 'lazy'}
       fetchPriority={n === 0 ? 'high' : 'auto'}
       decoding="async"
       draggable={false}
      />
     ))}
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
 return (
  <section className="section rates" id="rates">
   <div className="center">
    <p className="eyebrow">ROOM RATES AND POLICIES</p>
    <h2>Rates and policies</h2>
     <p className="intro">Current tariffs for a night at Hotel Paradise on the Nile. Choose your currency, every rate is quoted in Uganda Shillings and in US dollars, includes breakfast and the local hotel tax, and is subject to change without notice.</p>
    <div className="curToggle" role="group" aria-label="Choose the currency you want to see">
     <button type="button" className={cur === 'UGX' ? 'on' : ''} aria-pressed={cur === 'UGX'} onClick={() => setCur('UGX')}>UGX</button>
     <button type="button" className={cur === 'USD' ? 'on' : ''} aria-pressed={cur === 'USD'} onClick={() => setCur('USD')}>USD</button>
    </div>
   </div>
   <div className="ratesWrap">
    <div className="rateCard">
     {rooms.map(r => {
      const priced = r.price > 0;
      return (
       <div className="rateRow" key={r.type}>
        <div>
         <h4>{r.type}</h4>
         <small>{priced ? 'Classic comfort, breakfast and taxes included' : 'A well equipped single room, contact the hotel for the Uganda Shilling rate'}</small>
        </div>
        <b>{cur === 'UGX'
          ? (priced ? <>{fmt(r.price)}<span>per night</span></> : <>On request<span>contact the hotel</span></>)
          : <>US$ {r.usd}<span>per night</span></>}</b>
       </div>
      );
     })}
    </div>
    <div className="policy">
     <h4>GOOD TO KNOW</h4>
     <p><b>Check in</b> is from 12 noon and <b>check out</b> is 10 am.</p>
     <p>Rooms held past 6 pm are charged at 75% of the applicable rate, and the full rate applies after 6 pm.</p>
     <p>All rates quoted include the local hotel tax of UGX 2,000 per room per day, and every rate includes breakfast.</p>
     <p>US dollar rates are quoted for international guests and carry the same breakfast, tax and timing terms as the Uganda Shilling rates.</p>
     <p>Baby cots are free, and children above six years sharing a room with their parents pay for breakfast only at UGX 25,000.</p>
     <p>Lunch is served from 12 noon to 3 pm, and dinner from 7 pm to 11 pm.</p>
     <a className="btn" href="./rooms.html" style={{marginTop: 12}}>Choose your room</a>
    </div>
   </div>
  </section>
 );
}

function Home() {
  return <div>
   <TopBar/>
   <PageNav/>
   <Hero/>

   <AvailabilityStrip/>

   <p className="stripNote">Your room has its own page. When you choose below, you will see the bed clearly and you are free to change your mind before booking.</p>

   <section className="section" id="rooms">
    <div className="center">
     <p className="eyebrow">STAY IN PARADISE</p>
     <h2>Rooms and beds</h2>
     <p className="intro">Eight welcoming room types with honest rates in Uganda Shillings and US dollars. Open any room to see the bed clearly, choose it, or pick another one before you book. Every rate includes breakfast and the local hotel tax.</p>
    </div>
    <div className="grid">
     {rooms.filter(r => r.featured || r.id === 6).map(r => (
      <article className="card" key={r.id}>
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
    <div className="center" style={{marginTop: 46}}>
     <a className="btn ghost2" href="./rooms.html">See all rooms and beds</a>
    </div>
   </section>

   <Rates/>


  <section className="section" id="dining">
   <div className="center">
    <p className="eyebrow">DINING AND BAR</p>
    <h2>Good food, great moments</h2>
    <p className="intro">Meals are served with the warmth Jinja is known for. Walk ins are always welcome, or open the full menu to browse every dish and send your order to the kitchen. Breakfast is included in every room rate.</p>
   </div>
   <div className="menuWrap">
    {dining.map(m => (
     <div className="menuRow" key={m.name}><div><h4>{m.name}</h4><small>{m.note}</small></div><b>{m.price}</b></div>
    ))}
   </div>
   <div className="center" style={{marginTop: 40}}>
    <a className="btn" href="./menu.html">See the full menu and order</a>
   </div>
  </section>

  <section className="section" id="facilities">
   <div className="center">
    <p className="eyebrow">THE HOTEL</p>
    <h2>Everything you need, in one place</h2>
     <p className="intro">Hotel Paradise on the Nile sits right on the banks of the River Nile, about a three hour drive from Entebbe Airport and only five minutes from the centre of Jinja town.</p>
   </div>
   <div className="factsGrid">
    {facts.map(f => <div className="fact" key={f.t}><h4>{f.t.toUpperCase()}</h4><p>{f.d}</p></div>)}
   </div>
  </section>

  <section className="section contact" id="contact">
   <div className="center">
    <p className="eyebrow">BOOKINGS AND ENQUIRIES</p>
    <h2>How to reach us</h2>
    <p className="intro">We are at 19 Kiira Road, a few minutes from the river. Call, write or email the front desk to confirm availability, check in times and current rates.</p>
   </div>
   <div className="contactWrap">
    <div className="contactCard">
     <div className="contactRow"><b>HOTEL</b><span>Hotel Paradise on the Nile Ltd</span></div>
     <div className="contactRow"><b>ADDRESS</b><span>19 Kiira Rd, Jinja, Uganda</span></div>
     <div className="contactRow"><b>POST</b><span>P.O. Box 1139, Jinja, Uganda</span></div>
     <div className="contactRow"><b>TELEPHONE</b><span>+256 759 504 928</span></div>
     <div className="contactRow"><b>EMAIL</b><span>hotel@hotelparadiseonthenile.info</span></div>
     <div className="contactRow"><b>FRONT DESK</b><span>Open every day, 24 hours</span></div>
    </div>
    <div className="mapBox">
     <iframe title="Hotel Paradise on the Nile on Google Maps" src={MAP_EMBED} loading="lazy" referrerPolicy="no-referrer-when-downgrade" allowFullScreen/>
     <p>Hotel Paradise on the Nile, 19 Kiira Rd, Jinja. <a href={MAP_LINK} target="_blank" rel="noreferrer">Open in Google Maps</a></p>
    </div>
   </div>
  </section>

  <Footer/>
 </div>;
}

createRoot(document.getElementById('root')!).render(<Home/>);