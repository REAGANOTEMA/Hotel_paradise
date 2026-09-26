import React from 'react';

export const API = '/hotelparadiseonthenile/backend-php/api.php';
export const LOGO = './logo-256.png';

export const fmt = (n: number): string => 'UGX ' + Math.round(n).toLocaleString();

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
  {id: 1, type: 'Suite', rate: 'UGX 248,000', usd: '100 to 120', price: 248000, guests: 'Up to 2 guests', beds: 'One king sized bed', pillow: 'The grand retreat', text: 'Our most spacious room, generous in space and comfort, with premium furnishings, a king sized bed and a calm, elegant atmosphere.', featured: true},
  {id: 2, type: 'Family Room', rate: 'UGX 314,000', usd: '122 to 125', price: 314000, guests: 'Up to 4 guests', beds: 'One double bed and two single beds', pillow: 'Made for families', text: 'Roomier than most, with a double bed and two single beds, made for families travelling together with comfort in mind.', featured: true},
  {id: 3, type: 'Triple Room', rate: 'UGX 213,000', usd: '100', price: 213000, guests: 'Up to 3 guests', beds: 'Three single beds', pillow: 'For three guests', text: 'A comfortable setting with three single beds, ideal for friends or a small group staying together.'},
  {id: 4, type: 'Executive Deluxe', rate: 'UGX 202,000', usd: '80', price: 202000, guests: 'Up to 2 guests', beds: 'One king sized bed', pillow: 'Business ready', text: 'An elevated stay with refined touches and a king sized bed, well suited to business and leisure travellers alike.'},
  {id: 5, type: 'Deluxe Double', rate: 'UGX 178,000', usd: '70', price: 178000, guests: 'Up to 2 guests', beds: 'One double bed', pillow: 'The popular choice', text: 'Elegant double accommodation with a restful, warm and private atmosphere and a comfortable double bed.'},
  {id: 6, type: 'Standard Twin', rate: 'UGX 142,000', usd: '60', price: 142000, guests: 'Up to 2 guests', beds: 'Two single beds', pillow: 'Two beds', text: 'A neatly kept room with two comfortable single beds for a peaceful night of rest.'},
  {id: 7, type: 'Standard Double', rate: 'UGX 178,000', usd: '60', price: 178000, guests: 'Up to 2 guests', beds: 'One double bed', pillow: 'Quiet and cosy', text: 'A well kept double room with a comfortable bed, everything you need for a good night in Jinja.'},
  {id: 8, type: 'Standard Single', rate: 'On request', usd: '55', price: 0, guests: '1 guest', beds: 'One single bed', pillow: 'Great value', text: 'A simple, well equipped single room with a comfortable single bed. Contact the hotel for today rate.'}
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
   <span>HOTEL PARADISE ON THE NILE, 19 KIIRA RD, JINJA, UGANDA</span>
   <span className="right">+256 759 504 928</span>
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
      <Brand/>
      <p>Premium hospitality in Jinja, on the banks of the Nile.</p>
     </div>
     <div><h4>HOTEL</h4><p>19 Kiira Road, Jinja</p><p>Rooms, dining, bar and events</p><p>P.O. Box 1139, Jinja, Uganda</p></div>
     <div><h4>STAY</h4><p>Check in from 12 noon</p><p>Check out by 10 am</p><p>Breakfast included</p></div>
     <div><h4>CONTACT</h4><p><a className="footLink" href="tel:+256759504928">+256 759 504 928</a></p><p><a className="footLink" href="mailto:hotel@hotelparadiseonthenile.info">hotel@hotelparadiseonthenile.info</a></p><p>Front desk open 24 hours</p></div>
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
 const here = (location.pathname.split('/').pop() || 'index.html');
 const active = (href: string) => href.split('#')[0] === './' + here;
 const close = () => setOpen(false);

 React.useEffect(() => {
  if (!open) return;
  const onKey = (e: KeyboardEvent) => { if (e.key === 'Escape') setOpen(false); };
  document.addEventListener('keydown', onKey);
  const prev = document.body.style.overflow;
  document.body.style.overflow = 'hidden';
  return () => { document.removeEventListener('keydown', onKey); document.body.style.overflow = prev; };
 }, [open]);

 return (
  <>
   <header className={onDark ? 'nav dark' : 'nav'}>
    <Brand light={onDark}/>
    <nav>{NAV.map(([href, label]) => <a key={href} className={active(href) ? 'active' : ''} href={href}>{label}</a>)}</nav>
    <div className="navRight">
     <a className="btn navCta" href="./rooms.html">Book now</a>
     <button className={'burger' + (open ? ' open' : '')} onClick={() => setOpen(o => !o)} aria-label={open ? 'Close menu' : 'Open menu'} aria-expanded={open} aria-controls="mobile-menu">
      <span/><span/><span/>
     </button>
    </div>
   </header>

   <div className={'drawer' + (open ? ' open' : '')} id="mobile-menu" aria-hidden={!open}>
    <div className="drawerScrim" onClick={close}/>
    <aside className="drawerPanel" role="dialog" aria-modal="true" aria-label="Site menu">
     <div className="drawerNav">
      {NAV.map(([href, label]) => <a key={href} className={active(href) ? 'active' : ''} href={href} onClick={close}>{label}</a>)}
     </div>
     <div className="drawerFoot">
      <a className="btn" href="./rooms.html" onClick={close}>Book now</a>
      <a className="drawerCall systemLink" href="./system/" onClick={close}>Management system</a>
      <a className="drawerCall" href="tel:+256759504928">Call +256 759 504 928</a>
      <p className="drawerNote">19 Kiira Rd, Jinja, Uganda</p>
     </div>
    </aside>
   </div>

   <div className="mobileCta">
    <a className="btn" href="./rooms.html">Book your stay</a>
    <a className="btn ghost" href="tel:+256759504928">Call us</a>
   </div>
  </>
 );
}