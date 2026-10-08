import React from 'react';
import {createRoot} from 'react-dom/client';
import './styles.css';
import {TopBar, PageNav, Footer, fmtPrice, apiUrl, CALL, telHref} from './shared';
import {SmartImage, photoHintsEnabled} from './SmartImage';
import {
  MENU_REVISION,
  addOnPrice,
  companionsFor,
  defaultCompanion,
  dishImage,
  linePrice,
  menuSections,
  saladsFor,
  sectionImage,
  slugify,
  tidySections,
  totalDishes,
  ADD_ONS_INCLUDED,
  type Choice,
  type MenuItem,
  type MenuSection
} from './menuData';

type Line = {key: string; dish: MenuItem; qty: number; companion: Choice | null; salads: Choice[]};

/** The fallback menu, read the way it is going to be printed. */
const FALLBACK: MenuSection[] = tidySections(menuSections);

/** The photographs each slot is still waiting for, shown on request only. */
const SHOW_FILE_HINTS = photoHintsEnabled();

/** Reads the live kitchen menu and folds it into the same shape as the fallback. */
type LiveCategory = {name: string; outlet?: string; eyebrow?: string; blurb?: string; image?: string; items: any[]};

/**
 * Where a section sits on the page. The kitchen orders its own sections by a
 * sort number that runs across all of its outlets at once, which puts the bar
 * between the starters and the burgers. Food first, then the drinks, then what
 * the room can order: a guest reads a menu the way the printed one reads.
 */
const outletRank = (outlet?: string): number => {
  const o = String(outlet || '').toLowerCase();
  if (o.startsWith('bar')) return 1;
  if (o.startsWith('room')) return 2;
  return 0;
};

const toSections = (cats: LiveCategory[]): MenuSection[] => {
  // Sections that share a heading are folded into one, and a dish filed twice
  // in the same section is only printed once. Both happen when an import is
  // run twice, and a guest should never see the copies.
  const folded = new Map<string, MenuSection>();
  const order: string[] = [];
  const rank = new Map<string, number>();

  cats.forEach(c => {
    if (!Array.isArray(c.items) || c.items.length === 0) return;
    const key = slugify(c.name);
    let section = folded.get(key);
    if (!section) {
      section = {key, name: c.name, eyebrow: '', blurb: '', image: '', groups: []};
      folded.set(key, section);
      order.push(key);
      rank.set(key, outletRank(c.outlet));
    }
    if (!section.eyebrow) section.eyebrow = c.eyebrow || '';
    if (!section.blurb) section.blurb = c.blurb || '';
    if (!section.image) section.image = c.image || '';

    const seen = new Set<string>();
    c.items.forEach(raw => {
      const g = String(raw.group || 'Items');
      const price = raw.price === null || raw.price === undefined ? null : Number(raw.price);
      const signature = String(raw.name || '') + '\u0000' + (price === null ? '?' : price);
      if (seen.has(signature)) return;
      seen.add(signature);
      let bucket = section!.groups.find(x => x.name === g);
      if (!bucket) { bucket = {name: g, items: []}; section!.groups.push(bucket); }
      bucket.items.push({
        id: Number(raw.id),
        name: String(raw.name || ''),
        desc: String(raw.desc || ''),
        price,
        image: String(raw.image || ''),
        group: g
      });
    });
  });

  const ranked = order.map(key => ({key, rank: rank.get(key) ?? 0}));
  ranked.sort((a, b) => a.rank - b.rank);
  return ranked.map(r => folded.get(r.key)!);
};

/* ------------------------------------------------------------------
   The small marks on the page. Drawn here rather than pulled from an
   icon set, so the menu carries nothing it does not use.
   ------------------------------------------------------------------ */

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

const PlusIcon = () => (
  <svg viewBox="0 0 16 16" fill="none" aria-hidden="true" focusable="false">
    <path d="M8 2.5v11M2.5 8h11" stroke="currentColor" strokeWidth="1.9" strokeLinecap="round"/>
  </svg>
);

const CloseIcon = () => (
  <svg viewBox="0 0 16 16" fill="none" aria-hidden="true" focusable="false">
    <path d="M3.5 3.5l9 9M12.5 3.5l-9 9" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round"/>
  </svg>
);

