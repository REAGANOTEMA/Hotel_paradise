import React from 'react';
import {createRoot} from 'react-dom/client';
import './styles.css';
import {TopBar, PageNav, Footer, fmt, apiUrl, CALL, HOTEL, telHref} from './shared';

/*
 * Secure checkout. The room booking and the kitchen order both land here with
 * their reference and total in the URL. The guest adds the details the receipt
 * needs, picks a payment method and pays. Pesapal is the gateway; the merchant
 * keys are still pending, so for now the payment is recorded as pending and the
 * front desk confirms it. The moment Pesapal is switched on, this page sends the
 * guest to Pesapal's secure page and the same payment row receives the callback.
 */

type MethodKey = 'pesapal' | 'mtn_momo' | 'airtel_money' | 'card';

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
 const [done, setDone] = React.useState<{reference: string; message: string} | null>(null);

 const keep = (patch: object) => setForm(f => {
  const next = {...f, ...patch} as typeof f;
  try { window.localStorage.setItem('hpn_name', next.name); window.localStorage.setItem('hpn_phone', next.phone); window.localStorage.setItem('hpn_email', next.email); } catch {}
  return next;
 });
 const f = (k: 'name' | 'phone' | 'email') => ((e: React.ChangeEvent<HTMLInputElement>) => keep({[k]: e.target.value} as object));

 const momoLabel = method === 'mtn_momo' ? 'MTN' : 'Airtel';

 const pay = async () => {
  setErr('');
  if (!src || !ref) { setErr('There is nothing to pay right now. Please start again from the rooms or the menu.'); return; }
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
    method, amount: Number(amt || 0)
   };
   const res = await fetch(await apiUrl('payment'), {method: 'POST', headers: {'Content-Type': 'application/json'}, body: JSON.stringify(body)});
   const d = await res.json();
   if (d.ok) {
    setDone({reference: String(d.reference || ref), message: String(d.message || 'The front desk will confirm your request on ' + form.phone + '.')});
   } else {
    setErr(d.error || 'We could not take the payment right now. Please call ' + CALL + '.');
   }
  } catch {
   setErr('Could not reach the payment service. Please call ' + CALL + '.');
  }
  setBusy(false);
 };

 if (done) {
  return <div>
   <TopBar/>
   <PageNav/>
   <section className="payWrap">
    <div className="payCard panned" style={{maxWidth: 620, margin: '0 auto', textAlign: 'center'}}>
     <div className="payCheck"><CheckIcon/></div>
     <p className="eyebrow">PAYMENT REQUEST RECEIVED</p>
     <h1 className="payThanks">Thank you, {form.name.trim().split(' ')[0] || 'friend'}.</h1>
     <p className="payDoneLine">Your <b>{src === 'booking' ? 'room booking ' : 'food order '}</b>for <b>{fmt(amt)}</b> is with the hotel.</p>
     <div className="doneRef"><span>Your reference</span><b>{done.reference}</b></div>
     <p className="payDoneNote">{done.message}</p>
     <p className="payDoneNote2">Online payment with Pesapal is being switched on. Until it is live, no money is charged on this page and you are welcome to pay at the front desk, or call <a className="footLink" href={telHref(CALL)}>{CALL}</a>.</p>
     <div className="payDoneActions">
      <a className="btn" href="./index.html">Back to the hotel</a>
      <a className="btn ghost2" href={telHref(CALL)}>Call the front desk</a>
     </div>
    </div>
   </section>
   <Footer/>
  </div>;
 }

 return <div>
  <TopBar/>
  <PageNav/>

  <section className="pageHero">
   <p className="eyebrow">SECURE CHECKOUT</p>
   <h1>Your details, then pay your way.</h1>
   <p>Review what you are paying for, add the name and phone number for the receipt, and choose how you would like to pay. Payment is handled by Pesapal, and no card details are ever stored on this website.</p>
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
      <h3>{item || (src === 'booking' ? 'Room booking' : 'Food order')}</h3>
      <dl className="payLine">
       <div><dt>Reference</dt><dd>{ref}</dd></div>
       {qty && <div><dt>On this request</dt><dd>{qty}{unit === 'night' ? ' night' + (Number(qty) > 1 ? 's' : '') : unit === 'meal' ? ' dish' + (Number(qty) > 1 ? 'es' : '') : ''}</dd></div>}
       <div><dt>Prepared for</dt><dd>{form.name.trim() || 'your name below'}</dd></div>
       {form.phone && <div><dt>Phone</dt><dd>{normPhone(form.phone)}</dd></div>}
      </dl>
      <div className="payTotal"><span>Amount to pay</span><b>{fmt(amt)}</b></div>
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

     <button className="btn planBook" style={{marginTop: 22}} onClick={pay} disabled={busy || !amt}>
      {busy ? 'Contacting Pesapal...' : method === 'card' || method === 'pesapal' ? 'Pay ' + fmt(amt) : 'Pay ' + fmt(amt) + ' with ' + momoLabel + ' MoMo'}
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