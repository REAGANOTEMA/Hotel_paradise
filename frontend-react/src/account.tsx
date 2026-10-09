import React from 'react';
import {createRoot} from 'react-dom/client';
import './styles.css';
import {TopBar, PageNav, Footer, apiUrl, CALL, HOTEL, telHref, customerToken, setCustomer, forgetCustomer, LOGO, BackLink} from './shared';

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

/** The eye that shows and hides a password, stroked in the current colour. */
const EyeIcon = ({off}: {off?: boolean}) => (
 <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true">
  <path d="M1.5 12S5 5.5 12 5.5 22.5 12 22.5 12 19 18.5 12 18.5 1.5 12 1.5 12Z"/>
  <circle cx="12" cy="12" r="3"/>
  {off && <path d="M3 3l18 18"/>}
 </svg>
);

const post = async (payload: object): Promise<any> => {
  const res = await fetch(await apiUrl('account'), {
    method: 'POST',
    headers: {'Content-Type': 'application/json'},
    body: JSON.stringify(payload)
  });
  try { return await res.json(); } catch { return {ok: false, error: 'We could not reach the account service. Please call ' + CALL + '.'}; }
};

/** Only a path inside this site is ever sent to, never another host. */
const safeNext = (raw: string): string => {
  if (!raw) return '';
  if (raw.startsWith('//')) return '';
  if (raw.startsWith('./') || raw.startsWith('/')) return raw;
  return '';
};

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
  const btn = React.useRef<HTMLDivElement>(null);

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
    setCust(null); setRegToken(''); setNote(''); setErr('');
    setPassword(''); setPhone('');
    setMode('signin');
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

   <section className="pageHero canvas hasCover" id="main" style={{'--bg': "url('./images/hero/bed-executive-1920.webp')"} as unknown as React.CSSProperties}>
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
    <div className="payCard" style={{maxWidth: 480, margin: '0 auto'}}>

     <div className="acctBrand">
      <img src={LOGO} alt=""/>
      <div><b>Hotel Paradise</b><span>on the Nile &middot; Jinja</span></div>
     </div>

     {mode === 'account' && cust ? (
      <>
       <p className="eyebrow">SIGNED IN AS</p>
       <h3>{cust.name}</h3>
       <dl className="payLine">
        <div><dt>Email</dt><dd>{cust.email}</dd></div>
        <div><dt>Mobile</dt><dd>{cust.phone || 'not given yet'}</dd></div>
        <div><dt>Signed in with</dt><dd>{cust.google ? 'Google' : 'Email and password'}</dd></div>
       </dl>
       {next && <button className="btn planBook" onClick={() => window.location.replace(next)}>Continue to payment</button>}
       <div className="payDoneActions" style={{marginTop: 16}}>
        <a className="btn ghost2" href="./rooms.html">Book a room</a>
        <a className="btn ghost2" href="./menu.html">Order food</a>
       </div>
       <button className="btn ghost2 planBook" style={{marginTop: 12}} onClick={signOut}>Sign out</button>
       <p className="plannerNote">Need to change anything? Call <a className="footLink" href={telHref(CALL)}>{CALL}</a> or email {HOTEL.email}.</p>
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
        {mode === 'signup'
          ? <>Already have an account? <a className="footLink" href="./account.html">Sign in</a>.</>
          : <>New here? <a className="footLink" href="./account.html?mode=signup">Create an account</a>.</>}
        <br/>{next ? 'You will come straight back to your payment when this is done.' : <>For help, call <a className="footLink" href={telHref(CALL)}>{CALL}</a>.</>}
       </p>
      </>
     )}
    </div>
   </section>

   <Footer/>
  </div>;
}

createRoot(document.getElementById('root')!).render(<AccountPage/>);
