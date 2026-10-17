import React from 'react';
import {createRoot} from 'react-dom/client';
import './styles.css';
import {ExploreMore, TopBar, PageNav, Footer, BackLink, apiUrl, CALL, telHref, HOTEL, useReveal, customerToken} from './shared';
import {SmartImage} from './SmartImage';
import {MenuConcierge} from './concierge';

/**
 * Talk to the house: the one page where a guest can write to the hotel.
 *
 * Two doors, one form. A guest staying in the house or planning to visit can
 * send a message to the front desk or the kitchen, and a guest who has just
 * lived the stay can set down their experience with a rating. Both are the
 * same table behind the scenes, so the team reads them in one place and the
 * best of the experiences, once the hotel chooses, appear on this page under
 * "What our guests say".
 */

type Experience = {name: string; rating: number; text: string; department: string; when: string};

const STAR_LABELS = ['', 'Poor', 'Fair', 'Good', 'Very good', 'Excellent'];

function StarPicker({value, onChange}: {value: number; onChange: (n: number) => void}) {
 return <div className="stars" role="radiogroup" aria-label="Your rating">
  {[1, 2, 3, 4, 5].map(n => (
   <button key={n} type="button" role="radio" aria-checked={value === n} aria-label={n + ' star' + (n === 1 ? '' : 's') + ' - ' + STAR_LABELS[n]}
    className={n <= value ? 'star on' : 'star'} onClick={() => onChange(n)}>&#9733;</button>
  ))}
  <span className="starWord">{value ? STAR_LABELS[value] : 'Tap to rate'}</span>
 </div>;
}

