import React from 'react';

/**
 * Where the PHP API actually is.
 *
 * The site has been installed in more than one place: at the root of a domain
 * and inside a subdirectory. Guessing one of them and being wrong on the other
 * host is how a working site ends up silently serving its baked-in menu while
 * every order fails. So the plausible places are tried once, in order, and the
 * first one that answers is kept for the rest of the visit.
 */
let apiBase: string | null = null;

const apiCandidates = (): string[] => {
  const here = new URL('.', window.location.href).pathname.replace(/\/+$/, '');
  return [...new Set([
    `${here}/backend-php/api.php`,
    '/backend-php/api.php',
    '/hotelparadiseonthenile/backend-php/api.php',
  ])];
};

export const apiUrl = async (act: string): Promise<string> => {
  if (apiBase === null) {
    for (const candidate of apiCandidates()) {
      try {
        const res = await fetch(`${candidate}?act=health`, {headers: {Accept: 'application/json'}});
        if (res.ok) {
          const body = await res.json();
          if (body && body.ok) {
            apiBase = candidate;
            break;
          }
        }
      } catch {
        // This address is not the API. Try the next one.
      }
    }
    // Nothing answered, so use the most likely address and let the caller's
    // own error handling report it in words the guest can act on.
    if (apiBase === null) apiBase = apiCandidates()[0];
  }
  return `${apiBase}?act=${act}`;
};

export const LOGO = './logo-256.png';

/**
 * The 3.5% the hotel carries inside every price it quotes.
 *
 * A guest reads one number. The card on the menu, the rate on the room, the
 * total in the tray and the amount the payment takes are the same figure, so
 * the 3.5% is added in exactly one place here and the server adds the same
 * 3.5% when it fixes a total. The receipt itemises it, so the arithmetic can
 * still be read.
 */
export const SERVICE_RATE = 0.035;

/** A base figure with the hotel's 3.5% carried inside it. */
export const withService = (n: number): number => Math.round(n * (1 + SERVICE_RATE));

/** Formats shillings that already carry everything they should. */
export const fmt = (n: number): string => 'UGX ' + Math.round(n).toLocaleString();

/** A price as it is printed on a tag: the base figure with the 3.5% inside it. */
export const fmtPrice = (n: number): string => fmt(withService(n));

/**
 * The guest's own account, kept in this browser.
 *
 * The token is a random string the server only ever stores as its sha256, so
 * nothing here can be turned back into a login by anyone who reads it. The name
 * is kept beside it so the navigation can say who is signed in without asking
 * the API on every page load.
 */
const TOKEN_KEY = 'hpn_customer_token';
const NAME_KEY = 'hpn_customer_name';

export const customerToken = (): string => {
  try { return window.localStorage.getItem(TOKEN_KEY) || ''; } catch { return ''; }
};
export const customerFirstName = (): string => {
  try { return (window.localStorage.getItem(NAME_KEY) || '').split(' ')[0]; } catch { return ''; }
};
export const setCustomer = (token: string, name: string): void => {
  try { window.localStorage.setItem(TOKEN_KEY, token); window.localStorage.setItem(NAME_KEY, name); } catch {}
};
export const forgetCustomer = (): void => {
  try { window.localStorage.removeItem(TOKEN_KEY); window.localStorage.removeItem(NAME_KEY); } catch {}
};

export type Room = {
  id: number;
  type: string;
  rate: string;
  usd: string;
  price: number;
  guests: string;
  beds: string;
  pillow: string;
  text: string;
  featured?: boolean;
};

export const rooms: Room[] = [
     {id: 1, type: 'Suite', rate: fmtPrice(248000), usd: '100 to 120', price: 248000, guests: 'Up to 3 guests', beds: 'One king sized bed', pillow: 'The grand retreat', text: 'Our most spacious room, generous in space and comfort, with premium furnishings, a king sized bed and a calm, elegant atmosphere.', featured: true},
  {id: 2, type: 'Family Room', rate: fmtPrice(314000), usd: '122 to 125', price: 314000, guests: 'Up to 4 guests', beds: 'One double bed and two single beds', pillow: 'Made for families', text: 'Roomier than most, with a double bed and two single beds, made for families travelling together with comfort in mind.', featured: true},
  {id: 3, type: 'Triple Room', rate: fmtPrice(213000), usd: '100', price: 213000, guests: 'Up to 3 guests', beds: 'Three single beds', pillow: 'For three guests', text: 'A comfortable setting with three single beds, ideal for friends or a small group staying together.'},
  {id: 4, type: 'Executive Deluxe', rate: fmtPrice(202000), usd: '80', price: 202000, guests: 'Up to 2 guests', beds: 'One king sized bed', pillow: 'Business ready', text: 'An elevated stay with refined touches and a king sized bed, well suited to business and leisure travellers alike.'},
  {id: 5, type: 'Deluxe Double', rate: fmtPrice(178000), usd: '70', price: 178000, guests: 'Up to 2 guests', beds: 'One double bed', pillow: 'The popular choice', text: 'Elegant double accommodation with a restful, warm and private atmosphere and a comfortable double bed.'},
     {id: 6, type: 'Standard Double', rate: fmtPrice(155000), usd: '60', price: 155000, guests: 'Up to 2 guests', beds: 'One double bed', pillow: 'Quiet and cosy', text: 'A well kept double room with a comfortable bed, everything you need for a good night in Jinja.'},
     {id: 7, type: 'Standard Twin', rate: fmtPrice(142000), usd: '60', price: 142000, guests: 'Up to 2 guests', beds: 'Two single beds', pillow: 'Two beds', text: 'A neatly kept room with two comfortable single beds for a peaceful night of rest.'},
     {id: 8, type: 'Standard Single', rate: fmtPrice(128000), usd: '55', price: 128000, guests: '1 guest', beds: 'One single bed', pillow: 'Great value', text: 'A simple, well equipped single room with a comfortable single bed, and the best value on the river.'}
   ];

