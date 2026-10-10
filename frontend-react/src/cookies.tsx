import {createRoot} from 'react-dom/client';
import './styles.css';
import {LegalPage, type LegalClause} from './legal';

/**
 * The Cookie Policy.
 *
 * Describes what the site actually does: a signed-in token and an install
 * prompt flag in local storage, a service worker that caches static files for
 * offline use, and the two Google embeds (Fonts and Maps) the pages rely on.
 */
const clauses: LegalClause[] = [
 {
  id: 'what-are-cookies',
  title: 'What Are Cookies and Similar Technologies',
  paras: [
   'Cookies are small text files that a website asks your browser to store, and read back on a later visit. Similar technologies include local storage, which lets a site keep information in your browser, and service workers, which run quietly in the background.',
   'Together, these technologies help a website remember your choices, keep you signed in where that is offered, and work reliably. This policy explains how we use them on this website.'
  ]
 },
 {
  id: 'our-approach',
  title: 'Our Approach',
  paras: [
   'We keep this simple. This website does not use advertising cookies and does not run behavioural tracking across other sites. We set the smallest amount of storage needed to make the site work and to remember your preferences, and we are clear about the third-party embeds that appear on our pages.',
   'Where a feature depends on your browser storing something, you will find it listed below.'
  ]
 },
 {
  id: 'categories',
  title: 'Categories We Use',
  paras: ['If you visit this website, the storage we rely on falls into the following categories.'],
  list: [
   'Strictly necessary. Needed for the site to function and for the signed-in account area to work. These cannot be switched off without breaking those features.',
   'Preferences. Used to remember a choice you have made, such as dismissing an app-install prompt, so the site does not ask again.',
   'Third-party embeds. Some pages load content from other providers, such as web fonts and an embedded map, which may set their own cookies.'
  ]
 },
 {
  id: 'what-we-set',
  title: 'Cookies and Storage We Set',
  paras: ['The main items we store in your browser are as follows.'],
  list: [
   'A sign-in token and the first name of the signed-in guest, kept in your browser\u2019s local storage, so that the account and payment pages can recognise you. This is strictly necessary when you choose to sign in, and is never used for advertising.',
   'A small flag in local storage that remembers you have dismissed the \u201Cinstall app\u201D prompt, so it is not shown to you again. This is a preference only.',
   'A service worker cache, which stores the public site\u2019s own static files (pages, styles, scripts and images) so the site opens quickly and, where possible, works offline. It does not store personal information and is never used to serve one guest\u2019s data to another.'
  ]
 },
 {
  id: 'third-party',
  title: 'Third-Party Content and Cookies',
  paras: ['Some parts of the site are provided by other companies, and they may set their own cookies.'],
  list: [
   'Web fonts are loaded from Google Fonts so that our typography displays correctly. Google may receive your IP address and basic request information when a font is loaded.',
   'A Google Map is embedded on our home page so you can find the hotel. Google may set cookies when the map is loaded or used.',
   'When you choose to pay online, you are taken to our payment partner\u2019s secure page, which is governed by that partner\u2019s own privacy and cookie policies.'
  ]
 },
 {
  id: 'managing',
  title: 'Managing Cookies and Storage',
  paras: [
   'You can control and clear cookies and local storage through your browser settings, and most browsers let you block third-party cookies. The exact steps differ from browser to browser, so please use your browser\u2019s help pages for guidance.',
   'Please note that blocking or clearing certain storage may affect how the site works. In particular, clearing local storage will sign you out, and disabling the service worker will remove the offline capability.'
  ]
 },
 {
  id: 'changes',
  title: 'Changes to This Cookie Policy',
  paras: [
   'We may update this Cookie Policy if we change the technologies we use. The current version is the one published on this page, and the date of the last review is shown above.'
  ]
 },
 {
  id: 'contact',
  title: 'How to Contact Us',
  paras: [
   'If you have any question about this policy, write to us at the email address in the page footer, or to Hotel Paradise on the Nile Ltd, Plot 12, 19 & 25 Kiira Lane, Jinja, Uganda; P.O. Box 1139, Jinja, Uganda.'
  ]
 }
];

createRoot(document.getElementById('root')!).render(
 <LegalPage
  eyebrow="COOKIES AND STORAGE"
  title="Cookie Policy"
  updated="10 October 2026"
  heroBg="./images/hero/pool-1920.webp"
  intro="What we store in your browser, why we store it, and how you stay in control. We use the least we can, and we set out every item that matters."
  clauses={clauses}
 />
);
