import React from 'react';
import {createRoot} from 'react-dom/client';
import './styles.css';
import {rooms as baseRooms, TopBar, PageNav, Footer, BedGlyph, roomImage, fmt, API} from './shared';
import {SmartImage} from './SmartImage';

/**
 * Add ?photos=1 to see the file name each room is waiting for. Guests never
 * see it; it is here so the front desk can tell which rooms still need a shot.
 */
const SHOW_FILE_HINTS = new URLSearchParams(location.search).get('photos') === '1';

function useQuery() {
 const p = new URLSearchParams(window.location.search);
 return {
  room: p.get('room') || '',
  check_in: p.get('check_in') || '',
  check_out: p.get('check_out') || '',
  adults: p.get('adults') || '2'
 };
}

function RoomsPage() {
 const q = useQuery();
 const [live, setLive] = React.useState<Record<string, number>>({});
 const [chosen, setChosen] = React.useState<string>(q.room || '');
 const [form, setForm] = React.useState({name: '', phone: '', email: '', check_in: q.check_in, check_out: q.check_out, adults: q.adults || '2'});
 const [msg, setMsg] = React.useState<{ok: boolean; text: string} | null>(null);
 const [busy, setBusy] = React.useState(false);

 React.useEffect(() => {
  fetch(API + '?act=rooms').then(r => r.json()).then(d => {
   if (d.ok && Array.isArray(d.rooms)) {
    const m: Record<string, number> = {};
    d.rooms.forEach((r: {name: string; price: number}) => { if (r.price > 0) m[r.name] = r.price; });
    setLive(m);
   }
  }).catch(() => {});
 }, []);

 const rooms = baseRooms.map(r => ({...r, price: live[r.type] ?? r.price, rate: live[r.type] ? fmt(live[r.type]) : r.rate}));
 const sel = rooms.find(r => r.type === chosen) || null;
 const nights = form.check_in && form.check_out && form.check_out > form.check_in ? Math.max(1, Math.ceil((Date.parse(form.check_out) - Date.parse(form.check_in)) / 86400000)) : 0;
 const total = sel && nights && sel.price > 0 ? sel.price * nights : 0;

 const pick = (t: string) => {
  setChosen(t);
  setMsg(null);
  const el = document.getElementById('planner');
  if (el) setTimeout(() => el.scrollIntoView({behavior: 'smooth', block: 'start'}), 60);
 };

 const f = (k: keyof typeof form) => ((e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => setForm({...form, [k]: e.target.value}));

 const book = async () => {
  if (!sel) return;
  setBusy(true); setMsg(null);
  try {
   const res = await fetch(API + '?act=booking', {method: 'POST', headers: {'Content-Type': 'application/json'}, body: JSON.stringify({
    name: form.name, phone: form.phone, email: form.email, check_in: form.check_in, check_out: form.check_out,
    room_type: sel.type, adults: parseInt(form.adults) || 1
   })});
   const d = await res.json();
   setMsg({ok: !!d.ok, text: d.ok ? ('You have chosen the ' + sel.type + '. Request ' + d.booking_number + ' received. ' + d.message) : (d.error || 'Something went wrong. Please try again or call +256 759 504 928.')});
  } catch {
   setMsg({ok: false, text: 'Could not reach the booking service. Please call +256 759 504 928.'});
  }
  setBusy(false);
 };

  return <div>
   <TopBar/>
   <PageNav/>

   <section className="pageHero">
    <p className="eyebrow">CHOOSE YOUR ROOM</p>
    <h1>Rooms and beds, your way.</h1>
    <p>Every room type is photographed, so you can see exactly what you are booking. Choose the one you like, and change or drop it as often as you like before you book. Rates are per night, shown in Uganda Shillings and US dollars, and include breakfast and the local hotel tax.</p>
   </section>

   <section className="bedsWrap section">
    <div className="bedList">
     {rooms.map(r => {
      const active = chosen === r.type;
      return (
       <article className={'bedCard' + (active ? ' chosen' : '')} id={'bed-' + r.id} key={r.id}>
        <SmartImage
         group="rooms"
         name={roomImage(r.type)}
         alt={r.type}
         ratio="3 / 4"
         widths={[320, 480, 640, 960]}
         sizes="(max-width:1050px) 100vw, 300px"
         position="50% 45%"
         zoom
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
       <SmartImage
        group="rooms"
        name={roomImage(sel.type)}
        alt={sel.type}
        ratio="16 / 10"
        widths={[320, 480, 640]}
        sizes="(max-width:1050px) 100vw, 360px"
        position="50% 45%"
        className="spot"
        placeholder={<BedGlyph size={86}/>}
       />
       <h3>{sel.type}</h3>
       <p className="bedsLine">{sel.beds} &middot; {sel.guests}</p>
        <div className="spotTotal"><span>{sel.rate} per night</span><b>{nights ? fmt(total) : 'Pick your dates'}</b><small>{nights ? 'For ' + nights + ' night' + (nights > 1 ? 's' : '') + ', breakfast and hotel tax included. Also US$ ' + sel.usd + ' per night' : 'Choose check in and check out to see your total, quoted in Uganda Shillings'}</small></div>



      <div className="planGrid">
       <div className="planField"><label>Your name</label><input value={form.name} onChange={f('name')} placeholder="Full name"/></div>
       <div className="planField"><label>Phone</label><input value={form.phone} onChange={f('phone')} type="tel" placeholder="e.g. 0759504928"/></div>
       <div className="planField"><label>Email (optional)</label><input value={form.email} onChange={f('email')} type="email" placeholder="you@email.com"/></div>
       <div className="planField"><label>Check in</label><input type="date" value={form.check_in} onChange={f('check_in')}/></div>
       <div className="planField"><label>Check out</label><input type="date" value={form.check_out} onChange={f('check_out')}/></div>
       <div className="planField"><label>Guests</label><select value={form.adults} onChange={f('adults')}><option>1</option><option>2</option><option>3</option><option>4</option><option>5</option></select></div>
      </div>

      <button className="btn planBook" onClick={book} disabled={busy}>{busy ? 'Sending your request...' : 'Book this room'}</button>
      <button className="linkBtn" onClick={() => setChosen('')}>Choose another room instead</button>
     </div>
    )}
    {msg && <div className={msg.ok ? 'bookMsg ok' : 'bookMsg'}>{msg.text}</div>}
    <p className="plannerNote">You are in full control. Drop your choice and pick any other bed at any time before you book. You will never be charged here.</p>
   </div>
  </section>

  <Footer/>
 </div>;
}

createRoot(document.getElementById('root')!).render(<RoomsPage/>);