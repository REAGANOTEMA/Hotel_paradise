import React from 'react';
import {CALL, HOTEL, STUDIO} from './shared';
import type {MenuSection} from './menuData';

/* ------------------------------------------------------------------
   PARADISE, THE VOICE GUIDE

   A calm voice that stands in the corner of a page and simply waits. A
   woman welcomes the guest first, then a man offers to help and keeps
   listening. It knows the hotel's products by heart - the rooms and
   rates, the restaurant, bar and menu, the events and venues, the
   facilities, the offers, the way here, and the way to pay - and it
   reads the menu it is standing in front of, so it can point a guest
   to the right section, name the section a dish lives in, read a
   dish's price, or walk them through booking and paying.

   Three rules shape it:

   - It never moves on its own. It waits as a small button and speaks
     only after the guest opens it and asks to begin. After that it only
     answers something the guest actually said or tapped. A guest who
     says nothing is left in peace for as long as they like.
   - It never records and never saves anything. Speech is read and
     answered in the moment and then forgotten; no audio is written
     anywhere, and nothing is sent to the hotel.
   - It never covers the page. It stands as a small button until it is
     asked to open, the card itself can be quieted, folded away or closed
     at any time, and it is left out of print.

   The browser does the listening and the speaking through its own Web
   Speech API, so the microphone opens only after the guest has opened
   the guide and asked to begin, and a guest who declines the microphone
   is simply told so once and never asked again.

   The answers are written out here, in full, rather than guessed at, so
   the hotel's products, rates and offers are always presented the same
   way, in a warm and businesslike voice that helps a guest choose and
   book. When a guest asks something it does not hold, it says so
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

/* Speech recognition mishears a place name far more often than a common word,
   so a handful of likely spellings of the town and the lane are folded back
   to the true ones before anything is looked up. */
const NAME_FIXES: [RegExp, string][] = [
  [/\bjin[gj]ah?\b/g, 'jinja'],
  [/\bkii?ra\b/g, 'kiira']
];
const normalise = (s: string): string => NAME_FIXES.reduce((t, [re, v]) => t.replace(re, v), s);

const FEMALE = /female|woman|zira|samantha|serena|aria|hazel|libby|sonia|joanna|salli|kendra|kimberly|ivy|karen|moira|tessa|fiona|veena|victoria|allison|ava|susan|nicole|catherine|clara|emily|michelle|elizabeth|jenny|jenna|aria|emma|olivia|sophie|amber|ana|sara|nancy|linda|heather|ashley|allison|google uk english female|google us english/i;
const MALE = /male|david|mark|daniel|alex|fred|rishi|george|guy|brian|matthew|arthur|oliver|thomas|james|ryan|nico|diego|jorge|aaron|william|eric|christopher|liam|connor|davis|tony|jason|brandon|roger|steffan|andrew|google uk english male|google us english male/i;
const NOVELTY = /albert|bad news|bahh|bells|boing|bubbles|cellos|deranged|good news|hysterical|jester|organ|superstar|trinoids|whisper|wobble|zarvox/i;

/* Where two voices are available, the richer one is chosen: an "online" or
   "natural" voice first, then a Google voice, then a Microsoft one. British
   and American English are preferred, and novelty voices are never chosen.
   A phone that offers only one voice still works, it is simply the voice used. */
