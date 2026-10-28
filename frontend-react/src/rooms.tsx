import React from 'react';
import {createRoot} from 'react-dom/client';
import './styles.css';
import {rooms as baseRooms, EndLinks, TopBar, PageNav, Footer, BedGlyph, roomImage, fmt, fmtPrice, withService, apiUrl, CALL, customerToken, BackLink, PageHeroCover, AccountGate, type HeroCoverFrame} from './shared';
import {SmartImage, photoHintsEnabled, type ImageGroup} from './SmartImage';
import {MenuConcierge} from './concierge';

/** The photographs each room is still waiting for, shown on request only. */
const SHOW_FILE_HINTS = photoHintsEnabled();

/**
 * One photograph in a room's tour: the group it lives in (rooms on disk,
 * the bed working folders, or the site root) and the slug to find it by.
 */
type BedSlide = {group: ImageGroup; name: string; position?: string};

/**
 * The photographs each room type turns through. Every list opens on the room's
 * main plate - for the newly delivered rooms that is the photograph the hotel
 * provided (single-room, tripple-room, executive-deluxe-room) - and then walks
 * through the bed shots the hotel keeps in the working folders, finishing on
 * the bathroom. A room is never shown as one lonely picture again.
 */
const ROOM_SLIDES: Record<string, BedSlide[]> = {
  'Suite': [
   {group: 'site', name: 'Suite-768x511', position: '50% 45%'},
   {group: 'beds-suit', name: 'suit1', position: '50% 45%'},
   {group: 'beds-suit', name: 'suit2', position: '50% 45%'}
  ],
  'Family Room': [
   {group: 'site', name: 'DSC_5418-768x512', position: '50% 45%'},
   {group: 'rooms', name: 'family-room', position: '50% 45%'}
  ],
  'Triple Room': [
   {group: 'rooms', name: 'triple-room', position: '50% 45%'},
   {group: 'beds-triple', name: 'triple-bed', position: '50% 45%'}
  ],
  'Executive Deluxe': [
   {group: 'site', name: 'executive-deluxe-room', position: '50% 45%'},
   {group: 'beds-exec', name: 'executive-bed1', position: '50% 45%'}
  ],
  'Deluxe Double': [
   {group: 'rooms', name: 'deluxe-double', position: '50% 45%'},
   {group: 'rooms', name: 'deluxe-double-2', position: '50% 45%'}
  ],
  'Standard Double': [
   {group: 'rooms', name: 'standard-double', position: '50% 45%'},
   {group: 'site', name: 'double-deluxe-bed', position: '50% 45%'}
  ],
  'Standard Twin': [
   {group: 'rooms', name: 'standard-twin', position: '50% 45%'},
   {group: 'rooms', name: 'standard-twin-2', position: '50% 45%'}
  ],
  'Standard Single': [
   {group: 'site', name: 'single-room', position: '50% 45%'},
   {group: 'rooms', name: 'standard-single', position: '50% 45%'},
   {group: 'rooms', name: 'standard-single-2', position: '50% 45%'}
  ]
};

/** The fallback frame a room is drawn from when every working folder is empty. */
const roomFallback = (type: string): BedSlide[] => [{group: 'rooms', name: roomImage(type), position: '50% 45%'}];

const SLIDE_MS = 5000;

/**
 * A room photograph that turns over: the mainplate first, then the bed shots
 * the hotel keeps in the working folder. It behaves exactly like the home
 * carousel - the turning stops for a guest who asked for less motion or
 * moved to another tab - and every control is a real button.
 */
