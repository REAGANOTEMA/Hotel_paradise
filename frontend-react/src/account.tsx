import React from 'react';
import {createRoot} from 'react-dom/client';
import './styles.css';
import {ExploreMore, TopBar, PageNav, Footer, apiUrl, CALL, HOTEL, telHref, customerToken, setCustomer, forgetCustomer, LOGO, BackLink, bgUrl} from './shared';

/*
 * The guest's own account.
 *
 * Two ways in, one shape at the end. An email address with a password, or a
 * Google account; both then ask for the mobile number, because that is the one
 * thing the hotel confirms a booking and a payment on, and neither way of
 * signing in can supply it. Until the number is given nothing is usable, so the
 * page has exactly one thing to ask for at each step.
 *
 * The token that comes back is a random string the server cannot reconstruct,
 * kept in this browser only. It is never a password and never a session id.
 */

type Mode = 'checking' | 'signin' | 'signup' | 'phone' | 'account';
type Customer = {id: number; name: string; email: string; phone: string; google: boolean};

/** The fields a hotel keeps on a returning guest, as the API returns them. */
type Profile = {
  date_of_birth: string; gender: string; nationality: string; national_id: string;
  address: string; city: string; country: string; postcode: string; company: string;
  job_title: string; preferred_language: string; dietary_preferences: string;
  room_preferences: string; emergency_contact_name: string; emergency_contact_phone: string;
  notes: string; marketing_opt_in: boolean; has_avatar: boolean;
};

const emptyProfile = (): Profile => ({
  date_of_birth: '', gender: '', nationality: '', national_id: '', address: '', city: '',
  country: '', postcode: '', company: '', job_title: '', preferred_language: '',
  dietary_preferences: '', room_preferences: '', emergency_contact_name: '',
  emergency_contact_phone: '', notes: '', marketing_opt_in: false, has_avatar: false
});

type Booking = {reference: string; status: string; check_in: string; check_out: string; nights: number; total: number; paid: number};
type Order = {reference: string; outlet: string; kind: string; status: string; total: number; when: string};
type Payment = {reference: string; amount: number; method: string; status: string; when: string};
type Activity = {bookings: Booking[]; orders: Order[]; payments: Payment[]};

/** The eye that shows and hides a password, stroked in the current colour. */
const EyeIcon = ({off}: {off?: boolean}) => (
 <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true">
  <path d="M1.5 12S5 5.5 12 5.5 22.5 12 22.5 12 19 18.5 12 18.5 1.5 12 1.5 12Z"/>
  <circle cx="12" cy="12" r="3"/>
  {off && <path d="M3 3l18 18"/>}
 </svg>
);

const post = async (payload: object): Promise<any> => {
  try {
    const res = await fetch(await apiUrl('account'), {
      method: 'POST',
      headers: {'Content-Type': 'application/json'},
      body: JSON.stringify(payload)
    });
    return await res.json();
  } catch {
    return {ok: false, error: 'We could not reach the account service. Please call ' + CALL + '.'};
  }
};

/** Only a path inside this site is ever sent to, never another host. */
const safeNext = (raw: string): string => {
  if (!raw) return '';
  if (raw.startsWith('//')) return '';
  if (raw.startsWith('./') || raw.startsWith('/')) return raw;
  return '';
};

/*
 * A guest's photograph, made small before it ever leaves the browser.
 *
 * A phone camera picture is several megabytes, which is slow to send and much
 * larger than anything a profile avatar needs. It is drawn onto a canvas at a
 * modest size and written back as a compact JPEG, so the upload is quick, the
 * file the hotel keeps is small, and nothing is ever refused for being too big.
 */
const shrinkImage = (file: File): Promise<string> =>
  new Promise((resolve, reject) => {
    const objectUrl = URL.createObjectURL(file);
    const img = new Image();
    img.onload = () => {
      try {
        const max = 512;
        let width = img.naturalWidth || img.width;
        let height = img.naturalHeight || img.height;
        if (!width || !height) throw new Error('empty');
        if (width > max || height > max) {
          const scale = max / Math.max(width, height);
          width = Math.max(1, Math.round(width * scale));
          height = Math.max(1, Math.round(height * scale));
        }
        const canvas = document.createElement('canvas');
        canvas.width = width;
        canvas.height = height;
        const ctx = canvas.getContext('2d');
        if (!ctx) throw new Error('no canvas');
        ctx.fillStyle = '#ffffff';
        ctx.fillRect(0, 0, width, height);
        ctx.drawImage(img, 0, 0, width, height);
        resolve(canvas.toDataURL('image/jpeg', 0.82));
      } catch (e) {
        reject(e);
      } finally {
        URL.revokeObjectURL(objectUrl);
      }
    };
    img.onerror = () => { URL.revokeObjectURL(objectUrl); reject(new Error('read')); };
    img.src = objectUrl;
  });

