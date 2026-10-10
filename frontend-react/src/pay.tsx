import React from 'react';
import {createRoot} from 'react-dom/client';
import './styles.css';
import {TopBar, PageNav, Footer, fmt, apiUrl, CALL, HOTEL, telHref, customerToken, rooms as bedRooms, WhatsAppIcon, BackLink, bgUrl} from './shared';
import {SmartImage} from './SmartImage';

/*
 * Secure checkout. The room booking and the kitchen order both land here with
 * their reference and total in the URL. The guest adds the details the receipt
 * needs, picks a payment method and pays. Pesapal is the gateway; the merchant
 * keys are still pending, so for now the payment is recorded as pending and the
 * front desk confirms it. The moment Pesapal is switched on, this page sends the
 * guest to Pesapal's secure page and the same payment row receives the callback.
 *
 * The reference is read back from the database before anything is charged. The
 * url can say whatever it likes - it is edited by hand as often as it is
 * followed - so the lines, the dates and the amount on this page are the ones
 * the hotel holds, and only those are ever sent to be paid.
 */

type MethodKey = 'pesapal' | 'mtn_momo' | 'airtel_money' | 'card';

/** One line of an order, exactly as the kitchen stored it. */
type PayLine = {name: string; qty: number; unit: number; total: number; image: string; note: string};

type PayDetail = {
 source: string;
 reference: string;
 status: string;
 total: number;
 paid: number;
 due: number;
 booking?: {
  room_type: string;
  check_in: string;
  check_in_time: string;
  check_out: string;
  check_out_time: string;
  nights: number;
  adults: number;
  children: number;
  subtotal: number;
  tax: number;
  withdrawal_fee: number | null;
  fee_label: string;
 };
 order?: {
  outlet: string;
  kind: string;
  table: string;
  placed: string;
  subtotal: number;
  tax: number;
  items: PayLine[];
 };
 payments: {reference: string; method: string; amount: number; status: string; when: string}[];
};

/** '2026-10-11' plus '14:00' the way a guest reads it: Sat 11 Oct, 14:00 */
const whenText = (date: string, time: string): string => {
 const d = /^\d{4}-\d{2}-\d{2}$/.test(date || '') ? new Date(date + 'T' + (time || '00:00') + ':00') : null;
 if (!d || isNaN(d.getTime())) return date + (time ? ' ' + time : '');
 const day = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][d.getDay()];
 const month = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][d.getMonth()];
 return `${day} ${d.getDate()} ${month}, ${time}`;
};

const METHOD_TEXT: Record<string, string> = {pesapal: 'Pesapal', mtn_momo: 'MTN MoMo', airtel_money: 'Airtel Money', card: 'Card', cash: 'Cash', bank: 'Bank transfer'};

/**
 * The tone of a reference status, so a guest reads it at a glance without
 * knowing the hotel's wording: settled money is green, money still awaited
 * is amber, anything stopped is red, and anything else stays neutral blue.
 */
const statusTone = (status: string): string => {
 const v = String(status || '').toLowerCase();
 if (v.includes('paid') || v.includes('settled') || v.includes('complete') || v.includes('cleared') || v.includes('confirmed')) return 'ok';
 if (v.includes('cancel') || v.includes('reject') || v.includes('fail') || v.includes('void') || v.includes('expire')) return 'bad';
 if (v.includes('pend') || v.includes('await') || v.includes('request') || v.includes('partial') || v.includes('due')) return 'warn';
 return 'blue';
};

/**
 * The hotel on WhatsApp, in the international form wa.me wants, without the
 * plus. Every forwarded receipt goes to this one number: the front desk,
 * which is the number printed in the top bar of the site.
 */
const WA_HOTEL = '256759504928';

/** The bed behind a room type, so the hotel reads the bed as well as the room. */
const bedOf = (roomType: string): {beds: string; guests: string} | null => {
 const hit = bedRooms.find(r => String(roomType).toLowerCase().includes(r.type.toLowerCase()));
 return hit ? {beds: hit.beds, guests: hit.guests} : null;
};

const METHODS: {key: MethodKey; label: string; hint: string; icon: string}[] = [
 {key: 'pesapal', label: 'Pesapal Pay', hint: 'Pay from a Pesapal account, or a credit or debit card, on Pesapal\u2019s secure page.', icon: 'wallet'},
 {key: 'mtn_momo', label: 'MTN Mobile Money', hint: 'Instant payment from an MTN MoMo number, no account needed.', icon: 'phone'},
 {key: 'airtel_money', label: 'Airtel Money', hint: 'Instant payment from an Airtel Money number, no account needed.', icon: 'phone'},
 {key: 'card', label: 'Visa or Mastercard', hint: 'Card numbers are entered on Pesapal\u2019s secure page, never saved here.', icon: 'card'}
];

