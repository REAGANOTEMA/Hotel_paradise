import React from 'react';
import {createRoot} from 'react-dom/client';
import './styles.css';
import {TopBar, PageNav, Footer, fmt, API} from './shared';
import {SmartImage} from './SmartImage';
import {
  MENU_REVISION,
  dishImage,
  menuSections,
  sectionImage,
  slugify,
  totalDishes,
  type MenuGroup,
  type MenuItem,
  type MenuSection
} from './menuData';

type Line = {dish: MenuItem; qty: number};

const CALL = '+256 759 504 928';

/**
 * Add ?photos=1 to any page to see the file name each slot is waiting for.
 * Guests never see it; it is here so the kitchen can tell at a glance which
 * photographs are still outstanding.
 */
const SHOW_FILE_HINTS = new URLSearchParams(location.search).get('photos') === '1';

/** Reads the live kitchen menu and folds it into the same shape as the fallback. */
const toSections = (cats: Array<{name: string; eyebrow?: string; blurb?: string; image?: string; items: any[]}>): MenuSection[] =>
  cats
    .filter(c => Array.isArray(c.items) && c.items.length > 0)
    .map(c => {
      const groups: MenuGroup[] = [];
      c.items.forEach(raw => {
        const g = raw.group || 'Items';
        let bucket = groups.find(x => x.name === g);
        if (!bucket) { bucket = {name: g, items: []}; groups.push(bucket); }
        bucket.items.push({
          id: Number(raw.id),
          name: String(raw.name || ''),
          desc: String(raw.desc || ''),
          price: raw.price === null || raw.price === undefined ? null : Number(raw.price),
          image: String(raw.image || ''),
          group: g
        });
      });
      return {
        key: slugify(c.name),
        name: c.name,
        eyebrow: c.eyebrow || '',
        blurb: c.blurb || '',
        image: c.image || '',
        groups
      };
    });

/** Reserved plate drawn while a dish is still waiting for its photograph. */
function PlateGlyph() {
  return (
    <svg className="plateGlyph" viewBox="0 0 64 64" fill="none" aria-hidden="true">
      <circle cx="32" cy="32" r="19" stroke="currentColor" strokeWidth="1.4"/>
      <circle cx="32" cy="32" r="12.5" stroke="currentColor" strokeWidth="1" strokeDasharray="2 3.4"/>
      <path d="M32 6v6M32 52v6M6 32h6M52 32h6" stroke="currentColor" strokeWidth="1.2" strokeLinecap="round"/>
      <path d="M32 26.5a5.5 5.5 0 1 1 0 11 5.5 5.5 0 0 1 0-11Z" stroke="currentColor" strokeWidth="1.1"/>
    </svg>
  );
}

/**
 * The photograph of one dish.
 *
 * Drop a file named after the slug into /images/dishes/ and it fills itself,
 * at whatever size the screen needs. Until then the card shows a warm, printed
 * plate rather than an empty box, so the menu still reads as a finished menu.
 */
function DishShot({dish}: {dish: MenuItem}) {
  const file = dishImage(dish);
  return (
    <SmartImage
      group="dishes"
      name={file}
      alt={dish.name}
      ratio="4 / 3"
      widths={[320, 480, 640, 960]}
      sizes="(max-width:640px) 132px, (max-width:1050px) 240px, (max-width:1400px) 300px, 340px"
      position="50% 52%"
      zoom
      className="shot"
      placeholder={
        <div className="shotEmpty">
          <PlateGlyph/>
          <span className="shotNote">{dish.group}</span>
          {SHOW_FILE_HINTS && <code className="shotFile">images/dishes/{file}</code>}
        </div>
      }
    />
  );
}

/**
 * The wide photograph that opens a section, with the section name laid over it.
 * Falls back to a deep navy panel with a gold rule, which reads as designed
 * rather than broken while the photograph is still outstanding.
 */
function SectionBanner({section, children}: {section: MenuSection; children: React.ReactNode}) {
  const file = sectionImage(section);
  return (
    <SmartImage
      group="dishes"
      name={file}
      alt=""
      ratio="21 / 8"
      widths={[640, 1024, 1440, 1920]}
      sizes="(max-width:1400px) 100vw, 1260px"
      position="72% 50%"
      className="secBanner"
      placeholder={<span className="secBannerGlyph" aria-hidden="true">{section.name.slice(0, 1).toUpperCase()}</span>}
    >
      {children}
    </SmartImage>
  );
}