const ArrowIcon = () => (
  <svg viewBox="0 0 18 12" fill="none" aria-hidden="true" focusable="false">
    <path d="M1 6h15M11.5 1.5 16 6l-4.5 4.5" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"/>
  </svg>
);

const CheckIcon = () => (
  <svg viewBox="0 0 14 14" fill="none" aria-hidden="true" focusable="false">
    <path d="M2 7.4 5.4 11 12 3.6" stroke="currentColor" strokeWidth="2.1" strokeLinecap="round" strokeLinejoin="round"/>
  </svg>
);

const PhoneIcon = () => (
  <svg viewBox="0 0 16 16" fill="none" aria-hidden="true" focusable="false">
    <path d="M3 1.8h2.4l1.3 3.3-1.6 1.1a9 9 0 0 0 3.7 3.7l1.1-1.6L13.3 9.6V12a1.6 1.6 0 0 1-1.7 1.6A11.4 11.4 0 0 1 1.4 3.5 1.6 1.6 0 0 1 3 1.8Z" stroke="currentColor" strokeWidth="1.3" strokeLinejoin="round"/>
  </svg>
);

/** A little garnish mark, drawn so a priced plate reads differently to a plain row. */
function ValueMark({children}: {children: React.ReactNode}) {
  return <span className="valueMark">{children}</span>;
}

/**
 * The photograph of one dish.
 *
 * Drop a file named after the slug into /images/dishes/ and it fills itself,
 * at whatever size the screen needs. Until then the card shows a warm, printed
 * plate rather than an empty box, so the menu still reads as a finished menu.
 */