const ls = (k: string): string => { try { return window.localStorage.getItem(k) || ''; } catch { return ''; } };

const LockIcon = ({size = 16}: {size?: number}) => (
 <svg width={size} height={size} viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="M12 2a5 5 0 0 0-5 5v3H6a2 2 0 0 0-2 2v7a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2v-7a2 2 0 0 0-2-2h-1V7a5 5 0 0 0-5-5Zm-3 8V7a3 3 0 0 1 6 0v3Z"/></svg>
);
const PhoneIcon = ({size = 18}: {size?: number}) => (
 <svg width={size} height={size} viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="M6.6 10.8c1.4 2.8 3.8 5.2 6.6 6.6l2.2-2.2c.3-.3.7-.4 1-.2 1.2.4 2.4.6 3.7.6.6 0 1 .4 1 1V20c0 .6-.4 1-1 1C10.9 21 3 13.1 3 3.5c0-.6.4-1 1-1H7c.6 0 1 .4 1 1 0 1.2.2 2.5.6 3.7.1.3 0 .7-.2 1z"/></svg>
);
const CardIcon = ({size = 18}: {size?: number}) => (
 <svg width={size} height={size} viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="M3 5h18a1 1 0 0 1 1 1v12a1 1 0 0 1-1 1H3a1 1 0 0 1-1-1V6a1 1 0 0 1 1-1Zm1 4h16v-1H4Zm0 4v3h6v-3Z"/></svg>
);
const WalletIcon = ({size = 18}: {size?: number}) => (
 <svg width={size} height={size} viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="M19 7V5a2 2 0 0 0-2-2H5a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-2h1v-3h-1V8h1V5zm-2 0H5V5h12zm3 8h-5a1 1 0 1 1 0-2h5z"/></svg>
);
const CheckIcon = ({size = 22}: {size?: number}) => (
 <svg width={size} height={size} viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="M12 22a10 10 0 1 1 0-20 10 10 0 0 1 0 20Zm-1.2-6.2 6-6-1.4-1.4-4.6 4.6-2.2-2.2-1.4 1.4z"/></svg>
);

const Icon = ({kind}: {kind: string}) =>
 kind === 'card' ? <CardIcon/> : kind === 'wallet' ? <WalletIcon/> : <PhoneIcon/>;

const normPhone = (p: string) => p.replace(/[^\d+]/g, '');
const validMomo = (p: string) => /^(\+?256|0)7\d{8}$/.test(normPhone(p));
const fmtCard = (v: string) => v.replace(/\D/g, '').slice(0, 16).replace(/(\d{4})(?=\d)/g, '$1 ');
const fmtExp = (v: string) => { const d = v.replace(/\D/g, '').slice(0, 4); return d.length > 2 ? d.slice(0, 2) + '/' + d.slice(2) : d; };
const validExp = (v: string) => {
 const m = /^(\d{2})\/(\d{2})$/.exec(v);
 if (!m) return false;
 const mm = parseInt(m[1], 10), yy = parseInt(m[2], 10);
 if (mm < 1 || mm > 12) return false;
 return yy >= (new Date().getFullYear() % 100);
};

/**
 * The official receipt, shown on the page and printed through the phone's own
 * print dialog - opened by the guest, never by script, and never as a popup.
 * It reads the settled reference from the checkout detail when that has been
 * fetched, and falls back to what the url carried if the hotel is slow to
 * answer.
 */