function BedSlider({slides, alt, ratio, sizes, className, placeholder}: {
  slides: BedSlide[];
  alt: string;
  ratio: string;
  sizes?: string;
  className?: string;
  placeholder?: React.ReactNode;
}) {
  const n = slides.length;
  const [i, setI] = React.useState(0);
  const [still, setStill] = React.useState(false);
  const [gone, setGone] = React.useState(false);
  // The moment the guest takes over - taps an arrow, a dot, presses a key or
  // swipes the photographs - the automatic turn stops for good, so the bed they
  // chose stays on screen instead of rolling on to the next one under their hand.
  const [held, setHeld] = React.useState(false);
  // A pointer resting on a wide screen simply pauses, then lets it turn again.
  const [hover, setHover] = React.useState(false);

  React.useEffect(() => {
    const mq = window.matchMedia('(prefers-reduced-motion: reduce)');
    const sync = () => setStill(mq.matches);
    sync();
    if (mq.addEventListener) mq.addEventListener('change', sync);
    else if (mq.addListener) mq.addListener(sync);
    return () => { if (mq.removeEventListener) mq.removeEventListener('change', sync); else if (mq.removeListener) mq.removeListener(sync); };
  }, []);

  React.useEffect(() => {
    const onVis = () => setGone(document.hidden);
    document.addEventListener('visibilitychange', onVis);
    return () => document.removeEventListener('visibilitychange', onVis);
  }, []);

  React.useEffect(() => {
    if (still || gone || held || hover || n < 2) return;
    const t = window.setInterval(() => setI(v => (v + 1) % n), SLIDE_MS);
    return () => window.clearInterval(t);
  }, [still, gone, held, hover, n]);

  const step = (d: number) => { setHeld(true); setI(v => (v + d + n) % n); };
  const choose = (idx: number) => { setHeld(true); setI(idx); };

  // A finger roll across the photographs: a sideways swipe moves one frame, the
  // way a guest expects on a phone. A mostly vertical drag is left to the page
  // so scrolling never catches.
  const startX = React.useRef<number | null>(null);
  const startY = React.useRef<number | null>(null);
  const onTouchStart = (e: React.TouchEvent) => { const t = e.touches[0]; startX.current = t.clientX; startY.current = t.clientY; };
  const onTouchEnd = (e: React.TouchEvent) => {
    if (startX.current === null) return;
    const t = e.changedTouches[0];
    const dx = t.clientX - startX.current;
    const dy = t.clientY - (startY.current ?? 0);
    startX.current = null; startY.current = null;
    if (Math.abs(dx) > 40 && Math.abs(dx) > Math.abs(dy)) step(dx < 0 ? 1 : -1);
  };

  return (
   <div className={'bedSlider' + (className ? ' ' + className : '') + (held ? ' held' : '')}
    role="group" aria-roledescription="carousel" aria-label={alt + ', ' + n + ' photographs'}
    tabIndex={n > 1 ? 0 : -1}
    onMouseEnter={() => setHover(true)} onMouseLeave={() => setHover(false)}
    onFocus={() => setHeld(true)}
    onKeyDown={e => { if (e.key === 'ArrowRight') { e.preventDefault(); step(1); } else if (e.key === 'ArrowLeft') { e.preventDefault(); step(-1); } }}
    onTouchStart={onTouchStart} onTouchEnd={onTouchEnd}>
    <div className="bedSliderStage" style={{aspectRatio: ratio}}>
     {slides.map((s, idx) => (
      <div key={s.group + '/' + s.name} className={'bedSlide' + (idx === i ? ' on' : '')} aria-hidden={idx !== i}>
       <SmartImage
        group={s.group}
        name={s.name}
        alt={idx === 0 ? alt : ''}
        ratio={ratio}
        widths={[320, 480, 640, 960]}
        sizes={sizes}
        position={s.position || '50% 45%'}
        className={className}
        placeholder={idx === 0 ? placeholder : undefined}
       />
      </div>
     ))}
    </div>
    {n > 1 && (
     <div className="bedSliderBar">
      <button type="button" className="bedArrow" onClick={() => step(-1)} aria-label={'Previous photograph of ' + alt}>
       <svg viewBox="0 0 24 24" aria-hidden="true" focusable="false"><path d="M15 5l-7 7 7 7"/></svg>
      </button>
      <div className="bedDots" role="tablist" aria-label="Choose a photograph">
       {slides.map((s, idx) => (
        <button key={s.group + '/' + s.name} type="button" role="tab" aria-selected={idx === i}
         aria-label={'Photograph ' + (idx + 1) + ' of ' + n + ' for ' + alt}
         className={'bedDot' + (idx === i ? ' on' : '')} onClick={() => choose(idx)}/>
       ))}
      </div>
      <button type="button" className="bedArrow" onClick={() => step(1)} aria-label={'Next photograph of ' + alt}>
       <svg viewBox="0 0 24 24" aria-hidden="true" focusable="false"><path d="M9 5l7 7-7 7"/></svg>
      </button>
     </div>
    )}
   </div>
  );
}

/**
 * The bed photographs that turn over behind the page header. They are the
 * hotel's own room shots, so the header shows what the page is about, and each
 * frame carries its three widths so a phone never downloads the wide one.
 */
