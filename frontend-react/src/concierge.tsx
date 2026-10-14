import React from 'react';
import {CALL, HOTEL, STUDIO} from './shared';
import type {MenuSection} from './menuData';

/* ------------------------------------------------------------------
   THE MENU CONCIERGE

   A voice that stands in the corner of the menu and simply waits. A
   woman welcomes the guest first, then a man offers to help and keeps
   listening. It reads the menu it is standing in front of, so it can
   point a guest to the right section, name the section a dish lives
   in, read a dish's price, or walk them through paying.

   Three rules shape it:

   - It never moves on its own. It speaks once to welcome a guest, and
     after that it only answers something the guest actually said. A
     guest who says nothing is left in peace for as long as they like.
   - It never records and never saves anything. Speech is read and
     answered in the moment and then forgotten; no audio is written
     anywhere, and nothing is sent to the hotel.
   - It never covers the page. On a phone it stands as a small round
     button until it is asked to open, the card itself can be quieted,
     folded away or closed at any time, and it is left out of print.

   The browser does the listening and the speaking through its own
   Web Speech API, so the microphone only opens after the guest has
   touched the page, and a guest who declines the microphone is simply
   told so once and never asked again.
   ------------------------------------------------------------------ */

type RecognitionResult = {isFinal: boolean; [index: number]: {transcript: string}};
type RecognitionEvent = {resultIndex: number; results: {length: number; [index: number]: RecognitionResult}};
type RecognitionError = {error: string};

interface RecognitionLike {
  lang: string;
  continuous: boolean;
  interimResults: boolean;
  maxAlternatives: number;
  start(): void;
  stop(): void;
  abort(): void;
  onstart: (() => void) | null;
  onend: (() => void) | null;
  onerror: ((e: RecognitionError) => void) | null;
  onresult: ((e: RecognitionEvent) => void) | null;
}

type RecognitionCtor = new () => RecognitionLike;

const speechWindow = (): {speech: typeof window.speechSynthesis | undefined; Ctor: RecognitionCtor | undefined} => {
  if (typeof window === 'undefined') return {speech: undefined, Ctor: undefined};
  const w = window as unknown as {speechSynthesis?: typeof window.speechSynthesis; SpeechRecognition?: RecognitionCtor; webkitSpeechRecognition?: RecognitionCtor};
  return {speech: w.speechSynthesis, Ctor: w.SpeechRecognition || w.webkitSpeechRecognition};
};

/* Words that carry no meaning for a menu search, so "I am looking for a
   dish of grilled fish" is read as "grilled fish". */
const STOP = new Set(['a','an','the','i','im','want','wanted','looking','look','for','some','please','me','my','is','am','are','was','of','to','can','could','would','will','show','tell','where','find','get','have','has','had','do','does','did','how','and','or','with','menu','food','dish','dishes','eat','eating','order','ordering','something','anything','what','which','that','this','these','those','it','on','in','at','by','about','like','give','need','needs','there','here','also','just','help','helping','you','your','please','tell','point','take','us','our']);

const strip = (s: string): string => s.toLowerCase().replace(/[^a-z0-9\s]/g, ' ').replace(/\s+/g, ' ').trim();

const stem = (w: string): string => (w.length > 3 ? w.replace(/s$/, '') : w);

const tokens = (s: string): string[] => strip(s).split(' ').filter(w => w && !STOP.has(w)).map(stem);

const FEMALE = /female|woman|zira|samantha|serena|aria|hazel|libby|sonia|joanna|salli|kendra|kimberly|ivy|karen|moira|tessa|fiona|veena|victoria|allison|ava|susan|nicole|catherine|clara|emily|google uk english female/i;
const MALE = /male|david|mark|daniel|alex|fred|rishi|george|guy|brian|matthew|arthur|oliver|thomas|james|ryan|nico|diego|jorge|aaron|william|eric|christopher|google uk english male/i;

/* The time of day, said once at the top of a welcome. */
const timeGreeting = (): string => {
  const h = new Date().getHours();
  if (h < 12) return 'Good morning';
  if (h < 17) return 'Good afternoon';
  return 'Good evening';
};

/* A phone number read the way a switchboard would say it, number by number,
   so the speech engine never turns "+256 759 504 928" into something a guest
   has to untangle. */
