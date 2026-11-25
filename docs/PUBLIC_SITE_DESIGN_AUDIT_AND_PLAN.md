# Public Website Discovery And Luxury Redesign Plan

Status: Phase 1–5 complete; implementation not started.

Project root: `C:\xampp\htdocs\Hotel_paradise`  
Frontend root: `C:\xampp\htdocs\Hotel_paradise\frontend-react`  
Live site: `https://hotelparadiseonthenile.info`

## 1. Objective

Transform every existing public page into a cohesive, international luxury hotel website while preserving all pages, sections, features, React components, PHP integrations, booking/payment flows, images, navigation, localStorage keys, query parameters and database/config behavior.

The redesign must feel like a premium Nile-side hotel: confident, calm, editorial, photographic and timeless. It must not look like a generic template, a cheap gradient landing page or an AI-generated hotel site.

## 2. Non-negotiables

### Preserve completely

- All public pages and entry points.
- All existing sections and content, including fine print, policies, availability notes, rate rules, testimonials, news categories and legal clauses.
- All React components, hooks, utilities, routes, query strings, hashes and localStorage keys.
- All booking, ordering, account, payment, enquiry, news, testimonial and Pesapal flows.
- All PHP API calls, actions, redirects, settlement behavior and server-calculated amounts.
- All navigation links, CTAs, forms, modals, drawers, tabs, filters, search controls, print actions and social/contact links.
- All existing approved images. Do not replace with Unsplash, Pexels, AI, stock hotel imagery or newly invented hotel photography.
- The current hero image sequence and `HERO_COPY` order in `frontend-react\src\main.tsx` and `frontend-react\imageLibrary.mjs`.
- The current reduced-motion, keyboard, accessibility, loading, empty, error and success behaviors.

### Change only the presentation layer

- Styling, spacing, typography, hierarchy, motion refinement, art direction, layout composition and component polish.
- Additive CSS/classes and small presentational JSX refinements only.
- No destructive SQL, no baseline SQL dump edits, no live DB writes/imports and no destructive file operations.
- No unnecessary servers or external services beyond the existing app stack.

## 3. Build And Delivery Map

| Item | Current value |
|---|---|
| Vite config | `C:\xampp\htdocs\Hotel_paradise\frontend-react\vite.config.ts` |
| Vite inputs | `home`, `rooms`, `menu`, `pay`, `account`, `events`, `facilities`, `news`, `talk`, `terms`, `privacy`, `cookies` |
| Vite base | `./` |
| Output dir | `C:\xampp\htdocs\Hotel_paradise\frontend-react\dist` |
| Built public CSS | `C:\xampp\htdocs\Hotel_paradise\assets\shared.css` |
| Built public JS | `C:\xampp\htdocs\Hotel_paradise\assets\{home,rooms,menu,pay,account,events,facilities,news,talk,terms,privacy,cookies}.js` |
| Source CSS | `C:\xampp\htdocs\Hotel_paradise\frontend-react\src\styles.css` |
| Generated image manifest | `C:\xampp\htdocs\Hotel_paradise\frontend-react\src\image-manifest.json` |
| Backend API | `C:\xampp\htdocs\Hotel_paradise\backend-php\api.php` |
| Staff entry | `C:\xampp\htdocs\Hotel_paradise\system\index.php` → `backend-php\index.php?page=login` |

Build/verification commands:

```powershell
cd C:\xampp\htdocs\Hotel_paradise\frontend-react
npm run typecheck
npm run build
```

There is no separate lint script in `frontend-react\package.json`; `npm run build` runs typecheck then Vite build.

## 4. Current Design System

Existing guidelines: `docs\DESIGN_SYSTEM.md`.

Current palette tokens in `frontend-react\src\styles.css:5-15`:

- Gold: `#C9A227`, deep `#A9861B`, soft `#C9A2271a`, ink `#8A6D14`
- Navy: `#071A33`, `#0F2850`, `#1E3A5F`
- Nile: `#0B5D78`
- Ivory: `#F8F5EC`
- Ink/body: `#172033`, muted `#5D6878`, faint `#8A93A1`
- Lines: `#E4E0D2`, `#ECEEF2`
- Radius: `6px`; nav height: `82px`

Later premium tokens already exist at `frontend-react\src\styles.css:2992-2997`:

- `--hp-gold`, `--hp-gold-soft`, `--hp-gold-deep`
- `--hp-navy`, `--hp-navy-2`, `--hp-nile`, `--hp-ivory`, `--hp-white`
- `--hp-shadow`, `--hp-shadow-soft`
- `--hp-radius`, `--hp-radius-sm`, `--hp-ease`

Important cascade note: `styles.css:2999` overrides the earlier body background. Additive luxury CSS must be appended after `styles.css:3050` or carefully scoped to new opt-in classes.