const ROOM_HERO_FRAMES: HeroCoverFrame[] = [
 {base: './images/hero/bed-executive', ext: 'webp', widths: [960, 1280, 1920]},
 {base: './images/hero/bed-suite', ext: 'webp', widths: [960, 1280, 1920]},
 {base: './images/hero/bed-twin', ext: 'webp', widths: [960, 1280, 1920]},
 {base: './images/hero/bed-triple', ext: 'webp', widths: [960, 1280, 1920]},
 {base: './images/hero/bed-deluxe', ext: 'webp', widths: [960, 1280, 1920]}
];

function useQuery() {
 const p = new URLSearchParams(window.location.search);
 return {
  room: p.get('room') || '',
  check_in: p.get('check_in') || '',
  check_out: p.get('check_out') || '',
  adults: p.get('adults') || '2',
  // Set when the guest has just come back from creating their account, so the
  // page knows to greet them and carry their chosen bed straight to the form.
  resume: p.get('resume') === '1'
 };
}

/** Reads the signed in guest back from the hotel, or null when there is none. */
const whoIsSignedIn = async (): Promise<{name: string; email: string; phone: string} | null> => {
 const token = customerToken();
 if (!token) return null;
 try {
  const res = await fetch(await apiUrl('account'), {
   method: 'POST',
   headers: {'Content-Type': 'application/json'},
   body: JSON.stringify({action: 'me', token})
  });
  const d = await res.json();
  if (d && d.ok && d.customer) return {name: String(d.customer.name || ''), email: String(d.customer.email || ''), phone: String(d.customer.phone || '')};
 } catch {
  /* a hotel that cannot answer is treated as nobody signed in */
 }
 return null;
};