function PayReceipt({src, ref, charged, amt, form, detail, item, qty, unit, methodLabel}: {
 src: string; ref: string; charged: number; amt: number;
 form: {name: string; phone: string; email: string};
 detail: PayDetail | null;
 item: string; qty: string; unit: string; methodLabel: string;
}) {
 const now = new Date();
 const dateStr = now.toLocaleDateString('en-GB', {day: '2-digit', month: '2-digit', year: 'numeric'});
 const timeStr = now.toLocaleTimeString('en-GB', {hour: '2-digit', minute: '2-digit'});
 const total = detail ? Math.round(detail.total) : (charged || amt);
 const g = form;
 const Row = ({k, v}: {k: string; v: React.ReactNode}) => <div className="prRow"><span>{k}</span><b>{v}</b></div>;

 return (
  <div className="payReceipt">
   <div className="prHead">
    <img src="./images/paradise-logo.png" alt="Hotel Paradise logo" onError={e => {e.currentTarget.style.display = 'none';}}/>
    <h3>HOTEL PARADISE ON THE NILE</h3>
    <p>Jinja, Uganda</p>
    <p>Tel: {HOTEL.phones[0] || CALL} &middot; Email: {HOTEL.email}</p>
   </div>
   <div className="prInfo">
    <Row k="Receipt No:" v={ref}/>
    <Row k="Date:" v={dateStr}/>
    <Row k="Time:" v={timeStr}/>
    <Row k="Customer:" v={g.name.trim() || '-'}/>
    <Row k="Phone:" v={normPhone(g.phone) || '-'}/>
    {g.email.trim() && <Row k="Email:" v={g.email.trim()}/>}
   </div>

   {detail?.booking ? (() => {
    const b = detail.booking;
    const bed = bedOf(b.room_type);
    return (
     <div className="prSec">
      <h4>ROOM BOOKING</h4>
      <p className="prItemName">{b.room_type}</p>
      {bed && <p className="prNote">Bed: {bed.beds} | Sleeps: {bed.guests}</p>}
      <p className="prNote">Check In: {whenText(b.check_in, b.check_in_time)}</p>
      <p className="prNote">Check Out: {whenText(b.check_out, b.check_out_time)}</p>
      <p className="prNote">Nights: {b.nights} | Guests: {b.adults} {b.adults === 1 ? 'adult' : 'adults'}{b.children ? ' + ' + b.children + ' ' + (b.children === 1 ? 'child' : 'children') : ''}</p>
     </div>
    );
   })() : detail?.order ? (() => {
    const o = detail.order;
    return (
     <div className="prSec">
      <h4>FOOD ORDER</h4>
      <p className="prNote">
       Outlet: {o.outlet === 'room_service' ? 'Room Service' : o.outlet === 'bar' ? 'Bar' : 'Restaurant'}{o.kind ? ' | ' + o.kind.replace(/_/g, ' ') : ''}
       <br/>Placed: {o.placed}
      </p>
      {o.items.map((it, i) => (
       <div className="prItem" key={i}>
        <b>{it.name}</b>
        <span>{it.qty} x {fmt(it.unit)} = {fmt(it.total)}</span>
        {it.note && <em>{it.note}</em>}
       </div>
      ))}
     </div>
    );
   })() : (
    <div className="prSec">
     <h4>{src === 'booking' ? 'ROOM BOOKING' : 'FOOD ORDER'}</h4>
     <div className="prItem"><b>{item || '-'}</b></div>
     {qty && <p className="prNote">Quantity: {qty}{unit === 'night' ? ' night' + (Number(qty) > 1 ? 's' : '') : unit === 'meal' ? ' dish' + (Number(qty) > 1 ? 'es' : '') : ''}</p>}
    </div>
   )}

   <div className="prTotals">
    {detail?.booking ? (() => {
     const b = detail.booking;
     return (<>
      <Row k="Room Subtotal:" v={fmt(b.subtotal)}/>
      {b.tax > 0 && <Row k="Service Charge (3.5%):" v={fmt(b.tax)}/>}
      {b.withdrawal_fee ? <Row k={(b.fee_label || 'Fee') + ':'} v={fmt(b.withdrawal_fee)}/> : null}
      <div className="prTotal"><span>TOTAL:</span><b>{fmt(detail.total)}</b></div>
      {detail.paid > 0 && <Row k="Already Paid:" v={'-' + fmt(detail.paid)}/>}
     </>);
    })() : detail?.order ? (() => {
     const o = detail.order;
     return (<>
      <Row k="Subtotal:" v={fmt(o.subtotal)}/>
      {o.tax > 0 && <Row k="Service Charge (3.5%):" v={fmt(o.tax)}/>}
      <div className="prTotal"><span>TOTAL:</span><b>{fmt(detail.total)}</b></div>
      {detail.paid > 0 && <Row k="Already Paid:" v={'-' + fmt(detail.paid)}/>}
     </>);
    })() : (
     <div className="prTotal"><span>TOTAL:</span><b>{fmt(total)}</b></div>
    )}
   </div>
   <p className="prFoot">Thank you for choosing Hotel Paradise on the Nile.<br/>This is your official receipt. {methodLabel ? methodLabel + ' · ' : ''}{HOTEL.website}</p>
  </div>
 );
}