const DIGIT_WORD = ['zero', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine'];
const spokenPhone = (phone: string): string =>
  phone.replace(/[^0-9]/g, '')
    .replace(/(\d{3})(\d{3})(\d{3})(\d{3})/, '$1, $2, $3, $4')
    .split('')
    .map(ch => /\d/.test(ch) ? DIGIT_WORD[Number(ch)] : ch)
    .join(' ')
    .replace(/\s+/g, ' ')
    .trim();

function pickVoices(): {female?: SpeechSynthesisVoice; male?: SpeechSynthesisVoice} {
  try {
    const all = window.speechSynthesis.getVoices() || [];
    const english = all.filter(v => /^en([-_]|$)/i.test(v.lang));
    const pool = english.length ? english : all;
    const female = pool.find(v => FEMALE.test(v.name));
    const male = pool.find(v => MALE.test(v.name) && v !== female);
    return {female: female || pool[0], male: male || pool[pool.length - 1]};
  } catch {
    return {};
  }
}

type Line = {text: string; who: 'woman' | 'man'};

type Catalog = {
  cats: {key: string; name: string; toks: string[]}[];
  items: {name: string; price: number | null; sectionKey: string; sectionName: string; toks: string[]}[];
};

type Action =
  | {kind: 'payment'}
  | {kind: 'ordering'}
  | {kind: 'greeting'}
  | {kind: 'thanks'}
  | {kind: 'options'}
  | {kind: 'category'; name: string}
  | {kind: 'dish'; name: string; sectionName: string; priced: boolean; price: number | null}
  | {kind: 'info'; topic: string}
  | {kind: 'unknown'};

type Phase = 'idle' | 'listening' | 'speaking' | 'paused' | 'blocked';

/* Mark the section that was just spoken about, so the guest can see
   exactly which button to press without it being pressed for them. */
function highlightCategory(name: string): void {
  const chips = Array.from(document.querySelectorAll<HTMLElement>('.catChip'));
  const want = name.trim().toLowerCase();
  const chip = chips.find(c => (c.textContent || '').trim().toLowerCase() === want);
  if (!chip) return;
  chip.scrollIntoView({behavior: 'smooth', inline: 'center', block: 'nearest'});
  chip.classList.add('catGuide');
  window.setTimeout(() => chip.classList.remove('catGuide'), 5400);
}

function buildCatalog(sections: MenuSection[]): Catalog {
  const cats: Catalog['cats'] = [];
  const items: Catalog['items'] = [];
  const seen = new Set<string>();
  sections.forEach(s => {
    cats.push({key: s.key, name: s.name, toks: tokens(s.name)});
    s.groups.forEach(g => g.items.forEach(it => {
      const id = s.key + '\u0000' + it.name.toLowerCase();
      if (seen.has(id)) return;
      seen.add(id);
      items.push({name: it.name, price: it.price, sectionKey: s.key, sectionName: s.name, toks: tokens(it.name)});
    }));
  });
  return {cats, items};
}

/* The strongest match in a list, by counted words. Each query word earns a
   point when it appears in a name, a point when it is a prefix of one (so
   "pizza" finds "pizzeria"), and a half point for a looser overlap. A phrase
   spoken whole is worth three, so "grilled tilapia" never loses to "tilapia". */
function bestMatch<T extends {toks: string[]}>(query: string[], raw: string, list: T[], phrase: (t: T) => string): {hit: T; score: number} | null {
  let best: {hit: T; score: number} | null = null;
  list.forEach(t => {
    let score = 0;
    const toks = t.toks;
    query.forEach(q => {
      if (toks.includes(q)) { score += 1; return; }
      if (q.length < 3) return;
      for (const tok of toks) {
        if (tok.length >= 3 && (tok.startsWith(q) || q.startsWith(tok))) { score += 1; return; }
        if (tok.length >= 4 && (tok.includes(q) || q.includes(tok))) { score += 0.5; return; }
      }
    });
    const p = strip(phrase(t));
    if (p && raw.includes(p)) score += 3;
    if (score > 0 && (!best || score > best.score)) best = {hit: t, score};
  });
  return best;
}

const TOPICS: {id: string; re: RegExp}[] = [
  {id: 'menu', re: /\b(show me (the )?menu|open the menu|full menu|what do you have|what.s on (the )?(menu|offer)|what can i (get|eat|order))\b/},
  {id: 'roomservice', re: /\b(room ?service|in my room|bring it to my room|deliver to my room)\b/},
  {id: 'transfer', re: /\b(airport transfer|pick ?up|shuttle|transport from)\b/},
  {id: 'hours', re: /\b(opening|open (from|until|till|at)|close|closing|hours|what time|when do you|serve (from|until|till)|serving)\b/},
  {id: 'location', re: /\b(where (are|is|can i find|do you sit)|address|located?|directions?|how (do|can) i get there|how to get (there|to you)|kiira lane|near (the )?river|entebbe|airport|drive)\b/},
  {id: 'contact', re: /\b(phone|telephone|call|contact|email|whatsapp|reach|talk to|messenger)\b/},
  {id: 'table', re: /\b(book a table|reserve a table|table reservation|table for|table tonight)\b/},
  {id: 'reservations', re: /\b(book(ing)?|reserve|reservation|accommodat|stay(ing)?|room rate|rates?|availability|suite|vacancy|how much is a room|room price|overnight|check ?in|check ?out)\b/},
  {id: 'events', re: /\b(event|wedding|conference|meeting|party|venue|function|banquet|birthday|reception|honeymoon|get together)\b/},
  {id: 'facilities', re: /\b(pool|swim|swimming|gym|fitness|workout|spa|massage|sauna|laundr|garden|jog|tennis|jaccuzi)\b/},
  {id: 'bar', re: /\b(^-?\b)?(bar|drinks|cocktail|wine|beer|terrace|lounge)\b/},
  {id: 'wifi', re: /\b(wi ?fi|internet|wireless|network|password for)\b/},
  {id: 'parking', re: /\b(parking|park (the )?car|car park|driveway|garage)\b/},
  {id: 'delivery', re: /\b(deliver|delivery|takeaway|take away|takeout|take out|parcel|packed|lunch box)\b/},
  {id: 'vegetarian', re: /\b(vegetarian|vegan|veggie|plant based|no meat|meatless|halal|non ?veg)\b/},
  {id: 'spicy', re: /\b(spicy|spice|hot|peppery|mild|chilli)\b/},
  {id: 'children', re: /\b(children|child|kids|kid|bab(ies|y)|family|high chair)\b/},
  {id: 'breakfast', re: /\b(breakfast|morning meal|continental)\b/},
  {id: 'dress', re: /\b(dress ?code|what (should|do) i wear|attire|smart (casual|dress))\b/},
  {id: 'currency', re: /\b(currency|dollar|usd|us ?\$|exchange|ugx|shillings?)\b/},
  {id: 'news', re: /\b(news|updates|announcements|what.s happening|what.s on|loyalty|offer|special offer)\b/},
  {id: 'jobs', re: /\b(job|vacanc|career|hiring|work with us|employment|intern)\b/},
  {id: 'gift', re: /\b(gift|voucher|gift ?card)\b/},
  {id: 'safety', re: /\b(security|safe|secure|surveillance|cctv)\b/},
  {id: 'founding', re: /\b(when (did|was) (it|you|the hotel)|founded|founder|owner|who (started|owns|built|opened)|established|since when|how old (is|are)|history|story|registration|registered|ursb)\b/},
  {id: 'about', re: /\b(who are you|tell me about|what is (this|your|the hotel)|about (you|the hotel|us)|our story|history)\b/},
  {id: 'designer', re: /\b(who (designed|built|made|created|developed)|designer|developer|made by|built by|website designer|reagan|reagansoft|software house|who is behind)\b/},
  {id: 'prices', re: /\b(price|prices|cost|how much|how expensive|cheap)\b/},
];

const CATEGORY_RX = /\b(breakfast|pizza|burger|sandwich|soup|dessert|starter|seafood|asian|chinese|pasta|curry|sizzler|chicken|beef|pork|salad|rice|noodle|omelet|wrap|accompaniment|drink|beverage)\b/;

function interpret(text: string, catalog: Catalog): Action {
  const raw = strip(text);
  const query = tokens(text);

  // A dish or a section, first: "grilled tilapia", "pizza", "how much is X".
  const dish = bestMatch(query, raw, catalog.items, t => t.name);
  const cat = bestMatch(query, raw, catalog.cats, t => t.name);

  if (dish || cat) {
    if (dish && cat && dish.score <= cat.score && query.length <= 2) {
      return {kind: 'category', name: cat.hit.name};
    }
    if (dish && (!cat || dish.score > cat.score)) {
      return {kind: 'dish', name: dish.hit.name, sectionName: dish.hit.sectionName, priced: dish.hit.price !== null, price: dish.hit.price};
    }
    if (cat) return {kind: 'category', name: cat.hit.name};
  }

  for (const t of TOPICS) {
    if (t.re.test(raw)) return {kind: 'info', topic: t.id};
  }

  if (/\b(pay|payment|paying|bill|invoice|receipt|send my order|mobile money|\bmomo\b|mtn|airtel|pesapal|visa|master ?card|\bcard\b|bank transfer|transfer the money|checkout)\b/.test(raw)) {
    return {kind: 'payment'};
  }
  if (/\b(add (to my )?order|place (an|my|a) order|start (an|my|a) order|send (my|our|an) order|make (an|my|a) order|how (do|can) i (order|add|buy|send))\b/.test(raw)) {
    return {kind: 'ordering'};
  }

  if (/\b(hello|hi|hey|good (morning|afternoon|evening))\b/.test(raw)) return {kind: 'greeting'};
  if (/\b(thank|thanks)\b/.test(raw)) return {kind: 'thanks'};
  if (/\b(what can you do|what do you do|help me|help\b|options?)\b/.test(raw)) return {kind: 'options'};

  if (raw === '' || CATEGORY_RX.test(raw)) return {kind: 'options'};
  return {kind: 'unknown'};
}

const PH = spokenPhone(CALL);

const INFO_ANSWERS: Record<string, string> = {
  menu: `This page is the whole menu. Name any dish and I will read you its price, or name a section and I will point you to it.`,
  roomservice: `Room service runs through the same kitchen. Add a dish to your order and tell us your room number when we call to confirm.`,
  transfer: `We arrange pick-ups from the airport or anywhere in Jinja. Call the front desk on ${PH} and tell them your arrival time.`,
  hours: `Breakfast runs from six thirty to ten thirty and is included in every room rate. Lunch runs until three, and dinner until eleven at night.`,
  location: `We are at Plot 12, 19 and 25, Kiira Lane, Jinja — on the banks of the River Nile, five minutes from town and three hours from Entebbe Airport.`,
  contact: `The front desk is on ${PH}, answered around the clock. You can also write to ${HOTEL.email} or visit ${HOTEL.website}.`,
  table: `Walk ins are always welcome. For a busy evening, call ${PH} and we will hold a table for your party.`,
  reservations: `Open the Rooms page, pick your dates and your room, and reserve — or call ${PH} and we will arrange it. Breakfast is included in every room rate.`,
  events: `Our lawns run to the Nile, so we host weddings, parties and conferences by the river. Open the Events page, or call the front desk and our team will plan it with you.`,
  facilities: `There is a pool, a gym, a riverside bar and a terrace, plus laundry and room service for our guests.`,
  bar: `Cold beer, a careful wine list and cocktails, by the window or out on the terrace as the sun sets behind Jinja.`,
  wifi: `Wi-Fi is free for every guest throughout the hotel. Ask the front desk for the password when you arrive.`,
  parking: `Yes. We have private, secure parking on the grounds, watched around the clock.`,
  delivery: `Yes. Order from this menu, add your delivery address, and we will bring it to you in Jinja. The kitchen confirms every delivery by phone first.`,
  vegetarian: `The salads are full plates, the pizzeria has vegetable pizzas, and the kitchen will leave the meat off any curry or sizzler — just say the word.`,
  spicy: `Say how hot you like it, from mild to very hot, and the kitchen will cook it to your taste.`,
  children: `Children are welcome — high chairs, smaller portions and safe green lawns. Just tell your waiter.`,
  breakfast: `Breakfast runs from six thirty to ten thirty and is included in every room rate — eggs, sausage, toast, fruit, fresh juice and hot Ugandan coffee.`,
  dress: `Smart casual is perfect at any hour — you are by the Nile. For an evening event or a wedding, most guests dress up a little more.`,
  currency: `Prices are in Ugandan shillings and include taxes. Pay cash, or at checkout by card, bank transfer, Mobile Money, Airtel Money or Pesapal.`,
  news: `Open the News page for our latest news, specials and vacancies.`,
  jobs: `Send your CV to the front desk email on the website, and our Human Resource office will be in touch.`,
  gift: `Call ${PH} and we will arrange a gift card for any amount, valid across the rooms, the restaurant and the bar.`,
  safety: `The entrance and the grounds are watched around the clock, rooms have secure locks, and parking is on site.`,
  founding: `Hotel Paradise on the Nile is one of the oldest and best loved hotels in Jinja, and one of the most iconic on the river. It opened its doors on ${HOTEL.founded}, and it is registered with ${HOTEL.registration}. It was founded by ${HOTEL.founders}. ${HOTEL.founderSurnameSpoken} that is the family name. With vision, commitment and a great deal of hard work, and by God's grace, they grew the hotel from its first ${HOTEL.roomsAtOpening} rooms into the ${HOTEL.roomsToday} rooms you see today. Mr. Otile Francis and Mrs. Magrate Otile are deeply respected in Jinja, and the hotel they built remains a true landmark on the Nile.`,
  rooms: `The hotel opened with ${HOTEL.roomsAtOpening} rooms in nineteen ninety eight and has grown to ${HOTEL.roomsToday} today, from cosy singles to full suites with a view of the river. Say a room type, or open the Rooms page, and I will tell you more.`,
  about: `Hotel Paradise on the Nile is one of Jinja's iconic and oldest hotels. It sits on the banks of the River Nile in Jinja, and it has been on the water since ${HOTEL.founded}. It was founded by ${HOTEL.founders}, who still own it today. They opened the doors with just ${HOTEL.roomsAtOpening} rooms, and by their effort and God's grace it has grown to ${HOTEL.roomsToday} today - rooms with a view, a riverside restaurant, a pool, a gym and a bar. It is registered with ${HOTEL.registration}.`,
  designer: `This website and the management system were developed by ${STUDIO.founder}, founder of ${STUDIO.name}, based in ${STUDIO.city}. Their office is in Jinja. For more about the company, visit their website, reagansoftinnovation dot com. You can also find them by searching Reagansoft Innovation Limited on Google.`,
  prices: `Name the dish and I will read you its price, or name a section and I will point you to it.`,
  fallback: `I did not quite catch that. I can tell you about the hotel's history and its founders, our rooms, the menu, payment, or the team behind this website. For anything else, please call the front desk on ${PH}, or reach our developers, Reagansoft Innovation, at reagansoftinnovation dot com. I am still listening.`,
};

export function MenuConcierge({sections}: {sections: MenuSection[]}) {
  const {speech, Ctor} = React.useMemo(speechWindow, []);
  const ready = Boolean(speech && Ctor && typeof SpeechSynthesisUtterance !== 'undefined');

  const catalog = React.useMemo(() => buildCatalog(sections), [sections]);

  const [phase, setPhase] = React.useState<Phase>('idle');
  const [caption, setCaption] = React.useState('');
  const [heard, setHeard] = React.useState('');
  const [note, setNote] = React.useState('');
  const [closed, setClosed] = React.useState(false);
  const [expanded, setExpanded] = React.useState<boolean>(
    () => typeof window !== 'undefined' && window.matchMedia('(min-width: 1001px)').matches
  );

  const recRef = React.useRef<RecognitionLike | null>(null);
  const voicesRef = React.useRef<{female?: SpeechSynthesisVoice; male?: SpeechSynthesisVoice}>({});
  const wantRef = React.useRef(false);
  const pausedRef = React.useRef(false);
  const speakingRef = React.useRef(false);
  const activeRef = React.useRef(false);
  const pendingRef = React.useRef(0);
  const batchRef = React.useRef(0);
  const startedRef = React.useRef(false);
  const restartRef = React.useRef(0);
  const watchdogRef = React.useRef(0);
  const lastRef = React.useRef({text: '', at: 0});
  const closedRef = React.useRef(false);
  const handleRef = React.useRef<(t: string) => void>(() => {});
  const beginRef = React.useRef<() => void>(() => {});

  /* ------- the guest's own voice, read and answered, never kept ------- */

  const startRec = React.useCallback(() => {
    const rec = recRef.current;
    if (!rec || !wantRef.current || speakingRef.current || activeRef.current || closedRef.current) return;
    window.clearTimeout(restartRef.current);
    try { rec.start(); activeRef.current = true; } catch { activeRef.current = false; }
  }, []);

  const abortRec = React.useCallback(() => {
    try { recRef.current?.abort(); } catch { /* not started, nothing to do */ }
    activeRef.current = false;
  }, []);

  const finishSpeech = React.useCallback(() => {
    window.clearTimeout(watchdogRef.current);
    pendingRef.current = 0;
    speakingRef.current = false;
    setPhase(pausedRef.current ? 'paused' : 'listening');
    startRec();
  }, [startRec]);

  const makeUtter = (text: string, who: 'woman' | 'man'): SpeechSynthesisUtterance => {
    const u = new SpeechSynthesisUtterance(text);
    const v = who === 'woman' ? voicesRef.current.female : voicesRef.current.male;
    if (v) u.voice = v;
    u.lang = v?.lang || 'en-US';
    u.rate = 0.85;
    u.pitch = who === 'woman' ? 1.03 : 0.82;
    u.volume = 1;
    return u;
  };

  const stopSpeaking = React.useCallback(() => {
    try { speech?.cancel(); } catch { /* nothing was speaking */ }
    window.clearTimeout(watchdogRef.current);
    batchRef.current += 1;
    pendingRef.current = 0;
    speakingRef.current = false;
  }, [speech]);

  const speakAll = React.useCallback((lines: Line[]) => {
    if (!speech || !lines.length || closedRef.current) return;
    stopSpeaking();
    abortRec();
    const batch = batchRef.current;
    speakingRef.current = true;
    pendingRef.current = lines.length;
    setPhase('speaking');
    lines.forEach(line => {
      const u = makeUtter(line.text, line.who);
      u.onstart = () => { if (batch === batchRef.current) setCaption(line.text); };
      u.onend = u.onerror = () => {
        if (batch !== batchRef.current) return;
        pendingRef.current = Math.max(0, pendingRef.current - 1);
        if (pendingRef.current === 0) finishSpeech();
      };
      window.speechSynthesis.speak(u);
    });
    // A browser that never reports the end of a line must not leave the
    // concierge mute and deaf: after a generous pause it simply resumes.
    window.clearTimeout(watchdogRef.current);
    watchdogRef.current = window.setTimeout(finishSpeech, 9000 * lines.length + 4000);
  }, [speech, stopSpeaking, abortRec, finishSpeech]);

  const handle = React.useCallback((text: string) => {
    const now = Date.now();
    const key = text.toLowerCase();
    if (key === lastRef.current.text && now - lastRef.current.at < 2600) return;
    lastRef.current = {text: key, at: now};
    setHeard(text);

    const action = interpret(text, catalog);
    if (action.kind === 'payment') {
      speakAll([{who: 'man', text: `Open the Your order panel at the bottom and send it. Checkout takes Pesapal, MTN or Airtel Mobile Money, or Visa and Mastercard, and your receipt is emailed at once. We are on ${PH} if you would like a hand.`}]);
      return;
    }
    if (action.kind === 'ordering') {
      speakAll([{who: 'man', text: 'Open any dish, choose your companion and salad, then add it. When you are ready, open the Your order panel and send it. Name any dish and I will point you to it.'}]);
      return;
    }
    if (action.kind === 'greeting') {
      speakAll([
        {who: 'woman', text: `${timeGreeting()}, and welcome to Hotel Paradise on the Nile.`},
        {who: 'man', text: 'Say any dish and I will point you to it, or ask me anything about the hotel.'}
      ]);
      return;
    }
    if (action.kind === 'thanks') {
      speakAll([{who: 'man', text: 'You are most welcome. I am still here whenever you need me.'}]);
      return;
    }
    if (action.kind === 'options') {
      const examples = catalog.cats.slice(0, 3).map(c => c.name.toLowerCase()).join(', ');
      speakAll([{who: 'man', text: `Name a dish, and I will point you to it. Or say a section, such as ${examples}. Ask anything about the hotel — hours, location, delivery, payment — and I will answer.`}]);
      return;
    }
    if (action.kind === 'category') {
      highlightCategory(action.name);
      speakAll([{who: 'man', text: `What you are looking for sits in the ${action.name} section. Tap it in the row of buttons near the top — I have marked it for you.`}]);
      return;
    }
    if (action.kind === 'dish') {
      highlightCategory(action.sectionName);
      const price = action.priced
        ? ` It is ${action.price!.toLocaleString()} shillings.`
        : ' The kitchen prices this one on request, so do call us and we will confirm it.';
      speakAll([{who: 'man', text: `${action.name} sits in the ${action.sectionName} section.${price} Tap its card to open it. I have marked the ${action.sectionName} section for you.`}]);
      return;
    }
    if (action.kind === 'info') {
      const answer = INFO_ANSWERS[action.topic] || INFO_ANSWERS.prices;
      speakAll([{who: 'man', text: answer}]);
      return;
    }
    speakAll([{who: 'man', text: INFO_ANSWERS.fallback}]);
  }, [catalog, speakAll]);

  handleRef.current = handle;

  /* ------- the welcome, once, in a woman's voice then a man's ------- */

  const begin = React.useCallback(() => {
    if (!ready || closedRef.current) return;
    startedRef.current = true;
    wantRef.current = true;
    pausedRef.current = false;
    speakAll([
      {who: 'woman', text: `${timeGreeting()}, and welcome to Hotel Paradise on the Nile.`},
      {who: 'man', text: `I am your menu guide. Say any dish, such as grilled tilapia, and I will point you to it. Ask anything about the hotel and I will answer.`},
      {who: 'man', text: 'Please speak whenever you are ready. I am listening.'}
    ]);
  }, [ready, speakAll]);

  beginRef.current = begin;

  const pause = React.useCallback(() => {
    pausedRef.current = true;
    wantRef.current = false;
    stopSpeaking();
    abortRec();
    setPhase('paused');
    setCaption('');
  }, [stopSpeaking, abortRec]);

  const resume = React.useCallback(() => {
    pausedRef.current = false;
    wantRef.current = true;
    setNote('');
    if (!startedRef.current) { beginRef.current(); return; }
    setPhase('listening');
    startRec();
  }, [startRec]);

  /* ------- close hides it for the whole visit; fold keeps it listening ------- */

  const closeConcierge = React.useCallback(() => {
    closedRef.current = true;
    pausedRef.current = true;
    wantRef.current = false;
    stopSpeaking();
    abortRec();
    setPhase('paused');
    setCaption('');
    setHeard('');
    setClosed(true);
  }, [stopSpeaking, abortRec]);

  const openPanel = React.useCallback(() => {
    if (closedRef.current) return;
    setExpanded(true);
    if (!startedRef.current) beginRef.current();
  }, []);

  const foldPanel = React.useCallback(() => {
    setExpanded(false);
  }, []);

  /* ------- the little status line, folded in or open ------- */

  const miniStatus =
    phase === 'idle' ? 'Tap to begin' :
    phase === 'paused' ? 'Resume to listen' :
    phase === 'blocked' ? 'Mic unavailable' :
    phase === 'speaking' ? 'Speaking...' :
    'Listening...';

  const status = phase === 'idle'
    ? 'Tap the Begin button, or tap anywhere on the page, and I will welcome you.'
    : phase === 'paused'
      ? 'Voice is quiet. Press Resume when you would like me to listen again, or Close to hide me.'
      : phase === 'blocked'
        ? note
        : phase === 'speaking'
          ? caption
          : 'Listening... speak to search the menu, ask a price, or ask about the hotel.';

  /* ------- set-up: voices, the microphone, the first touch ------- */

  React.useEffect(() => {
    if (!ready) return;
    const load = () => { voicesRef.current = pickVoices(); };
    load();
    speech!.addEventListener('voiceschanged', load);
    return () => speech!.removeEventListener('voiceschanged', load);
  }, [ready, speech]);

  React.useEffect(() => {
    if (!ready || !Ctor) return;
    const rec = new Ctor();
    rec.lang = 'en-US';
    rec.continuous = true;
    rec.interimResults = false;
    rec.maxAlternatives = 1;
    rec.onstart = () => {
      activeRef.current = true;
      if (!pausedRef.current && !speakingRef.current) setPhase('listening');
    };
    rec.onend = () => {
      activeRef.current = false;
      if (wantRef.current && !speakingRef.current && !closedRef.current) {
        window.clearTimeout(restartRef.current);
        restartRef.current = window.setTimeout(() => { if (wantRef.current && !pausedRef.current && !closedRef.current) startRec(); }, 350);
      }
    };
    rec.onerror = (ev) => {
      activeRef.current = false;
      const err = ev?.error;
      if (err === 'not-allowed' || err === 'service-not-allowed' || err === 'audio-capture') {
        wantRef.current = false;
        setPhase('blocked');
        setNote(`I could not reach your microphone, so I will stay quiet. You can still search the menu, tap a section, or call ${CALL}.`);
      }
    };
    rec.onresult = (ev) => {
      let text = '';
      for (let i = ev.resultIndex; i < ev.results.length; i += 1) {
        const r = ev.results[i];
        if (r.isFinal) text += ' ' + r[0].transcript;
      }
      text = text.trim();
      if (text) handleRef.current(text);
    };
    recRef.current = rec;
    return () => {
      try { rec.onend = null; rec.onresult = null; rec.onerror = null; rec.abort(); } catch { /* already gone */ }
      recRef.current = null;
      window.clearTimeout(restartRef.current);
      window.clearTimeout(watchdogRef.current);
    };
  }, [ready, Ctor, startRec]);

  React.useEffect(() => {
    if (!ready) return;
    const go = () => { if (!closedRef.current && !startedRef.current) beginRef.current(); };
    const opts: AddEventListenerOptions = {passive: true};
    document.addEventListener('pointerdown', go, opts);
    document.addEventListener('keydown', go);
    document.addEventListener('touchstart', go, opts);
    return () => {
      document.removeEventListener('pointerdown', go, opts);
      document.removeEventListener('keydown', go);
      document.removeEventListener('touchstart', go, opts);
    };
  }, [ready]);

  React.useEffect(() => {
    if (!ready) return;
    const onVis = () => {
      if (document.hidden) { abortRec(); }
      else if (wantRef.current && !pausedRef.current && !speakingRef.current && !closedRef.current) { startRec(); }
    };
    document.addEventListener('visibilitychange', onVis);
    return () => document.removeEventListener('visibilitychange', onVis);
  }, [ready, abortRec, startRec]);

  /* The install prompt steps up so it never sits on the concierge. The
     compact flag tells it how high to step: folded or full. */
  React.useEffect(() => {
    if (!ready) return;
    const cl = document.body.classList;
    if (closed) { cl.remove('hpn-concierge'); cl.remove('hpn-concierge-min'); }
    else { cl.add('hpn-concierge'); cl.toggle('hpn-concierge-min', !expanded); }
    return () => { cl.remove('hpn-concierge'); cl.remove('hpn-concierge-min'); };
  }, [ready, closed, expanded]);

  React.useEffect(() => () => { try { speech?.cancel(); } catch { /* leaving the page */ } }, [speech]);

  if (!ready || closed) return null;

  if (!expanded) {
    return (
      <button type="button" className={'conLauncher' + (phase === 'listening' || phase === 'speaking' ? ' live' : '')} onClick={openPanel} aria-label="Open the menu voice concierge">
        <span className="conIcon" aria-hidden="true">
          <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
            <path d="M11 5 6.5 9H3v6h3.5L11 19z"/>
            <path d="M15.5 8.6a4.7 4.7 0 0 1 0 6.8"/>
            <path d="M18.4 6a8.4 8.4 0 0 1 0 12"/>
          </svg>
          <i className="conDot" />
        </span>
        <span className="conLauncherText">
          <b>Menu concierge</b>
          <em>{miniStatus}</em>
        </span>
      </button>
    );
  }

  return (
    <div className={'concierge phase-' + phase} role="region" aria-label="Menu voice concierge">
      <div className="conHeader">
        <span className="conIcon" aria-hidden="true">
          <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
            <path d="M11 5 6.5 9H3v6h3.5L11 19z"/>
            <path d="M15.5 8.6a4.7 4.7 0 0 1 0 6.8"/>
            <path d="M18.4 6a8.4 8.4 0 0 1 0 12"/>
          </svg>
          <i className="conDot" />
        </span>
        <b className="conTitle">Menu concierge</b>
        <button type="button" className="conIconBtn" aria-label="Fold the menu concierge away" onClick={foldPanel}>
          <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true">
            <path d="m6 9 6 6 6-6"/>
          </svg>
        </button>
        <button type="button" className="conIconBtn" aria-label="Close the menu concierge" onClick={closeConcierge}>×</button>
      </div>

      <div className="conBody">
        <span className="conLine" aria-live="polite">{status}</span>
        {heard && phase !== 'idle' && phase !== 'blocked' && <span className="conHeard">Heard: {heard}</span>}
        <span className="conPrivacy">Nothing is recorded or saved.</span>
      </div>

      <div className="conActions">
        {phase === 'idle' && <button type="button" className="conBtn" onClick={begin}>Begin</button>}
        {(phase === 'listening' || phase === 'speaking') && <button type="button" className="conBtn" onClick={pause}>Quiet</button>}
        {(phase === 'paused' || phase === 'blocked') && <button type="button" className="conBtn" onClick={resume}>{phase === 'blocked' ? 'Try again' : 'Resume'}</button>}
        <button type="button" className="conBtn conBtnGhost" onClick={foldPanel}>Fold away</button>
        <button type="button" className="conBtn conBtnGhost" onClick={closeConcierge}>Close</button>
      </div>
    </div>
  );
}