function AccountPage() {
  const q = new URLSearchParams(window.location.search);
  const next = safeNext(q.get('next') || '');

  const [mode, setMode] = React.useState<Mode>(q.get('mode') === 'signup' ? 'signup' : 'checking');
  const [name, setName] = React.useState('');
  const [email, setEmail] = React.useState('');
  const [password, setPassword] = React.useState('');
  const [phone, setPhone] = React.useState('');
  const [regToken, setRegToken] = React.useState('');
  const [cust, setCust] = React.useState<Customer | null>(null);
  const [busy, setBusy] = React.useState(false);
  const [err, setErr] = React.useState('');
  const [note, setNote] = React.useState('');
  const [googleId, setGoogleId] = React.useState('');
  const [showPw, setShowPw] = React.useState(false);
  const [prof, setProf] = React.useState<Profile>(emptyProfile());
  const [photo, setPhoto] = React.useState('');
  const [avatarUrl, setAvatarUrl] = React.useState('');
  const [saved, setSaved] = React.useState('');
  const [more, setMore] = React.useState(false);
  const [act, setAct] = React.useState<Activity | null>(null);
  const fileRef = React.useRef<HTMLInputElement>(null);
  const btn = React.useRef<HTMLDivElement>(null);

  /** The address of the guest's own photograph, which only their token opens. */
  const avatarSrc = async (token: string) => `${await apiUrl('avatar')}&token=${encodeURIComponent(token)}`;

  const takeProfile = (p: any) => {
    const next = emptyProfile();
    if (p && typeof p === 'object') {
      (Object.keys(next) as (keyof Profile)[]).forEach(k => {
        if (k === 'marketing_opt_in') next.marketing_opt_in = !!(p.marketing_opt_in);
        else if (k === 'has_avatar') next.has_avatar = !!(p.has_avatar);
        else (next as any)[k] = String(p[k] ?? '');
      });
    }
    setProf(next);
    return next;
  };

  // Who is already signed in on this browser?
  React.useEffect(() => {
    let live = true;
    (async () => {
      const token = customerToken();
      if (!token) { if (live) setMode(q.get('mode') === 'signup' ? 'signup' : 'signin'); return; }
      const d = await post({action: 'me', token});
      if (!live) return;
      if (d.ok && d.customer) {
        setCust(d.customer);
        setName(d.customer.name || '');
        setEmail(d.customer.email || '');
        setPhone(d.customer.phone || '');
        const p = takeProfile(d.profile);
        if (p.has_avatar) setAvatarUrl(await avatarSrc(token));
        setMode('account');
      } else {
        forgetCustomer();
        setMode('signin');
      }
    })();
    return () => { live = false; };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  // Does this installation have Google sign in switched on?
  React.useEffect(() => {
    let live = true;
    (async () => {
      const d = await post({action: 'config'});
      if (live && d && d.ok) setGoogleId(String(d.google_client_id || ''));
    })();
    return () => { live = false; };
  }, []);

  const arrive = (tok: string, c: Customer) => {
    setCustomer(tok, c.name);
    setCust(c);
    if (next) { window.location.replace(next); return; }
    setMode('account');
  };

  const useGoogleCredential = async (credential: string) => {
    setErr(''); setBusy(true);
    const d = await post({action: 'google', credential});
    setBusy(false);
    if (!d.ok) { setErr(d.error || 'Google could not sign you in. Please try your email instead.'); return; }
    if (d.step === 'phone') {
      setRegToken(String(d.register_token || ''));
      setName(d.name || ''); setEmail(d.email || '');
      setNote(String(d.message || ''));
      setMode('phone');
      return;
    }
    arrive(String(d.token || ''), d.customer);
  };

  // Google's own button, drawn once the library has arrived.
  React.useEffect(() => {
    if (!googleId || mode === 'checking' || mode === 'phone' || mode === 'account') return;
    const draw = () => {
      const g = (window as any).google;
      if (!g || !g.accounts || !g.accounts.id || !btn.current) return;
      g.accounts.id.initialize({
        client_id: googleId,
        callback: (res: any) => useGoogleCredential(String(res.credential || ''))
      });
      btn.current.innerHTML = '';
      g.accounts.id.renderButton(btn.current, {theme: 'outline', size: 'large', width: 300, text: mode === 'signup' ? 'signup_with' : 'signin_with'});
    };
    const existing = document.getElementById('google-gsi');
    if (existing) { draw(); return; }
    const s = document.createElement('script');
    s.id = 'google-gsi'; s.src = 'https://accounts.google.com/gsi/client'; s.async = true;
    s.onload = draw;
    s.onerror = () => setErr('Google sign in could not be loaded. Please use your email address instead.');
    document.head.appendChild(s);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [googleId, mode]);

  const submit = async (action: string) => {
    setErr(''); setBusy(true);
    let payload: object = {action};
    if (action === 'signup') payload = {...payload, name: name.trim(), email: email.trim(), password};
    if (action === 'signin') payload = {...payload, email: email.trim(), password};
    if (action === 'phone') payload = {...payload, register_token: regToken, phone: phone.trim()};
    const d = await post(payload);
    setBusy(false);
    if (!d.ok) { setErr(d.error || 'Something went wrong. Please try again.'); return; }

    if (action === 'phone') { arrive(String(d.token || ''), d.customer); return; }

    setRegToken(String(d.register_token || ''));
    if (d.step === 'phone') { setNote(String(d.message || '')); setMode('phone'); return; }
    arrive(String(d.token || ''), d.customer);
  };

  const signOut = async () => {
    const token = customerToken();
    forgetCustomer();
    try { await post({action: 'logout', token}); } catch {}
    setCust(null); setRegToken(''); setNote(''); setErr(''); setSaved('');
    setPassword(''); setPhone(''); setPhoto(''); setAvatarUrl(''); setAct(null);
    setMode('signin');
  };

  const loadActivity = async () => {
    const token = customerToken();
    if (!token) return;
    const d = await post({action: 'activity', token});
    if (d.ok) setAct({bookings: d.bookings || [], orders: d.orders || [], payments: d.payments || []});
  };

  // The guest's own bookings and orders are loaded once the account is open.
  React.useEffect(() => {
    if (mode === 'account') loadActivity();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [mode]);

  const setF = (k: keyof Profile, v: any) => setProf(p => ({...p, [k]: v}));

  /**
   * The picture is shrunk in the browser, shown immediately, and saved at once,
   * so choosing a photo is the whole job: one tap, and it is on the profile.
   */
  const onPhoto = async (file?: File) => {
    setErr(''); setSaved('');
    if (!file) return;
    if (!/^image\//.test(file.type)) { setErr('Please choose a picture (JPG, PNG, GIF or WebP).'); return; }
    if (file.size > 15 * 1024 * 1024) { setErr('That picture is very large. Please choose one under 15MB.'); return; }
    setBusy(true);
    let data = '';
    try {
      data = await shrinkImage(file);
    } catch {
      setBusy(false);
      setErr('That picture could not be read. Please choose another one.');
      return;
    }
    setPhoto(data);
    setAvatarUrl(data);
    await saveProfile(data);
  };

  const saveProfile = async (photoOverride?: string) => {
    setErr(''); setSaved(''); setBusy(true);
    const payload: any = {
      action: 'update', token: customerToken(),
      name: name.trim(), phone: phone.trim(),
      date_of_birth: prof.date_of_birth, gender: prof.gender, nationality: prof.nationality,
      national_id: prof.national_id, address: prof.address, city: prof.city, country: prof.country,
      postcode: prof.postcode, company: prof.company, job_title: prof.job_title,
      preferred_language: prof.preferred_language, dietary_preferences: prof.dietary_preferences,
      room_preferences: prof.room_preferences, emergency_contact_name: prof.emergency_contact_name,
      emergency_contact_phone: prof.emergency_contact_phone, notes: prof.notes,
      marketing_opt_in: prof.marketing_opt_in
    };
    const pic = photoOverride ?? photo;
    if (pic) payload.photo = pic;
    const d = await post(payload);
    setBusy(false);
    if (!d.ok) { setErr(d.error || 'Your profile could not be saved. Please try again.'); return; }
    setCust(d.customer);
    setName(d.customer.name || '');
    setPhone(d.customer.phone || '');
    const p = takeProfile(d.profile);
    setPhoto('');
    if (p.has_avatar) { const t = customerToken(); if (t) setAvatarUrl(await avatarSrc(t) + '&v=' + Date.now()); }
    setSaved('Your profile has been saved.');
    loadActivity();
  };

  if (mode === 'checking') {
    return <div><TopBar/><PageNav/>
      <section className="payWrap" style={{paddingTop: 70, paddingBottom: 90}}>
        <div className="payCard" style={{maxWidth: 520, margin: '0 auto', textAlign: 'center'}}>
          <p className="eyebrow">YOUR ACCOUNT</p>
          <h3>One moment…</h3>
          <p className="plannerNote">Checking whether you are already signed in on this browser.</p>
        </div>
      </section>
      <Footer/>
    </div>;
  }

  const heading = mode === 'phone' ? 'Your mobile number'
    : mode === 'signup' ? 'Create your account'
    : mode === 'account' ? 'Your account'
    : 'Sign in';

  return <div>
   <TopBar/>
   <PageNav onDark/>

   <section className="pageHero canvas hasCover" id="main" style={{'--bg': bgUrl('./images/hero/bed-executive-1920.webp')} as unknown as React.CSSProperties}>
    <div className="pageHeroInner">
    <BackLink label="Back" fallback="./index.html"/>
    <p className="eyebrow">YOUR ACCOUNT</p>
    <h1>{heading}</h1>
    <p>{mode === 'phone'
      ? 'The last thing we need. The hotel confirms your room, your order and your payment on this number.'
      : mode === 'account'
        ? 'Your details are kept here so a booking or an order does not ask for them twice.'
        : 'One account for room bookings and food orders. Sign in with Google, or with an email address and a password.'}</p>
    </div>
   </section>

   <section className="payWrap" style={{paddingTop: 56}}>
    <div className="payCard" style={{maxWidth: mode === 'account' ? 720 : 480, margin: '0 auto'}}>

     <div className="acctBrand">
      <img src={LOGO} alt=""/>
      <div><b>Hotel Paradise</b><span>on the Nile &middot; Jinja</span></div>
     </div>

     {mode === 'account' && cust ? (
      <>
       <div className="acctHead">
        <div className={'acctAvatar' + (avatarUrl ? ' hasImg' : '')}>
         {avatarUrl ? <img src={avatarUrl} alt={`${cust.name}'s photo`}/> : <span>{(cust.name || 'G').trim().charAt(0).toUpperCase()}</span>}
        </div>
        <div className="acctHeadText">
         <p className="eyebrow">SIGNED IN AS</p>
         <h3>{cust.name}</h3>
         <p className="plannerNote">{cust.email}{cust.phone ? ' · ' + cust.phone : ''} · {cust.google ? 'Google' : 'Email and password'}</p>
        </div>
       </div>

       <input ref={fileRef} type="file" accept="image/png,image/jpeg,image/webp,image/gif" hidden
        onChange={e => onPhoto(e.target.files ? e.target.files[0] : undefined)}/>
       <div className="acctPhotoActions">
        <button type="button" className="btn ghost2" onClick={() => fileRef.current && fileRef.current.click()} disabled={busy}>
         {avatarUrl ? 'Change photo' : 'Add your photo'}
        </button>
        {busy && photo && <span className="acctHintPhoto">Saving your photo…</span>}
       </div>

       <form className="acctForm" onSubmit={e => { e.preventDefault(); saveProfile(); }}>
        <p className="acctSection">Your details</p>
        <div className="acctGrid">
         <div className="planField acctWide"><label>Full name</label><input value={name} onChange={e => setName(e.target.value)} autoComplete="name"/></div>
         <div className="planField"><label>Mobile number</label><input value={phone} onChange={e => setPhone(e.target.value)} type="tel" inputMode="tel" placeholder="0759 504 928" autoComplete="tel"/></div>
         <div className="planField"><label>Email</label><input value={cust.email} readOnly/></div>
         <div className="planField"><label>Date of birth</label><input type="date" value={prof.date_of_birth} onChange={e => setF('date_of_birth', e.target.value)}/></div>
         <div className="planField"><label>Nationality</label><input value={prof.nationality} onChange={e => setF('nationality', e.target.value)} placeholder="Ugandan"/></div>
        </div>

        <button type="button" className="acctMore" aria-expanded={more} onClick={() => setMore(v => !v)}>
         {more ? 'Hide extra details' : 'Add extra details (optional)'}
         <span className="acctMoreSign" aria-hidden="true">{more ? '−' : '+'}</span>
        </button>

        {more && (
         <>
          <div className="acctGrid">
           <div className="planField"><label>Gender</label>
            <select value={prof.gender} onChange={e => setF('gender', e.target.value)}>
             <option value="">Prefer not to say</option>
             <option value="male">Male</option>
             <option value="female">Female</option>
             <option value="other">Other</option>
             <option value="prefer_not_to_say">Prefer not to say</option>
            </select>
           </div>
           <div className="planField"><label>ID or passport</label><input value={prof.national_id} onChange={e => setF('national_id', e.target.value)}/></div>
           <div className="planField"><label>Company</label><input value={prof.company} onChange={e => setF('company', e.target.value)}/></div>
           <div className="planField"><label>Job title</label><input value={prof.job_title} onChange={e => setF('job_title', e.target.value)}/></div>
           <div className="planField"><label>City or town</label><input value={prof.city} onChange={e => setF('city', e.target.value)} placeholder="Jinja"/></div>
           <div className="planField"><label>Country</label><input value={prof.country} onChange={e => setF('country', e.target.value)} placeholder="Uganda"/></div>
           <div className="planField acctWide"><label>Address</label><input value={prof.address} onChange={e => setF('address', e.target.value)} autoComplete="street-address" placeholder="Plot, street, area"/></div>
           <div className="planField"><label>Preferred language</label><input value={prof.preferred_language} onChange={e => setF('preferred_language', e.target.value)} placeholder="English"/></div>
           <div className="planField"><label>Room preference</label><input value={prof.room_preferences} onChange={e => setF('room_preferences', e.target.value)} placeholder="High floor, quiet side"/></div>
           <div className="planField acctWide"><label>Dietary needs</label><input value={prof.dietary_preferences} onChange={e => setF('dietary_preferences', e.target.value)} placeholder="Allergies or dishes to avoid"/></div>
           <div className="planField acctWide"><label>Anything else we should know</label><input value={prof.notes} onChange={e => setF('notes', e.target.value)} placeholder="Celebrations, mobility needs, arrival time"/></div>
           <div className="planField"><label>Emergency contact name</label><input value={prof.emergency_contact_name} onChange={e => setF('emergency_contact_name', e.target.value)}/></div>
           <div className="planField"><label>Emergency contact phone</label><input value={prof.emergency_contact_phone} onChange={e => setF('emergency_contact_phone', e.target.value)} type="tel" inputMode="tel"/></div>
          </div>
          <label className="acctCheck">
           <input type="checkbox" checked={prof.marketing_opt_in} onChange={e => setF('marketing_opt_in', e.target.checked)}/>
           <span>Send me offers, news and updates from Hotel Paradise</span>
          </label>
         </>
        )}

        {err && <div className="bookMsg" style={{marginTop: 14}}>{err}</div>}
        {saved && <div className="bookMsg ok" style={{marginTop: 14}}>{saved}</div>}

        <button className={'btn planBook' + (busy ? ' loading' : '')} type="submit" disabled={busy}>{busy ? 'Saving…' : 'Save my profile'}</button>
       </form>

       <p className="acctSection">Your stays &amp; orders</p>
       {act && (act.bookings.length || act.orders.length || act.payments.length) ? (
        <div className="acctAct">
         {act.bookings.map(b => (
          <div className="acctActRow" key={'b' + b.reference}>
           <b>Room {b.reference}</b>
           <span>{b.check_in} → {b.check_out} · {b.nights} night{b.nights === 1 ? '' : 's'} · {b.status}</span>
           <em>UGX {Math.round(b.total).toLocaleString()}</em>
          </div>
         ))}
         {act.orders.map(o => (
          <div className="acctActRow" key={'o' + o.reference}>
           <b>Order {o.reference}</b>
           <span>{(o.outlet || o.kind || 'Restaurant') + (o.when ? ' · ' + o.when : '')} · {o.status}</span>
           <em>UGX {Math.round(o.total).toLocaleString()}</em>
          </div>
         ))}
        </div>
       ) : (
        <p className="plannerNote">No bookings or orders yet. When you book a room or order food with this email or number, they will appear here.</p>
       )}

       {next && <button className="btn planBook" style={{marginTop: 16}} onClick={() => window.location.replace(next)}>Continue</button>}
       <div className="payDoneActions" style={{marginTop: 16}}>
        <a className="btn ghost2" href="./rooms.html">Book a room</a>
        <a className="btn ghost2" href="./menu.html">Order food</a>
        <a className="btn ghost2" href="./news.html">News &amp; careers</a>
       </div>
       <button className="btn ghost2 planBook" style={{marginTop: 12}} onClick={signOut}>Sign out</button>
       <p className="plannerNote">Need to change anything urgent? Call <a className="footLink" href={telHref(CALL)}>{CALL}</a> or email {HOTEL.email}.</p>
      </>
     ) : mode === 'phone' ? (
      <form onSubmit={e => { e.preventDefault(); submit('phone'); }}>
       <p className="eyebrow">STEP 2 OF 2</p>
       <h3>Add your mobile number</h3>
       {note && <div className="bookMsg ok" style={{marginTop: 14}}>{note}</div>}
       <div className="planField" style={{marginTop: 16}}>
        <label>Mobile number</label>
        <input value={phone} onChange={e => setPhone(e.target.value)} type="tel" inputMode="tel" autoFocus placeholder="e.g. 0759 504 928"/>
       </div>
       {err && <div className="bookMsg" style={{marginTop: 14}}>{err}</div>}
        <button className={'btn planBook' + (busy ? ' loading' : '')} type="submit" disabled={busy}>{busy ? 'Saving…' : 'Finish and continue'}</button>
       <p className="plannerNote">Ugandan mobile numbers look like 0759 504 928 or +256 759 504 928. We use it to confirm your booking and your payment, and nothing else.</p>
      </form>
     ) : (
      <>
       <p className="eyebrow">{mode === 'signup' ? 'STEP 1 OF 2 · EMAIL' : 'WELCOME BACK'}</p>
       <h3>{mode === 'signup' ? 'Where should we reach you?' : 'Sign in to your account'}</h3>

       <form onSubmit={e => { e.preventDefault(); submit(mode === 'signup' ? 'signup' : 'signin'); }}>
        {mode === 'signup' && (
         <div className="planField" style={{marginTop: 16}}>
          <label>Full name</label>
          <input value={name} onChange={e => setName(e.target.value)} autoComplete="name" placeholder="Name as it appears on your booking"/>
         </div>
        )}
        <div className="planField" style={{marginTop: 16}}>
         <label>Email address</label>
         <input value={email} onChange={e => setEmail(e.target.value)} type="email" autoComplete="email" placeholder="you@email.com"/>
        </div>
        <div className="planField pwdField" style={{marginTop: 14}}>
         <label>Password</label>
         <input value={password} onChange={e => setPassword(e.target.value)} type={showPw ? 'text' : 'password'} autoComplete={mode === 'signup' ? 'new-password' : 'current-password'} placeholder={mode === 'signup' ? 'At least 8 characters' : 'Your password'}/>
         <button type="button" className="pwdToggle" onClick={() => setShowPw(v => !v)} aria-label={showPw ? 'Hide password' : 'Show password'} title={showPw ? 'Hide password' : 'Show password'}>
          <EyeIcon off={!showPw}/>
         </button>
        </div>

        {err && <div className="bookMsg" style={{marginTop: 14}}>{err}</div>}
        {note && <div className="bookMsg ok" style={{marginTop: 14}}>{note}</div>}

        <button className={'btn planBook' + (busy ? ' loading' : '')} type="submit" disabled={busy}>
         {busy ? 'One moment…' : mode === 'signup' ? 'Continue' : 'Sign in'}
        </button>
       </form>

       {googleId && <>
        <div className="acctOr"><span>or</span></div>
        <div ref={btn} style={{display: 'flex', justifyContent: 'center'}}/>
       </>}

       <p className="plannerNote">
        <span className="acctPrompt">
         {mode === 'signup'
           ? <>Already have an account? <a className="footLink" href="./account.html">Sign in</a>.</>
           : <>New here? <a className="footLink" href="./account.html?mode=signup">Create an account</a>.</>}
        </span>
        {next ? 'You will come straight back to finish where you left off.' : <>For help, call <a className="footLink" href={telHref(CALL)}>{CALL}</a>.</>}
       </p>
      </>
     )}
    </div>
   </section>

   <ExploreMore current="account"/>

   <Footer/>
  </div>;
 }

createRoot(document.getElementById('root')!).render(<AccountPage/>);