Do not redefine `--r`; it is heavily used for image aspect ratios.

## 5. Phase 1 Inventory — Public Pages

### 5.1 Home

| Field | Inventory |
|---|---|
| Root built HTML | `C:\xampp\htdocs\Hotel_paradise\index.html` |
| Vite source HTML | `C:\xampp\htdocs\Hotel_paradise\frontend-react\index.html` |
| Vite input | `home: 'index.html'` |
| React source | `C:\xampp\htdocs\Hotel_paradise\frontend-react\src\main.tsx` |
| Shared sources | `shared.tsx`, `SmartImage.tsx`, `concierge.tsx`, `styles.css` |
| Built JS | `C:\xampp\htdocs\Hotel_paradise\assets\home.js` |

Sections in order:

1. `TopBar`
2. `PageNav onDark`
3. `Hero` carousel
4. `AvailabilityStrip`
5. Availability note strip
6. `STAY IN PARADISE` / `Rooms and beds`
7. `ROOM RATES AND POLICIES` / `Rates and policies`
8. `DINING AND BAR` / `Good food, great moments`
9. `THE HOTEL` / `Everything you need, in one place`
10. `CONFERENCES, WEDDINGS AND FUNCTIONS` / `Gather by the Nile`
11. `BOOKINGS AND ENQUIRIES` / `How to reach us`
12. `ExploreMore`
13. `MenuConcierge`
14. `Footer`

Interactions: hero arrows/dots/autoplay/pause, check-in/check-out/adults/room-type availability form, UGX/USD rate toggle, call/email/WhatsApp/map links, links to rooms/menu/order/events/facilities/news/talk/account.

Integrations: no direct home API call; uses shared formatting/API helpers. Availability routes to `rooms.html` with `room`, `check_in`, `check_out`, `adults`, `type`.

Images: hero folder, rooms, facilities, dishes/food, general site via `SmartImage` and `bgUrl()`.

### 5.2 Rooms

| Field | Inventory |
|---|---|
| Root HTML | `rooms.html` |
| Vite source | `frontend-react\rooms.html` |
| Vite input | `rooms` |
| React source | `frontend-react\src\rooms.tsx` |

Sections: top bar/nav, `CHOOSE YOUR ROOM`, room/bed selector, date and guest planner, price summary/booking fee, account gate, `ExploreMore`, footer.

Interactions: choose/drop bed, dates, adults, room type, continue to payment, create account/sign in gate.

Integrations:

- `apiUrl('rooms')` GET
- `apiUrl('account')` POST `me`
- `apiUrl('booking')` POST creates reservation, room rows, hold, notification and server totals

State/routing: `room`, `check_in`, `check_out`, `adults`, `resume`; `customerToken()`; success redirects to `pay.html?src=booking&ref=...&amt=...`.

Images: rooms, suit beds, triple beds, executive beds, twin beds, site and gallery.

### 5.3 Menu

| Field | Inventory |
|---|---|
| Root HTML | `menu.html` |
| Vite source | `frontend-react\menu.html` |
| Vite input | `menu` |
| React source | `frontend-react\src\menu.tsx` |
| Support | `menuData.ts`, `concierge.tsx`, `SmartImage.tsx` |

Sections: top bar/nav, `DINING AND BAR`, search/result count/sort, category chips, menu revision/dish count/live status/print menu, dish groups/cards, order note, order panel, cart drawer, sticky order pill, dish detail modal, end links, concierge, footer.

Categories: Fisherman’s Offer, Starters & Salads, Soups, Omelets & Snacks, Sandwiches, Burgers, Rolex Wraps & Burritos, House Specials & Platters, Chicken Dishes, Beef & Goat Main Courses, Pork Courses, Pizzeria, Italian Pastas, Asian & Indian Curries, Chinese Corner, Sizzler Hot Plates, Rice & Noodles, Accompaniments & Extras, Buffet & Conference, Desserts & Bakery.

Interactions: search, sort, category filters, expand/collapse, show more, dish modal with companion/salad/quantity, add to order, cart quantity/drop/continue, print menu, voice guide.

Integrations:

- `apiUrl('menu')` GET with `menuData.ts` fallback
- `apiUrl('account')` POST `me`
- `apiUrl('order')` POST creates food order and notifies kitchen/staff

State/routing/storage: `?dish=slug`; localStorage `hpn_tray`, `hpn_name`, `hpn_phone`, `hpn_email`, `hpn_address`, `hpn_notes`; success redirects to `pay.html?src=order&ref=...`.

Images: hero frames, dishes, side choices, section images.

### 5.4 Pay