function DishShot({dish, large = false, hint = true}: {dish: MenuItem; large?: boolean; hint?: boolean}) {
  const file = dishImage(dish);
  return (
    <SmartImage
      group="dishes"
      name={file}
      alt={dish.name}
      ratio={large ? '16 / 10' : '4 / 3'}
      widths={large ? [640, 1024, 1440] : [320, 480, 640, 960]}
      sizes={large ? '(max-width:900px) 100vw, 46vw' : '(max-width:640px) 132px, (max-width:1050px) 240px, (width:94%;max-width:100%) 300px, 340px'}
      position="50% 52%"
      zoom={!large}
      className={large ? 'shot shotLarge' : 'shot'}
      placeholder={
        <div className="shotEmpty">
          <PlateGlyph/>
          <span className="shotNote">{dish.group}</span>
          {hint && SHOW_FILE_HINTS && <code className="shotFile">images/dishes/{file}</code>}
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
      sizes="(width:94%;max-width:100%) 100vw, 1260px"
      position="72% 50%"
      className="secBanner"
      placeholder={<span className="secBannerGlyph" aria-hidden="true">{section.name.slice(0, 1).toUpperCase()}</span>}
    >
      {children}
    </SmartImage>
  );
}

/* ------------------------------------------------------------------
   THE DISH DETAIL VIEW

   Every dish on the menu opens here. The guest sees the plate at full
   size, the whole description, where it sits in the menu, what comes
   with it and what it comes to, and chooses a companion and a salad
   before anything is added. Nothing is added by accident, and the
   total always moves in front of the guest.
   ------------------------------------------------------------------ */

type PickProps = {
  id: string;
  legend: string;
  hint: string;
  list: Choice[];
  /** A single choice, or a set of them. Which one depends on `multiple`. */
  chosen: Choice | Choice[] | null;
  multiple: boolean;
  onChange: (next: Choice[]) => void;
};

/** Stands in for a companion photograph until one is filed under images/dishes. */
const SideGlyph = () => (
  <svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true">
    <circle cx="12" cy="12" r="8.5" />
    <circle cx="12" cy="12" r="4.5" />
  </svg>
);

function ChoicePicker({id, legend, hint, list, chosen, multiple, onChange}: PickProps) {
  const picked = multiple ? (Array.isArray(chosen) ? chosen : []) : [];
  const isOn = (c: Choice) => (multiple ? picked.some(x => x.key === c.key) : Array.isArray(chosen) ? false : chosen?.key === c.key);

  const toggle = (c: Choice) => {
    if (!multiple) return onChange([c]);
    onChange(isOn(c) ? picked.filter(x => x.key !== c.key) : [...picked, c]);
  };

  return (
    <fieldset className="pickSet">
      <legend className="pickLegend">
        <span>{legend}</span>
        <em>{hint}</em>
      </legend>
      <div className="pickGrid">
        {list.map(c => {
          const free = addOnPrice(c) === 0;
          return (
            <label key={c.key} className={'pickCard' + (isOn(c) ? ' on' : '')}>
              <input
                type={multiple ? 'checkbox' : 'radio'}
                name={id}
                value={c.key}
                checked={isOn(c)}
                onChange={() => toggle(c)}
              />
              <span className="pickShot">
                <SmartImage
                  group="dishes"
                  name={'side-' + c.key}
                  alt={c.name}
                  ratio="1/1"
                  widths={[160, 320]}
                  sizes="44px"
                  placeholder={<span className="pickShotGlyph" aria-hidden="true"><SideGlyph/></span>}
                />
              </span>
              <span className="pickTick" aria-hidden="true"><CheckIcon/></span>
              <span className="pickText">
                <b>{c.name}</b>
                <small>{c.note}</small>
                {SHOW_FILE_HINTS && <code className="shotFile">images/dishes/side-{c.key}.jpg</code>}
              </span>
              <span className={'pickPrice' + (free ? ' incl' : '')}>{free ? 'Included' : '+ ' + fmtPrice(addOnPrice(c))}</span>
            </label>
          );
        })}
      </div>
    </fieldset>
  );
}

function DishDetail({
  dish,
  section,
  groupName,
  trayCount,
  onAdd,
  onClose
}: {
  dish: MenuItem;
  section: MenuSection | null;
  groupName: string;
  trayCount: number;
  onAdd: (dish: MenuItem, companion: Choice | null, salads: Choice[], qty: number) => void;
  onClose: () => void;
}) {
  const companions = React.useMemo(() => companionsFor(dish), [dish]);
  const salads = React.useMemo(() => saladsFor(dish), [dish]);
  const [companion, setCompanion] = React.useState<Choice | null>(() => defaultCompanion(dish));
  const [pickedSalads, setPickedSalads] = React.useState<Choice[]>([]);
  const [qty, setQty] = React.useState(1);
  const panel = React.useRef<HTMLDivElement>(null);
  const addBtn = React.useRef<HTMLButtonElement>(null);
  const restoreTo = React.useRef<HTMLElement | null>(null);

  const onRequest = dish.price === null;
  const unit = linePrice(dish, companion, pickedSalads);
  const total = unit * qty;

  React.useEffect(() => {
    restoreTo.current = document.activeElement as HTMLElement | null;
    const prev = document.body.style.overflow;
    document.body.style.overflow = 'hidden';
    (addBtn.current ?? panel.current)?.focus();
    return () => {
      document.body.style.overflow = prev;
      restoreTo.current?.focus?.();
    };
  }, []);

  React.useEffect(() => {
    const onKey = (e: KeyboardEvent) => {
      if (e.key === 'Escape') { onClose(); return; }
      if (e.key !== 'Tab' || !panel.current) return;
      const nodes = Array.from(
        panel.current.querySelectorAll<HTMLElement>('a[href],button:not([disabled]),input:not([disabled]),select,textarea,[tabindex]:not([tabindex="-1"])')
      ).filter(n => n.offsetParent !== null);
      if (!nodes.length) return;
      const first = nodes[0];
      const last = nodes[nodes.length - 1];
      if (e.shiftKey && document.activeElement === first) { e.preventDefault(); last.focus(); }
      else if (!e.shiftKey && document.activeElement === last) { e.preventDefault(); first.focus(); }
    };
    document.addEventListener('keydown', onKey);
    return () => document.removeEventListener('keydown', onKey);
  }, [onClose]);

  const breadcrumb = [section?.eyebrow, section?.name, groupName].filter(Boolean).filter((v, i, a) => a.indexOf(v) === i);

  return (
    <div className="modal" role="presentation">
      <div className="modalScrim" onClick={onClose}/>
      <div
        className="modalPanel"
        role="dialog"
        aria-modal="true"
        aria-labelledby="dishTitle"
        ref={panel}
      >
        <button className="modalClose" onClick={onClose} aria-label="Close the details of this dish">
          <CloseIcon/>
        </button>

        <div className="modalMedia">
          <DishShot dish={dish} large hint={false}/>
          <div className="modalMediaTag">
            <ValueMark>{breadcrumb[0] ?? 'Our menu'}</ValueMark>
          </div>
        </div>

        <div className="modalBody">
          <p className="modalCrumb">{breadcrumb.join('  ›  ')}</p>
          <h2 className="modalTitle" id="dishTitle">{dish.name}</h2>

          <p className="modalPrice">
            {onRequest
              ? <span className="askPrice">Priced on request</span>
              : <>{fmtPrice(unit)}<small>per serving</small></>}
          </p>

          {dish.desc && <p className="modalDesc">{dish.desc}</p>}

          {SHOW_FILE_HINTS && <code className="shotFile modalFile">images/dishes/{dishImage(dish)}</code>}

          {onRequest ? (
            <div className="askBox">
              <h3>Priced by our team</h3>
              <p>
                The kitchen prices this one to the weight of what you order, so it is confirmed before it
                reaches the pass. Call us and we will price it and take your order straight away.
              </p>
              <a className="btn askCall" href={telHref(CALL)}><PhoneIcon/>Call {CALL}</a>
            </div>
          ) : (
            <>
              {companions.length > 0 && (
                <ChoicePicker
                  id={'companion-' + dish.id}
                  legend="Choose your companion"
                  hint="One comes with the dish, the rest are an upgrade"
                  list={companions}
                  chosen={companion}
                  multiple={false}
                  onChange={next => setCompanion(next[0] ?? null)}
                />
              )}

              {salads.length > 0 && (
                <ChoicePicker
                  id={'salad-' + dish.id}
                  legend="Add a salad or side"
                  hint="Optional, choose as many as you like"
                  list={salads}
                  chosen={pickedSalads}
                  multiple
                  onChange={setPickedSalads}
                />
              )}

              <div className="modalBar">
                <div className="qtyBox">
                  <span className="qtyLabel">How many</span>
                  <div className="qtyStep">
                    <button onClick={() => setQty(q => Math.max(1, q - 1))} disabled={qty <= 1} aria-label="One less">&minus;</button>
                    <output aria-live="polite">{qty}</output>
                    <button onClick={() => setQty(q => Math.min(30, q + 1))} aria-label="One more"><PlusIcon/></button>
                  </div>
                </div>
                <div className="modalTotal">
                  <span>Total</span>
                  <b>{fmtPrice(total)}</b>
                </div>
              </div>

              <button className="btn addBtn addBtnWide" ref={addBtn} onClick={() => onAdd(dish, companion, pickedSalads, qty)}>
                <PlusIcon/>{trayCount > 0 ? 'Add ' + qty + ' more, ' + trayCount + ' in your order' : 'Add to my order'}
              </button>

              <p className="modalNote">
                {ADD_ONS_INCLUDED
                  ? 'Companions and salads are served on the side at no extra charge. Prices include taxes.'
                  : 'One companion comes with the dish, salads are on the side and charged as shown. Prices include taxes.'}
              </p>
            </>
          )}

          <a className="modalBack" href={'#sec-' + (section?.key ?? '')} onClick={onClose}>
            <ArrowIcon/>Back to the {section?.name ?? 'menu'}
          </a>
        </div>
      </div>
    </div>
  );
}

/* ------------------------------------------------------------------
   THE MENU
   ------------------------------------------------------------------ */

function MenuPage() {
  const [sections, setSections] = React.useState<MenuSection[]>(FALLBACK);
  const [live, setLive] = React.useState(false);
  const [tray, setTray] = React.useState<Line[]>([]);
  const [open, setOpen] = React.useState(false);
  // The category the guest has picked. null means the whole menu, so the
  // page still opens as one printed list until a category is chosen.
  const [cat, setCat] = React.useState<string | null>(null);
  const [name, setName] = React.useState('');
  const [phone, setPhone] = React.useState('');
  const [msg, setMsg] = React.useState<{ok: boolean; text: string} | null>(null);
  const [busy, setBusy] = React.useState(false);
  const [picked, setPicked] = React.useState<{dish: MenuItem; section: MenuSection | null; group: string} | null>(null);
  const [justAdded, setJustAdded] = React.useState<string | null>(null);

  React.useEffect(() => {
    apiUrl('menu')
      .then(url => fetch(url))
      .then(r => r.json())
      .then(d => {
        if (d.ok && Array.isArray(d.categories) && d.categories.some((c: {items?: unknown[]}) => Array.isArray(c.items) && c.items.length)) {
          const next = tidySections(toSections(d.categories));
          if (next.length) {
            setSections(next);
            setLive(true);
            setCat(c => (c === null || next.some(s => s.key === c)) ? c : null);
          }
        }
      })
      .catch(() => {});
  }, []);

  // Deep link: menu.html?dish=mushroom-soup opens that plate straight away.
  // Held back until the live menu has had its say, so a link to a dish that
  // only the kitchen knows about still opens.
  const deepLink = React.useRef(new URLSearchParams(location.search).get('dish'));
  React.useEffect(() => {
    const want = deepLink.current;
    if (!want) return;
    for (const s of sections) {
      for (const g of s.groups) {
        const hit = g.items.find(i => slugify(i.name) === want);
        if (hit) { deepLink.current = null; setPicked({dish: hit, section: s, group: g.name}); return; }
      }
    }
  }, [sections]);

  const writeDishParam = (slug: string | null) => {
    const u = new URL(location.href);
    if (slug) u.searchParams.set('dish', slug); else u.searchParams.delete('dish');
    history.replaceState(null, '', u.pathname + u.search + u.hash);
  };

  const openDish = (dish: MenuItem, section: MenuSection, group: string) => {
    setPicked({dish, section, group});
    writeDishParam(slugify(dish.name));
  };

  const closeDish = React.useCallback(() => {
    setPicked(null);
    writeDishParam(null);
  }, []);

  // Deep link: menu.html#sec-desserts opens straight on that one category.
  // Read once, and only accepted for a category that really exists.
  const hashCat = React.useRef(location.hash.indexOf('#sec-') === 0 ? decodeURIComponent(location.hash.slice(5)) : '');
  React.useEffect(() => {
    const want = hashCat.current;
    if (!want) return;
    if (sections.some(s => s.key === want)) { hashCat.current = ''; setCat(want); }
  }, [sections]);

  // A category that has since disappeared from the live menu falls back to
  // the whole menu rather than to an empty screen.
  const activeCat = cat && sections.some(s => s.key === cat) ? cat : null;
  const visible = activeCat ? sections.filter(s => s.key === activeCat) : sections;

  /** One category, or the whole menu, and back to the head of the list. */
  const pickCat = (key: string | null) => {
    setCat(key);
    const jump = document.getElementById('jump');
    if (jump) {
      const y = jump.getBoundingClientRect().top + window.scrollY;
      if (window.scrollY > y) window.scrollTo({top: y, behavior: 'smooth'});
    }
  };

  const lineKey = (dish: MenuItem, companion: Choice | null, salads: Choice[]): string =>
    [dish.id, companion?.key ?? 'plain', salads.map(s => s.key).sort().join('+') || 'none'].join('|');

  const add = (dish: MenuItem, companion: Choice | null = null, salads: Choice[] = [], qty = 1) => {
    if (dish.price === null) {
      setMsg({ok: false, text: dish.name + ' is priced on request. Please call ' + CALL + ' and the team will price it for you.'});
      return;
    }
    setMsg(null);
    const key = lineKey(dish, companion, salads);
    setTray(t => {
      const ex = t.find(x => x.key === key);
      return ex ? t.map(x => (x.key === key ? {...x, qty: x.qty + qty} : x)) : [...t, {key, dish, qty, companion, salads}];
    });
    setJustAdded(key);
    window.setTimeout(() => setJustAdded(k => (k === key ? null : k)), 900);
  };

  const bump = (key: string, d: number) => setTray(t => t.map(x => (x.key === key ? {...x, qty: Math.max(0, x.qty + d)} : x)).filter(x => x.qty > 0));
  const drop = (key: string) => setTray(t => t.filter(x => x.key !== key));
  const sumLine = (x: Line) => linePrice(x.dish, x.companion, x.salads) * x.qty;
  const subtotal = tray.reduce((s, x) => s + sumLine(x), 0);
  const count = tray.reduce((s, x) => s + x.qty, 0);
  const inTray = (dish: MenuItem) => tray.filter(x => x.dish.id === dish.id).reduce((s, x) => s + x.qty, 0);

  // The floating button stands in for the order panel only while the panel
  // is off the screen, so the two are never both asking for the same tap.
  const [orderAway, setOrderAway] = React.useState(true);
  React.useEffect(() => {
    const panel = document.getElementById('order');
    if (!panel) return;
    const io = new IntersectionObserver(([e]) => setOrderAway(e.intersectionRatio < .35), {threshold: [0, .35, 1]});
    io.observe(panel);
    return () => io.disconnect();
  }, []);

  React.useEffect(() => { if (tray.length) setOpen(true); }, [tray.length]);

  const goToOrder = () => {
    setOpen(true);
    document.getElementById('order')?.scrollIntoView({behavior: 'smooth', block: 'start'});
  };

  const send = async () => {
    if (!tray.length) { setMsg({ok: false, text: 'Add at least one dish to your order first.'}); return; }
    if (!name.trim() || !phone.trim()) { setMsg({ok: false, text: 'Please add your name and phone number so we can confirm your order.'}); return; }
    setBusy(true); setMsg(null);
    try {
      const res = await fetch(await apiUrl('order'), {method: 'POST', headers: {'Content-Type': 'application/json'}, body: JSON.stringify({
        name: name.trim(), phone: phone.trim(),
        items: tray.map(x => ({
          id: x.dish.id,
          qty: x.qty,
          companion: x.companion?.key ?? '',
          salads: x.salads.map(s => s.key)
        }))
      })});
      const d = await res.json();
      if (d.ok) {
        // Auto-print receipt for the order
        try {
          const now = new Date();
          const dateStr = now.toLocaleDateString('en-GB', { day: '2-digit', month: '2-digit', year: 'numeric' });
          const timeStr = now.toLocaleTimeString('en-GB', { hour: '2-digit', minute: '2-digit' });
          const printWindow = window.open('', '_blank', 'width=400,height=600');
          if (printWindow) {
            let receiptHtml = `
              <html>
                <head><title>Receipt - ${d.order_number}</title>
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
                  .id{display:flex;justify-content:space-between;margin-top:2px}
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
                    <div class="r"><span>Order No:</span><span>${d.order_number}</span></div>
                    <div class="r"><span>Date:</span><span>${dateStr}</span></div>
                    <div class="r"><span>Time:</span><span>${timeStr}</span></div>
                    <div class="r"><span>Customer:</span><span>${name.trim()}</span></div>
                    <div class="r"><span>Phone:</span><span>${phone.trim()}</span></div>
                  </div>
                  <div class="sec">
                    <div class="st">FOOD ORDER</div>`;
            tray.forEach((x) => {
              const unit = linePrice(x.dish, x.companion, x.salads);
              receiptHtml += `
                    <div class="it">
                      <b>${x.dish.name}</b>
                      <div class="id">
                        <span>${x.qty} x UGX ${unit.toLocaleString()}</span>
                        <span>UGX ${(unit*x.qty).toLocaleString()}</span>
                      </div>
                      ${(x.companion || x.salads.length) ? `<div style="font-size:9px;margin-top:1px;font-style:italic;">${[x.companion?('with '+x.companion.name.toLowerCase()):'', x.salads.length?x.salads.map(s=>s.name.toLowerCase()).join(', '):''].filter(Boolean).join(' · ')}</div>` : ''}
                    </div>`;
            });
            receiptHtml += `
                  </div>
                  <div class="tot">
                    <div class="tr"><span>Subtotal:</span><span>UGX ${Math.round(subtotal).toLocaleString()}</span></div>
                    <div class="tr gt"><span>TOTAL:</span><span>UGX ${Math.round(Number(d.total)||subtotal).toLocaleString()}</span></div>
                  </div>
                  <div class="f">
                    <p>Thank you for choosing Hotel Paradise on the Nile</p>
                    <p>Order placed successfully</p>
                  </div>
                </body></html>`;
            printWindow.document.write(receiptHtml);
            printWindow.document.close();
            printWindow.focus();
            setTimeout(() => { printWindow.print(); printWindow.close(); }, 500);
          }
        } catch {}
        // The order is with the kitchen and its total is fixed on the server.
        // Hand the guest to checkout so the payment follows the order number.
        const p = new URLSearchParams({
         src: 'order', ref: String(d.order_number || ''),
         amt: String(Math.round(Number(d.total) || subtotal || 0)),
         item: count + ' dish' + (count === 1 ? '' : 'es'), qty: String(count), unit: 'meal',
         name: name.trim(), phone: phone.trim()
        });
        window.location.assign('./pay.html?' + p.toString());
        return;
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

    <section className="pageHero hasCover">
      <SmartImage
        group="dishes"
        name="steak-dinner-and-wine-on-table"
        alt="A steak dinner and a glass of wine on the table at Hotel Paradise on the Nile"
        className="pageHeroCover"
        widths={[640, 1024, 1440, 1920]}
        sizes="100vw"
        position="50% 50%"
      />
      <div className="pageHeroInner">
        <p className="eyebrow">DINING AND BAR</p>
        <h1>Our menu, your order.</h1>
        <p>
          Every dish in its own section, with a photograph of each plate. Pick a category above to see only
          that part of the menu, or leave it on All to read the whole thing. Open any dish to see it in full,
          choose your companion and a salad, and add it to your order. Prices include taxes.
        </p>
      </div>
    </section>

    <div className="menuJump" id="jump">
      <div className="menuJumpInner" role="group" aria-label="Choose a category">
        <button
          className={'catChip' + (activeCat === null ? ' on' : '')}
          aria-pressed={activeCat === null}
          onClick={() => pickCat(null)}
        >All</button>
        {sections.map(s => (
          <button
            key={s.key}
            className={'catChip' + (activeCat === s.key ? ' on' : '')}
            aria-pressed={activeCat === s.key}
            onClick={() => pickCat(s.key)}
          >{s.name}</button>
        ))}
        <button className="jumpOrder" onClick={goToOrder}>
          Your order{count > 0 && ' (' + count + ')'}
        </button>
      </div>
    </div>

    <section className="menuWrap section">
      <div className="menuWatermark" aria-hidden="true"/>

      <div className="menuMeta">
        <span>{MENU_REVISION}</span>
        <span className="menuMetaCount">
          {activeCat ? visible.map(s => s.name).join(' · ') + ' · ' : ''}
          {totalDishes(visible)} dishes
        </span>
        <button className="printBtn" onClick={() => window.print()}>Print this menu</button>
      </div>

      {visible.map(section => (
        <section className="secBlock" id={'sec-' + section.key} key={section.key}>
          <header className="secHead">
            <SectionBanner section={section}>
              {section.eyebrow && <p className="secEyebrow">{section.eyebrow}</p>}
              <h2>{section.name}</h2>
            </SectionBanner>
            {section.blurb && <p className="secBlurb">{section.blurb}</p>}
          </header>

          {section.groups.map((g, gi) => (
            <div className={'subGroup' + (g.title === '' ? ' noHead' : '')} key={section.key + '-' + gi}>
              {g.title !== '' && <h3 className="subHead">{g.title}</h3>}
              <div className="dishGrid">
                {g.items.map(dish => {
                  const mine = inTray(dish);
                  return (
                  <article
                    className={'dishCard' + (mine > 0 ? ' held' : '')}
                    key={section.key + '-' + dish.id + '-' + dish.name}
                  >
                    <div className="dishOpenMedia">
                      <DishShot dish={dish}/>
                      <span className="dishPeek" aria-hidden="true">Open<ArrowIcon/></span>
                      {mine > 0 && <span className="dishHeld">{mine} in your order</span>}
                    </div>
                    <div className="dishOpenText">
                      <h4 className="dishTitle">{dish.name}</h4>
                      {dish.desc && <p className="dishDesc">{dish.desc}</p>}
                    </div>
                    <div className="dishBody">
                      <div className="dishFoot">
                        <b className={dish.price === null ? 'askPrice' : ''}>
                          {dish.price === null ? 'Price on request' : fmtPrice(dish.price)}
                        </b>
                        <button className="addBtn" onClick={() => openDish(dish, section, g.name)}>
                          <PlusIcon/>{mine > 0 ? 'Add more' : 'Add'}
                        </button>
                      </div>
                    </div>
                    <button
                      className="dishOpen"
                      onClick={() => openDish(dish, section, g.name)}
                      aria-label={'See the details of ' + dish.name}
                    />
                  </article>
                  );
                })}
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
            <em>{tray.length === 0 ? 'Nothing added yet. Open any dish to add it.' : count + ' item' + (count === 1 ? '' : 's') + '  ' + fmtPrice(subtotal)}</em>
          </span>
          <span className="orderPanelToggle">{open ? 'Collapse' : 'Open'}</span>
        </button>

        {open && <div className="orderPanelBody" id="orderBody">
          {tray.length === 0 ? (
            <div className="trayEmpty"><p>Your order is empty. Open any dish to see it in full, choose your companion and a salad, and it will appear here. You can drop or change anything freely before you send.</p></div>
          ) : (
            <div className="trayList">
              {tray.map(x => {
                const unit = linePrice(x.dish, x.companion, x.salads);
                return (
                  <div className={'trayItem' + (justAdded === x.key ? ' fresh' : '')} key={x.key}>
                    <div className="trayInfo">
                      <b>{x.dish.name}</b>
                      {(x.companion || x.salads.length > 0) && <span className="traySides">
                        {x.companion && <>with {x.companion.name.toLowerCase()}</>}
                        {x.companion && x.salads.length > 0 && ' · '}
                        {x.salads.length > 0 && x.salads.map(s => s.name).join(', ').toLowerCase()}
                      </span>}
                      <span>{fmtPrice(unit)} each</span>
                    </div>
                    <div className="trayQty"><button onClick={() => bump(x.key, -1)} aria-label="One less">&minus;</button><em>{x.qty}</em><button onClick={() => bump(x.key, 1)} aria-label="One more">+</button></div>
                    <span className="lineTotal">{fmtPrice(sumLine(x))}</span>
                    <button className="dropBtn" onClick={() => drop(x.key)} title="Drop this dish">Drop</button>
                  </div>
                );
              })}
              <div className="trayTotal"><span>Total</span><b>{fmtPrice(subtotal)}</b></div>
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
              <div className="bookMsg">Online ordering is briefly unavailable. Your list is still here — call <a href={telHref(CALL)}>{CALL}</a> to place it.</div>
            </div>
          )}

          {msg && <div className={msg.ok ? 'bookMsg ok' : 'bookMsg'}>{msg.text}</div>}
          <p className="plannerNote">You are in full control. Open any dish to change its companion or salad, or change quantities and drop any line before you send your order. No payment is taken here.</p>
        </div>}
      </div>
    </section>

    {count > 0 && orderAway && (
      <button className={'orderPill' + (justAdded ? ' pop' : '')} onClick={goToOrder}>
        <span className="orderPillDot">{count}</span>
        <span className="orderPillText">
          <b>Your order</b>
          <em>{fmtPrice(subtotal)}</em>
        </span>
      </button>
    )}

    {picked && (
      <DishDetail
        dish={picked.dish}
        section={picked.section}
        groupName={picked.group}
        trayCount={inTray(picked.dish)}
        onAdd={(d, c, s, q) => { add(d, c, s, q); closeDish(); goToOrder(); }}
        onClose={closeDish}
      />
    )}

    <Footer/>
  </div>;
}

createRoot(document.getElementById('root')!).render(<MenuPage/>);