/**
 * The photograph a room is illustrated by, in /images/rooms/.
 * Naming follows the room type: Deluxe Double looks for deluxe-double.jpg.
 */
export const roomImage = (type: string): string =>
  type.toLowerCase().replace(/&/g, 'and').replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '');

export const palettes = (i: number): string =>
  ['linear-gradient(150deg,#16293f,#0B5D78)', 'linear-gradient(150deg,#c9a22766,#0d2338)', 'linear-gradient(150deg,#071A33,#3d7d96)', 'linear-gradient(150deg,#16324a,#0f4c66)', 'linear-gradient(150deg,#c9a22755,#1E3A5F)', 'linear-gradient(150deg,#0d2338,#0B5D78)', 'linear-gradient(150deg,#0f4c66,#16293f)'][i % 7];

export function BedGlyph({size = 120}: {size?: number}) {
 return (
  <svg width={size} height={size} viewBox="0 0 100 100" fill="none" aria-hidden="true">
   <rect x="10" y="48" width="80" height="22" rx="4" stroke="currentColor" strokeWidth="3.2"/>
   <rect x="17" y="38" width="66" height="13" rx="3.5" stroke="currentColor" strokeWidth="3.2"/>
   <rect x="15" y="27" width="58" height="10" rx="3.5" stroke="currentColor" strokeWidth="3.2"/>
   <line x1="23" y1="70" x2="23" y2="84" stroke="currentColor" strokeWidth="3.6" strokeLinecap="round"/>
   <line x1="77" y1="70" x2="77" y2="84" stroke="currentColor" strokeWidth="3.6" strokeLinecap="round"/>
   <rect x="11" y="8" width="8" height="40" rx="3" stroke="currentColor" strokeWidth="3"/>
   <rect x="81" y="8" width="8" height="40" rx="3" stroke="currentColor" strokeWidth="3"/>
   <path d="M15 20 q20 -6 70 0" stroke="currentColor" strokeWidth="2.6" strokeLinecap="round"/>
   <rect x="52" y="50" width="11" height="7" rx="2" stroke="currentColor" strokeWidth="2.4"/>
  </svg>
 );
}

/* ------------------------------------------------------------------
   THE HOTEL'S OWN DETAILS

   Written down once, here, so that the top bar, the footer, the drawer,
   the menu page and the booking page cannot drift apart. A phone number
   that appears on one page and not another is the sort of thing a guest
   notices at the moment they need it.

   The web address is hotelparadiseonthenile.info. It is not a .com and
   must never be written as one.
   ------------------------------------------------------------------ */

export const HOTEL = {
  legalName: 'Hotel Paradise on the Nile Ltd',
  shortName: 'Hotel Paradise on the Nile',
  /** The full postal address, as it stands on the title deeds. */
  address: 'Plot 12, 19 & 25 Kiira Lane, Jinja, Uganda',
  /** Without the country, for a footer column that already says Uganda. */
  addressShort: 'Plot 12, 19 & 25 Kiira Lane, Jinja',
  /** What to hand to a map, which wants the comma after the plot numbers. */
  addressForMap: 'Plot 12, 19 & 25, Kiira Lane, Jinja, Uganda',
  poBox: 'P.O. Box 1139, Jinja, Uganda',
  /** Front desk first, reservations second. Both are dialled, both are answered. */
  phones: ['+256 759 504 928', '+256 773 565 668'],
  email: 'hotel@hotelparadiseonthenile.info',
  website: 'www.hotelparadiseonthenile.info',
  certification: 'UNBS Certified, US 130:2017'
} as const;

