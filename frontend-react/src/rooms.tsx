import React from 'react';
import {createRoot} from 'react-dom/client';
import './styles.css';
import {rooms as baseRooms, TopBar, PageNav, Footer, BedGlyph, roomImage, fmt, fmtPrice, withService, apiUrl, CALL} from './shared';
import {SmartImage, photoHintsEnabled} from './SmartImage';

/** The photographs each room is still waiting for, shown on request only. */
const SHOW_FILE_HINTS = photoHintsEnabled();

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
  // The fee is read from the server, never guessed here, so what the guest is
  // shown is what the server will actually charge.
  const [fee, setFee] = React.useState<{label: string; amount: number}>({label: 'Withdrawal fee', amount: 0});

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

 const book = async () => {
  if (!sel) return;
  setBusy(true); setMsg(null);
  try {
   const res = await fetch(await apiUrl('booking'), {method: 'POST', headers: {'Content-Type': 'application/json'}, body: JSON.stringify({
    name: form.name, phone: form.phone, email: form.email, check_in: form.check_in, check_out: form.check_out,
    room_type: sel.type, adults: parseInt(form.adults) || 1
   })});
    const d = await res.json();
    if (d.ok) {
      // Auto-print receipt for booking
      try {
        const now = new Date();
        const dateStr = now.toLocaleDateString('en-GB', { day: '2-digit', month: '2-digit', year: 'numeric' });
        const timeStr = now.toLocaleTimeString('en-GB', { hour: '2-digit', minute: '2-digit' });
        const printWindow = window.open('', '_blank', 'width=400,height=600');
        if (printWindow) {
          let receiptHtml = `
            <html>
              <head><title>Receipt - ${d.booking_number}</title>
              <style>
                body{font-family:'Courier New',monospace;margin:0;padding:15px;max-width:400px}
                .h{text-align:center;border-bottom:2px solid #000;padding-bottom:8px;margin-bottom:12px}
                .t{font-size:18px;font-weight:bold;margin:0}
                .s{font-size:11px;margin:3px 0 0}
                .i{font-size:11px;margin-bottom:10px}
                .r{display:flex;justify-content:space-between;margin:2px 0}
                .sec{margin:10px 0;border-bottom:1px dashed #000;padding-bottom:8px}
                .st{font-weight:bold;font-size:12px;text-align:center;margin-bottom:6px}
                .it{margin:4px 0;font-size:10px}
                .tot{margin-top:12px;font-size:12px}
                .tr{display:flex;justify-content:space-between;margin:3px 0}
                .gt{font-size:14px;font-weight:bold;border-top:2px solid #000;padding-top:6px;margin-top:6px}
                .f{text-align:center;margin-top:15px;font-size:10px}
              </style>
              </head>
              <body>
                  <div class="h">
                    <img src="./images/paradise-logo.png" alt="Hotel Paradise Logo" style="max-width:60px;height:auto;margin-bottom:6px" onerror="this.style.display='none'"/>
                    <h1 class="t">HOTEL PARADISE ON THE NILE</h1>
                    <p class="s">Jinja, Uganda</p>
                    <p class="s">Tel: +256 759 504 928</p>
                  </div>
                <div class="i">
                  <div class="r"><span>Booking No:</span><span>${d.booking_number}</span></div>
                  <div class="r"><span>Date:</span><span>${dateStr}</span></div>
                  <div class="r"><span>Time:</span><span>${timeStr}</span></div>
                  <div class="r"><span>Customer:</span><span>${form.name}</span></div>
                  <div class="r"><span>Phone:</span><span>${form.phone}</span></div>
                  ${form.email ? `<div class="r"><span>Email:</span><span>${form.email}</span></div>` : ''}
                </div>
                <div class="sec">
                  <div class="st">ROOM BOOKING</div>
                  <div class="it">
                    <b>${sel.type}</b><br/>
                    <span style="font-size:9px">Check In: ${form.check_in} 14:00</span><br/>
                    <span style="font-size:9px">Check Out: ${form.check_out} 11:00</span><br/>
                    <span style="font-size:9px">Nights: ${nights} | Adults: ${form.adults}</span>
                  </div>
                </div>
                <div class="tot">
                  <div class="tr gt"><span>TOTAL:</span><span>UGX ${Math.round(Number(d.total)||0).toLocaleString()}</span></div>
                </div>
                <div class="f">
                  <p>Thank you for choosing Hotel Paradise on the Nile</p>
                  <p>Booking request received</p>
                </div>
              </body></html>`;
          printWindow.document.write(receiptHtml);
          printWindow.document.close();
          printWindow.focus();
          setTimeout(() => { printWindow.print(); printWindow.close(); }, 500);
        }
      } catch {}
      // The booking exists on the server. Hand the guest to the checkout page,
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
   <PageNav/>

<section className="pageHero hasCover">
    <SmartImage
      group="rooms"
      name="suite"
      alt="Hotel Paradise on the Nile - Suite"
      className="pageHeroCover"
      widths={[640,1024,1440,1920]}
      sizes="100vw"
      position="50% 50%"
    />
    <div className="pageHeroInner">
     <p className="eyebrow">CHOOSE YOUR ROOM</p>
     <h1>Rooms and beds, your way.</h1>
     <p>Every room type is photographed, so you can see exactly what you are booking. Choose the one you like, and change or drop it as often as you like before you book. Rates are per night, shown in Uganda Shillings and US dollars, and include breakfast and the local hotel tax.</p>
    </div>
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
        <div className="spotTotal"><span>{sel.rate} per night</span><b>{nights ? fmt(total) : 'Pick your dates'}</b><small>{nights ? 'For ' + nights + ' night' + (nights > 1 ? 's' : '') + ', breakfast and hotel tax included. Also US$ ' + sel.usd + ' per night' : 'Choose check in and check out to see your total, quoted in Uganda Shillings'}</small>
         {nights && fee.amount > 0 ? <small className="feeLine">{fmtPrice(subtotal)} for the room, plus a {fmt(fee.amount)} {fee.label.toLowerCase()}</small> : null}</div>



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
