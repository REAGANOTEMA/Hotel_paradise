import React from 'react';
import {createRoot} from 'react-dom/client';
import './styles.css';
import {TopBar, PageNav, Footer, BackLink, apiUrl, CALL, telHref, HOTEL, useReveal} from './shared';
import {SmartImage, type ImageGroup} from './SmartImage';

/**
 * One facility of the hotel. `group` and `name` address the photograph exactly
 * as every other picture on the site is addressed, so the copy and the plate
 * can never drift apart.
 */
type Facility = {group: ImageGroup; name: string; alt: string; eyebrow: string; title: string; text: string};

const facilities: Facility[] = [
 {group: 'site', name: 'Pool-Area', alt: 'The swimming pool at Hotel Paradise on the Nile',
  eyebrow: 'THE POOL',
  title: 'A morning swim by the Nile',
  text: 'A sparkling pool set among sun loungers and green lawns, with the river a few steps further on. Cool off any hour it is warm - and in Jinja, that is most of the day. Towels are waiting, the water is clear, and the loungers have the best view of an afternoon anywhere in town.'},
 {group: 'site', name: 'gym', alt: 'The health club and gym',
  eyebrow: 'HEALTH CLUB AND GYM',
  title: 'Keep your routine, keep the view',
  text: 'A working gym with the machines and free weights a proper session needs, open early enough to train before the day starts and late enough to fit an evening. Whether you are keeping a routine or starting one, a towel, a bottle of water and a good stretch are all waiting.'},
 {group: 'site', name: 'Bar', alt: 'The bar at Hotel Paradise on the Nile',
  eyebrow: 'THE BAR',
  title: 'Evenings start here',
  text: 'A relaxed riverside bar with a carefully chosen wine list, cold beer and cocktails made without watching the clock. Settle into a seat by the window or out on the terrace as the sun drops behind Jinja - it is the kind of place a short visit turns into the whole evening.'}
];

const gifts: {t: string; d: string}[] = [
 {t: 'Free for guests', d: 'The pool and the gym are included in every room rate.'},
 {t: 'Open to visitors', d: 'Non residents are welcome too - ask the front desk about a day pass.'},
 {t: 'Sauna and steam', d: 'Relax after your session or before dinner.'},
 {t: 'Towels and water', d: 'Laid on before you even ask.'},
 {t: 'By the river', d: 'Jinja meets the Nile at the edge of the lawns.'},
 {t: 'Open daily', d: 'The pool from sunrise, the bar until late.'}
];

const FACILITY_TYPES = ['Swimming pool', 'Health club and gym', 'The bar and terrace', 'A function', 'Just an enquiry'];