function TalkPage() {
 const [mode, setMode] = React.useState<'message' | 'experience'>('message');
 const [form, setForm] = React.useState({name: '', phone: '', email: '', room_number: '', subject: '', message: '', department: 'front_office'});
 const [rating, setRating] = React.useState(0);
 const [msg, setMsg] = React.useState<{ok: boolean; text: string; ref?: string} | null>(null);
 const [busy, setBusy] = React.useState(false);
 const [said, setSaid] = React.useState<Experience[]>([]);
 const [saidLoading, setSaidLoading] = React.useState(true);

 useReveal();

 React.useEffect(() => {
  let alive = true;
  (async () => {
   try {
    const res = await fetch(await apiUrl('testimonials'));
    const d = await res.json();
    if (alive && d.ok && Array.isArray(d.items)) setSaid(d.items);
   } catch { /* the band simply stays quiet */ }
   if (alive) setSaidLoading(false);
  })();
  return () => { alive = false; };
 }, []);

 const f = (k: keyof typeof form) => ((e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement | HTMLTextAreaElement>) => setForm({...form, [k]: e.target.value}));

 const reset = () => { setForm({name: '', phone: '', email: '', room_number: '', subject: '', message: '', department: 'front_office'}); setRating(0); };

 const send = async () => {
  setBusy(true); setMsg(null);
  try {
   const payload = {...form, kind: mode, rating: mode === 'experience' ? rating : 0, token: customerToken()};
   const res = await fetch(await apiUrl('guest_message'), {method: 'POST', headers: {'Content-Type': 'application/json'}, body: JSON.stringify(payload)});
   const d = await res.json();
   if (d.ok) {
    setMsg({ok: true, text: d.message || 'Thank you. The team has your message and will answer you shortly.', ref: d.reference});
    reset();
   } else {
    setMsg({ok: false, text: d.error || 'Could not send your message. Please call ' + CALL + '.'});
   }
  } catch {
   setMsg({ok: false, text: 'Could not reach the hotel right now. Please call ' + CALL + '.'});
  }
  setBusy(false);
 };

 const pick = (m: 'message' | 'experience') => { setMode(m); setMsg(null); };

 return <div>
  <TopBar/>
  <PageNav onDark/>

  <section className="pageHero hasCover" id="main">
   <SmartImage group="site" name="hero-hotel-entrence"
    alt="" ratio="auto" widths={[480, 960, 1440]} sizes="100vw" className="pageHeroCover"/>
   <div className="pageHeroInner">
    <BackLink label="Back" fallback="./index.html"/>
    <p className="eyebrow">TALK TO THE HOUSE</p>
    <h1>The front desk is listening.</h1>
    <p>Message the front office or the kitchen, tell us how your stay was, or ask for anything at all. Whether you are in the house tonight or remembering it months later, this is where your words reach the people who made your stay.</p>
   </div>
  </section>

  <section className="section" id="write">
   <div className="center reveal">
    <p className="eyebrow">ONE FORM, TWO DOORS</p>
    <h2>Send a message, or write your experience</h2>
    <p className="intro">Everything you send reaches the house directly. A message goes to the desk that handles it; an experience is read by the team and, when it is kind, kept for other guests to see.</p>
   </div>

   <div className="talkTabs reveal" role="tablist">
    <button type="button" role="tab" aria-selected={mode === 'message'} className={mode === 'message' ? 'talkTab on' : 'talkTab'} onClick={() => pick('message')}>Send a message</button>
    <button type="button" role="tab" aria-selected={mode === 'experience'} className={mode === 'experience' ? 'talkTab on' : 'talkTab'} onClick={() => pick('experience')}>Tell us about your stay</button>
   </div>

   <div className="evForm reveal">
    <div className="planGrid">
     <div className="planField"><label>Your name</label><input value={form.name} onChange={f('name')} placeholder="Full name"/></div>
     <div className="planField"><label>Phone</label><input value={form.phone} onChange={f('phone')} type="tel" placeholder="e.g. 0759504928"/></div>
    </div>
    <div className="planGrid">
     <div className="planField"><label>{mode === 'message' ? 'Who should read this?' : 'What are you telling us about?'}</label>
      <select value={form.department} onChange={f('department')}>
       <option value="front_office">{mode === 'message' ? 'The front office - rooms, bookings, anything at all' : 'The whole stay and the service'}</option>
       <option value="kitchen">{mode === 'message' ? 'The kitchen - food, dining and orders' : 'The food and the dining'}</option>
      </select></div>
     <div className="planField"><label>Email (optional)</label><input value={form.email} onChange={f('email')} type="email" placeholder="you@email.com"/></div>
    </div>

    {mode === 'message' && <>
     <div className="planGrid">
      <div className="planField"><label>Subject (optional)</label><input value={form.subject} onChange={f('subject')} placeholder="e.g. Extra towels, a late check-out, a dinner table"/></div>
      <div className="planField"><label>Room number (if you are staying with us)</label><input value={form.room_number} onChange={f('room_number')} placeholder="e.g. 42"/></div>
     </div>
    </>}

    {mode === 'experience' && <div className="planField"><label>Your rating</label><StarPicker value={rating} onChange={setRating}/></div>}

    <div className="planField"><label>{mode === 'message' ? 'Your message' : 'Your experience of the stay'}</label>
     <textarea value={form.message} onChange={f('message')} rows={5}
      placeholder={mode === 'message' ? 'Write it in your own words. A room number or a time helps the desk find you faster…' : 'What made the stay? The room, the food, the people, the river. Write it as you would tell a friend…'}/></div>

    {msg && <div className={'bookMsg' + (msg.ok ? ' ok' : '')}>{msg.text}{msg.ref ? <><br/><small>Your reference is {msg.ref}.</small></> : null}</div>}

    <button className={'btn planBook' + (busy ? ' loading' : '')} onClick={send} disabled={busy}>
     {busy ? 'Sending…' : mode === 'message' ? 'Send to the hotel' : 'Share your experience'}
    </button>
    <p className="evFormNote">In the house and need someone now? Call the front desk on <a className="footLink nileLine" href={telHref(CALL)}>{CALL}</a> or write to <a className="footLink nileLine" href={'mailto:' + HOTEL.email}>{HOTEL.email}</a>. The desk is answered 24 hours.</p>
   </div>
  </section>

  <section className="section hasTint" id="said">
   <div className="center reveal">
    <p className="eyebrow">WHAT OUR GUESTS SAY</p>
    <h2>Words from the people who stayed</h2>
    <p className="intro">A few of the experiences guests have trusted us with, chosen by the hotel from those written here.</p>
   </div>
   {saidLoading ? <p className="saidEmpty">Loading what guests have said…</p>
    : said.length === 0 ? <p className="saidEmpty">No experiences are on show just yet. Yours could be the first: write it in the form above.</p>
    : <div className="saidGrid">
     {said.map((s, i) => (
      <figure className="said reveal" key={i}>
       <div className="saidStars" aria-label={s.rating + ' out of 5'}>{'★'.repeat(Math.max(0, Math.min(5, s.rating)))}{'☆'.repeat(Math.max(0, 5 - s.rating))}</div>
       <blockquote>{s.text}</blockquote>
       <figcaption><b>{s.name}</b><span>{s.when}{s.department === 'kitchen' ? ' · on the dining' : ' · on the stay'}</span></figcaption>
      </figure>
     ))}
    </div>}
  </section>

  <ExploreMore current="talk"/>

  <MenuConcierge sections={[]}/>

  <Footer/>
 </div>;
}

createRoot(document.getElementById('root')!).render(<TalkPage/>);