function PayPage() {
 const q = new URLSearchParams(window.location.search);
 const src = q.get('src') === 'order' ? 'order' : q.get('src') === 'booking' ? 'booking' : '';
 const ref = q.get('ref') || '';
 const amt = Math.max(0, parseInt(q.get('amt') || '0', 10) || 0);
 const item = q.get('item') || '';
 const qty = q.get('qty') || '';
 const unit = q.get('unit') || '';

 const [form, setForm] = React.useState({name: q.get('name') || ls('hpn_name') || '', phone: q.get('phone') || ls('hpn_phone') || '', email: q.get('email') || ls('hpn_email') || ''});
 const [method, setMethod] = React.useState<MethodKey>('pesapal');
 const [momo, setMomo] = React.useState('');
 const [card, setCard] = React.useState({holder: '', number: '', exp: '', cvv: ''});
 const [busy, setBusy] = React.useState(false);
 const [err, setErr] = React.useState('');
  const [done, setDone] = React.useState<{reference: string; message: string; paid: boolean} | null>(null);

  const keep = (patch: object) => setForm(f => {
   const next = {...f, ...patch} as typeof f;
   try { window.localStorage.setItem('hpn_name', next.name); window.localStorage.setItem('hpn_phone', next.phone); window.localStorage.setItem('hpn_email', next.email); } catch {}
   return next;
  });
  const f = (k: 'name' | 'phone' | 'email') => ((e: React.ChangeEvent<HTMLInputElement>) => keep({[k]: e.target.value} as object));

  /**
   * Nobody reaches the till without an account.
   *
   * The account is what ties a payment to a guest, and its mobile number is
   * what the front desk confirms on, so this page sends a browser with no
   * account to the sign up and waits there rather than letting a receipt be
   * written against no one. The whole address it arrived with travels in the
   * query string, so it comes straight back here afterwards.
   */
  const token = customerToken();
  React.useEffect(() => {
   if (token) return;
   const back = window.location.pathname + window.location.search;
   window.location.replace('./account.html?next=' + encodeURIComponent(back));
  }, [token]);

  /**
   * The reference, read back from the hotel.
   *
   * Until it lands the page falls back to the amount in the url, which is what
   * the rooms or the menu page wrote there a moment ago; from then on it shows
   * what is actually owed, including anything already paid. A lookup that fails
   * on its own is not worth stopping for: the payment is priced on the server
   * either way.
   */
  const [detail, setDetail] = React.useState<PayDetail | null>(null);
  const [looking, setLooking] = React.useState(Boolean(src && ref));
  React.useEffect(() => {
   if (!src || !ref) { setLooking(false); return; }
   let alive = true;
   (async () => {
    try {
     const url = await apiUrl('checkout');
     const res = await fetch(`${url}&src=${encodeURIComponent(src)}&ref=${encodeURIComponent(ref)}`, {headers: {Accept: 'application/json'}});
     const d = await res.json();
     if (alive && d && d.ok) setDetail(d as PayDetail);
    } catch {
     /* the url amount stands until the hotel answers */
    }
    if (alive) setLooking(false);
   })();
   return () => { alive = false; };
  }, [src, ref]);

  const owed = detail ? Math.max(0, Math.round(detail.due)) : amt;
  const settled = Boolean(detail) && owed <= 0;
  const payable = settled ? 0 : owed;
  /** What the receipt will say, once it has been said. */
  const [charged, setCharged] = React.useState(0);

  const momoLabel = method === 'mtn_momo' ? 'MTN' : 'Airtel';

 const pay = async () => {
  setErr('');
  if (!src || !ref) { setErr('There is nothing to pay right now. Please start again from the rooms or the menu.'); return; }
  if (settled) { setErr('This reference has already been paid in full. Nothing further is due on it.'); return; }
  if (!form.name.trim()) { setErr('Please add the name that should appear on the receipt.'); return; }
  if (!normPhone(form.phone)) { setErr('Please add a phone number we can confirm the payment on.'); return; }
  if (method === 'mtn_momo' || method === 'airtel_money') {
   if (!validMomo(momo)) { setErr('Please enter a valid ' + momoLabel + ' mobile money number, for example 0700 000 000 or +256 700 000 000.'); return; }
  }
  if (method === 'card') {
   if (card.number.replace(/\D/g, '').length < 12) { setErr('Please enter a valid card number.'); return; }
   if (!validExp(card.exp)) { setErr('Please enter a valid expiry date, for example 09/28.'); return; }
   if (!/^\d{3,4}$/.test(card.cvv)) { setErr('Please enter the CVV from the back of the card.'); return; }
  }
  setBusy(true);
  try {
   const body = {
    source: src, reference: ref, name: form.name.trim(), phone: normPhone(form.phone), email: form.email.trim(),
    method, amount: payable,
    ...(token ? {token} : {})
   };
   const res = await fetch(await apiUrl('payment'), {method: 'POST', headers: {'Content-Type': 'application/json'}, body: JSON.stringify(body)});
   const d = await res.json();
   if (d.ok) {
    setCharged(typeof d.amount === 'number' ? Math.round(d.amount) : payable);
    // A receipt is only a receipt once the money is actually in. Until the
    // gateway marks the payment successful this is a request, so no receipt is
    // printed - the guest pays first, the receipt follows.
    const paid = String(d.status || '').toLowerCase() === 'successful' || d.paid === true;
    setDone({reference: String(d.reference || ref), message: String(d.message || 'The front desk will confirm your request on ' + form.phone + '.'), paid});
   } else {
    setErr(d.error || 'We could not take the payment right now. Please call ' + CALL + '.');
   }
  } catch {
   setErr('Could not reach the payment service. Please call ' + CALL + '.');
  }
  setBusy(false);
 };

  /**
   * The whole payment, written for WhatsApp.
   *
   * The hotel asked for one message that carries everything the front desk
   * needs to act on it: who paid, against which reference, every dish with its
   * price and any companion, or the room with its bed, dates and nights, then
   * the subtotal, the 3.5% and the total. Room bookings and food orders both
   * come through here, so a guest never has to explain the same payment twice.
   */
  const whatsappText = (): string => {
   const L: string[] = [];
   const say = (k: string, v: string | number) => { if (v !== '' && v !== null && v !== undefined) L.push(k + ': ' + v); };
   const money = (n: number) => fmt(n);

   L.push('HOTEL PARADISE ON THE NILE', 'Payment details', '');
   say('Guest', form.name.trim() || '-');
   say('Phone', normPhone(form.phone) || '-');
   if (form.email.trim()) say('Email', form.email.trim());
   say(src === 'booking' ? 'Booking' : 'Order', ref || '-');
   if (done && done.reference && done.reference !== ref) say('Payment ref', done.reference);
    say('Method', METHOD_TEXT[method] || method);
    say('Amount', money(charged || amt));
    say('Payment status', done ? (done.paid ? 'Paid - receipt issued' : 'Request received - the front desk confirms it on ' + (normPhone(form.phone) || 'the phone given')) : 'Details only - no money has been taken yet');
    L.push('');

   if (detail && detail.booking) {
    const b = detail.booking;
    const bed = bedOf(b.room_type);
    L.push('ROOM BOOKING');
    say('Room', b.room_type);
    if (bed) { say('Bed', bed.beds); say('Sleeps', bed.guests); }
    say('Check in', whenText(b.check_in, b.check_in_time));
    say('Check out', whenText(b.check_out, b.check_out_time));
    say('Nights', b.nights);
    say('Guests', b.adults + ' adult' + (b.adults === 1 ? '' : 's') + (b.children ? ' + ' + b.children + ' child' + (b.children === 1 ? '' : 'ren') : ''));
    L.push('');
    say('Room subtotal', money(b.subtotal));
    if (b.tax > 0) say('Service charge (3.5%)', money(b.tax));
    if (b.withdrawal_fee) say(b.fee_label, money(b.withdrawal_fee));
    say('Total', money(detail.total));
    L.push('');
   }

   if (detail && detail.order) {
    const o = detail.order;
    L.push('FOOD ORDER');
    say('Outlet', o.outlet === 'room_service' ? 'Room service' : o.outlet === 'bar' ? 'Bar' : 'Restaurant');
    if (o.kind) say('Kind', o.kind.replace(/_/g, ' '));
    say('Placed', o.placed);
    L.push('');
    o.items.forEach((it, i) => {
     L.push((i + 1) + '. ' + it.qty + ' x ' + it.name + '  ' + money(it.total) + (it.note ? '\n    ' + it.note : ''));
    });
    L.push('');
    say('Subtotal', money(o.subtotal));
    if (o.tax > 0) say('Service charge (3.5%)', money(o.tax));
    say('Total', money(detail.total));
    L.push('');
   }

   if (!detail) {
    L.push(src === 'booking' ? 'ROOM BOOKING' : 'FOOD ORDER');
    say(src === 'booking' ? 'Room' : 'Items', item || '-');
    if (qty) say('Quantity', qty + (unit === 'night' ? ' night' + (Number(qty) > 1 ? 's' : '') : unit === 'meal' ? ' dish' + (Number(qty) > 1 ? 'es' : '') : ''));
    say('Total', money(charged || amt));
    L.push('');
   }

   L.push('Sent from ' + HOTEL.website);
   return L.join('\n');
  };

  const waHref = 'https://wa.me/' + WA_HOTEL + '?text=' + encodeURIComponent(whatsappText());

  /**
   * Sending it to the hotel without being asked.
   *
   * The moment a request is accepted the whole payment opens in WhatsApp on
   * the number the hotel watches, because a payment the front desk cannot see
   * is not a payment yet. A browser is allowed to refuse a tab opened from
   * script, so the button that does exactly the same thing stays on the page
   * as the way that cannot be refused. This runs once, for food orders and for
   * room bookings alike.
   */
/**
   * No popups here. A window that opens itself mid-payment is blocked by
   * phones, so nothing tries: the moment the money is in, app/receipts.php
   * emails the guest their receipt, this page shows the same receipt below,
   * and the Print / Save as PDF button hands it to the phone's own print
   * dialog. The WhatsApp button underneath is the manual way to forward every
   * detail to the front desk.
   */

  if (!token) {
   return <div>
    <TopBar/>
    <PageNav/>
    <section className="payWrap" style={{paddingTop: 70, paddingBottom: 90}}>
     <div className="payCard" style={{maxWidth: 520, margin: '0 auto', textAlign: 'center'}}>
      <p className="eyebrow">SECURE CHECKOUT</p>
      <h3>One moment&hellip;</h3>
      <p className="plannerNote">Taking you to sign in. Your booking reference and amount are kept exactly as they are, and you come straight back here.</p>
     </div>
    </section>
    <Footer/>
   </div>;
  }

if (done) {
  return <div className="payPage">
   <TopBar/>
   <PageNav/>
   <section className="payWrap">
    <div className="payCard panned" style={{maxWidth: 620, margin: '0 auto', textAlign: 'center'}}>
     <div className="payCheck"><CheckIcon/></div>
     <p className="eyebrow">PAYMENT REQUEST RECEIVED</p>
     <h1 className="payThanks">Thank you, {form.name.trim().split(' ')[0] || 'friend'}.</h1>
     <p className="payDoneLine">Your <b>{src === 'booking' ? 'room booking ' : 'food order '}</b>for <b>{fmt(charged || amt)}</b> is with the hotel.</p>
     <div className="doneRef"><span>Your reference</span><b>{done.reference}</b></div>
     <p className="payDoneNote">{done.message}</p>
     {done.paid ? (
      <>
       <PayReceipt
        src={src} ref={done.reference || ref} charged={charged} amt={amt} form={form}
        detail={detail} item={item} qty={qty} unit={unit} methodLabel={METHOD_TEXT[method] || method}
       />
       <p className="payDoneNote2">This receipt has been emailed to {form.email.trim() || 'the address we have on file'} as well as shown here. To keep a copy, use the <b>Print / Save as PDF</b> button below and your phone will save it as a file.</p>
      </>
     ) : (
      <p className="payDoneNote2">Online payment with Pesapal is being switched on. Until it is live, the front desk confirms your payment, and your official receipt is emailed to you and appears here the moment it is confirmed.</p>
     )}
     <div className="payDoneActions">
       {done.paid && (
         <button className="btn" onClick={() => window.print()} style={{marginBottom:8}}>
           🖨️ Print / Save as PDF
         </button>
       )}
       <a className="btn waBtn" href={waHref} target="_blank" rel="noopener noreferrer">
        <WhatsAppIcon size={16}/> Send every detail to the hotel on WhatsApp
       </a>
       <a className="btn ghost2" href="./index.html">Back to the hotel</a>
       <a className="btn ghost2" href={telHref(CALL)}>Call the front desk</a>
     </div>
     <p className="payDoneNote2">WhatsApp carries your name, your reference, the amount, and the whole booking or order, dish by dish and room by room, to the front desk on {HOTEL.phones[0]}.</p>
    </div>
   </section>
   <Footer/>
  </div>;
 }

 return <div className="payPage">
  <TopBar/>
  <PageNav onDark/>

  <section className="pageHero canvas hasCover" id="main" style={{'--bg': bgUrl('./images/hero/pool-1920.webp')} as unknown as React.CSSProperties}>
   <div className="pageHeroInner">
   <BackLink label="Back" fallback="./index.html"/>
   <p className="eyebrow">SECURE CHECKOUT</p>
   <h1>Your details, then pay your way.</h1>
   <p>Review what you are paying for, add the name and phone number for the receipt, and choose how you would like to pay. Payment is handled by Pesapal, and no card details are ever stored on this website.</p>
   </div>
  </section>

  <section className="payWrap section" style={{paddingTop: 56}}>
   {!src || !ref ? (
    <div className="payCard panned" style={{maxWidth: 620, margin: '0 auto', textAlign: 'center'}}>
     <h3>Nothing to pay</h3>
     <p className="payDoneNote">This page finishes a booking or an order. Nothing has been carried here yet, so there is nothing to pay.</p>
     <div className="payDoneActions"><a className="btn" href="./rooms.html">Book a room</a><a className="btn ghost2" href="./menu.html">Order food</a></div>
    </div>
   ) : (
   <div className="payGrid">
    <div>
      <div className="payCard">
       <p className="eyebrow">YOUR REQUEST</p>
       <h3>{detail?.booking?.room_type || item || (src === 'booking' ? 'Room booking' : 'Food order')}</h3>
       {detail && <span className={'badge ' + statusTone(detail.status)} style={{marginTop: 10}}>{detail.status || 'Status'}</span>}
      <dl className="payLine">
       <div><dt>Reference</dt><dd>{ref}</dd></div>
       {detail?.booking && (
        <div><dt>Stay</dt><dd>{whenText(detail.booking.check_in, detail.booking.check_in_time)}<br/>{whenText(detail.booking.check_out, detail.booking.check_out_time)}</dd></div>
       )}
       {detail?.booking && (
        <div><dt>Guests</dt><dd>{detail.booking.adults} adult{detail.booking.adults === 1 ? '' : 's'}{detail.booking.children ? ' + ' + detail.booking.children + ' child' + (detail.booking.children === 1 ? '' : 'ren') : ''} &middot; {detail.booking.nights} night{detail.booking.nights === 1 ? '' : 's'}</dd></div>
       )}
       {detail?.order && (
        <div><dt>Order</dt><dd>{detail.order.outlet === 'room_service' ? 'Room service' : detail.order.outlet === 'bar' ? 'Bar order' : 'Restaurant'}{detail.order.kind ? ' · ' + detail.order.kind.replace('_', ' ') : ''}<br/>{detail.order.placed}</dd></div>
       )}
       {!detail && qty && (
        <div><dt>On this request</dt><dd>{qty}{unit === 'night' ? ' night' + (Number(qty) > 1 ? 's' : '') : unit === 'meal' ? ' dish' + (Number(qty) > 1 ? 'es' : '') : ''}</dd></div>
       )}
       <div><dt>Prepared for</dt><dd>{form.name.trim() || 'your name below'}</dd></div>
       {form.phone && <div><dt>Phone</dt><dd>{normPhone(form.phone)}</dd></div>}
      </dl>

      {detail?.order && detail.order.items.length > 0 && (
       <div className="payLines">
        {detail.order.items.map((l, i) => (
         <div className="payLineItem" key={i}>
          <SmartImage group="dishes" name={l.image || l.name} alt={l.name} ratio="4 / 3" widths={[160, 320]} sizes="56px"/>
          <span className="payLineText">
           <b>{l.name}</b>
           <small>{l.qty} &times; {fmt(l.unit)}{l.note ? ' · ' + l.note : ''}</small>
          </span>
          <span className="payLineSum">{fmt(l.total)}</span>
         </div>
        ))}
       </div>
      )}

      {detail?.booking && (
       <div className="payLines">
        <div className="payMoney"><span>Room{detail.booking.nights > 1 ? ' · ' + detail.booking.nights + ' nights' : ''}</span><b>{fmt(detail.booking.subtotal)}</b></div>
        {detail.booking.withdrawal_fee ? <div className="payMoney"><span>{detail.booking.fee_label}</span><b>{fmt(detail.booking.withdrawal_fee)}</b></div> : null}
        {detail.booking.tax > 0 && <div className="payMoney"><span>Service charge (3.5%)</span><b>{fmt(detail.booking.tax)}</b></div>}
        <div className="payMoney"><span>Total</span><b>{fmt(detail.total)}</b></div>
        {detail.paid > 0 && <div className="payMoney paidRow"><span>Already paid</span><b>&minus;{fmt(detail.paid)}</b></div>}
       </div>
      )}

      {detail?.order && (
       <div className="payLines">
        <div className="payMoney"><span>Subtotal</span><b>{fmt(detail.order.subtotal)}</b></div>
        {detail.order.tax > 0 && <div className="payMoney"><span>Service charge (3.5%)</span><b>{fmt(detail.order.tax)}</b></div>}
        <div className="payMoney"><span>Total</span><b>{fmt(detail.total)}</b></div>
        {detail.paid > 0 && <div className="payMoney paidRow"><span>Already paid</span><b>&minus;{fmt(detail.paid)}</b></div>}
       </div>
      )}

      {looking && <div className="payMoney" style={{color: '#7b8798'}}><span>Checking this reference with the hotel&hellip;</span></div>}

      <div className="payDue">
       <span>{settled ? 'Settled' : 'Amount to pay'}</span>
       <b className={settled ? 'clear' : ''}>{settled ? 'Paid in full' : fmt(payable)}</b>
      </div>

{settled && <div className="paySettled">
       <p style={{margin: 0}}>This reference is settled in full, so there is nothing left to pay on it. Your booking or order stays exactly as it is.</p>
       <p className="payDoneNote2" style={{margin: '8px 0 0'}}>Your official receipt is below, and a copy has been emailed to {form.email.trim() || 'the address we have on file'}.</p>
       <PayReceipt
        src={src} ref={ref} charged={charged} amt={amt} form={form}
        detail={detail} item={item} qty={qty} unit={unit} methodLabel={METHOD_TEXT[method] || method}
       />
        <div style={{display:'flex',gap:8,flexWrap:'wrap',justifyContent:'center',marginTop:10}}>
          <button className="btn" onClick={() => window.print()}>🖨️ Print / Save as PDF</button>
          <a className="btn waBtn" href={waHref} target="_blank" rel="noopener noreferrer"><WhatsAppIcon size={16}/> Send the details to the hotel on WhatsApp</a>
        </div>
      </div>}

      {detail && detail.payments.length > 0 && (
       <div className="payHistory">
        <p className="eyebrow" style={{margin: '0 0 6px'}}>RECORDED AGAINST THIS REFERENCE</p>
        {detail.payments.map((p, i) => (
         <div className="payHistoryRow" key={i}>
          <span>{METHOD_TEXT[p.method] || p.method}{p.when ? ' · ' + p.when : ''}</span>
          <b>{fmt(p.amount)} &middot; {p.status}</b>
         </div>
        ))}
       </div>
      )}

      <div className="payTrust"><LockIcon/><span>Secured by Pesapal. You can also pay this at the front desk with this reference.</span></div>
     </div>

     <div className="payCard paySteps">
      <p className="eyebrow">WHAT HAPPENS NEXT</p>
      <ol>
       <li>We confirm your {src === 'booking' ? 'room' : 'order'} by phone on {form.phone || 'the number you give'}.</li>
       <li>Pesapal sends a secure payment once online payments are live here.</li>
       <li>Until then, pay at the front desk in cash, by card or by mobile money.</li>
      </ol>
     </div>
    </div>

    <div className="payCard">
     <p className="eyebrow">1 &middot; YOUR DETAILS</p>
     <h3>Receipt details</h3>
     <div className="planField" style={{marginTop: 14}}><label>Full name</label><input value={form.name} onChange={f('name')} placeholder="Name as it should appear"/></div>
     <div className="payRow2">
      <div className="planField"><label>Phone</label><input value={form.phone} onChange={f('phone')} type="tel" placeholder="e.g. 0759504928"/></div>
      <div className="planField"><label>Email (optional)</label><input value={form.email} onChange={f('email')} type="email" placeholder="you@email.com"/></div>
     </div>

     <p className="eyebrow" style={{marginTop: 26}}>2 &middot; PAYMENT METHOD</p>
     <h3>How would you like to pay?</h3>
     <div className="payMethodList">
      {METHODS.map(m => (
       <button key={m.key} type="button" className={'payMethodRow' + (method === m.key ? ' sel' : '')} onClick={() => { setMethod(m.key); setErr(''); }}>
        <span className="payIcon"><Icon kind={m.icon}/></span>
        <span className="payMethodText">
         <b>{m.label}</b>
         <em>{m.hint}</em>
         {method === m.key && (m.key === 'mtn_momo' || m.key === 'airtel_money') && (
          <span className="paySub">
           <input value={momo} onChange={e => setMomo(e.target.value)} inputMode="tel" placeholder={momoLabel + ' number, e.g. 0700000000'} aria-label={momoLabel + ' mobile money number'}/>
          </span>
         )}
         {method === m.key && m.key === 'card' && (
          <span className="paySub cardGrid">
           <span className="payCardName"><input value={card.holder} onChange={e => setCard({...card, holder: e.target.value})} placeholder="Name on card"/></span>
           <span className="payCardNumber"><input value={card.number} onChange={e => setCard({...card, number: fmtCard(e.target.value)})} inputMode="numeric" placeholder="Card number" aria-label="Card number"/></span>
           <span><input value={card.exp} onChange={e => setCard({...card, exp: fmtExp(e.target.value)})} inputMode="numeric" placeholder="MM/YY" aria-label="Expiry month and year"/></span>
           <span><input value={card.cvv} onChange={e => setCard({...card, cvv: e.target.value.replace(/\D/g, '').slice(0, 4)})} inputMode="numeric" placeholder="CVV" type="password" aria-label="Card CVV"/></span>
          </span>
         )}
        </span>
        <span className="payRadio" aria-hidden="true"><i/></span>
       </button>
      ))}
     </div>

     {err && <div className="bookMsg" style={{marginTop: 16}}>{err}</div>}

       <button className={'btn planBook' + (busy ? ' loading' : '')} style={{marginTop: 22}} onClick={pay} disabled={busy || !payable}>
       {busy ? 'Contacting Pesapal...' : settled ? 'Already paid in full' : method === 'card' || method === 'pesapal' ? 'Pay ' + fmt(payable) : 'Pay ' + fmt(payable) + ' with ' + momoLabel + ' MoMo'}
      </button>
     <p className="plannerNote">Pesapal is the merchant of record for online payments. Reviewing your request does not charge you, and you are never charged twice. For help, call <a className="footLink" href={telHref(CALL)}>{CALL}</a> or email {HOTEL.email}.</p>
    </div>
   </div>
   )}
  </section>

  <Footer/>
 </div>;
}

createRoot(document.getElementById('root')!).render(<PayPage/>);
