import React from 'react';
import {CALL, HOTEL, STUDIO} from './shared';
import type {MenuSection} from './menuData';

/* ------------------------------------------------------------------
   PARADISE, THE VOICE GUIDE

   A calm voice that stands in the corner of a page and simply waits. A
   woman welcomes the guest first, then a man offers to help and keeps
   listening. It knows the whole hotel by heart - who owns it, when it
   opened, the rooms, the restaurant, the events, the way here, the way
   to pay, and the people behind the website - and it reads the menu it
   is standing in front of, so it can point a guest to the right
   section, name the section a dish lives in, read a dish's price, or
   walk them through paying.

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

   The browser does the listening and the speaking through its own Web
   Speech API, so the microphone only opens after the guest has touched
   the page, and a guest who declines the microphone is simply told so
   once and never asked again.

   The answers are written out here, in full, rather than guessed at, so
   the hotel's own story, its owners and its facts are always said the
   same way. When a guest asks something it does not hold, it says so
   plainly and points them to the front desk rather than inventing an
   answer.
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

/* Words that carry no meaning for a search, so "I am looking for a dish of
   grilled fish" is read as "grilled fish". */
const STOP = new Set(['a','an','the','i','im','want','wanted','looking','look','for','some','please','me','my','is','am','are','was','of','to','can','could','would','will','show','tell','where','find','get','have','has','had','do','does','did','how','and','or','with','menu','food','dish','dishes','eat','eating','order','ordering','something','anything','what','which','that','this','these','those','it','on','in','at','by','about','like','give','need','needs','there','here','also','just','help','helping','you','your','tell','point','take','us','our']);

const strip = (s: string): string => s.toLowerCase().replace(/[^a-z0-9\s]/g, ' ').replace(/\s+/g, ' ').trim();

const stem = (w: string): string => (w.length > 3 ? w.replace(/s$/, '') : w);

const tokens = (s: string): string[] => strip(s).split(' ').filter(w => w && !STOP.has(w)).map(stem);

/* Speech recognition mishears a name far more often than a common word, so a
   handful of likely spellings of the owner's surname and the town are folded
   back to the true ones before anything is looked up. */
const NAME_FIXES: [RegExp, string][] = [
  [/\b(oh|o|a|the|eye)\s+tile\b/g, 'otile'],
  [/\botill?e?\b/g, 'otile'],
  [/\botil+a\b/g, 'otile'],
  [/\botel+i?\b/g, 'otile'],
  [/\bmagrat\w*/g, 'magrate'],
  [/\bjin[gj]ah?\b/g, 'jinja'],
  [/\bkii?ra\b/g, 'kiira']
];
const normalise = (s: string): string => NAME_FIXES.reduce((t, [re, v]) => t.replace(re, v), s);

const FEMALE = /female|woman|zira|samantha|serena|aria|hazel|libby|sonia|joanna|salli|kendra|kimberly|ivy|karen|moira|tessa|fiona|veena|victoria|allison|ava|susan|nicole|catherine|clara|emily|michelle|elizabeth|google uk english female|google us english/i;
const MALE = /male|david|mark|daniel|alex|fred|rishi|george|guy|brian|matthew|arthur|oliver|thomas|james|ryan|nico|diego|jorge|aaron|william|eric|christopher|liam|connor|google uk english male/i;

/* Where two voices are available, the richer one is chosen: an "online" or
   "natural" voice first, then a Google voice, then a Microsoft one. A phone
   that offers only one voice still works, it is simply the voice used. */
const voiceScore = (v: SpeechSynthesisVoice): number => {
  let score = 0;
  if (/natural|neural|online|premium|enhanced|wavenet/i.test(v.name)) score += 8;
  if (/google/i.test(v.name)) score += 4;
  if (/microsoft/i.test(v.name)) score += 2;
  if (!v.localService) score += 1;
  return score;
};

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

/* The names and a few hotel words respelled for the voice alone, so the screen
   keeps the true spelling while the ear hears the right sound. The owner's
   surname is the important one: "Otile" is said "oh-teh-ah-leh". */
