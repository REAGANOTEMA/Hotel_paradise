import {createRoot} from 'react-dom/client';
import './styles.css';
import {LegalPage, type LegalClause} from './legal';

/**
 * The Terms and Conditions.
 *
 * Written to sit on top of the hotel's real practice: the check-in and
 * check-out times the Stay column states, the 48 hour direct-booking window,
 * and the UNBS certification the footer already carries.
 */
const clauses: LegalClause[] = [
 {
  id: 'introduction',
  title: 'Introduction and Acceptance',
  paras: [
   'Welcome to Hotel Paradise on the Nile. These Terms and Conditions govern your use of our website and the rooms, dining, events and other services offered at our property on Kiira Lane, Jinja.',
   'By browsing this website, making a reservation, or staying with us, you agree to be bound by these terms. Please read them carefully and keep a copy for your reference.',
   'These terms should be read together with our Privacy Policy and our Cookie Policy, which explain how we handle your personal information and the technologies we use on this website. Both documents form part of these terms.'
  ]
 },
 {
  id: 'definitions',
  title: 'Definitions',
  paras: ['In these terms, the following words have the meanings set out below.'],
  list: [
   '\u201CThe Hotel\u201D, \u201Cwe\u201D, \u201Cus\u201D and \u201Cour\u201D mean Hotel Paradise on the Nile Ltd, Plot 12, 19 & 25 Kiira Lane, Jinja, Uganda.',
   '\u201CGuest\u201D and \u201Cyou\u201D mean the person making a booking with us, and, where the context allows, any person staying or attending under that booking.',
   '\u201CBooking\u201D means a confirmed reservation of a room, table, hall, function or other service we provide.',
   '\u201CWebsite\u201D means hotelparadiseonthenile.info and every page served under it.'
  ]
 },
 {
  id: 'bookings',
  title: 'Bookings and Reservations',
  paras: [
   'A booking may be made directly at the front desk, over the telephone, through this website, or through a partner or travel agent. It is confirmed once we have issued a confirmation and, where a deposit or cancellation window applies, the required details have been provided.',
   'The person making a booking must be at least eighteen years old and is responsible for the full value of the stay, including any charges properly incurred by the guests accompanying them.',
   'All bookings are subject to availability. Photographs of rooms, halls and dining are indicative of the category offered; the room or space assigned may differ in layout, view or furnishings while remaining of the category booked.'
  ]
 },
 {
  id: 'rates',
  title: 'Rates, Taxes and Payment',
  paras: [
   'Rates are quoted in Uganda Shillings unless stated otherwise, and include the amenities described for the room or service booked. Applicable government taxes, levies and statutory charges are added where required by law, and are shown on your confirmation and invoice.',
   'Payment may be made in cash, by mobile money, or by card. Where an online payment is offered it is processed by our payment partner, which acts as merchant of record; we do not store full card details on our systems.',
   'We may ask for valid identification and, for some stays, a pre-authorisation or refundable deposit to cover incidental charges. Amounts held are released in line with the policy of your bank, mobile money provider or card issuer.'
  ]
 },
 {
  id: 'stay',
  title: 'Check-in, Check-out and Your Stay',
  paras: [
   'Check-in is available from 12 noon and check-out is by 10 am. An early check-in or late check-out is offered subject to availability and may carry a charge.',
   'A full breakfast is included in every room rate and is served each morning. Guests must present valid identification (a national identity document or passport) at check-in. We may decline a stay where identity cannot reasonably be confirmed.',
   'The front desk is open twenty four hours a day for the comfort and security of our guests.'
  ]
 },
 {
  id: 'cancellations',
  title: 'Cancellations, Changes and Refunds',
  paras: [
   'You may change or cancel a direct booking without charge up to 48 hours before the check-in date, unless different terms were agreed in writing at the time of booking or apply to a promotional or seasonal rate.',
   'Cancellations made within 48 hours of check-in, and no-shows, may be charged the first night or such other amount as was agreed at the time of booking.',
   'Approved refunds are made to the original method of payment within a reasonable period. Charges levied by a bank, mobile money provider or payment partner may not be refundable.',
   'Events, weddings, conferences and group bookings may be subject to separate cancellation and minimum-number terms, which will be confirmed in your written proposal.'
  ]
 },
 {
  id: 'house-rules',
  title: 'House Rules and Guest Conduct',
  paras: [
   'We ask every guest to treat the property, our team and fellow guests with courtesy. Quiet hours are observed in the evening so that all our guests can rest.',
   'Guests are responsible for any loss or damage they cause to the Hotel\u2019s property, and will be charged the reasonable cost of repair or replacement. The Hotel may ask a guest to leave, without refund, where their behaviour is unlawful, dangerous or seriously disruptive to others.'
  ],
  list: [
   'Smoking is not permitted in the rooms; designated outdoor areas are provided.',
   'Please respect the comfort of other guests and keep noise to a minimum after hours.',
   'Children remain the responsibility of their parents or guardians at all times.',
   'The use of the pool and other facilities is at your own risk and subject to any notices displayed on site.'
  ]
 },
 {
  id: 'dining-events',
  title: 'Dining, Events and Functions',
  paras: [
   'Menus, buffet offerings and prices are subject to change with the season and availability. We are pleased to accommodate dietary requirements where these are notified to us in advance.',
   'Event and function bookings are confirmed by a written proposal and, where required, a deposit. Final guest numbers are normally confirmed a few days before the event, and may affect the price of a catered function.',
   'We are not responsible for services arranged with third-party suppliers engaged by you, although we will reasonably assist with coordination wherever we can.'
  ]
 },
 {
  id: 'parking-property',
  title: 'Parking and Personal Property',
  paras: [
   'Parking is available on the property and is provided as a courtesy. The Hotel is not liable for loss of or damage to vehicles or their contents, except where caused by our negligence.',
   'Please keep valuables secure. The Hotel is not liable for personal belongings left in public areas or elsewhere on the property, except where the law provides otherwise.'
  ]
 },
 {
  id: 'website-ip',
  title: 'Website Use and Intellectual Property',
  paras: [
   'The content of this website, including its text, photographs, the hotel name and logo, is owned by or licensed to the Hotel and may not be copied, reproduced, distributed or reused without our prior written permission.',
   'You agree not to misuse the website, to interfere with its normal operation, or to attempt to gain unauthorised access to any part of it or to the systems that support it.'
  ]
 },
 {
  id: 'liability',
  title: 'Liability',
  paras: [
   'We take care to keep our guests safe and comfortable. However, to the fullest extent permitted by law, the Hotel is not liable for indirect or consequential loss, or for events beyond our reasonable control.',
   'Nothing in these terms excludes or limits any liability that cannot lawfully be excluded or limited, including liability for death or personal injury caused by our negligence.',
   'Any concern or claim relating to a stay should be raised with us promptly so that we have a fair opportunity to put matters right.'
  ]
 },
 {
  id: 'privacy-cookies',
  title: 'Privacy and Cookies',
  paras: [
   'We handle your personal information in accordance with our Privacy Policy, and we use cookies and similar technologies as described in our Cookie Policy. Both documents form part of these terms and should be read alongside them.'
  ]
 },
 {
  id: 'disputes',
  title: 'Complaints, Governing Law and Disputes',
  paras: [
   'If something is not right, please tell us while you are with us, or as soon as possible afterwards, so that we can address it. Written complaints may be sent to the email or postal address below.',
   'These terms are governed by the laws of the Republic of Uganda, and the courts of Uganda have jurisdiction over any dispute that arises, without prejudice to any rights you may have under mandatory consumer law.'
  ]
 },
 {
  id: 'changes',
  title: 'Changes to These Terms',
  paras: [
   'We may update these terms from time to time. The version published on this page is the current one, and the date of the last review is shown above. Continued use of our website or services after a change takes effect means that you accept the updated terms.'
  ]
 },
 {
  id: 'contact',
  title: 'How to Contact Us',
  paras: [
   'Hotel Paradise on the Nile Ltd, Plot 12, 19 & 25 Kiira Lane, Jinja, Uganda. P.O. Box 1139, Jinja, Uganda.',
   'For any question about these terms, please use the contact details in the page footer or the button below.'
  ]
 }
];

createRoot(document.getElementById('root')!).render(
 <LegalPage
  eyebrow="LEGAL"
  title="Terms & Conditions"
  updated="10 October 2026"
  heroBg="./images/hero/hotel-1920.webp"
  intro="The terms on which we welcome you to Hotel Paradise on the Nile. They set out how bookings, payments, stays and events work, and the standards we hold ourselves to in looking after every guest."
  clauses={clauses}
 />
);