| Field | Inventory |
|---|---|
| Root HTML | `pay.html` |
| Vite source | `frontend-react\pay.html` |
| Vite input | `pay` |
| React source | `frontend-react\src\pay.tsx` |

Sections/states: signed-out redirect checking, done/receipt state, top bar/nav, `SECURE CHECKOUT`, `VoiceGuide`, `YOUR REQUEST`, request detail lines, server totals, already-paid receipt, recorded payments, `WHAT HAPPENS NEXT`, details, currency, payment method, pay button/Pesapal note, explore, footer.

Interactions: edit receipt details, choose currency and payment method (Pesapal, MTN, Airtel, Visa/Mastercard), pay securely, print receipt, save PDF, WhatsApp handoff, payment-status polling.

Integrations:

- `apiUrl('currencies')`, `apiUrl('quote')`, `apiUrl('checkout')`
- `apiUrl('account')` POST `me`
- `apiUrl('payment')` POST creates payment intent and redirects to server-provided `redirect_url`
- `pesapal_ipn` / `pesapal_callback` settle server-side

Critical: the browser amount is not authoritative. `backend-php\api.php` uses DB due plus signed quote; current errors include `Oops, please refresh and try again`; demo settlement uses `DEMO_SETTLE`; Pesapal pending uses `PESAPAL_PENDING`. Preserve exactly.

State/storage: query `src`, `ref`, `amt`, `item`, `qty`, `unit`, `name`, `phone`, `email`, `address`, `paid`; localStorage `hpn_name`, `hpn_phone`, `hpn_email`, `hpn_customer_token`; requires `customerToken()`; polls up to 8 times.

Images: `hero\pool-1920.webp`, master logo, dish thumbnails.

### 5.5 Account

| Field | Inventory |
|---|---|
| Root HTML | `account.html` |
| Vite source | `frontend-react\account.html` |
| Vite input | `account` |
| React source | `frontend-react\src\account.tsx` |

Sections/states: checking state, dynamic hero, brand card, signed-in account view, phone step, email/password step, welcome-back sign-in, Google sign-in mount, explore, footer.

Signed-in features: avatar, identity, basic/extended profile, stays and orders activity, continue destination, quick links, sign out.

Profile fields: name, phone, email, DOB, gender, nationality, ID, address, city, country, postcode, company, job title, preferred language, dietary preferences, room preferences, emergency contact, notes, marketing opt-in, avatar.

Integrations: `apiUrl('account')` actions `config`, `signup`, `phone`, `signin`, `google`, `update`, `activity`, `me`, `logout`; `apiUrl('avatar')`.

State/routing/storage: query `mode`, `next`; modes `checking`, `signin`, `signup`, `phone`, `account`; `safeNext()`; localStorage `hpn_customer_token`, `hpn_customer_name`.

Images: master logo, `hero\bed-executive-1920.webp`, backend avatar.

### 5.6 Events

| Field | Inventory |
|---|---|
| Root HTML | `events.html` |
| Vite source | `frontend-react\events.html` |
| Vite input | `events` |
| React source | `frontend-react\src\events.tsx` |

Sections: top bar/nav, `CONFERENCES, WEDDINGS AND FUNCTIONS`, `OUR VENUES`, `CONFERENCE AND GROUP DINING`, `WHAT WE PLAN`, `THE EQUATION`, `START PLANNING`, explore, concierge, footer.

Venues: Nile Hall (up to 150), Banquet Hall, Conference Room, Riverside venue.

Interactions: event enquiry form with name/phone/email/event type/date/guests/venue/message, request proposal, call/email.

Integrations: `apiUrl('event')` POST writes enquiry and notifies staff.

Images: site hero, halls, site, gallery, buffet/site.

### 5.7 Facilities

| Field | Inventory |
|---|---|
| Root HTML | `facilities.html` |
| Vite source | `frontend-react\facilities.html` |
| Vite input | `facilities` |
| React source | `frontend-react\src\facilities.tsx` |

Sections: top bar/nav, facilities hero, `THE POOL`, `HEALTH CLUB AND GYM`, `THE BAR`, `GOOD TO KNOW`, gallery, `PLAN YOUR VISIT`, explore, concierge, footer.

Interactions: facility enquiry form with name/phone/email/interest/date/people/message, send enquiry, call/email.

Integrations: `apiUrl('facility')` POST writes enquiry and notifies front desk/management.

Images: `Pool-Area`, `gym`, `Bar`, `Hotel-paradise`, `fact-wellness`, `pool1`.

### 5.8 News

| Field | Inventory |
|---|---|
| Root HTML | `news.html` |
| Vite source | `frontend-react\news.html` |
| Vite input | `news` |
| React source | `frontend-react\src\news.tsx` |