const voiceScore = (v: SpeechSynthesisVoice): number => {
  let score = 0;
  if (/natural|neural|online|premium|enhanced|wavenet/i.test(v.name)) score += 8;
  if (/google/i.test(v.name)) score += 4;
  if (/microsoft/i.test(v.name)) score += 2;
  if (/^en[-_]GB/i.test(v.lang)) score += 3;
  if (/^en[-_]US/i.test(v.lang)) score += 2;
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

/* A few hotel and place words respelled for the voice alone, so the screen
   keeps the true spelling while the ear hears the right sound. */
const SAY: [RegExp, string][] = [
  [/\bKiira\b/g, 'Kee-rah'],
  [/\bJinja\b/g, 'Jin-jah'],
  [/\bPesapal\b/g, 'Pess-a-pal']
];
const forSpeech = (text: string): string => SAY.reduce((t, [re, v]) => t.replace(re, v), text);

function pickVoices(): {female?: SpeechSynthesisVoice; male?: SpeechSynthesisVoice} {
  try {
    const all = window.speechSynthesis.getVoices() || [];
    const english = all.filter(v => /^en([-_]|$)/i.test(v.lang));
    const natural = (english.length ? english : all).filter(v => !NOVELTY.test(v.name));
    const pool = natural.length ? natural : (english.length ? english : all);
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

/* The hotel's knowledge, in the order it should be trusted. A guest who asks
   about the hotel, its packages or the way to book is answered from these
   facts before any dish or section is considered, so a question about a stay
   is never read as a question about the menu. */
const TOPICS: {id: string; re: RegExp}[] = [
  {id: 'assistant', re: /\b(are you (a )?(human|robot|real|ai)|who are you|what are you|is this a robot|the voice)\b/},
  {id: 'developer', re: /\b(developer|designer|reagansoft|reagan|who (designed|built|made|created|developed|programmed|coded|wrote|did) (this|the|your|it)|who (made|built|designed|did) this|who is behind|who built (this|the) (site|website|web|page|system|software|app)|built (this|the) (site|website|system))\b/},
  {id: 'founding', re: /\b(founder|founders|founded|establish\w*|estab|inception|when (did|was|has|it|the hotel|this hotel|you)|started|began|opened (its doors|the doors)|first opened|since when|how (old|long)|history|the story|origin|who (started|began|built|opened|established|created|put up))\b/},
  {id: 'about', re: /\b(tell me about|what is (this|your|the hotel)|about (you|the hotel|us|this place)|our story|an overview|introduce)\b/},
  {id: 'tables', re: /\b(book a table|reserve a table|table reservation|table for|a table)\b/},
  {id: 'offers', re: /\b(offers?|deals?|discounts?|promos?|promotions?|packages?|specials?|loyalty|reward|weekend (escape|getaway)|staycation|long stay|group rate|corporate rate)\b/},
  {id: 'booking', re: /\b(book|booking|reserve|reservation|availability|vacancy|deposit|cancellation|cancel my)\b/},
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
  {id: 'news', re: /\b(news|updates|announcements|what.s happening|what.s on)\b/},
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

/* A nudge to keep a conversation going: "more", "what else", "go on". */
const MORE_RX = /\b(more|else|continue|go on|tell me more|keep going|anything else|what else)\b/;

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
  founding: `Hotel Paradise on the Nile has welcomed guests on the banks of the Nile since ${HOTEL.founded}. It began with ${HOTEL.roomsAtOpening} rooms and has grown into a full riverside hotel with ${HOTEL.roomsToday} rooms, a restaurant and bar, a swimming pool, a health club and gardens for every occasion. That heritage is part of the experience: calm, established and genuinely on the water. It is registered with ${HOTEL.registration} and certified ${HOTEL.certification}.`,
  about: `Hotel Paradise on the Nile is a riverside hotel in Jinja, on the banks of the Nile since ${HOTEL.founded}. We offer ${HOTEL.roomsToday} rooms across eight room types, a restaurant and bar with more than two hundred and fifty dishes, a swimming pool, a health club, and gardens and venues for weddings, conferences and celebrations. Every room rate includes breakfast, and booking direct gives you our best available rate and a confirmed booking. Tell me what you are planning, and I will point you to the right rooms, menu or venue.`,
  developer: `This website and the hotel's management system were designed and built by ${STUDIO.founder}, the founder of ${STUDIO.name}, based in ${STUDIO.city}. You can find them at reagansoftinnovation dot com, on WhatsApp at zero seven three zero, three one four, nine seven nine, or by searching Reagansoft Innovation Limited on Google.`,
  location: `We are at Plot 12, 19 and 25, Kiira Lane, Jinja, Uganda, right on the banks of the River Nile. That is about five minutes from the centre of Jinja town, and about a three hour drive from Entebbe International Airport. The front desk can arrange a pick up if you call ${PH}, and the riverside setting comes with the room.`,
  contact: `The front desk is on ${PH}, and it is answered around the clock, every day. You can also email ${HOTEL.email}, or book and browse our rooms, menu and events at ${HOTEL.website}.`,
  web: `Our website is ${HOTEL.website}. You can book a room, explore the full menu, plan an event and see our current offers, all in one place.`,
  rooms: `We have eight room types and sixty nine rooms, from the Standard Single to the Suite, all with a private bathroom and satellite television. Breakfast is included in every rate, and rates start from about one hundred and twenty eight thousand Uganda shillings a night. Booking direct gives you our best available rate and a confirmed booking. Say a room type, or open the Rooms page, and I will tell you more.`,
  booking: `You can book direct on our website at ${HOTEL.website}, or call the front desk on ${PH} and we will confirm your room and rate in one call. Booking direct gives you our best available rate, breakfast included, free Wi-Fi and access to the pool and health club. We accept Pesapal, MTN and Airtel Mobile Money, Visa and Mastercard, and bank transfer. Would you like to hear about our rooms and rates, or our current offers?`,
  offers: `We put our best value into packages and direct offers: weekend escapes, romantic stays, business and corporate rates, long-stay rates and seasonal promotions. Every room rate includes breakfast, free Wi-Fi and access to the pool and health club. Open the News page for what is current, or call ${PH} and the reservations team will build the right package around your dates.`,
  checkin: `Check in is from twelve noon, and check out is by ten in the morning. A room held past six in the evening is charged at seventy five per cent of its rate. If you would like an early check in or a late check out, call the front desk on ${PH} and they will do their best to help.`,
  events: `We host weddings, conferences, meetings and functions on our lawns and in our halls, right by the Nile. We have four venues, a kitchen that can plate for up to two hundred guests, and one events manager who looks after your day from the first call to the last dance. Call the front desk on ${PH}, or open the Events page, and we will send you a proposal the same day.`,
  facilities: `Your stay includes a swimming pool, a health club with a gym, a riverside bar and terrace, beautiful gardens, laundry and room service. Every room has its own private bathroom and satellite television. It is a full riverside experience, not just a bed for the night.`,
  restaurant: `Our kitchen serves breakfast, lunch and dinner, and more than two hundred and fifty dishes on the a la carte menu, from light bites to full platters. Breakfast is included in every room rate, and the riverside setting comes with every table. Name any dish and I will read you its price.`,
  hours: `Breakfast runs from six thirty to ten thirty in the morning, lunch from twelve noon to three in the afternoon, and dinner from seven to eleven in the evening. The front desk never closes.`,
  bar: `Our bar pours cold beer, a careful wine list and cocktails, out on the terrace or by the window, as the sun sets behind Jinja. It is the best seat in the house for the river at dusk.`,
  roomservice: `Room service runs through the same kitchen. Add a dish to your order, tell us your room number when we call to confirm, and we will bring it up to you.`,
  delivery: `Yes, we deliver in Jinja. Order from this menu, add your delivery address, and the kitchen will bring it to you. We confirm every delivery by phone first.`,
  transfer: `We arrange pick ups and airport transfers from Entebbe or anywhere in Jinja. Call the front desk on ${PH} with your arrival time and we will take care of it.`,
  parking: `Yes. We have private, secure parking on the grounds, watched around the clock, and it is free for guests.`,
  wifi: `Wi-Fi is free for every guest throughout the hotel. Ask the front desk for the password when you arrive, and you can work or stream from anywhere on the grounds.`,
  children: `Children are very welcome. We have baby cots at no charge, high chairs, smaller portions, and safe green lawns. Just tell your waiter or the front desk.`,
  pets: `I would check with the front desk about pets, on ${PH}, so they can tell you exactly what is possible for your stay.`,
  smoking: `There are designated smoking areas on the grounds. Ask the front desk to point them out, and please keep the rooms smoke free.`,
  access: `If you need step free access, or a room set up in a particular way, call the front desk on ${PH} before you travel and they will arrange it for you.`,
  dress: `Smart casual is perfect at any hour, you are by the Nile. For an evening function or a wedding, most guests dress up a little more.`,
  safety: `The entrance and the grounds are watched around the clock, rooms have secure locks, and our parking is on site. You are in safe hands.`,
  jobs: `We are often hiring. Open the News and Careers page for the roles we have open, or send your CV to the front desk and our human resource office will be in touch.`,
  news: `Open the News page for our latest news, special offers and vacancies.`,
  gift: `Call ${PH} and we will arrange a gift voucher for any amount, good across the rooms, the restaurant and the bar. It makes an easy gift for someone who deserves a night by the Nile.`,
  tables: `Walk ins are always welcome. For a busy evening, call ${PH} and we will hold a table for your party.`,
  currency: `Prices are in Ugandan shillings and include the taxes. We also quote room rates in US dollars for our international guests.`,
  taxes: `Every room rate includes the local hotel tax of two thousand shillings per room per day, and breakfast. Restaurant prices carry a small service charge, and your receipt itemises everything.`,
  feedback: `I am sorry if something was not right, and thank you for telling us. Please speak to the front desk on ${PH}, or open the Talk to Us page and send your message, and the team will look after it straight away.`,
  vegetarian: `The salads are full plates, the pizzeria has vegetable pizzas, and the kitchen will leave the meat off any curry or sizzler. Just say the word.`,
  spicy: `Say how hot you like it, from mild to very hot, and the kitchen will cook it to your taste.`,
  weather: `I cannot see the sky from here, but Jinja is warm through the year, with the long rains around March to May and the short rains around September to November. The riverside gardens are beautiful in every season.`,
  places: `Jinja is the city at the source of the Nile, about two hours from Kampala. Guests enjoy the source of the Nile, boat rides, Bujagali Falls and the markets in town. The front desk will gladly help you plan a day out from the hotel.`,
  language: `I speak English. For Luganda, Lusoga or another language, the front desk team on ${PH} will be glad to help you.`,
  assistant: `I am Paradise, the digital voice guide for Hotel Paradise on the Nile. I can help you choose a room and book it, explore the restaurant, bar and menu, plan a wedding, conference or celebration, understand our offers, find us, and pay. I am not a person, but I am here around the clock, and I can pass you to the front desk on ${PH} at any time.`,
  menu: `This page is the whole menu. Name any dish and I will read you its price, or name a section and I will point you to it.`,
  prices: `Name the dish and I will read you its price, or name a section and I will point you to it. If you mean a room rate, say the word room and I will tell you.`,
  clarify: `Let me make sure I give you the right thing. I can tell you about our rooms and rates, the restaurant, bar and menu, our events and venues, the facilities, current offers, directions, booking and payment. Ask me again in your own words, and I will look closer. I am listening.`,
  fallback: `I want to get this exactly right for you. I can tell you about our rooms and rates, the restaurant, bar and menu, our events and venues, the facilities, current offers, directions, booking and payment. Ask me in your own words, and if it is something I truly do not know, I will point you to the front desk on ${PH}. I am still listening.`
};

const MORE_ANSWERS: Record<string, string> = {
  founding: `A little more of the story. Since opening on ${HOTEL.founded}, the hotel has grown from ${HOTEL.roomsAtOpening} rooms into the ${HOTEL.roomsToday} rooms it has today, with a restaurant, a bar, a pool, a health club and gardens, all on the banks of the Nile. The result is a hotel that feels established, calm and genuinely part of Jinja.`,
  rooms: `The eight room types are the Suite, the Family Room, the Triple Room, the Executive Deluxe, the Deluxe Double, the Standard Double, the Standard Twin and the Standard Single. Every rate includes breakfast and the local hotel tax, and booking direct gives you our best available rate. Open the Rooms page to see each one.`,
  booking: `Booking direct is the simplest way to get the best available rate. Choose your dates on the Rooms page, or call ${PH} and we will confirm the room in one call. We hold the reservation, include breakfast, and send your confirmation straight away. We also accept Pesapal, MTN and Airtel Mobile Money, Visa and Mastercard.`,
  offers: `Our packages are built around the way people actually stay: a weekend escape for two, a romantic stay, a business or corporate rate, and a long-stay rate for guests who settle in. Each includes breakfast, free Wi-Fi and access to the pool and health club. Call ${PH} and we will tailor the package to your dates.`,
  events: `For events we offer four venues, from our halls to the riverside lawns, and a kitchen that can serve up to two hundred guests. Weddings, conferences, meetings and parties are all welcome. Call ${PH} and our events manager will plan it with you.`,
  facilities: `Our facilities include the swimming pool, the health club and gym, the riverside bar and terrace, the gardens, laundry, and room service. Every room has a private bathroom and satellite television. They are all part of the stay, not extras.`,
  restaurant: `The kitchen serves breakfast, lunch and dinner, with more than two hundred and fifty dishes on the a la carte menu, from a quick bite to a full riverside platter. Breakfast is included in every room rate. Name any dish and I will read you its price.`,
  bar: `The bar is the place to end the day: cold beer, a careful wine list and cocktails, out on the terrace or by the window as the sun sets over the Nile. It is open to guests and visitors alike.`,
  gift: `A gift voucher from Hotel Paradise on the Nile can be used across the rooms, the restaurant and the bar. Call ${PH} and we will arrange any amount and send it to you or straight to the person you are treating.`
};

const MORE_DEFAULT = `I would be glad to say more. Tell me which part you would like: the rooms and rates, booking, our offers, the restaurant and bar, events, facilities, directions, or payment.`;

const QUICK_ASKS: {label: string; ask: string}[] = [
  {label: 'Rooms', ask: 'rooms'},
  {label: 'Book', ask: 'booking'},
  {label: 'Offers', ask: 'offers'},
  {label: 'Menu', ask: 'menu'},
  {label: 'Events', ask: 'events'},
  {label: 'Find us', ask: 'location'}
];

export function MenuConcierge({sections}: {sections: MenuSection[]}) {
  const {speech, Ctor} = React.useMemo(speechWindow, []);
  const ready = Boolean(speech && Ctor && typeof SpeechSynthesisUtterance !== 'undefined');

  const catalog = React.useMemo(() => buildCatalog(sections), [sections]);

  const [phase, setPhase] = React.useState<Phase>('idle');
  const [caption, setCaption] = React.useState('');
  const [heard, setHeard] = React.useState('');
  const [note, setNote] = React.useState('');
  const [closed, setClosed] = React.useState(false);
  const [expanded, setExpanded] = React.useState(false);

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
    setPhase(pausedRef.current ? 'paused' : wantRef.current ? 'listening' : 'idle');
    startRec();
  }, [startRec]);

  const makeUtter = (text: string, who: 'woman' | 'man'): SpeechSynthesisUtterance => {
    const u = new SpeechSynthesisUtterance(forSpeech(text));
    const v = who === 'woman' ? voicesRef.current.female : voicesRef.current.male;
    if (v) u.voice = v;
    u.lang = v?.lang || 'en-GB';
    u.rate = 0.96;
    u.pitch = who === 'woman' ? 1.03 : 0.9;
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
        {who: 'man', text: 'I am Paradise, your voice guide. Ask me about our rooms and rates, booking, our offers, the restaurant, bar and menu, events, facilities, directions or payment — or say any dish and I will point you to it.'}
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
      speakAll([{who: 'man', text: `Ask me anything about your stay. I can tell you about our rooms and rates, booking, our offers, the restaurant and bar, events, facilities, directions or payment.${menuBit} What would you like to know?`}]);
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
      {who: 'man', text: 'I am Paradise, your voice guide. Ask me about our rooms and rates, booking, our offers, the restaurant and bar, events, facilities, directions or payment — and I will answer. You can also say any dish, and I will point you to it.'},
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
  }, []);

  const foldPanel = React.useCallback(() => {
    setExpanded(false);
  }, []);

  /* ------- the little status line, folded in or open ------- */

  const miniStatus =
    phase === 'idle' ? 'Tap to open' :
    phase === 'paused' ? 'Resume to listen' :
    phase === 'blocked' ? 'Mic unavailable' :
    phase === 'speaking' ? 'Speaking...' :
    'Listening...';

  const status = phase === 'idle'
    ? 'Tap Begin and I will welcome you, or choose a quick question below.'
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

      <div className="conQuick" role="group" aria-label="Quick questions">
        {QUICK_ASKS.map(q => (
          <button type="button" className="conChip" key={q.ask} onClick={() => handle(q.ask)}>{q.label}</button>
        ))}
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
