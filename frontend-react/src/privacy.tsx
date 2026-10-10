import {createRoot} from 'react-dom/client';
import './styles.css';
import {LegalPage, type LegalClause} from './legal';

/**
 * The Privacy Policy.
 *
 * Ties the hotel's practice to Uganda's Data Protection and Privacy Act, and
 * names the real channels a guest writes to: the front desk email and phone in
 * the footer, and the Personal Data Protection Office as the regulator.
 */
const clauses: LegalClause[] = [
 {
  id: 'introduction',
  title: 'Introduction',
  paras: [
   'Hotel Paradise on the Nile respects your privacy. This Privacy Policy explains what personal information we collect, why we collect it, how we use and protect it, and the choices and rights available to you.',
   'It applies to information we collect through this website, at our premises on Kiira Lane, Jinja, and in the course of providing rooms, dining, events and related hospitality services. It should be read together with our Terms & Conditions and our Cookie Policy.'
  ]
 },
 {
  id: 'who-we-are',
  title: 'Who We Are',
  paras: [
   'Hotel Paradise on the Nile Ltd, of Plot 12, 19 & 25 Kiira Lane, Jinja, Uganda, is the controller responsible for the personal information described in this policy.',
   'We are registered and operate in Uganda and handle personal information in accordance with the Data Protection and Privacy Act, 2019 and the regulations made under it.'
  ]
 },
 {
  id: 'what-we-collect',
  title: 'Information We Collect',
  paras: ['Depending on how you interact with us, we may collect the following.'],
  list: [
   'Identity and contact details, such as your name, telephone number, email address and postal address.',
   'Booking and stay details, such as arrival and departure dates, room type, number of guests, special requests and dining or event information.',
   'Identification presented at check-in, such as a national identity document or passport, where we are required or permitted to record it.',
   'Payment-related information, such as the amount, method and reference of a payment. Card payments are handled by our payment partner and we do not store full card details.',
   'Enquiry content, such as the details you send us when you ask about a room, a table or an event.',
   'Limited technical information recorded automatically when you use this website, such as your IP address, browser type and the pages you visit, kept for the security and reliable operation of the site.'
  ]
 },
 {
  id: 'how-we-use',
  title: 'How We Use Your Information',
  paras: ['We use personal information to look after you and to run the hotel properly. In particular, to:'],
  list: [
   'confirm, manage and provide your booking, and to deliver the services you request;',
   'communicate with you about your stay, your enquiry or your event;',
   'process payments and keep accurate financial records;',
   'keep our guests, our team and our property safe and secure;',
   'improve our services and understand how our website is used;',
   'comply with our legal, tax and regulatory obligations; and',
   'with your consent, send you news and offers. You may withdraw that consent at any time.'
  ]
 },
 {
  id: 'legal-basis',
  title: 'Our Lawful Basis for Processing',
  paras: [
   'We process your personal information on one or more of the following bases: to perform a contract with you, such as providing a room you have booked; to comply with a legal obligation, such as tax and safety requirements; for our legitimate interests, such as securing our premises and improving our services, weighed against your rights; and, where applicable, on your consent, which you may withdraw at any time.'
  ]
 },
 {
  id: 'sharing',
  title: 'Sharing Your Information',
  paras: [
   'We do not sell your personal information. We share it only as needed to run the hotel and as the law allows. This may include sharing with members of our team, with service providers such as our payment partner and our website host, and with professional advisers.',
   'We may also disclose information to a public authority, court or regulator where we are required to do so by law, or where necessary to protect the rights, property or safety of our guests, our team or others.'
  ]
 },
 {
  id: 'transfers',
  title: 'International Transfers',
  paras: [
   'Some of our service providers may process information on systems located outside Uganda. Where information is transferred abroad, we take reasonable steps to ensure that it continues to receive an appropriate standard of protection, as required by applicable law.'
  ]
 },
 {
  id: 'retention',
  title: 'How Long We Keep It',
  paras: [
   'We keep personal information only for as long as we need it for the purposes described in this policy, and for any period required by law. Booking and financial records are usually kept for the period required by Ugandan tax and accounting rules, after which they are securely deleted or anonymised.'
  ]
 },
 {
  id: 'security',
  title: 'How We Protect Your Information',
  paras: [
   'We use appropriate technical and organisational measures to protect your personal information against unauthorised access, loss, misuse or alteration. These measures include secure systems, access controls and staff training.',
   'No method of transmission or storage is completely secure. While we work hard to protect your information, we cannot guarantee absolute security, and we encourage you to contact us immediately if you believe your information has been compromised.'
  ]
 },
 {
  id: 'your-rights',
  title: 'Your Rights',
  paras: ['Subject to the law, you have the right to:'],
  list: [
   'be informed about how we handle your personal information;',
   'request access to the personal information we hold about you;',
   'ask us to correct information that is inaccurate or out of date;',
   'ask us to delete information that we no longer need to keep;',
   'ask us to restrict or to stop certain processing, and to object to processing based on our legitimate interests;',
   'request the information you gave us in a portable form, where technically feasible;',
   'withdraw any consent you have given, at any time; and',
   'lodge a complaint with the Personal Data Protection Office, or the courts.'
  ]
 },
 {
  id: 'children',
  title: 'Children\u2019s Privacy',
  paras: [
   'Our website and services are not directed at children. Bookings must be made by a person who is at least eighteen years old, and we do not knowingly collect personal information directly from children. Where a child is a guest, their information is provided and managed by a parent or guardian.'
  ]
 },
 {
  id: 'cookies',
  title: 'Cookies and Similar Technologies',
  paras: [
   'This website uses cookies, local storage and a service worker to keep the site working and to remember your preferences. Full details, and how to manage them, are set out in our Cookie Policy.'
  ]
 },
 {
  id: 'changes',
  title: 'Changes to This Policy',
  paras: [
   'We may update this Privacy Policy from time to time to reflect changes in our practice or the law. The current version is the one published on this page, and the date of the last review is shown above. Where a change is significant, we will take reasonable steps to bring it to your attention.'
  ]
 },
 {
  id: 'contact',
  title: 'How to Contact Us',
  paras: [
   'If you have any question about this policy, or wish to exercise any of your rights, write to us at the email address in the page footer, or to Hotel Paradise on the Nile Ltd, Plot 12, 19 & 25 Kiira Lane, Jinja, Uganda; P.O. Box 1139, Jinja, Uganda.',
   'If you are not satisfied with our response, you may contact the Personal Data Protection Office, the regulator for data protection in Uganda.'
  ]
 }
];

createRoot(document.getElementById('root')!).render(
 <LegalPage
  eyebrow="YOUR PRIVACY"
  title="Privacy Policy"
  updated="10 October 2026"
  heroBg="./images/hero/view-1920.webp"
  intro="A clear account of the personal information we hold, why we hold it, and the rights and choices you have. We keep it plain, and we keep it current."
  clauses={clauses}
 />
);