Sections: top bar/nav, news hero, featured spotlight carousel, search/category chips, loading/error, open article view with reactions/comments/more stories, list view with featured/employee/news/opportunity cards, explore, concierge, footer.

Interactions: open story, carousel arrows/dots/autoplay/pause, search, filters, clear filters, reactions (like/love/applause toggle), comment form with honeypot, retry.

Integrations: `apiUrl('news')`, `apiUrl('news_react')`, `apiUrl('news_comment')`; published/scheduled stories, visitor hash uniqueness, moderation/rate limiting.

State/routing/storage: open story, query/hash slug, `history.pushState`/`replaceState`/`popstate`, localStorage `hpn_news_visitor`.

Images: cocktail/juice hero, category fallbacks `hotel`, `wine-and-fried-chiken`, `food-spread`, `dinning-space`, `view`.

### 5.9 Talk To Us

| Field | Inventory |
|---|---|
| Root HTML | `talk.html` |
| Vite source | `frontend-react\talk.html` |
| Vite input | `talk` |
| React source | `frontend-react\src\talk.tsx` |

Sections: top bar/nav, `TALK TO THE HOUSE`, `ONE FORM, TWO DOORS`, message/experience mode tabs, shared fields, message-only subject/room, star rating, `WHAT OUR GUESTS SAY`, explore, concierge, footer.

Interactions: switch mode, star radiogroup, department select, submit message/experience, load testimonials.

Integrations: `apiUrl('testimonials')`, `apiUrl('guest_message')`.

State: mode, form, rating, success, busy; reads `customerToken()`.

Images: site hero / `hero-hotel-entrence`.

### 5.10 Legal Pages — Terms, Privacy, Cookies

| Page | Root HTML | React source | Shared layout |
|---|---|---|---|
| Terms | `terms.html` | `frontend-react\src\terms.tsx` | `frontend-react\src\legal.tsx` |
| Privacy | `privacy.html` | `frontend-react\src\privacy.tsx` | `frontend-react\src\legal.tsx` |
| Cookies | `cookies.html` | `frontend-react\src\cookies.tsx` | `frontend-react\src\legal.tsx` |

All use top bar/nav, legal hero, table of contents anchor rail, clause sections, back link, explore, footer. No forms, API calls or page-specific localStorage.

Hero images:

- Terms: `hero\hotel-1920.webp`
- Privacy: `hero\view-1920.webp`
- Cookies: `hero\pool-1920.webp`

All legal wording and clause order must be preserved exactly.

### 5.11 Utility Pages

| Page | Path | Notes |
|---|---|---|
| Offline | `offline.html`; source `frontend-react\public\offline.html` | Logo, offline warning, try again → `./index.html`, call front desk → `tel:+256759504928`, reloads on `online`. No Vite input/React/API/localStorage. |
| QR landing | `qr\index.html` | Brand header, view menu, book room, printable QR codes and print sheets, service worker registration, footer contacts. Preserve utility exactly. |
| Management entry | `management-system.html` | Redirect to `./system/`; `system\index.php` redirects to `../backend-php/index.php?page=login`. Out of public visual redesign scope except preserving links. |

## 6. Shared Architecture Inventory

| Path | Role |
|---|---|
| `frontend-react\src\shared.tsx` | `apiUrl`, `apiCandidates`, customer token helpers, `LOGO`, `bgUrl`, `HOTEL`, `CALL`, `STUDIO`, `NAV`, `SERVICE_RATE`, `withService`, `fmt`, `fmtPrice`, `TopBar`, `PageNav`, `Footer`, `ExploreMore`, `EndLinks`, `AccountGate`, `HeroCoverFrame`, `PageHeroCover`, `BackLink`, `BackToTop`, `useCinematicType`, `useReveal`, service worker registration |
| `frontend-react\src\SmartImage.tsx` | Responsive image selection, manifest variants, HEAD probing when `?photos=1`, `HeroShot`, `HeroPoster`, `ImageGroupStrip`, `BedSlider`, `PageHeroCover`, empty states, srcset, width/height, lazy/eager handling |
| `frontend-react\src\concierge.tsx` | Voice guide; explicit open/start only; menu-aware when sections passed; no recording or server storage |
| `frontend-react\src\legal.tsx` | Shared legal page shell, contents rail, clause renderer |
| `frontend-react\src\menuData.ts` | Fallback menu data and helpers |
| `frontend-react\src\buttonShake.ts` | Shared button feedback animation |
| `frontend-react\public\sw.js` | Static asset caching; avoids private/admin/API caching |
| `frontend-react\public\manifest.webmanifest` | PWA install metadata |

Image groups:

