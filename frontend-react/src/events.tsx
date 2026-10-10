import React from 'react';
import {createRoot} from 'react-dom/client';
import './styles.css';
import {TopBar, PageNav, Footer, BackLink, apiUrl, CALL, telHref, HOTEL} from './shared';
import {SmartImage, type ImageGroup} from './SmartImage';

/**
 * The venues the events page is built from. `group` says where the photograph
 * lives and `name` is the slug the build knows it by, exactly as every other
 * picture on the site is addressed.
 */
type Venue = {group: ImageGroup; name: string; alt: string; title: string; text: string; tag: string};

const venues: Venue[] = [
 {group: 'halls', name: 'meeting-room-nile-hall', alt: 'The Nile Hall set up for a function',
  title: 'The Nile Hall', tag: 'Up to 150 guests',
  text: 'Our signature hall, laid out the morning of your event and dressed to your theme. Boardroom, classroom, rounds or a ceremony - the room is rearranged for the day, not for the catalogue.'},
 {group: 'site', name: 'paradise-banquet-hall-768x1024', alt: 'The banquet hall of Hotel Paradise on the Nile',
  title: 'The Banquet Hall', tag: 'Weddings and dinners',
  text: 'A full banquet space for receptions, dinners and celebrations, with a kitchen that plates for every guest at once. Set the table, we will fill the glasses and keep the evening moving.'},
 {group: 'site', name: 'paradise-conference-room', alt: 'The conference room meeting space',
  title: 'The Conference Room', tag: 'Meetings and seminars',
  text: 'A focused, well lit room for meetings, seminars and training, with seating, a screen and refreshments served without the room ever losing its pace.'},
 {group: 'gallery', name: 'nile-hall1', alt: 'Hotel Paradise on the Nile gardens at the riverside',
  title: 'The Riverside Gardens', tag: 'Receptions under the sky',
  text: 'The lawns run down towards the Nile, so a cocktail hour or an open air reception has the river for a backdrop. When the sun sets on Jinja, this is where the evening belongs.'}
];

/** The occasions the hotel plans for, each drawn as its own small card. */
const occasions: {title: string; text: string}[] = [
 {title: 'Weddings', text: 'Ceremony, reception and the party after, styled around your colours and served from a kitchen that has cooked for hundreds of guests at a time.'},
 {title: 'Conferences & seminars', text: 'Halls with table plans, screens and uninterrupted sessions, plus tea breaks and lunch served exactly when your agenda says.'},
 {title: 'Team retreats', text: 'Meeting rooms by day and the pool and gardens by evening, a working trip that actually feels like a trip.'},
 {title: 'Birthdays & family parties', text: 'A day for the family, with space for the children, a menu everyone will eat and a room dressed to celebrate.'},
 {title: 'Anniversaries & ceremonies', text: 'Small and private or a room of fifty, the details handled and the day allowed to rest on the people in the room.'},
 {title: 'Corporate dinners', text: 'A seated dinner for your clients and colleagues on the banks of the Nile, with wine, warm service and a view worth the invitation.'}
];

const EVENT_TYPES = ['Wedding', 'Conference / seminar', 'Team retreat', 'Birthday party', 'Anniversary / ceremony', 'Corporate dinner', 'Family function', 'Other'];