function MenuPage() {
  const [sections, setSections] = React.useState<MenuSection[]>(menuSections);
  const [live, setLive] = React.useState(false);
  const [tray, setTray] = React.useState<Line[]>([]);
  const [open, setOpen] = React.useState(false);
  const [here, setHere] = React.useState(menuSections[0].key);
  const [name, setName] = React.useState('');
  const [phone, setPhone] = React.useState('');
  const [msg, setMsg] = React.useState<{ok: boolean; text: string} | null>(null);
  const [busy, setBusy] = React.useState(false);

  React.useEffect(() => {
    fetch(API + '?act=menu')
      .then(r => r.json())
      .then(d => {
        if (d.ok && Array.isArray(d.categories) && d.categories.some((c: {items?: unknown[]}) => Array.isArray(c.items) && c.items.length)) {
          const next = toSections(d.categories);
          if (next.length) { setSections(next); setLive(true); }
        }
      })
      .catch(() => {});
  }, []);

  // Highlight the section currently under the sticky navigation.
  React.useEffect(() => {
    const seen = new Map<string, number>();
    const io = new IntersectionObserver(entries => {
      entries.forEach(e => seen.set(e.target.id, e.isIntersecting ? e.intersectionRatio : 0));
      let best = '';
      let bestRatio = 0;
      seen.forEach((ratio, id) => { if (ratio > bestRatio) { bestRatio = ratio; best = id; } });
      if (best) setHere(best.replace('sec-', ''));
    }, {rootMargin: '-140px 0px -55% 0px', threshold: [0, .15, .4, .8, 1]});
    document.querySelectorAll('[id^="sec-"]').forEach(el => io.observe(el));
    return () => io.disconnect();
  }, [sections]);

  const add = (dish: MenuItem) => {
    if (dish.price === null) {
      setMsg({ok: false, text: dish.name + ' is priced on request. Please call ' + CALL + ' and the team will price it for you.'});
      return;
    }
    setMsg(null);
    setTray(t => {
      const ex = t.find(x => x.dish.id === dish.id);
      return ex ? t.map(x => x.dish.id === dish.id ? {...x, qty: x.qty + 1} : x) : [...t, {dish, qty: 1}];
    });
  };
  const bump = (id: number, d: number) => setTray(t => t.map(x => x.dish.id === id ? {...x, qty: Math.max(0, x.qty + d)} : x).filter(x => x.qty > 0));
  const drop = (id: number) => setTray(t => t.filter(x => x.dish.id !== id));
  const subtotal = tray.reduce((s, x) => s + x.qty * (x.dish.price || 0), 0);
  const count = tray.reduce((s, x) => s + x.qty, 0);

  React.useEffect(() => { if (tray.length) setOpen(true); }, [tray.length]);

  const send = async () => {
    if (!tray.length) { setMsg({ok: false, text: 'Add at least one dish to your order first.'}); return; }
    if (!name.trim() || !phone.trim()) { setMsg({ok: false, text: 'Please add your name and phone number so we can confirm your order.'}); return; }
    setBusy(true); setMsg(null);
    try {
      const res = await fetch(API + '?act=order', {method: 'POST', headers: {'Content-Type': 'application/json'}, body: JSON.stringify({
        name: name.trim(), phone: phone.trim(), items: tray.map(x => ({id: x.dish.id, qty: x.qty}))
      })});
      const d = await res.json();
      if (d.ok) {
        setMsg({ok: true, text: 'Your order ' + d.order_number + ' is with the kitchen. ' + d.message});
        setTray([]); setName(''); setPhone('');
      } else {
        setMsg({ok: false, text: d.error || 'Something went wrong. Please call ' + CALL + '.'});
      }
    } catch {
      setMsg({ok: false, text: 'Could not reach the kitchen. Please call ' + CALL + '.'});
    }
    setBusy(false);
  };

  return <div>
    <TopBar/>
    <PageNav/>

    <section className="pageHero">
      <p className="eyebrow">DINING AND BAR</p>
      <h1>Our menu, your order.</h1>
      <p>Every dish in its own section, with a photograph of each plate. Add what you fancy to your order and change or drop anything freely before it reaches the kitchen. Prices include taxes.</p>
    </section>

    <div className="menuJump" id="jump">
      <div className="menuJumpInner">
        {sections.map(s => (
          <a key={s.key} className={here === s.key ? 'active' : ''} href={'#sec-' + s.key}>{s.name}</a>
        ))}
        <button className="jumpOrder" onClick={() => { setOpen(true); document.getElementById('order')?.scrollIntoView({behavior: 'smooth', block: 'start'}); }}>
          Your order{count > 0 && ' (' + count + ')'}
        </button>
      </div>
    </div>

    <section className="menuWrap section">
      <div className="menuWatermark" aria-hidden="true"/>

      <div className="menuMeta">
        <span>{MENU_REVISION}</span>
        <span className="menuMetaCount">{totalDishes(sections)} dishes</span>
        <button className="printBtn" onClick={() => window.print()}>Print this menu</button>
      </div>

      {sections.map(section => (
        <section className="secBlock" id={'sec-' + section.key} key={section.key}>
          <header className="secHead">
            <SectionBanner section={section}>
              {section.eyebrow && <p className="secEyebrow">{section.eyebrow}</p>}
              <h2>{section.name}</h2>
            </SectionBanner>
            {section.blurb && <p className="secBlurb">{section.blurb}</p>}
          </header>

          {section.groups.map((g, gi) => (
            <div className="subGroup" key={section.key + '-' + gi}>
              <h3 className="subHead">{g.name}</h3>
              <div className="dishGrid">
                {g.items.map(dish => (
                  <article className="dishCard" key={section.key + '-' + dish.id + '-' + dish.name}>
                    <DishShot dish={dish}/>
                    <div className="dishBody">
                      <h4>{dish.name}</h4>
                      {dish.desc && <p>{dish.desc}</p>}
                      <div className="dishFoot">
                        <b className={dish.price === null ? 'askPrice' : ''}>{dish.price === null ? 'Price on request' : fmt(dish.price)}</b>
                        {dish.price !== null && live &&
                          <button className="addBtn" onClick={() => add(dish)}>Add</button>}
                      </div>
                    </div>
                  </article>
                ))}
              </div>
            </div>
          ))}
        </section>
      ))}

      <p className="orderNote">Meals are served from the same kitchen for our guests and walk in visitors. Lunch is served until 3 pm and dinner until 11 pm. For orders into your room, mention your room number when we call to confirm. Dishes marked price on request are confirmed by our team before your order is placed.</p>
    </section>

    <section className="orderPanelWrap section" id="order">
      <div className={'orderPanel' + (open ? ' open' : '')}>
        <button className="orderPanelHead" onClick={() => setOpen(o => !o)} aria-expanded={open} aria-controls="orderBody">
          <span className="orderPanelTitle">
            <b>Your order</b>
            <em>{tray.length === 0 ? 'Nothing added yet. Tap Add on any dish.' : count + ' item' + (count === 1 ? '' : 's') + ' · UGX ' + Math.round(subtotal).toLocaleString()}</em>
          </span>
          <span className="orderPanelToggle">{open ? 'Collapse' : 'Open'}</span>
        </button>

        {open && <div className="orderPanelBody" id="orderBody">
          {tray.length === 0 ? (
            <div className="trayEmpty"><p>Your order is empty. Add a dish from the menu and it will appear here. You can drop or change anything freely before you send.</p></div>
          ) : (
            <div className="trayList">
              {tray.map(x => (
                <div className="trayItem" key={x.dish.id}>
                  <div className="trayInfo"><b>{x.dish.name}</b><span>{fmt(x.dish.price || 0)}</span></div>
                  <div className="trayQty"><button onClick={() => bump(x.dish.id, -1)} aria-label="One less">−</button><em>{x.qty}</em><button onClick={() => bump(x.dish.id, 1)} aria-label="One more">+</button></div>
                  <span className="lineTotal">{fmt(x.qty * (x.dish.price || 0))}</span>
                  <button className="dropBtn" onClick={() => drop(x.dish.id)} title="Drop this dish">Drop</button>
                </div>
              ))}
              <div className="trayTotal"><span>Total</span><b>{fmt(subtotal)}</b></div>
            </div>
          )}

          {live ? (
            <div className="trayForm">
              <div className="planField"><label>Your name</label><input value={name} onChange={e => setName(e.target.value)} placeholder="Full name"/></div>
              <div className="planField"><label>Phone</label><input value={phone} onChange={e => setPhone(e.target.value)} type="tel" placeholder="e.g. 0759504928"/></div>
              <button className="btn planBook" onClick={send} disabled={busy || tray.length === 0}>{busy ? 'Sending...' : 'Send my order'}</button>
              {tray.length > 0 && <button className="linkBtn" onClick={() => setTray([])}>Drop everything and start again</button>}
            </div>
          ) : (
            <div className="trayForm">
              <div className="bookMsg">Online ordering is briefly unavailable. Your list is still here — call <a href={'tel:' + CALL.replace(/\s/g, '')}>{CALL}</a> to place it.</div>
            </div>
          )}

          {msg && <div className={msg.ok ? 'bookMsg ok' : 'bookMsg'}>{msg.text}</div>}
          <p className="plannerNote">You are in full control. Change quantities or drop any dish before you send your order. No payment is taken here.</p>
        </div>}
      </div>
    </section>

    <Footer/>
  </div>;
}

createRoot(document.getElementById('root')!).render(<MenuPage/>);