| Group | Directory |
|---|---|
| `dishes` | `images\dishes\` |
| `rooms` | `images\rooms\` |
| `gallery` | `images\gallery\` |
| `facilities` | `images\facilities\` |
| `food` | `images\food\` |
| `site` | `images\` |
| `halls` | `images\meeting-rooms\` |
| `beds-exec` | `images\executive-beds-images\` |
| `beds-suit` | `images\suit-beds-images\` |
| `beds-triple` | `images\triple-beds-images\` |
| `beds-twin` | `images\twin-bed-images\` |

## 7. Phase 2 Inventory — Images And Hero Preservation

### 7.1 Source of truth

Current implemented hero source of truth:

- `frontend-react\imageLibrary.mjs:159-170`
- `frontend-react\src\image-manifest.json:9513-9732`
- `frontend-react\src\main.tsx:252-323` for `HERO_COPY`

Do not use the divergent root `imageLibrary.mjs` sequence; it is not the current frontend behavior.

### 7.2 Current hero sequence and copy

| # | Image | Copy headline |
|---|---|---|
| 1 | `images\hero\pool-1920.webp` | `THE POOL AND GARDENS` / `Golden afternoons by the pool.` |
| 2 | `images\hero\view-1920.webp` | `ON THE BANKS OF THE NILE` / `The river, right outside your door.` |
| 3 | `images\hero\bed-suite-1920.webp` | `THE SUITE` / `Space to unwind and celebrate.` |
| 4 | `images\hero\hotel-1920.webp` | `YOUR HOME IN JINJA` / `A landmark on the Nile.` |
| 5 | `images\hero\jinja-main-bridge-view-from-hotel-at-night.webp` | `JINJA AFTER DARK` / `The Nile, lit up at night.` |
| 6 | `images\hero\food-pizza-two-1920.webp` | `FROM THE PIZZA OVEN` / `A proper margherita.` |
| 7 | `images\hero\food-breakfast-1920.webp` | `MORNING AT THE HOTEL` / `Breakfast, served with the sunrise.` |
| 8 | `images\hero\bed-executive-1920.webp` | `THE EXECUTIVE ROOM` / `Rest, finely considered.` |
| 9 | `images\hero\pork-bbq.webp` | `STRAIGHT FROM THE GRILL` / `Pork barbecue, glazed and sticky.` |
| 10 | `images\hotel-view-poster.jpg` | `WELCOME TO PARADISE` / `A place the river calls home.` |

Preserve image slugs, order, copy, CTAs, variant widths and autoplay behavior. The redesign may refine overlay, typography framing, hairlines, progress indicators and spacing only.

### 7.3 Image library scale

| Directory | Images | Size |
|---|---:|---:|
| `images\` overall | 1845 | 1.425 GB |
| `images\hero\` | 118 | 12.50 MB |
| `images\rooms\` | 257 | 581.26 MB |
| `images\dishes\` | 393 | 162.50 MB |
| `images\food\` | 726 | 138.32 MB |
| `images\gallery\` | 41 | 115.77 MB |
| `images\executive-beds-images\` | 36 | 70.44 MB |
| `images\suit-beds-images\` | 36 | 63.30 MB |

### 7.4 Visual review limitation

Image subject descriptions from the image audit are label-derived from filenames, `alt` text, captions and surrounding page copy. The current model cannot reliably visually inspect all images. Final image approval must use direct image-capable review or user confirmation. No image should be removed or replaced because of a label-derived assumption.

## 8. Phase 3–5 Luxury Design Direction

### 8.1 Aesthetic direction

Direction name: **Nile Editorial Luxury**.

Principles:

- Full-bleed photography with calm, dark, low-saturation overlays.
- Ivory editorial content sheets that feel like a printed hotel journal.
- Navy as the primary authority color; gold used only for hairlines, small caps, rules and focus states.
-Generous whitespace, strong typographic hierarchy and restrained card use.
- Booking and ordering CTAs remain prominent but feel like concierge invitations, not hard-sell buttons.
- Each page receives a distinct introduction rhythm instead of one repeated hero template.
- The homepage remains cinematic; functional pages remain clear and fast.

Avoid:

- Bright generic gradients.
- Heavy gold backgrounds.
- Large stacked shadows.
- Crowded card walls.
- Excessive rounded UI.
- Decorative controls that do nothing.
- External stock or AI imagery.

### 8.2 Typography direction

Current: DM Sans body + Playfair Display headings via Google Fonts link in page heads.

Target:

- Display: keep `Playfair Display` for continuity and elegance.
- Body/UI: replace `DM Sans` with `Inter` for a cleaner international hotel feel.
- Keep weights restrained: Inter `400`, `500`, `600`, `700`; Playfair Display `500`, `600`, `700`.
- Keep `font-display=swap` and head-loaded font links; do not use CSS `@import`.
- Update the font link consistently across all root HTML files and the matching `frontend-react\*.html` sources.
- Do not change legal text, button labels or hero copy.

Proposed scale:

| Use | Treatment |
|---|---|
| Hero title | Playfair Display, large clamp, tight leading, restrained gold eyebrow |
| Section title | Playfair Display, 2–4rem, navy on ivory, white on navy |
| Kicker/eyebrow | Inter, uppercase, tracked, small, gold/deep gold |
| Body | Inter, 15.5–17px, relaxed line-height, max readable measure |
| Button | Inter, semibold, small tracking, clear focus ring |
| Price/number | Inter tabular numerals |
| Pull quote | Playfair Display italic, gold rule |

### 8.3 Color direction

Use existing `--hp-*` tokens. Add only semantic aliases if needed:

```css
:root{
  --lux-gold:var(--hp-gold);
  --lux-gold-soft:var(--hp-gold-soft);
  --lux-gold-deep:var(--hp-gold-deep);
  --lux-navy:var(--hp-navy);
  --lux-navy-2:var(--hp-navy-2);
  --lux-ivory:var(--hp-ivory);
  --lux-line:rgba(201,162,39,.24);
  --lux-panel:linear-gradient(145deg,rgba(255,255,255,.94),rgba(248,244,234,.88));
  --lux-radius:var(--hp-radius);
  --lux-shadow:var(--hp-shadow);
  --lux-ease:var(--hp-ease);
}
```

Recommended surfaces:

- Hero: photograph + navy/black gradient, gold hairline, white text.
- Main content: ivory/white paper with navy text.
- Premium panels: white/ivory panel, gold hairline, very soft shadow.
- Dark feature bands: navy or Nile blue with white text and gold rules.
- Forms: white panel, navy labels, gold focus border, clear error/success colors.
- Footer: navy base, preserve the existing Uganda flag stripe motif from `docs\DESIGN_SYSTEM.md`.

### 8.4 Motion direction

Preserve and refine existing motion system:

- 180–350ms transitions.
- Fade/slide reveal on section entry.
- Gentle hero zoom.
- Button hover lift of 1–2px.
- Subtle image parallax only where it does not hurt performance.
- Reveal hierarchy for editorial section headers.
- No continuous distracting animation.

Guardrails:

- Preserve global reduced-motion behavior already at `styles.css:3048-3050`.
- Autoplay pauses on hover, focus, hidden tab, reduced motion and low-motion states.
- Use `transform`/`opacity` where possible.
- Disabled transitions under `prefers-reduced-motion: reduce`.
- No motion that delays booking, payment, form completion or navigation.

### 8.5 Additive component layer

Add opt-in classes only; do not rename or remove existing classes:

- `.luxPanel` — premium surface.
- `.luxRule` — short gold divider.
- `.luxKicker` — restrained uppercase eyebrow.
- `.luxFrame` — optional mounted-print photo treatment.
- `.luxSectionHead` — editorial section heading layout.
- `.luxAction` — refined primary CTA skin layered on existing `.btn`.
- `.luxLedger` — premium rate/policy ledger presentation.
- `.luxForm` — refined form surface and label spacing.

Append these styles after `styles.css:3050`.

## 9. Phase 6 Page-By-Page Design Improvement Plan

### 9.1 Home — cinematic flagship

Preserve all 14 sections, all 10 hero slides, availability form, rates, dining, hotel, events, contact, explore, concierge and footer.

Design improvements:

- Keep the full-width hero sequence but refine it into a luxury title sequence: larger editorial typography, restrained gold rule, lower-left/center composition, stronger but softer scrim.
- Use a thin slide progress line and numbered pagination that feels like a hotel film, not a generic carousel.
- Style the availability strip as a refined white/gold concierge panel with clear labels and strong focus states.
- Convert section headings into editorial intro blocks with small numbered/kicker labels and short gold rules.
- Present rooms as large photographic stories with minimal text cards.
- Present rates as a clean ledger: hairline rows, aligned numbers, subtle currency toggle, no dense table feel.
- Dining section should be image-led and appetite-forward using existing food imagery.
- Events section should feel grand and calm, with a dark navy band and gold rule.
- Contact section should remain practical: call, email, WhatsApp and map links always obvious.
- Do not change hero copy, CTA destinations, URLs, query strings or rate logic.

### 9.2 Rooms — editorial accommodation catalogue

Preserve room selector, bed groups, planner, pricing/booking fee, account gate and booking API flow.

Design improvements:

- Use a split editorial introduction: room image on one side, concise heading and booking promise on the other.
- Treat bed cards as catalog entries with strong image hierarchy, clear occupancy/price badges and refined selected state.
- Make the date/guest planner a sticky concierge panel on desktop and a compact stacked panel on mobile.
- Show selected room details in a larger image-led panel instead of relying on dense card text.
- Style account gate as a discreet invitation, not a blocker or modal trap.
- Preserve `?room`, `?check_in`, `?check_out`, `?adults`, `?resume`, `customerToken()` and redirect to pay.

### 9.3 Menu — luxury dining journal

Preserve search, sort, categories, dish groups, count/revision, print, modal, order panel, tray, sticky pill, concierge and all localStorage keys.

Design improvements:

- Introduce an editorial menu masthead with dish count and live/printed status.
- Style category chips as fine-dining index tabs; preserve all categories.
- Dish cards should be image-first with restrained price typography and clear add/open actions.
- Dish detail modal should feel like a menu course card: large image, companion/salad choices, quantity and add-to-order.
- Cart drawer should feel like a private order sheet with totals and a strong continue action.
- Sticky order pill must remain visible but unobtrusive.
- Preserve `?dish=slug`, history updates, print and voice guide.

### 9.4 Pay — calm secure checkout

Preserve checking state, receipt state, request summary, server totals, payment methods, currency, polling, print/PDF, WhatsApp and Pesapal redirect.

Design improvements:

- Use a two-column layout: order summary panel plus checkout form.
- Increase trust signals without adding fake badges: secure checkout wording, clear totals, explicit next steps.
- Make payment method selection a refined radio-card list with gold selected state.
- Keep Pesapal note prominent but calm.
- Style receipts with tabular numerals, hairline rules and print-friendly layout.
- Ensure the browser never appears to control the authoritative amount; keep server-calculated totals clearly presented.
- Preserve all query params, localStorage autofill and redirect behavior.

### 9.5 Account — private guest lounge

Preserve checking, signup, phone, signin, Google sign-in, signed-in profile, activity, avatar upload, logout, `next` redirect and safe redirect rules.

Design improvements:

- Frame account steps as a private guest lounge: calm hero, numbered steps, minimal fields.
- Keep step progression visually explicit.
- Profile form should use grouped sections with clear labels and generous spacing.
- Activity list should use refined rows with status badges.
- Avatar and identity card should feel premium but not dominate.
- Google sign-in must remain conditional on backend config.
- Do not add requirements, remove fields or change validation behavior.

### 9.6 Events — grand gathering storytelling

Preserve venue cards, buffet/conference content, planning sections, form, explore, concierge and footer.

Design improvements:

- Use a dramatic photographic introduction with editorial heading.
- Venue cards should alternate image/text rhythm rather than a uniform grid.
- Capacity and venue purpose should be clear badges.
- The planning form should be an elegant navy/ivory panel with strong CTA.
- Call/email links remain prominent.
- Preserve `apiUrl('event')` POST behavior.

### 9.7 Facilities — sensory feature storytelling

Preserve pool, gym, bar, good-to-know, gallery, enquiry form, explore, concierge and footer.

Design improvements:

- Use alternating full-width imagery and editorial text for pool/gym/bar.
- Gallery becomes a refined masonry/editorial mosaic using existing images.
- Facility enquiry form should be compact and practical.
- Keep image loading lazy except first above-fold image.
- Preserve `apiUrl('facility')`.

### 9.8 News — hotel journal

Preserve featured carousel, search/filter, article/list views, reactions, comments, employee feature, opportunity apply panel, slug routing and visitor localStorage.

Design improvements:

- Treat news as a hotel journal with a strong masthead and featured-story spotlight.
- Article view should have a readable measure, elegant meta line and restrained image presentation.
- Reactions and comments should feel like refined guest notes with states preserved.
- Carousel should keep pause-on-hover/focus/hidden-tab and reduced-motion behavior.
- Preserve all API actions and routing behavior.

### 9.9 Talk To Us — concierge correspondence

Preserve mode tabs, forms, star picker, testimonials, customer token use and all backend submission behavior.

Design improvements:

- Style as a concierge desk: warm ivory panel, clear mode switch, thoughtful form rhythm.
- Star rating should be elegant and accessible.
- Testimonials should be presented as editorial quotes with restrained gold rules.
- Keep department select, room number and message-only fields intact.
- Preserve success/busy/error states.

### 9.10 Legal pages — quiet document luxury

Preserve every clause, heading, order, link, back link and hero image.

Design improvements:

- Sticky table of contents on desktop; collapsible/simple anchor navigation on mobile.
- Comfortable reading measure and spacing.
- Subtle numbered clause markers and gold hairlines.
- Strong focus states for anchors and back link.
- No content rewriting, summarization or legal interpretation.

### 9.11 Utility pages

- Offline: polish logo, message and buttons while preserving offline behavior and phone link.
- QR: preserve QR images, print sheets, menu/booking links and service worker registration; apply only light typography/spacing polish.
- Management entry: leave redirect/system behavior unchanged.

## 10. Phase 7 Functional Preservation Checklist

Every implementation batch must verify:

- Navigation links: home, rooms, menu, pay, account, events, facilities, news, talk, terms, privacy, cookies, staff login.
- Hero arrows/dots/autoplay/pause/keyboard.
- Availability form query string to rooms.
- Room selection, planner, account gate, booking POST and pay redirect.
- Menu search/sort/filter/show-more, dish modal, cart, print, voice guide, order POST and pay redirect.
- Pay quote/checkout/currency/method/payment POST, Pesapal redirect, polling, receipt print/PDF/WhatsApp.
- Account signup/phone/signin/Google/config/update/activity/avatar/logout and `next` redirect.
- Events and facilities forms and POST actions.
- News carousel/search/filter/article routing/reactions/comments/retry.
- Talk mode tabs, star rating, testimonials and guest message POST.
- Legal ToC anchors and back links.
- Offline reload and call button.
- QR links and print sheets.
- All localStorage keys and query params listed in this document.
- Mobile bottom booking CTA and desktop booking CTA remain visible where currently present.
- Keyboard focus, skip links, aria labels and reduced-motion behavior remain intact.

## 11. Phase 8 Responsive, Performance, Accessibility And SEO

### Responsive

- Inspect at 390px, 768px, 1024px, 1440px and 1920px.
- No horizontal overflow.
- Forms and CTAs remain usable one-handed on mobile.
- Sticky panels do not cover content or the mobile CTA.
- Large photography crops sensibly without losing subject.

### Performance

- Keep existing `SmartImage` responsive srcset/manifest behavior.
- First hero image eager/high priority; remaining images lazy.
- Avoid heavy fixed backgrounds on mobile; existing `body` background switches to scroll at `<=900px`.
- Prefer `transform`/`opacity` animations.
- Do not load extra image libraries or external image services.

### Accessibility

- Preserve `role="tablist"`, aria labels, focus states and skip links.
- Forms keep labels, error/success messages and keyboard operation.
- Modal/drawer focus behavior must not regress.
- Color contrast must remain WCAG-aware, especially gold text on light surfaces.
- Respect `prefers-reduced-motion`, forced colors and print styles.

### SEO

- Preserve titles, descriptions, canonical intent, favicon, manifest and Open Graph-related metadata already present.
- Do not remove structured data if present.
- Use semantic heading order; do not skip levels in new presentational markup.
- Keep image alt text meaningful and do not strip width/height attributes.

## 12. Implementation Sequencing

1. Additive global luxury layer in `frontend-react\src\styles.css` after line 3050.
2. Font head updates across root HTML sources and built HTML equivalents.
3. Shared shell polish in `shared.tsx` classes/markup only where needed for the new visual system.
4. Hero/typography polish in `main.tsx` without changing `HERO_COPY`, slugs or behavior.
5. Implement page batches:
   - Batch A: home, rooms, pay.
   - Batch B: menu, account.
   - Batch C: events, facilities, talk.
   - Batch D: news, legal pages.
   - Batch E: offline, QR and utility polish.
6. Run `npm run typecheck` and `npm run build` after each batch.
7. Run browser/DOM checks at required widths and fix regressions.
8. Final report listing changed files, preserved flows, screenshots if available, and limitations.

## 13. Risk Register

| Risk | Mitigation |
|---|---|
| Visual redesign breaks API flows | Only alter presentation; re-read integration checklist after each batch; run build and functional smoke checks. |
| Hero imagery altered accidentally | Do not touch `HERO_COPY`, `HERO_SEQUENCE`, image slugs or manifest order. |
| CSS cascade overrides fail | Append after `styles.css:3050`; scope new opt-in classes; do not redefine `--r`. |
| Font change affects layout | Use conservative scale and test at all breakpoints; keep existing font-display behavior. |
| Image crop hides subject | Use existing aspect-ratio system and direct image-capable review before final approval. |
| Motion hurts performance or accessibility | Use transform/opacity, reduced-motion guards and existing pause logic. |
| Legal wording changed | Preserve clause text exactly; only style the shared legal shell. |
| Payment behavior changed | Never use browser amount as authority; preserve api.php and Pesapal behavior. |
| Evaluation constraint | Frontend-design skill requires evaluator from different provider; current task tool does not expose model/provider selection. Use available subagents and report this limitation if evaluation cannot be provider-differentiated. |

## 14. Current Status

- Discovery and image/integration audits: complete.
- Design direction, typography, color, motion and page-by-page improvement plan: complete.
- Temp design brief for implementation agents: not yet written.
- Implementation: not started.
- Build/typecheck/browser verification: not yet run for redesign.
- No public files have been modified for this redesign yet.