/** A telephone number written for people to a form a dialler can use. */
export const telHref = (phone: string): string => 'tel:+' + phone.replace(/\D/g, '');

export const CALL = HOTEL.phones[0];

export function Brand({light = false}: {light?: boolean}) {
  return (
   <a className={light ? 'brandL light' : 'brandL'} href="./index.html">
    <img className="brandLogo" src={LOGO} alt="Hotel Paradise on the Nile logo"/>
    <span className="brandWord"><span>HOTEL PARADISE</span><small>ON THE NILE</small></span>
   </a>
  );
}

export function TopBar() {
 return (
  <div className="topbar">
   <span>HOTEL PARADISE ON THE NILE, PLOT 12, 19 &amp; 25 KIIRA LANE, JINJA, UGANDA</span>
   <span className="right">{HOTEL.phones.join('  ·  ')}</span>
  </div>
 );
}

export const NAV = [['./index.html', 'Home'], ['./rooms.html', 'Rooms and beds'], ['./menu.html', 'Menu and dining'], ['./index.html#facilities', 'Facilities'], ['./index.html#contact', 'Contact'], ['./system/', 'Management System']] as const;

/** The studio that designed and built this website and the management system behind it. */
export const STUDIO = {
  name: 'Reagansoft Innovation Limited',
  url: 'https://reagansoftinnovation.com',
  label: 'reagansoftinnovation.com',
  /** Uganda country code 256, then 730 314 979, written as 0730 314 979 locally. */
  whatsapp: '256730314979',
  whatsappLabel: 'WhatsApp 0730 314 979'
};

export const WhatsAppIcon = ({size = 15}: {size?: number}) => (
  <svg width={size} height={size} viewBox="0 0 24 24" fill="currentColor" aria-hidden="true" focusable="false">
   <path d="M12.04 2C6.6 2 2.2 6.4 2.2 11.84c0 1.74.46 3.44 1.32 4.94L2 22l5.36-1.4a9.84 9.84 0 0 0 4.68 1.2h.01c5.43 0 9.84-4.4 9.84-9.84C21.89 6.4 17.48 2 12.04 2Zm5.76 14.02c-.24.68-1.4 1.32-1.94 1.36-.5.04-.98.24-3.3-.7-2.78-1.1-4.54-3.94-4.68-4.12-.14-.18-1.12-1.5-1.12-2.86 0-1.36.72-2.04.98-2.32.24-.28.54-.34.72-.34h.5c.16 0 .38-.06.6.46.22.54.74 1.86.8 2 .06.14.1.3.02.48-.08.18-.14.28-.26.44-.14.14-.28.32-.4.44-.14.14-.28.28-.12.56.16.28.72 1.18 1.54 1.92 1.06.94 1.96 1.24 2.24 1.38.28.14.44.12.6-.08.16-.18.68-.8.86-1.08.18-.28.36-.22.6-.14.24.1 1.56.74 1.82.88.26.14.44.2.5.32.06.12.06.7-.18 1.38Z"/>
  </svg>
);

export function Footer() {
  return (
   <footer>
    <div className="flag"><i></i><i></i><i></i></div>
    <div className="footerMain">
     <div>
        <img src="./images/paradise-logo.png" alt="Hotel Paradise on the Nile" style={{maxWidth:80,height:'auto',marginBottom:12,filter:'drop-shadow(0 4px 20px rgba(212,175,55,0.3))'}} onError={(e:any)=>{e.currentTarget.style.display='none'}}/>
        <h3 style={{color:'#d4af37',margin:'0 0 8px 0',fontFamily:'Playfair Display'}}>HOTEL PARADISE</h3>
        <h4 style={{color:'#fff',margin:'-4px 0 12px 0',letterSpacing:'4px',fontSize:'12px',fontWeight:400}}>ON THE NILE</h4>
        <p style={{color:'#b9c7d6',marginTop:0}}>Premium hospitality in Jinja, on the banks of the Nile.</p>
     </div>
      <div><h4>HOTEL</h4><p>{HOTEL.addressShort}</p><p>Rooms, dining, bar and events</p><p>{HOTEL.poBox}</p><p>{HOTEL.certification}</p></div>
      <div><h4>STAY</h4><p>Check in from 12 noon</p><p>Check out by 10 am</p><p>Breakfast included</p></div>
      <div><h4>CONTACT</h4>
        <p>{HOTEL.phones.map((p, i) => (
          <React.Fragment key={p}>{i > 0 && ' · '}<a className="footLink" href={telHref(p)}>{p}</a></React.Fragment>
        ))}</p>
        <p><a className="footLink" href={'mailto:' + HOTEL.email}>{HOTEL.email}</a></p>
        <p>Front desk open 24 hours</p>
      </div>
     <div className="footerStudio">
      <h4>BUILT BY</h4>
      <a className="studioLink" href={STUDIO.url} target="_blank" rel="noopener noreferrer">
       <span className="studioName">{STUDIO.name}</span>
       <span className="studioUrl">{STUDIO.label}</span>
      </a>
      <p>Design, build and support of this website and the hotel management system.</p>
      <a className="studioWa" href={'https://wa.me/' + STUDIO.whatsapp} target="_blank" rel="noopener noreferrer">
       <WhatsAppIcon/>{STUDIO.whatsappLabel}
      </a>
     </div>
    </div>
    <div className="footerCredit">
     <span>Hotel Paradise on the Nile Ltd, Jinja, Uganda</span>
     <span>Designed, built and supported by <a className="projLink" href={STUDIO.url} target="_blank" rel="noopener noreferrer">{STUDIO.name}</a></span>
    </div>
   </footer>
  );
}