function RoomsPage() {
 const q = useQuery();
 const [live, setLive] = React.useState<Record<string, number>>({});
 const [chosen, setChosen] = React.useState<string>(q.room || '');
 const [form, setForm] = React.useState({name: '', phone: '', email: '', check_in: q.check_in, check_out: q.check_out, adults: q.adults || '2'});
 const [msg, setMsg] = React.useState<{ok: boolean; text: string} | null>(null);
 const [busy, setBusy] = React.useState(false);
 // Nobody books without an account: it is what carries their name, phone and
 // email into the booking and onto the receipt, so the page waits for one
 // rather than asking the guest to type it all again. The account comes before
 // the details, and comes straight back here with the chosen bed kept.
 const [signedIn, setSignedIn] = React.useState<boolean>(Boolean(customerToken()));
 // The fee is read from the server, never guessed here, so what the guest is
 // shown is what the server will actually charge.
 const [fee, setFee] = React.useState<{label: string; amount: number}>({label: 'Withdrawal fee', amount: 0});

 React.useEffect(() => {
  let live = true;
  whoIsSignedIn().then(c => {
   if (!live) return;
   if (!c) { setSignedIn(false); return; }
   setSignedIn(true);
   setForm(f => ({...f, name: f.name || c.name, phone: f.phone || c.phone, email: f.email || c.email}));
  });
  return () => { live = false; };
 }, []);

 // A room chosen on the home page arrives as ?room=Type. Land the guest on that
 // bed itself, so "View this bed" opens the very bed it promised.
 React.useEffect(() => {
  if (!q.room) return;
  const el = document.getElementById('bed-' + (baseRooms.find(r => r.type === q.room)?.id ?? ''));
  if (el) setTimeout(() => el.scrollIntoView({behavior: 'smooth', block: 'center'}), 120);
  // eslint-disable-next-line react-hooks/exhaustive-deps
 }, []);


  React.useEffect(() => {
   apiUrl('rooms').then(url => fetch(url)).then(r => r.json()).then(d => {
    if (d.ok && Array.isArray(d.rooms)) {
     const m: Record<string, number> = {};
     d.rooms.forEach((r: {name: string; price: number}) => { if (r.price > 0) m[r.name] = r.price; });
     setLive(m);
    }
    if (d.ok && d.booking_fee) {
     setFee({label: String(d.booking_fee.label || 'Withdrawal fee'), amount: Number(d.booking_fee.amount) || 0});
    }
   }).catch(() => {});
  }, []);

  const rooms = baseRooms.map(r => {
    const price = live[r.type] ?? r.price;
    // The rate a guest reads carries the hotel's 3.5%, and so does the total
    // below, because both are what the booking will actually charge.
    return {...r, price, rate: fmtPrice(price)};
  });
  const sel = rooms.find(r => r.type === chosen) || null;
  const nights = form.check_in && form.check_out && form.check_out > form.check_in ? Math.max(1, Math.ceil((Date.parse(form.check_out) - Date.parse(form.check_in)) / 86400000)) : 0;
  const subtotal = sel && nights && sel.price > 0 ? sel.price * nights : 0;
  // The withdrawal fee is a pass through, so the 3.5% rides on the room alone
  // and the fee is added exactly as the hotel set it.
  const total = withService(subtotal) + (nights ? fee.amount : 0);

 const pick = (t: string) => {
  setChosen(t);
  setMsg(null);
  const el = document.getElementById('planner');
  if (el) setTimeout(() => el.scrollIntoView({behavior: 'smooth', block: 'start'}), 60);
 };

 const f = (k: keyof typeof form) => ((e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => setForm({...form, [k]: e.target.value}));

 // Where a guest is sent to sign in or sign up, carrying the bed and dates so
 // the account page can hand them straight back to this exact booking.
 const continueUrl = (mode: 'signup' | 'signin') => {
  const p = new URLSearchParams();
  if (sel) p.set('room', sel.type);
  if (form.check_in) p.set('check_in', form.check_in);
  if (form.check_out) p.set('check_out', form.check_out);
  if (form.adults) p.set('adults', form.adults);
  p.set('resume', '1');
  return './account.html?mode=' + mode + '&next=' + encodeURIComponent('./rooms.html?' + p.toString());
 };

 const book = async () => {
  if (!sel) return;
  if (!signedIn) { window.location.assign(continueUrl('signup')); return; }
  setBusy(true); setMsg(null);
  try {
   const res = await fetch(await apiUrl('booking'), {method: 'POST', headers: {'Content-Type': 'application/json'}, body: JSON.stringify({
    name: form.name, phone: form.phone, email: form.email, check_in: form.check_in, check_out: form.check_out,
    room_type: sel.type, adults: parseInt(form.adults) || 1, token: customerToken()
   })});
    const d = await res.json();
if (d.ok) {
      // No receipt prints here: the guest pays first, and the receipt follows
      // by email and on the checkout page. Hand the guest to the checkout page,
      // which carries the reference, the total and their details so the payment
      // and the docket can never disagree with the booking.
      const p = new URLSearchParams({
       src: 'booking', ref: String(d.booking_number || ''),
       amt: String(Math.round(Number(d.total) || 0)),
       item: sel.type, qty: String(nights || 1), unit: 'night',
       name: form.name, phone: form.phone, email: form.email
      });
      window.location.assign('./pay.html?' + p.toString());
      return;
    }
    setMsg({ok: false, text: d.error || 'Something went wrong. Please try again or call ' + CALL + '.'});
  } catch {
   setMsg({ok: false, text: 'Could not reach the booking service. Please call ' + CALL + '.'});
  }
  setBusy(false);
 };

   return <div>
    <TopBar/>
    <PageNav onDark/>

<section className="pageHero hasCover" id="main">
    <PageHeroCover frames={ROOM_HERO_FRAMES}/>
    <div className="pageHeroInner">
     <BackLink label="Back" fallback="./index.html"/>
     <p className="eyebrow">CHOOSE YOUR ROOM</p>
     <h1>Rooms and beds, your way.</h1>
     <p>Every room is photographed, so you see exactly what you are booking. Pick a bed, check your dates, and continue to payment. Rates are per night and include breakfast and the local hotel tax.</p>
    </div>
   </section>
   <section className="bedsWrap section">
    <div className="bedList">
     {rooms.map(r => {
      const active = chosen === r.type;
      return (
       <article className={'bedCard' + (active ? ' chosen' : '')} id={'bed-' + r.id} key={r.id}>
        <BedSlider
         slides={ROOM_SLIDES[r.type]?.length ? ROOM_SLIDES[r.type] : roomFallback(r.type)}
         alt={r.type}
         ratio="3 / 4"
         sizes="(max-width:1050px) 100vw, 300px"
         className="bedMedia"
         placeholder={<>
          <BedGlyph size={92}/>
          <span className="bedMediaNote">{r.beds}</span>
          {SHOW_FILE_HINTS && <code className="shotFile">images/rooms/{roomImage(r.type)}.jpg</code>}
         </>}
        />
        <div className="bedBody">
         <p className="pill">{r.pillow}</p>
         <h3>{r.type}</h3>
         <p className="bedsLine">{r.beds} &middot; {r.guests}</p>
         <p className="bedText">{r.text}</p>
         <div className="bedFoot">
          <strong>{r.rate} <span>per night</span><span className="usdLine">US$ {r.usd} per night</span></strong>
          {active
           ? <button className="btn ghost2" onClick={() => setChosen('')}>Change or drop</button>
           : <button className="btn" onClick={() => pick(r.type)}>Choose this bed</button>}
          </div>
         </div>
         {!active && <button className="bedOpen" onClick={() => pick(r.type)} aria-label={'Choose this bed: ' + r.type}/>}
         {active && <span className="selBadge">Your choice</span>}
       </article>
      );
     })}
    </div>

    <div className="planner" id="planner">
     {!sel ? (
      <div className="plannerEmpty">
       <BedGlyph size={70}/>
       <h3>Your room</h3>
       <p>Nothing chosen yet. Pick a room from the list and its photograph appears here, so you can see exactly what you are booking.</p>
      </div>
     ) : (
      <div className="plannerActive">
       <BedSlider
        slides={ROOM_SLIDES[sel.type]?.length ? ROOM_SLIDES[sel.type] : roomFallback(sel.type)}
        alt={sel.type}
        ratio="16 / 10"
        sizes="(max-width:1050px) 100vw, 360px"
        className="spot"
        placeholder={<BedGlyph size={86}/>}
       />
       <div className="stepHead"><span className="stepNum">1</span><b>Room</b></div>
       <h3>{sel.type}</h3>
       <p className="bedsLine">{sel.beds} &middot; {sel.guests}</p>

       {signedIn ? (
        <p className="bookAs">Booking as <b>{form.name || 'you'}</b>{form.phone ? ' · ' + form.phone : ''} <a href="./account.html">change</a></p>
       ) : (
        <AccountGate signupHref={continueUrl('signup')} signinHref={continueUrl('signin')}>
         One quick account and we bring you straight back to this exact bed.
        </AccountGate>
       )}

       <div className="stepHead"><span className="stepNum">2</span><b>Dates</b></div>
       <div className="planGrid">
        <div className="planField"><label>Check in</label><input type="date" value={form.check_in} onChange={f('check_in')}/></div>
        <div className="planField"><label>Check out</label><input type="date" value={form.check_out} onChange={f('check_out')}/></div>
        <div className="planField"><label>Guests</label><select value={form.adults} onChange={f('adults')}><option>1</option><option>2</option><option>3</option><option>4</option><option>5</option></select></div>
       </div>

       <div className="stepHead"><span className="stepNum">3</span><b>Price and payment</b></div>
       <div className="spotTotal"><span>{sel.rate} per night</span><b>{nights ? fmt(total) : 'Pick your dates'}</b><small>{nights ? nights + ' night' + (nights > 1 ? 's' : '') + '. Breakfast and hotel tax included. Also US$ ' + sel.usd + ' per night.' : 'Choose check in and check out to see your total.'}</small>
        {nights && fee.amount > 0 ? <small className="feeLine">{fmtPrice(subtotal)} for the room, plus a {fmt(fee.amount)} {fee.label.toLowerCase()}</small> : null}</div>

      {signedIn && <button className={'btn planBook' + (busy ? ' loading' : '')} onClick={book} disabled={busy}>{busy ? 'Opening payment...' : 'Continue to payment'}</button>}
      <button className="linkBtn" onClick={() => setChosen('')}>Choose another room</button>
     </div>
    )}
    {msg && <div className={msg.ok ? 'bookMsg ok' : 'bookMsg'}>{msg.text}</div>}
    <p className="plannerNote">Change or drop your room any time before you pay. You are never charged here.</p>
   </div>
  </section>

  <EndLinks links={[
    {label: 'Book a room', href: '#planner', primary: true},
    {label: 'Go back home', href: './index.html'}
  ]}/>

  <MenuConcierge sections={[]}/>

  <Footer/>
 </div>;
}

createRoot(document.getElementById('root')!).render(<RoomsPage/>);