function FacilitiesPage() {
 const [form, setForm] = React.useState({name: '', phone: '', email: '', facility: '', date: '', guests: '', message: ''});
 const [msg, setMsg] = React.useState<{ok: boolean; text: string} | null>(null);
 const [busy, setBusy] = React.useState(false);

 useReveal();

 const f = (k: keyof typeof form) => ((e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement | HTMLTextAreaElement>) => setForm({...form, [k]: e.target.value}));

 const send = async () => {
  setBusy(true); setMsg(null);
  try {
   const res = await fetch(await apiUrl('facility'), {method: 'POST', headers: {'Content-Type': 'application/json'}, body: JSON.stringify(form)});
   const d = await res.json();
   if (d.ok) {
    setMsg({ok: true, text: d.message || 'Thank you. The front desk will confirm the details on ' + form.phone + '.'});
    setForm({name: '', phone: '', email: '', facility: '', date: '', guests: '', message: ''});
   } else {
    setMsg({ok: false, text: d.error || 'Could not send your enquiry. Please call ' + CALL + '.'});
   }
  } catch {
   setMsg({ok: false, text: 'Could not reach the hotel right now. Please call ' + CALL + '.'});
  }
  setBusy(false);
 };

 return <div>
  <TopBar/>
  <PageNav onDark/>

  <section className="pageHero hasCover" id="main">
   <SmartImage group="site" name="Pool-Area"
    alt="" ratio="auto" widths={[480, 960, 1440]} sizes="100vw" className="pageHeroCover"/>
   <div className="pageHeroInner">
    <BackLink label="Back" fallback="./index.html"/>
    <p className="eyebrow">POOL, HEALTH CLUB, BAR AND MORE</p>
    <h1>Facilities that feel like a treat, every day.</h1>
    <p>Hotel Paradise on the Nile is more than a place to sleep. The pool, the gym, the bar and the grounds are all part of the staying - and all of them are open to hotel guests and visitors alike. Come for the evening, or come for the season.</p>
   </div>
  </section>

  <section className="section" id="facilities">
   <div className="facStack">
    {facilities.map((fl, i) => (
     <article className={'fac reveal' + (i % 2 ? ' rev' : '')} key={fl.title}>
      <SmartImage group={fl.group} name={fl.name} alt={fl.alt} ratio="16 / 10"
       widths={[320, 480, 640, 960]} sizes="(max-width:1050px) 100vw, 560px"
       position="50% 50%" zoom className="photo"/>
      <div className="facBody">
       <div className="facIdx" aria-hidden="true">0{i + 1}</div>
       <p className="eyebrow">{fl.eyebrow}</p>
       <h2>{fl.title}</h2>
       <p className="facText">{fl.text}</p>
      </div>
     </article>
    ))}
   </div>
  </section>

  <section className="section hasTint" id="why">
   <div className="center reveal">
    <p className="eyebrow">GOOD TO KNOW</p>
    <h2>Everything else, in one building</h2>
    <p className="intro">The hotel sits on the banks of the Nile with 69 rooms across three floors, restaurants and a bar, grounds for functions and gardens to walk in. These are the small courtesies that make the stay.</p>
   </div>
   <div className="giftGrid">
    {gifts.map(g => <div className="gift reveal" key={g.t}><b>{g.t}</b><span>{g.d}</span></div>)}
   </div>
   <div className="facGallery reveal">
    <SmartImage group="site" name="Hotel-paradise" alt="The main building of Hotel Paradise on the Nile" ratio="16 / 9" widths={[480, 960, 1440]} sizes="(max-width:900px) 100vw, 640px" position="50% 40%" zoom className="photo">
     <span className="frameCap">The main building, on the banks of the Nile</span>
    </SmartImage>
    <SmartImage group="facilities" name="fact-wellness" alt="Relaxation and wellness at Hotel Paradise on the Nile" ratio="16 / 9" widths={[480, 960, 1440]} sizes="(max-width:900px) 100vw, 640px" zoom className="photo">
     <span className="frameCap">Relaxation and wellness, indoors and out</span>
    </SmartImage>
    <SmartImage group="gallery" name="pool1" alt="The pool at Hotel Paradise on the Nile" ratio="16 / 9" widths={[480, 960, 1440]} sizes="(max-width:900px) 100vw, 640px" position="50% 45%" zoom className="photo">
     <span className="frameCap">The pool, a few steps from the river</span>
    </SmartImage>
   </div>
  </section>

  <section className="section" id="plan">
   <div className="center reveal">
    <p className="eyebrow">PLAN YOUR VISIT</p>
    <h2>Ask us anything</h2>
    <p className="intro">Whether you want a pool day, a fitness plan, a table at the bar or a function in the grounds, tell us here and the front desk will answer the same day.</p>
   </div>
   <div className="evForm reveal">
    <div className="planGrid">
     <div className="planField"><label>Your name</label><input value={form.name} onChange={f('name')} placeholder="Full name"/></div>
     <div className="planField"><label>Phone</label><input value={form.phone} onChange={f('phone')} type="tel" placeholder="e.g. 0759504928"/></div>
    </div>
    <div className="planGrid">
     <div className="planField"><label>Email (optional)</label><input value={form.email} onChange={f('email')} type="email" placeholder="you@email.com"/></div>
     <div className="planField"><label>What are you interested in?</label><select value={form.facility} onChange={f('facility')}><option value="">Choose one…</option>{FACILITY_TYPES.map(t => <option key={t}>{t}</option>)}</select></div>
    </div>
    <div className="planGrid">
     <div className="planField"><label>Date (optional)</label><input value={form.date} onChange={f('date')} type="date"/></div>
     <div className="planField"><label>Number of people</label><input value={form.guests} onChange={f('guests')} type="number" min="1" placeholder="e.g. 4"/></div>
    </div>
    <div className="planField"><label>Your message</label><textarea value={form.message} onChange={f('message')} rows={4} placeholder="Ask us anything - availability, day passes, group visits, garden dinners…"/></div>
    {msg && <div className={'bookMsg' + (msg.ok ? ' ok' : '')}>{msg.text}</div>}
    <button className={'btn planBook' + (busy ? ' loading' : '')} onClick={send} disabled={busy}>{busy ? 'Sending your enquiry…' : 'Send your enquiry'}</button>
    <p className="evFormNote">Or call <a className="footLink nileLine" href={telHref(CALL)}>{CALL}</a> / email <a className="footLink nileLine" href={'mailto:' + HOTEL.email}>{HOTEL.email}</a>. The front desk is open 24 hours.</p>
   </div>
  </section>

  <Footer/>
 </div>;
}

createRoot(document.getElementById('root')!).render(<FacilitiesPage/>);