export function PageNav({onDark = false}: {onDark?: boolean}) {
 const [open, setOpen] = React.useState(false);
 /* The bar turns solid the moment the page moves, so the links never sit on
    top of whatever scrolls behind them. */
 const [stuck, setStuck] = React.useState(false);
 const burgerRef = React.useRef<HTMLButtonElement>(null);
 const firstLinkRef = React.useRef<HTMLAnchorElement>(null);
 const wasOpen = React.useRef(false);
 const here = (location.pathname.split('/').pop() || 'index.html');
 const active = (href: string) => href.split('#')[0] === './' + here;
 const close = () => setOpen(false);

 React.useEffect(() => {
  const onScroll = () => setStuck(window.scrollY > 40);
  onScroll();
  window.addEventListener('scroll', onScroll, {passive: true});
  return () => window.removeEventListener('scroll', onScroll);
 }, []);

 React.useEffect(() => {
  if (!open) return;
  const onKey = (e: KeyboardEvent) => { if (e.key === 'Escape') setOpen(false); };
  document.addEventListener('keydown', onKey);
  const prev = document.body.style.overflow;
  document.body.style.overflow = 'hidden';
  return () => { document.removeEventListener('keydown', onKey); document.body.style.overflow = prev; };
 }, [open]);

 /* Focus goes into the menu when it opens and comes back to the burger when it
    closes, so a keyboard guest is never dropped at the top of the page. */
 React.useEffect(() => {
  if (open) firstLinkRef.current?.focus();
  else if (wasOpen.current) burgerRef.current?.focus();
  wasOpen.current = open;
 }, [open]);

 return (
  <>
   <a className="skipLink" href="#main">Skip to content</a>
   <header className={(onDark ? 'nav dark' : 'nav') + (stuck ? ' stuck' : '')}>
    <Brand light={onDark}/>
    <nav>{NAV.map(([href, label]) => <a key={href} className={active(href) ? 'active' : ''} href={href}>{label}</a>)}</nav>
    <div className="navRight">
     <a className={'navSignIn' + (active('./account.html') ? ' active' : '')} href="./account.html">{customerFirstName() || 'Sign in'}</a>
     <a className="btn navCta" href="./rooms.html">Book now</a>
     <button ref={burgerRef} className={'burger' + (open ? ' open' : '')} onClick={() => setOpen(o => !o)} aria-label={open ? 'Close menu' : 'Open menu'} aria-expanded={open} aria-controls="mobile-menu">
      <span/><span/><span/>
     </button>
    </div>
   </header>

   <div className={'drawer' + (open ? ' open' : '')} id="mobile-menu" aria-hidden={!open}>
    <div className="drawerScrim" onClick={close}/>
    <aside className="drawerPanel" role="dialog" aria-modal="true" aria-label="Site menu">
     <div className="drawerNav">
      {NAV.map(([href, label], i) => <a key={href} ref={i === 0 ? firstLinkRef : undefined} className={active(href) ? 'active' : ''} href={href} onClick={close}>{label}</a>)}
     </div>
      <div className="drawerFoot">
       <a className="btn" href="./rooms.html" onClick={close}>Book now</a>
       <a className="drawerCall systemLink" href="./account.html" onClick={close}>{customerFirstName() ? 'My account · ' + customerFirstName() : 'Sign in or create an account'}</a>
       <a className="drawerCall systemLink" href="./system/" onClick={close}>Management system</a>
       <a className="drawerCall" href={telHref(CALL)}>Call {CALL}</a>
       <p className="drawerNote">{HOTEL.address}</p>
      </div>
     </aside>
    </div>

    <div className="mobileCta">
     <a className="btn" href="./rooms.html">Book your stay</a>
     <a className="btn ghost" href={telHref(CALL)}>Call us</a>
    </div>
  </>
 );
}