const SAY: [RegExp, string][] = [
  [/\bOtile\b/g, HOTEL.founderSurnameSay],
  [/\bKiira\b/g, 'Kee-rah'],
  [/\bJinja\b/g, 'Jin-jah'],
  [/\bPesapal\b/g, 'Pess-a-pal']
];
const forSpeech = (text: string): string => SAY.reduce((t, [re, v]) => t.replace(re, v), text);

function pickVoices(): {female?: SpeechSynthesisVoice; male?: SpeechSynthesisVoice} {
  try {
    const all = window.speechSynthesis.getVoices() || [];
    const english = all.filter(v => /^en([-_]|$)/i.test(v.lang));
    const pool = english.length ? english : all;
    if (!pool.length) return {};
    const rank = (list: SpeechSynthesisVoice[]) => [...list].sort((a, b) => voiceScore(b) - voiceScore(a));
    const female = rank(pool.filter(v => FEMALE.test(v.name)))[0];
    const male = rank(pool.filter(v => MALE.test(v.name) && v !== female))[0];
    const rest = rank(pool);
    return {
      female: female || rest[0],
      male: male || rest.find(v => v !== female) || rest[0]
    };
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
  | {kind: 'goodbye'}
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

/* The hotel's knowledge, in the order it should be trusted. A guest who names
   the owners or asks about the story is answered from these facts before any
   dish or section is considered, so a question about the hotel is never read
   as a question about the menu. */
const TOPICS: {id: string; re: RegExp}[] = [
  {id: 'assistant', re: /\b(are you (a )?(human|robot|real|ai)|who are you|what are you|is this a robot|the voice)\b/},
  {id: 'owners', re: /\b(owners?|proprietor|proprietors|landlord|who (owns?|owned|runs?|manages?)|whose (hotel|place)|belongs? to|owned by|otile|francis|the boss|the management|general manager)\b/},
  {id: 'wife', re: /\b(his wife|the wife|magrate|husband|co ?founder|co ?owner|the madam|mrs|the missus)\b/},
  {id: 'developer', re: /\b(developer|designer|reagansoft|reagan|who (designed|built|made|created|developed|programmed|coded|wrote|did) (this|the|your|it)|who (made|built|designed|did) this|who is behind|who built (this|the) (site|website|web|page|system|software|app)|built (this|the) (site|website|system))\b/},
  {id: 'founding', re: /\b(founder|founders|founded|establish\w*|estab|inception|when (did|was|has|it|the hotel|this hotel|you)|started|began|opened (its doors|the doors)|first opened|since when|how (old|long)|history|the story|origin|who (started|began|built|opened|established|created|put up))\b/},
  {id: 'about', re: /\b(tell me about|what is (this|your|the hotel)|about (you|the hotel|us|this place)|our story|an overview|introduce)\b/},
  {id: 'tables', re: /\b(book a table|reserve a table|table reservation|table for|a table)\b/},
  {id: 'location', re: /\b(where (are|is|can i find|do you sit)|address|located?|directions?|how (do|can) i get there|how to get (there|to you)|kiira|near (the )?river|entebbe|airport|drive|map|find you)\b/},
  {id: 'contact', re: /\b(phone|telephone|call|contact|email|e mail|whatsapp|reach|talk to|messenger|social|facebook|instagram|twitter|tiktok|number)\b/},
  {id: 'web', re: /\b(your (website|web|url|site)|hotel (website|site)|web address|online)\b/},
  {id: 'rooms', re: /\b(rooms?|suite|accommodat|room type|rate|rates|tariff|price of a room|how much is a room|overnight|stay(ing)?|vacancy|availability|book(ing)?|reserve|reservation)\b/},
  {id: 'checkin', re: /\b(check ?in|check ?out|arrival time|early check|late check)\b/},
  {id: 'events', re: /\b(event|wedding|conference|meeting|party|venue|function|banquet|birthday|reception|honeymoon|get together|seminar|launch|gala|hall|convention)\b/},
  {id: 'facilities', re: /\b(pool|swim|swimming|gym|fitness|workout|spa|massage|sauna|laundr|garden|jog|tennis|jacuzzi|health club|facilit)\b/},
  {id: 'restaurant', re: /\b(restaurant|dining|dine|kitchen|chef|food|meals?|eat|cousine|cuisine)\b/},
  {id: 'hours', re: /\b(opening|open (from|until|till|at|in)|close|closing|hours|what time|when do you|serve (from|until|till)|serving|breakfast|lunch|dinner|supper)\b/},
  {id: 'bar', re: /\b(bar|drinks?|cocktail|wine|beer|spirits?|whisk|whiskey|terrace|lounge)\b/},
  {id: 'roomservice', re: /\b(room ?service|in my room|bring it to my room|deliver to my room)\b/},
  {id: 'delivery', re: /\b(deliver|delivery|takeaway|take away|takeout|take out|parcel|packed|lunch box)\b/},
  {id: 'transfer', re: /\b(airport transfer|pick ?up|shuttle|taxi|transport from|transfer from|get picked|driver)\b/},
  {id: 'parking', re: /\b(parking|park (the|my)? ?car|car park|driveway|garage)\b/},
  {id: 'wifi', re: /\b(wi ?fi|internet|wireless|network|password for)\b/},
  {id: 'children', re: /\b(children|child|kids?|bab(ies|y)|family|high chair|cot)\b/},
  {id: 'pets', re: /\b(pets?|dogs?|cats?|animals?)\b/},
  {id: 'smoking', re: /\b(smok(ing|e|ers?) (area|room|allowed)|cigarette|vape|shisha)\b/},
  {id: 'access', re: /\b(wheelchair|disabled|disabilit|step ?free|accessible|accessibility)\b/},
  {id: 'dress', re: /\b(dress ?code|what (should|do) i wear|attire|smart (casual|dress))\b/},
  {id: 'safety', re: /\b(security|is it safe|safe|secure|surveillance|cctv|guard)\b/},
  {id: 'jobs', re: /\b(jobs?|vacanc|career|hiring|work (with|for) (you|us)|employment|intern(ship)?|recruit)\b/},
  {id: 'news', re: /\b(news|updates|announcements|what.s happening|what.s on|loyalty|special offer|offer|promo)\b/},
  {id: 'gift', re: /\b(gift|voucher|gift ?card|present)\b/},
  {id: 'currency', re: /\b(currency|dollar|usd|exchange|ugx|shillings?|forex)\b/},
  {id: 'taxes', re: /\b(tax|vat|service charge|receipt|invoice|efris|billing|bill)\b/},
  {id: 'feedback', re: /\b(complaint|complain|feedback|review|not happy|disappointed|refund|problem with)\b/},
  {id: 'vegetarian', re: /\b(vegetarian|vegan|veggie|plant based|no meat|meatless|halal|non ?veg)\b/},
  {id: 'spicy', re: /\b(spicy|spice|peppery|mild|chilli)\b/},
  {id: 'weather', re: /\b(weather|climate|rain|rainy|temperature|hot or cold)\b/},
  {id: 'places', re: /\b(things to do|attract|tour|tourism|visit near|bujagali|source of the nile|kampala|lake victoria|day out|excursion)\b/},
  {id: 'language', re: /\b(luganda|lusoga|swahili|kiswahili|language|do you speak)\b/},
  {id: 'menu', re: /\b(show me (the )?menu|open the menu|full menu|what do you have|what.s on (the )?(menu|offer)|what can i (get|eat|order))\b/},
  {id: 'prices', re: /\b(price|prices|cost|how much|how expensive|cheap|afford)\b/}
];

const CATEGORY_RX = /\b(breakfast|pizza|burger|sandwich|soup|dessert|starter|seafood|asian|chinese|pasta|curry|sizzler|chicken|beef|pork|salad|rice|noodle|omelet|wrap|accompaniment|drink|beverage)\b/;

/* A nudge to keep a conversation going: "more", "and his wife", "go on". */
const MORE_RX = /\b(more|else|continue|go on|and (his|her|the) (wife|husband|owner)s?|what about (him|her|them|the owner)|tell me more|keep going|anything else)\b/;

const QUESTION_RX = /^(who|what|when|where|why|which|whose|how|is there|are there|do you|does the|can i|could i|would i)\b/;

function interpret(text: string, catalog: Catalog): Action {
  const raw = normalise(strip(text));
  const query = tokens(text);

  if (raw === '') return {kind: 'options'};

  if (MORE_RX.test(raw)) return {kind: 'info', topic: 'more'};

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

  if (/\b(pay|payment|paying|mobile money|\bmomo\b|mtn|airtel|pesapal|visa|master ?card|\bcard\b|bank transfer|transfer the money|settle the bill)\b/.test(raw)) {
    return {kind: 'payment'};
  }
  if (/\b(add (to my )?order|place (an|my|a) order|start (an|my|a) order|send (my|our|an) order|make (an|my|a) order|how (do|can) i (order|add|buy|send)|i (want|would like) to order|order (food|something))\b/.test(raw)) {
    return {kind: 'ordering'};
  }

  for (const t of TOPICS) {
    if (t.re.test(raw)) return {kind: 'info', topic: t.id};
  }

  if (/\b(hello|hi|hey|good (morning|afternoon|evening|day))\b/.test(raw)) return {kind: 'greeting'};
  if (/\b(thank|thanks|appreciate)\b/.test(raw)) return {kind: 'thanks'};
  if (/\b(bye|goodbye|good ?night|see you|later|that.s all|nothing else)\b/.test(raw)) return {kind: 'goodbye'};
  if (/\b(what can you do|what do you do|how can you help|help me|hel+p|options?|what can i ask)\b/.test(raw)) return {kind: 'options'};

  if (raw === '' || CATEGORY_RX.test(raw)) return {kind: 'options'};
  if (QUESTION_RX.test(raw)) return {kind: 'info', topic: 'clarify'};
  return {kind: 'unknown'};
}

const PH = spokenPhone(CALL);

const INFO_ANSWERS: Record<string, string> = {
  owners: `Hotel Paradise on the Nile is owned by ${HOTEL.founders}. Mr. Otile Francis is the owner, and Mrs. Magrate Otile is his wife and his partner in everything. The two of them founded the hotel in nineteen ninety eight and they still own and guide it today. Their family name, Otile, is ${HOTEL.founderSurnameSpoken}, and they are among the most respected people here in Jinja.`,
  wife: `Mrs. Magrate Otile is the wife of Mr. Otile Francis. Together they own Hotel Paradise on the Nile, and together they built it from its first ten rooms. She is his partner in the hotel and in the family, and the two of them are widely loved and respected here in Jinja.`,
  founding: `Hotel Paradise on the Nile is one of the oldest and best loved hotels in Jinja, and one of the most iconic on the river. It opened its doors on ${HOTEL.founded}, and it was founded by ${HOTEL.founders}. They began with only ${HOTEL.roomsAtOpening} rooms and, through hard work and God's grace, grew it into the ${HOTEL.roomsToday} rooms you see today. It is registered with ${HOTEL.registration}. Their family name, Otile, is ${HOTEL.founderSurnameSpoken}.`,
  about: `Hotel Paradise on the Nile is one of Jinja's iconic and oldest hotels, standing on the banks of the River Nile. It has been on the water since ${HOTEL.founded}, founded by ${HOTEL.founders}, who still own it today. They opened with just ${HOTEL.roomsAtOpening} rooms and grew it into ${HOTEL.roomsToday} today, with a riverside restaurant and bar, a swimming pool, a health club and gardens for every occasion. It is registered with ${HOTEL.registration} and certified ${HOTEL.certification}.`,
  developer: `This website and the hotel's management system were designed and built by ${STUDIO.founder}, the founder of ${STUDIO.name}, based in ${STUDIO.city}. You can find them at reagansoftinnovation dot com, on WhatsApp at zero seven three zero, three one four, nine seven nine, or by searching Reagansoft Innovation Limited on Google.`,
  location: `We are at Plot 12, 19 and 25, Kiira Lane, Jinja, Uganda, right on the banks of the River Nile. That is about five minutes from the centre of Jinja town, and about a three hour drive from Entebbe International Airport. The front desk can arrange a pick up if you call ${PH}.`,
  contact: `The front desk is on ${PH}, and it is answered around the clock, every day. You can also email ${HOTEL.email}, or visit our website at ${HOTEL.website}.`,
  web: `Our website is ${HOTEL.website}. Everything is there, from the rooms and the menu to the events and how to reach us.`,
  rooms: `We have eight room types and sixty nine rooms in all, from a cosy Standard Single to the Suite, and breakfast is included in every rate. Rates start from about one hundred and twenty eight thousand Uganda shillings a night. Say a room type, or open the Rooms page, and I will tell you more.`,
  checkin: `Check in is from twelve noon, and check out is by ten in the morning. A room held past six in the evening is charged at seventy five per cent of its rate. If you would like an early check in or a late check out, call the front desk on ${PH} and they will do their best to help.`,
  events: `We host weddings, conferences, meetings and functions on our lawns and in our halls, right by the Nile. We have four venues, a kitchen that can plate for up to two hundred guests, and one events manager who looks after your day from the first call to the last dance. Call the front desk on ${PH}, or open the Events page, and we will send you a proposal the same day.`,
  facilities: `For our guests we have a swimming pool, a health club with a gym, a riverside bar and terrace, beautiful gardens, laundry and room service. Every room has its own private bathroom and satellite television.`,
  restaurant: `Our kitchen serves breakfast, lunch and dinner, and more than two hundred and fifty dishes on the a la carte menu, from light bites to full platters. Breakfast is included in every room rate. Name any dish and I will read you its price.`,
  hours: `Breakfast runs from six thirty to ten thirty in the morning, lunch from twelve noon to three in the afternoon, and dinner from seven to eleven in the evening. The front desk never closes.`,
  bar: `Our bar pours cold beer, a careful wine list and cocktails, out on the terrace or by the window, as the sun sets behind Jinja.`,
  roomservice: `Room service runs through the same kitchen. Add a dish to your order, tell us your room number when we call to confirm, and we will bring it up to you.`,
  delivery: `Yes, we deliver in Jinja. Order from this menu, add your delivery address, and the kitchen will bring it to you. We confirm every delivery by phone first.`,
  transfer: `We arrange pick ups and airport transfers from Entebbe or anywhere in Jinja. Call the front desk on ${PH} with your arrival time and we will take care of it.`,
  parking: `Yes. We have private, secure parking on the grounds, watched around the clock.`,
  wifi: `Wi-Fi is free for every guest throughout the hotel. Ask the front desk for the password when you arrive.`,
  children: `Children are very welcome. We have baby cots at no charge, high chairs, smaller portions, and safe green lawns. Just tell your waiter or the front desk.`,
  pets: `I would check with the front desk about pets, on ${PH}, so they can tell you exactly what is possible for your stay.`,
  smoking: `There are designated smoking areas on the grounds. Ask the front desk to point them out, and please keep the rooms smoke free.`,
  access: `If you need step free access, or a room set up in a particular way, call the front desk on ${PH} before you travel and they will arrange it for you.`,
  dress: `Smart casual is perfect at any hour, you are by the Nile. For an evening function or a wedding, most guests dress up a little more.`,
  safety: `The entrance and the grounds are watched around the clock, rooms have secure locks, and our parking is on site. You are in safe hands.`,
  jobs: `We are often hiring. Open the News and Careers page for the roles we have open, or send your CV to the front desk and our human resource office will be in touch.`,
  news: `Open the News page for our latest news, special offers and vacancies.`,
  gift: `Call ${PH} and we will arrange a gift voucher for any amount, good across the rooms, the restaurant and the bar.`,
  tables: `Walk ins are always welcome. For a busy evening, call ${PH} and we will hold a table for your party.`,
  currency: `Prices are in Ugandan shillings and include the taxes. We also quote room rates in US dollars for our international guests.`,
  taxes: `Every room rate includes the local hotel tax of two thousand shillings per room per day, and breakfast. Restaurant prices carry a small service charge, and your receipt itemises everything.`,
  feedback: `I am sorry if something was not right, and thank you for telling us. Please speak to the front desk on ${PH}, or open the Talk to Us page and send your message, and the team will look after it straight away.`,
  vegetarian: `The salads are full plates, the pizzeria has vegetable pizzas, and the kitchen will leave the meat off any curry or sizzler. Just say the word.`,
  spicy: `Say how hot you like it, from mild to very hot, and the kitchen will cook it to your taste.`,
  weather: `I cannot see the sky from here, but Jinja is warm through the year, with the long rains around March to May and the short rains around September to November.`,
  places: `Jinja is the city at the source of the Nile, about two hours from Kampala. Guests enjoy the source of the Nile, boat rides, Bujagali Falls and the markets in town. The front desk will gladly help you plan a day out.`,
  language: `I speak English. For Luganda, Lusoga or another language, the front desk team on ${PH} will be glad to help you.`,
  assistant: `I am the voice guide for Hotel Paradise on the Nile. I am here to answer your questions about the hotel, its owners, the rooms, the restaurant and events. I am not a person, but I will do my best to help, and I can pass you to the front desk on ${PH} at any time.`,
  menu: `This page is the whole menu. Name any dish and I will read you its price, or name a section and I will point you to it.`,
  prices: `Name the dish and I will read you its price, or name a section and I will point you to it. If you mean a room rate, say the word room and I will tell you.`,
  clarify: `Let me make sure I give you the right thing. I can tell you who owns the hotel - Mr. Otile Francis and his wife, Mrs. Magrate Otile - when it opened in nineteen ninety eight, our rooms and rates, the restaurant, events, directions, payment, or who built this website. Ask me again in your own words, and I will look closer. I am listening.`,
  fallback: `I want to get this exactly right for you. I can tell you who owns the hotel, when it opened, our rooms and rates, the restaurant, events, directions, payment, or who built this website. Ask me in your own words, and if it is something I truly do not know, I will point you to the front desk on ${PH}. I am still listening.`
};

const MORE_ANSWERS: Record<string, string> = {
  owners: `A little more about the owners. Mr. Otile Francis and his wife, Mrs. Magrate Otile, are the founders and the owners of Hotel Paradise on the Nile. Their family name is Otile, ${HOTEL.founderSurnameSpoken}. They are deeply respected in Jinja, and the hotel they built remains a true landmark on the river.`,
  founding: `A little more of the story. When the hotel opened on ${HOTEL.founded}, it had only ${HOTEL.roomsAtOpening} rooms. Step by step, and by God's grace, it grew into the ${HOTEL.roomsToday} rooms it has today, with a restaurant, a bar, a pool, a health club and gardens, all on the banks of the Nile.`,
  rooms: `The eight room types are the Suite, the Family Room, the Triple Room, the Executive Deluxe, the Deluxe Double, the Standard Double, the Standard Twin and the Standard Single. Every rate includes breakfast and the local hotel tax. Open the Rooms page to see each one.`,
  events: `For events we offer four venues, from our halls to the riverside lawns, and a kitchen that can serve up to two hundred guests. Weddings, conferences, meetings and parties are all welcome. Call ${PH} and our events manager will plan it with you.`,
  facilities: `Our facilities include the swimming pool, the health club and gym, the riverside bar and terrace, the gardens, laundry, and room service. Every room has a private bathroom and satellite television.`
};

const MORE_DEFAULT = `I would be glad to say more. Tell me which part you would like, the owners and the history, the rooms and rates, the restaurant, events, directions, or payment.`;

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
  const lastTopicRef = React.useRef('');
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
    const u = new SpeechSynthesisUtterance(forSpeech(text));
    const v = who === 'woman' ? voicesRef.current.female : voicesRef.current.male;
    if (v) u.voice = v;
    u.lang = v?.lang || 'en-US';
    u.rate = 0.94;
    u.pitch = who === 'woman' ? 1.05 : 0.88;
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
    watchdogRef.current = window.setTimeout(finishSpeech, 11000 * lines.length + 4000);
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
        {who: 'man', text: 'I am Paradise, your voice guide. Ask me anything about the hotel — who owns it, when it opened, the rooms and rates, the restaurant, events, directions or payment — or say any dish and I will point you to it.'}
      ]);
      return;
    }
    if (action.kind === 'thanks') {
      speakAll([{who: 'man', text: 'You are most welcome. I am still here whenever you need me.'}]);
      return;
    }
    if (action.kind === 'goodbye') {
      speakAll([{who: 'man', text: `Thank you for visiting Hotel Paradise on the Nile. If you need us, the front desk is on ${PH}. Have a wonderful day.`}]);
      return;
    }
    if (action.kind === 'options') {
      const examples = catalog.cats.slice(0, 3).map(c => c.name.toLowerCase()).join(', ');
      const menuBit = examples ? ` Or say a section, such as ${examples}, and I will point you to it.` : '';
      speakAll([{who: 'man', text: `Ask me anything about the hotel. I can tell you who owns it, when it opened, the rooms and rates, the restaurant, events, directions or payment.${menuBit} What would you like to know?`}]);
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
      if (action.topic === 'more') {
        const last = lastTopicRef.current;
        speakAll([{who: 'man', text: (last && MORE_ANSWERS[last]) || MORE_DEFAULT}]);
        return;
      }
      const answer = INFO_ANSWERS[action.topic] || INFO_ANSWERS.fallback;
      if (action.topic !== 'clarify') lastTopicRef.current = action.topic;
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
      {who: 'woman', text: `${timeGreeting()}, and welcome to Hotel Paradise on the Nile, on the banks of the river in Jinja.`},
      {who: 'man', text: 'I am Paradise, your voice guide. Ask me anything — who owns the hotel, when it opened, our rooms and rates, the restaurant, events, directions or payment — and I will answer. You can also say any dish, and I will point you to it.'},
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
          : 'Listening... ask me anything about the hotel, or name a dish.';

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
    rec.interimResults = true;
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
        setNote(`I could not reach your microphone, so I will stay quiet. You can still read the menu, tap a section, or call ${CALL}.`);
      }
    };
    rec.onresult = (ev) => {
      let interim = '';
      let finalText = '';
      for (let i = ev.resultIndex; i < ev.results.length; i += 1) {
        const r = ev.results[i];
        const said = r[0].transcript;
        if (r.isFinal) finalText += ' ' + said;
        else interim += ' ' + said;
      }
      const live = interim.trim();
      if (live) setHeard(live);
      finalText = finalText.trim();
      if (finalText) handleRef.current(finalText);
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
      <button type="button" className={'conLauncher' + (phase === 'listening' || phase === 'speaking' ? ' live' : '')} onClick={openPanel} aria-label="Open the Paradise voice guide">
        <span className="conIcon" aria-hidden="true">
          <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
            <path d="M11 5 6.5 9H3v6h3.5L11 19z"/>
            <path d="M15.5 8.6a4.7 4.7 0 0 1 0 6.8"/>
            <path d="M18.4 6a8.4 8.4 0 0 1 0 12"/>
          </svg>
          <i className="conDot" />
        </span>
        <span className="conLauncherText">
          <b>Ask Paradise</b>
          <em>{miniStatus}</em>
        </span>
      </button>
    );
  }

  return (
    <div className={'concierge phase-' + phase} role="region" aria-label="Paradise voice guide">
      <div className="conHeader">
        <span className="conIcon" aria-hidden="true">
          <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
            <path d="M11 5 6.5 9H3v6h3.5L11 19z"/>
            <path d="M15.5 8.6a4.7 4.7 0 0 1 0 6.8"/>
            <path d="M18.4 6a8.4 8.4 0 0 1 0 12"/>
          </svg>
          <i className="conDot" />
        </span>
        <b className="conTitle">Paradise, your voice guide</b>
        <button type="button" className="conIconBtn" aria-label="Fold the voice guide away" onClick={foldPanel}>
          <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true">
            <path d="m6 9 6 6 6-6"/>
          </svg>
        </button>
        <button type="button" className="conIconBtn" aria-label="Close the voice guide" onClick={closeConcierge}>×</button>
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