function EventsPage() {
 const [form, setForm] = React.useState({name: '', phone: '', email: '', event_type: '', event_date: '', guests: '', venue: '', message: ''});
 const [msg, setMsg] = React.useState<{ok: boolean; text: string} | null>(null);
 const [busy, setBusy] = React.useState(false);

 const f = (k: keyof typeof form) => ((e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement | HTMLTextAreaElement>) => setForm({...form, [k]: e.target.value}));

 const send = async () => {
  setBusy(true); setMsg(null);
  try {
   const res = await fetch(await apiUrl('event'), {method: 'POST', headers: {'Content-Type': 'application/json'}, body: JSON.stringify(form)});
   const d = await res.json();
   if (d.ok) {
    setMsg({ok: true, text: d.message || 'Thank you. Our events team will call you on ' + form.phone + ' to arrange everything.'});
    setForm({name: '', phone: '', email: '', event_type: '', event_date: '', guests: '', venue: '', message: ''});
   } else {
    setMsg({ok: false, text: d.error || 'Could not send your request. Please call ' + CALL + '.'});
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
   <SmartImage group="site" name="Hotel-Paradise-on-the-Nile-Conferences-Weddings-cover"
    alt="" ratio="auto" widths={[480, 960, 1440]} sizes="100vw" className="pageHeroCover"/>
   <div className="pageHeroInner">
    <BackLink label="Back" fallback="./index.html"/>
    <p className="eyebrow">CONFERENCES, WEDDINGS AND FUNCTIONS</p>
    <h1>Plan an event worth every guest.</h1>
    <p>Halls and gardens on the banks of the Nile, a kitchen that feeds a room of two hundred, and an events team that carries the details so you can carry the day. Tell us what you are planning and we will send you a proposal within the day.</p>
   </div>
  </section>

  <section className="section">
   <div className="center reveal">
    <p className="eyebrow">OUR VENUES</p>
    <h2>Four ways to gather</h2>
    <p className="intro">Every venue is photographed, so what you plan for is what you get. All of them sit inside the hotel, which means parking, power, a kitchen and rooms for your guests are already part of the building.</p>
   </div>
   <div className="venueGrid">
    {venues.map(v => (
     <article className="venue reveal" key={v.title}>
      <SmartImage group={v.group} name={v.name} alt={v.alt} ratio="4 / 3"
       widths={[320, 480, 640, 960]} sizes="(max-width:900px) 100vw, (max-width:1400px) 480px, 560px"
       position="50% 45%" zoom className="photo"/>
      <div className="venueBody">
       <p className="pill">{v.tag}</p>
       <h3>{v.title}</h3>
       <p>{v.text}</p>
      </div>
     </article>
    ))}
   </div>
  </section>

  <section className="section hasTint" id="occasions">
   <div className="center reveal">
    <p className="eyebrow">WHAT WE PLAN</p>
    <h2>Big enough for two hundred, intimate enough for ten</h2>
    <p className="intro">Some hotels host events; we run them. Whatever the occasion, the shape of the day - tables, timing, menu, music and the people who make it happen - is the same care, in the right size.</p>
   </div>
   <div className="occGrid">
    {occasions.map(o => (
     <article className="occ reveal" key={o.title}>
      <h3>{o.title}</h3>
      <p>{o.text}</p>
     </article>
    ))}
   </div>
  </section>

  <section className="section" id="plan">
   <div className="center reveal">
    <p className="eyebrow">THE EQUATION</p>
    <h2>Everything a great event needs is already here</h2>
   </div>
   <div className="evSplit">
    <div className="evWrite reveal">
     <div className="evPill"><b>Riverside setting</b><span>The Nile is a few steps from the door. Your guests will not need a story to tell; the hotel is one.</span></div>
     <div className="evPill"><b>On-site catering</b><span>Menus written with you, cooked by a kitchen that plates for every guest at once - buffet or seated.</span></div>
     <div className="evPill"><b>Rooms for your guests</b><span>Sixty nine rooms mean the wedding party sleeps at the wedding, and the conference stays until Friday.</span></div>
     <div className="evPill"><b>An events manager</b><span>One person who owns your day from the first phone call to the last dance, so nothing is ever someone else's job.</span></div>
    </div>
    <div className="evGall reveal">
     <div className="evGallRow">
      <SmartImage group="halls" name="nile-hall-meeting-room2" alt="Horizon spread across the Nile Hall" ratio="16 / 10" widths={[320, 480, 640]} sizes="(max-width:1050px) 100vw, 460px" className="photo"/>
     </div>
     <div className="evGallRow two">
      <SmartImage group="halls" name="nile-hall-meeting-room3" alt="A riverside function table" ratio="4 / 3" widths={[320, 480, 640]} sizes="(max-width:1050px) 100vw, 220px" className="photo"/>
      <SmartImage group="site" name="paradise-banquet-hall-768x1024" alt="The banquet hall dressed for dinner" ratio="4 / 5" widths={[320, 480, 640]} sizes="(max-width:1050px) 100vw, 220px" className="photo"/>
     </div>
    </div>
   </div>
  </section>

  <section className="section hasTint" id="form">
   <div className="center reveal">
    <p className="eyebrow">START PLANNING</p>
    <h2>Tell us about your event</h2>
    <p className="intro">Send the outline below and our events team will come back to you the same day with dates, a menu and a clear price. No obligation, and no small print.</p>
   </div>
   <div className="evForm reveal">
    <div className="planGrid">
     <div className="planField"><label>Your name</label><input value={form.name} onChange={f('name')} placeholder="Full name"/></div>
     <div className="planField"><label>Phone</label><input value={form.phone} onChange={f('phone')} type="tel" placeholder="e.g. 0759504928"/></div>
    </div>
    <div className="planGrid">
     <div className="planField"><label>Email (optional)</label><input value={form.email} onChange={f('email')} type="email" placeholder="you@email.com"/></div>
     <div className="planField"><label>Type of event</label><select value={form.event_type} onChange={f('event_type')}><option value="">Choose one…</option>{EVENT_TYPES.map(t => <option key={t}>{t}</option>)}</select></div>
    </div>
    <div className="planGrid">
     <div className="planField"><label>Event date (optional)</label><input value={form.event_date} onChange={f('event_date')} type="date"/></div>
     <div className="planField"><label>Expected guests</label><input value={form.guests} onChange={f('guests')} type="number" min="1" placeholder="e.g. 60"/></div>
    </div>
    <div className="planField"><label>Venue preference (optional)</label><select value={form.venue} onChange={f('venue')}><option value="">Not sure yet - advise me</option><option>The Nile Hall</option><option>The Banquet Hall</option><option>The Conference Room</option><option>The Riverside Gardens</option></select></div>
    <div className="planField"><label>What are you planning?</label><textarea value={form.message} onChange={f('message')} rows={4} placeholder="The occasion, the date you have in mind and anything you already know you want…"/></div>
    {msg && <div className={'bookMsg' + (msg.ok ? ' ok' : '')}>{msg.text}</div>}
    <button className={'btn planBook' + (busy ? ' loading' : '')} onClick={send} disabled={busy}>{busy ? 'Sending your request…' : 'Request a proposal'}</button>
    <p className="evFormNote">Prefer to talk it through? Call <a className="footLink nileLine" href={telHref(CALL)}>{CALL}</a> or email <a className="footLink nileLine" href={'mailto:' + HOTEL.email}>{HOTEL.email}</a>. The front desk is open 24 hours.</p>
   </div>
  </section>

  <Footer/>
 </div>;
}

createRoot(document.getElementById('root')!).render(<EventsPage/>);