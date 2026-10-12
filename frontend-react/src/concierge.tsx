import React from 'react';
import {CALL} from './shared';
import type {MenuSection} from './menuData';

/* ------------------------------------------------------------------
   THE MENU CONCIERGE

   A voice that stands in the corner of the menu and simply waits. A
   woman welcomes the guest first, then a man offers to help and keeps
   listening. It reads the menu it is standing in front of, so it can
   point a guest to the right section, name the section a dish lives
   in, or walk them through paying.

   Three rules shape it:

   - It never moves on its own. It speaks once to welcome a guest, and
     after that it only answers something the guest actually said. A
     guest who says nothing is left in peace for as long as they like.
   - It never records and never saves anything. Speech is read and
     answered in the moment and then forgotten; no audio is written
     anywhere, and nothing is sent to the hotel.
   - It never covers the page. It is a small, calm card at the foot of
     the screen that can be quieted at any time, and it is left out of
     print entirely.

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
const STOP = new Set(['a','an','the','i','im','want','wanted','looking','look','for','some','please','me','my','is','am','are','was','of','to','can','could','would','will','show','tell','where','find','get','have','has','had','do','does','did','how','and','or','with','menu','food','dish','dishes','eat','eating','order','ordering','something','anything','what','which','that','this','these','those','it','on','in','at','by','about','like','give','need','needs','there','here','also','just','help','helping']);

const strip = (s: string): string => s.toLowerCase().replace(/[^a-z0-9\s]/g, ' ').replace(/\s+/g, ' ').trim();

const stem = (w: string): string => (w.length > 3 ? w.replace(/s$/, '') : w);

const tokens = (s: string): string[] => strip(s).split(' ').filter(w => w && !STOP.has(w)).map(stem);

const FEMALE = /female|woman|zira|samantha|serena|aria|hazel|libby|sonia|joanna|salli|kendra|kimberly|ivy|karen|moira|tessa|fiona|veena|victoria|allison|ava|susan|nicole|catherine|clara|emily|google uk english female/i;
const MALE = /male|david|mark|daniel|alex|fred|rishi|george|guy|brian|matthew|arthur|oliver|thomas|james|ryan|nico|diego|jorge|aaron|william|eric|christopher|google uk english male/i;

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

function bestMatch<T extends {toks: string[]}>(query: string[], raw: string, list: T[], phrase: (t: T) => string): {hit: T; score: number} | null {
  let best: {hit: T; score: number} | null = null;
  list.forEach(t => {
    let score = 0;
    query.forEach(q => { if (t.toks.includes(q)) score += 1; });
    const p = strip(phrase(t));
    if (p && raw.includes(p)) score += 3;
    if (score > 0 && (!best || score > best.score)) best = {hit: t, score};
  });
  return best;
}

function interpret(text: string, catalog: Catalog): Action {
  const raw = strip(text);
  const query = tokens(text);

  if (/\b(pay|payment|paying|checkout|check out|bill|invoice|receipt)\b/.test(raw)
    || /\b(mobile money|momo|mtn|airtel|pesapal|visa|mastercard|card|bank|transfer)\b/.test(raw)) {
    return {kind: 'payment'};
  }
  if (/\b(how (do|can) i|where (do|can) i|help me) (order|add|buy)\b/.test(raw)
    || /\b(add to (my )?order|place (an|my) order|start (an|my) order|send my order|make (an|my) order)\b/.test(raw)) {
    return {kind: 'ordering'};
  }

  const dish = bestMatch(query, raw, catalog.items, t => t.name);
  const cat = bestMatch(query, raw, catalog.cats, t => t.name);

  if (dish && (!cat || dish.score >= cat.score)) {
    return {kind: 'dish', name: dish.hit.name, sectionName: dish.hit.sectionName, priced: dish.hit.price !== null, price: dish.hit.price};
  }
  if (cat) return {kind: 'category', name: cat.hit.name};

  if (!query.length) {
    if (/\b(hello|hi|hey|good (morning|afternoon|evening))\b/.test(raw)) return {kind: 'greeting'};
    if (/\b(thank|thanks|thank you)\b/.test(raw)) return {kind: 'thanks'};
    if (/\b(help|options|what can you do|what do you do|who are you)\b/.test(raw)) return {kind: 'options'};
  }
  return {kind: 'unknown'};
}

export function MenuConcierge({sections}: {sections: MenuSection[]}) {
  const {speech, Ctor} = React.useMemo(speechWindow, []);
  const ready = Boolean(speech && Ctor && typeof SpeechSynthesisUtterance !== 'undefined');

  const catalog = React.useMemo(() => buildCatalog(sections), [sections]);

  const [phase, setPhase] = React.useState<Phase>('idle');
  const [caption, setCaption] = React.useState('');
  const [heard, setHeard] = React.useState('');
  const [note, setNote] = React.useState('');

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
  const handleRef = React.useRef<(t: string) => void>(() => {});
  const beginRef = React.useRef<() => void>(() => {});

  /* ------- the guest's own voice, read and answered, never kept ------- */

  const startRec = React.useCallback(() => {
    const rec = recRef.current;
    if (!rec || !wantRef.current || speakingRef.current || activeRef.current) return;
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
    u.rate = 0.9;
    u.pitch = who === 'woman' ? 1.05 : 0.85;
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
    if (!speech || !lines.length) return;
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
      speakAll([{who: 'man', text: `When you are ready to pay, open the Your order panel at the bottom of this page and send it. That takes you to our secure checkout, where you can pay with Pesapal, MTN Mobile Money, Airtel Money, or a Visa or Mastercard. Your receipt appears at once and is emailed to you. If you would like a hand, call the front desk on ${CALL}.`}]);
      return;
    }
    if (action.kind === 'ordering') {
      speakAll([{who: 'man', text: 'To order, open any dish, choose your companion and a salad if you like, then add it to your order. When you are ready, open the Your order panel and send it. Tell me a dish whenever you wish, and I will point you to it.'}]);
      return;
    }
    if (action.kind === 'greeting') {
      speakAll([{who: 'man', text: 'Hello, and welcome to Hotel Paradise on the Nile. I can find a dish for you, take you to a section of the menu, or explain how to pay. What can I help you with?'}]);
      return;
    }
    if (action.kind === 'thanks') {
      speakAll([{who: 'man', text: 'You are most welcome. I am still here whenever you need me.'}]);
      return;
    }
    if (action.kind === 'options') {
      speakAll([{who: 'man', text: 'Here is what I can do. Say the name of a dish, such as grilled tilapia, and I will tell you where it is. Say a section, such as breakfast, pizza, or drinks, and I will point you to it. Or ask how to pay, and I will walk you through it.'}]);
      return;
    }
    if (action.kind === 'category') {
      highlightCategory(action.name);
      speakAll([{who: 'man', text: `Everything in ${action.name} has its own section. Please look at the row of buttons near the top of the page, and tap ${action.name}. I have marked it for you.`}]);
      return;
    }
    if (action.kind === 'dish') {
      highlightCategory(action.sectionName);
      const price = action.priced
        ? ` It is ${action.price!.toLocaleString()} shillings.`
        : ' The kitchen prices this one on request, so do call us and we will confirm it for you.';
      speakAll([{who: 'man', text: `${action.name} sits in the ${action.sectionName} section.${price} Tap its card to open it and see the full plate, or type its name in the search box at the top of the page. I have marked the ${action.sectionName} section for you.`}]);
      return;
    }
    speakAll([{who: 'man', text: 'I did not quite catch that. You can name a dish, or a section such as breakfast, pizza, or drinks. I am still listening.'}]);
  }, [catalog, speakAll]);

  handleRef.current = handle;

  /* ------- the welcome, once, in a woman's voice then a man's ------- */

  const begin = React.useCallback(() => {
    if (!ready) return;
    startedRef.current = true;
    wantRef.current = true;
    pausedRef.current = false;
    speakAll([
      {who: 'woman', text: 'Welcome to Hotel Paradise on the Nile, and to our menu. What can I help you with?'},
      {who: 'man', text: 'I am your menu guide. I can find a dish for you, take you to a section of the menu, or explain how to pay.'},
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
      if (wantRef.current && !speakingRef.current) {
        window.clearTimeout(restartRef.current);
        restartRef.current = window.setTimeout(() => { if (wantRef.current && !pausedRef.current) startRec(); }, 350);
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
    const go = () => { if (!startedRef.current) beginRef.current(); };
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
      else if (wantRef.current && !pausedRef.current && !speakingRef.current) { startRec(); }
    };
    document.addEventListener('visibilitychange', onVis);
    return () => document.removeEventListener('visibilitychange', onVis);
  }, [ready, abortRec, startRec]);

  React.useEffect(() => {
    if (!ready) return;
    document.body.classList.add('hpn-concierge');
    return () => document.body.classList.remove('hpn-concierge');
  }, [ready]);

  React.useEffect(() => () => { try { speech?.cancel(); } catch { /* leaving the page */ } }, [speech]);

  if (!ready) return null;

  const status = phase === 'idle'
    ? 'Tap or move anywhere on the page and I will welcome you.'
    : phase === 'paused'
      ? 'I am quiet. Press resume when you would like me to listen again.'
      : phase === 'blocked'
        ? note
        : phase === 'speaking'
          ? caption
          : 'I am listening. Name a dish or a section, whenever you are ready.';

  return (
    <div className={'concierge phase-' + phase} role="region" aria-label="Menu voice concierge">
      <span className="conIcon" aria-hidden="true">
        <svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
          <path d="M11 5 6.5 9H3v6h3.5L11 19z"/>
          <path d="M15.5 8.6a4.7 4.7 0 0 1 0 6.8"/>
          <path d="M18.4 6a8.4 8.4 0 0 1 0 12"/>
        </svg>
        <i className="conDot" />
      </span>

      <div className="conBody">
        <b className="conTitle">Menu concierge</b>
        <span className="conLine" aria-live="polite">{status}</span>
        {heard && phase !== 'idle' && phase !== 'blocked' && <span className="conHeard">Heard: “{heard}”</span>}
        <span className="conPrivacy">Nothing is recorded or saved.</span>
      </div>

      <div className="conActions">
        {phase === 'idle' && <button type="button" className="conBtn" onClick={begin}>Begin</button>}
        {(phase === 'listening' || phase === 'speaking') && <button type="button" className="conBtn" onClick={pause}>Quiet</button>}
        {(phase === 'paused' || phase === 'blocked') && <button type="button" className="conBtn" onClick={resume}>{phase === 'blocked' ? 'Try again' : 'Resume'}</button>}
      </div>
    </div>
  );
}
