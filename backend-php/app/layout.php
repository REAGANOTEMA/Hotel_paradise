<?php
declare(strict_types=1);

require_once __DIR__.'/notify.php';

/** The rail, in groups. Every group and every link is dropped when the
 *  signed-in member is not allowed to open that module, so each person
 *  sees only their own console.
 *
 *  A module appears once and in the one group that owns it, so nothing is
 *  repeated and no module sits where it does not belong. Each group is a
 *  button that folds its modules away, and the group holding the page in
 *  view opens itself and reads as the active one. */
function nav_groups(): array{
  return [
   ['label'=>'Overview','items'=>[
     'dashboard'=>'Dashboard','overview'=>'CEO / Director','integrity'=>'Integrity & Control']],
   ['label'=>'Reservations & Rooms','items'=>[
     'reservations'=>'Reservations','rooms'=>'Rooms','guests'=>'Guests']],
   ['label'=>'News & Events','items'=>[
     'news'=>'News & Careers','events'=>'Events & Enquiries']],
   ['label'=>'Guest Communications','items'=>[
     'messages'=>'Guest Messages','testimonials'=>'Guest Experiences']],
   ['label'=>'Restaurant & Bar','items'=>[
     'bar'=>'Bar Dashboard','pos'=>'POS and Orders','fnb'=>'Food and Beverage']],
   ['label'=>'Kitchen','items'=>[
     'kitchen'=>'Kitchen']],
   ['label'=>'Housekeeping & Maintenance','items'=>[
     'shifts'=>'Shifts']],
   ['label'=>'Procurement & Stores','items'=>[
     'inventory'=>'Inventory','suppliers'=>'Suppliers','purchases'=>'Purchases']],
['label'=>'Finance & Control','items'=>[
      'invoices'=>'Invoices','expenses'=>'Expenses','finance'=>'Finance','approvals'=>'Approvals','reports'=>'Reports','audit'=>'Audit Trail']],
   ['label'=>'Administration','items'=>[
     'users'=>'Team and Users','notifications'=>'Notifications','trash'=>'Trash','profile'=>'My Profile']],
  ];
}

/** The icon a collapsible group header carries, read off its label so a new
 *  group needs no second place to register a picture for itself. */
function nav_group_icon(string $label): string{
  $map=['overview'=>'grid','reservation'=>'calendar','news'=>'event','restaurant'=>'fork',
    'kitchen'=>'pot','housekeep'=>'bed','procurement'=>'bag','finance'=>'coins','administration'=>'user',
    'guest comm'=>'globe'];
  $l=strtolower($label);
  foreach($map as $re=>$ico){ if(strpos($l,$re)!==false) return $ico; }
  return 'grid';
}

/** One 24px stroke icon per module. Kept in a single place so the rail,
 *  the header menu and the KPI cards all draw the same hand. */
function svg_icon(string $name): string{
 $p=[
  'grid'=>'<rect x="3" y="3" width="7" height="7" rx="1.5"/><rect x="14" y="3" width="7" height="7" rx="1.5"/><rect x="14" y="14" width="7" height="7" rx="1.5"/><rect x="3" y="14" width="7" height="7" rx="1.5"/>',
  'chart'=>'<path d="M21.2 15.9A10 10 0 1 1 8 2.8"/><path d="M22 12A10 10 0 0 0 12 2v10z"/>',
  'calendar'=>'<rect x="3" y="5" width="18" height="16" rx="2"/><path d="M16 3v4M8 3v4M3 11h18"/>',
  'event'=>'<rect x="3" y="4.5" width="18" height="16" rx="2"/><path d="M8 2.5v4M16 2.5v4M3 9.5h18"/><path d="M9.5 15l1.9 1.9 3.6-4"/>',
  'bed'=>'<path d="M2 19v-9a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v9"/><path d="M2 15h20"/><path d="M6 10V7a2 2 0 0 1 2-2h8a2 2 0 0 1 2 2v3"/>',
  'users'=>'<path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/>',
  'cart'=>'<circle cx="9" cy="20" r="1.6"/><circle cx="18" cy="20" r="1.6"/><path d="M2 3h3l2.4 11.2a2 2 0 0 0 2 1.6h8.5a2 2 0 0 0 2-1.55L21.5 7H6"/>',
  'fork'=>'<path d="M6 2v7a2.5 2.5 0 0 0 2.5 2.5h0V22"/><path d="M4 2v5M8.5 2v5"/><path d="M17 2c2.4 2.6 2.6 7.5.4 10.4V22"/>',
  'pot'=>'<path d="M4 10h16v6a4 4 0 0 1-4 4H8a4 4 0 0 1-4-4v-6z"/><path d="M2 10h20"/><path d="M9.5 6.5c0-1.4 1.2-1.4 1.2-3M14 6.5c0-1.4 1.2-1.4 1.2-3"/>',
  'clock'=>'<circle cx="12" cy="12" r="9"/><path d="M12 7v5.2l3.2 1.9"/>',
  'box'=>'<path d="M21 8.5l-9-5-9 5v7l9 5 9-5v-7z"/><path d="M3 8.5l9 5 9-5"/><path d="M12 13.5v9"/>',
  'truck'=>'<path d="M1.5 4.5h14v11h-14z"/><path d="M15.5 9h4l3 3.2v3.3h-7z"/><circle cx="5.5" cy="18" r="2.2"/><circle cx="18" cy="18" r="2.2"/>',
  'bag'=>'<path d="M6 2L3 6.2V21a1.8 1.8 0 0 0 1.8 1.8h14.4A1.8 1.8 0 0 0 21 21V6.2L18 2z"/><path d="M3 6.2h18"/><path d="M16 10a4 4 0 0 1-8 0"/>',
  'receipt'=>'<path d="M5.5 2.5h13v19l-3.2-2-2.1 2-2.2-2-2.1 2-3.4-2z"/><path d="M9 8h6M9 12h6M9 16h4"/>',
  'coins'=>'<ellipse cx="12" cy="6" rx="7.5" ry="3.2"/><path d="M4.5 6v5c0 1.8 3.4 3.2 7.5 3.2s7.5-1.4 7.5-3.2V6"/><path d="M4.5 11v5c0 1.8 3.4 3.2 7.5 3.2s7.5-1.4 7.5-3.2v-5"/>',
  'trend'=>'<polyline points="22 7 13.5 15.5 8.5 10.5 2 17"/><polyline points="16 7 22 7 22 13"/>',
  'check'=>'<path d="M21.8 11.1V12a9.8 9.8 0 1 1-5.8-8.9"/><polyline points="21.5 5 12 14.5 9.2 11.7"/>',
  'file'=>'<path d="M14 2.5H6.5a2 2 0 0 0-2 2v15a2 2 0 0 0 2 2h11a2 2 0 0 0 2-2V8z"/><polyline points="14 2.5 14 8 19.5 8"/><path d="M15.5 13.5h-7M15.5 17h-7"/>',
  'bars'=>'<path d="M6 20v-5M12 20V8M18 20v-9"/><path d="M3 20.5h18"/>',
  'user'=>'<path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/>',
  'globe'=>'<circle cx="12" cy="12" r="9"/><path d="M3 12h18"/><path d="M12 3a14.5 14.5 0 0 1 0 18 14.5 14.5 0 0 1 0-18z"/>',
  'logout'=>'<path d="M9.5 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4.5"/><polyline points="16 17 21 12 16 7"/><path d="M21 12H9"/>',
  'bell'=>'<path d="M18 8.5a6 6 0 1 0-12 0c0 6-2.5 7.5-2.5 7.5h17S18 14.5 18 8.5z"/><path d="M13.7 20a2 2 0 0 1-3.4 0"/>',
  'alert'=>'<path d="M12 3.5L2.5 20h19z"/><path d="M12 10v4.2M12 17.2v.1"/>',
  'wallet'=>'<path d="M20 7.5V6a2 2 0 0 0-2-2H5.5A2.5 2.5 0 0 0 3 6.5v11A2.5 2.5 0 0 0 5.5 20H19a2 2 0 0 0 2-2v-8.5a2 2 0 0 0-2-2H5"/><circle cx="16.5" cy="14" r="1.2"/>',
  'plate'=>'<circle cx="12" cy="12" r="9"/><circle cx="12" cy="12" r="4.5"/>',
  'spark'=>'<path d="M12 3l1.9 5.4L19.5 10l-5.6 1.7L12 17l-1.9-5.3L4.5 10l5.6-1.6z"/>',
  'chev'=>'<polyline points="6 9 12 15 18 9"/>',
  'sound'=>'<path d="M11 5 6.5 9H3v6h3.5L11 19z"/><path d="M15.5 8.6a4.7 4.7 0 0 1 0 6.8"/><path d="M18.4 6a8.4 8.4 0 0 1 0 12"/>',
  'mute'=>'<path d="M11 5 6.5 9H3v6h3.5L11 19z"/><path d="M16 9.5l4 5M20 9.5l-4 5"/>',
  'mic'=>'<rect x="9" y="2.5" width="6" height="11" rx="3"/><path d="M5.5 11a6.5 6.5 0 0 0 13 0"/><path d="M12 17.5V21"/><path d="M8.5 21h7"/>',
  'note'=>'<path d="M9 18V5l10-2v13"/><circle cx="6.5" cy="18" r="2.5"/><circle cx="16.5" cy="16" r="2.5"/>',
  'trash'=>'<path d="M3 6h18"/><path d="M8 6V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/><path d="M6 6l1 14a2 2 0 0 0 2 2h6a2 2 0 0 0 2-2l1-14"/><path d="M10 11v6M14 11v6"/>',
  'help'=>'<circle cx="12" cy="12" r="9"/><path d="M9.3 9.3a2.8 2.8 0 0 1 5.4.9c0 1.9-2.7 2.4-2.7 3.8"/><path d="M12 17.4v.1"/>',
  ];
 $d=$p[$name]??$p['grid'];
 return '<svg viewBox="0 0 24 24" aria-hidden="true">'.$d.'</svg>';
}

/** Which icon a KPI card asks for, read off the label it was given, so
 *  no module has to pass one. */
function kpi_icon(string $label): string{
 $map=[
  '/arrival|check.?in/i'=>'calendar','/depart|check.?out/i'=>'logout','/in house|occupan/i'=>'bed',
  '/room/i'=>'bed','/reservation|booking/i'=>'calendar','/guest|customer|member/i'=>'users',
  '/revenue|payment|amount|money|sales|collection|total/i'=>'coins','/price|rate|tariff/i'=>'trend',
  '/approval|pending|awaiting/i'=>'check','/stock|reorder|level/i'=>'box','/inventory|item/i'=>'box',
  '/order|pass|cook|meal|dish/i'=>'pot','/table|cover/i'=>'plate','/shift|hour|time/i'=>'clock',
  '/expense|cost|bill/i'=>'wallet','/purchase|requisition/i'=>'bag','/supplier|deliver/i'=>'truck',
  '/event|enquiry|function|wedding|conference/i'=>'event',
  '/audit|trail|log/i'=>'file','/report|chart|analy/i'=>'bars','/task|alert|issue|risk/i'=>'alert',
  '/balance|cash|profit|income/i'=>'trend','/team|user|staff/i'=>'users',
 ];
 foreach($map as $re=>$ico){ if(preg_match($re,$label)) return $ico; }
 return 'spark';
}

/** The two letters in the roundel beside a name: the initials off the
 *  record, never anything guessed from the email. */
function initials(?string $name): string{
 $w=preg_split('/\s+/',trim((string)$name))?:[];
 $s='';
 foreach($w as $x){ if($x!=='') $s.=mb_strtoupper(mb_substr($x,0,1)); if(mb_strlen($s)>=2) break; }
 return $s!==''?$s:'HP';
}

/**
 * A short, warm spoken welcome for the department that just signed in.
 *
 * The browser reads it aloud when the dashboard opens and it can be replayed
 * from the header at any moment. It only ever speaks the member's own name and
 * role, so it carries nothing private, and every word is optional: the header
 * control mutes it and the choice is remembered.
 */
function welcome_voice(): array{
 $u=current_user();
 $name=trim((string)($u['name']??''));
 $words=$name!==''?preg_split('/\s+/',$name):[];
 $first=($words&&$words[0]!=='')?$words[0]:'';
 $h=(int)date('G');
 $greet=$h<12?'Good morning':($h<17?'Good afternoon':'Good evening');
 $byRole=[
  'director'=>'Welcome back to Hotel Paradise on the Nile, {first}. The whole house is in your hands and everything is ready. Let us make today outstanding.',
  'general_manager'=>'{greet}, {first}. Welcome back to Hotel Paradise on the Nile. Your team is ready and the day is yours. Let us make it a great one.',
  'receptionist'=>'Welcome to the front desk, {first}. Our guests are in wonderful hands with you. Have a calm and pleasant shift.',
  'cashier'=>'Welcome back, {first}. The till is reconciled and ready for you. Wishing you a smooth and accurate shift.',
  'accountant'=>'Welcome back, {first}. The books are in order and waiting. Have a focused and peaceful day.',
  'waiter'=>'Welcome, {first}. The restaurant is set, the guests are smiling, and the service is yours. Let us give them something to remember.',
  'bar_staff'=>'Welcome, {first}. The bar is stocked and ready. Here is to a wonderful shift.',
  'kitchen'=>'Welcome to the kitchen, Chef {first}. The pass is ready and the brigade is with you. Let us cook something memorable today.',
  'housekeeping'=>'Welcome, {first}. Thank you for keeping Hotel Paradise immaculate and welcoming. Have a lovely shift.',
  'storekeeper'=>'Welcome, {first}. The stores are counted and organised. Have a productive day.',
  'procurement'=>'Welcome, {first}. Supplies are in good order and the day is yours. Have a great shift.',
  'maintenance'=>'Welcome, {first}. Thank you for keeping everything running smoothly. Have a safe and steady shift.',
  'auditor'=>'Welcome, {first}. The records are ready for your careful eye. Have a productive day.',
  'events_manager'=>'Welcome, {first}. Let us turn today\'s plans into experiences our guests will remember.',
  'marketing'=>'Welcome, {first}. Let us tell the story of Hotel Paradise beautifully today.',
  'human_resource'=>'Welcome, {first}. Our team is stronger with you here. Have a lovely day.',
  'super_admin'=>'Welcome back, {first}. Everything is running and the house is ready. Have an excellent day.',
 ];
 $text='';
 foreach(roles_of() as $role){ if(isset($byRole[$role])){ $text=$byRole[$role]; break; } }
 if($text==='') $text='{greet}, {first}. Welcome to Hotel Paradise on the Nile. It is a pleasure to have you on the team. Have a wonderful shift.';
 $text=str_replace(['{greet}','{first}'],
   [$greet,$first!==''?$first:'friend'],$text);
 return ['text'=>$text,'auto'=>true];
}

/**
 * The verified public facts the console assistant may speak aloud.
 *
 * These are the hotel's own published details. Nothing private is ever placed
 * here: no staff addresses, no passwords, no guest records. If a question is
 * not answered by a fact or a piece of guidance, the assistant says so plainly
 * rather than inventing anything.
 */
function assistant_facts(): array{
 return [
  'hotel'=>'Hotel Paradise on the Nile',
  'city'=>'Jinja',
  'country'=>'Uganda',
  'address'=>'Plot 12, 19 and 25 Kiira Lane, Jinja, Uganda',
  'phones'=>['+256 759 504 928','+256 773 565 668'],
  'email'=>'frontdesk@hotelparadiseonthenile.info',
  'website'=>'www.hotelparadiseonthenile.info',
  'established'=>'18 April 1998',
  'founders'=>['Mr. Otile Francis','Mrs. Magrate Otile'],
  'founded_rooms'=>'10',
  'developer'=>'Reagan Otema',
  'company'=>'Reagansoft Innovation Limited',
  'company_site'=>'https://reagansoftinnovation.com',
 ];
}

/**
 * The assistant's spoken answers, each matched by the words a person is likely
 * to use. The first entry whose keywords are found in the question wins, so the
 * list is ordered from the most specific to the most general.
 */
function assistant_knowledge(): array{
 return [
  ['k'=>['history','founded','establish','started','began','origin','1998','when was','how old'],'a'=>'Hotel Paradise on the Nile was established on the eighteenth of April, nineteen ninety eight, by Mr. Otile Francis and his wife, Mrs. Magrate Otile. They began with just ten rooms, and through their vision and hard work, and as the owner puts it, by God\'s grace, the hotel has grown into the riverside retreat it is today.'],
  ['k'=>['founder','owner','francis','magrate','proprietor','who started'],'a'=>'The hotel was founded by Mr. Otile Francis and his wife, Mrs. Magrate Otile. They are warmly respected for their vision and dedication, and their efforts are the reason Hotel Paradise on the Nile stands on the banks of the Nile today.'],
  ['k'=>['how many rooms did it start','started with','ten rooms','10 rooms','original rooms','first rooms'],'a'=>'The hotel opened with ten rooms in 1998. Over the years it has grown well beyond that beginning, and the current room inventory is listed in the Rooms module and on the public website.'],
  ['k'=>['who developed','who built','developer','programmer','reagansoft','reagan','otema','who made the system','who made the website'],'a'=>'The hotel\'s website and management system were developed by Reagan Otema, founder of Reagansoft Innovation Limited, Uganda, based in Jinja. You can find the company at reagansoftinnovation dot com.'],
  ['k'=>['where is','located','location','address','directions','kiira','how do i get'],'a'=>'Hotel Paradise on the Nile is in Jinja, Uganda, at Plot twelve, nineteen and twenty five, Kiira Lane. The front desk can give exact directions on plus two five six, seven five nine, five oh four, nine two eight.'],
  ['k'=>['contact','phone','telephone','call them','email','reach the hotel'],'a'=>'You can reach the hotel on plus two five six, seven five nine, five oh four, nine two eight, or plus two five six, seven seven three, five six five, six six eight. The front desk email is front desk, at hotel paradise on the nile dot info.'],
  ['k'=>['website','web address','online','url'],'a'=>'The public website is hotel paradise on the nile dot info. There is also an Open website link in the menu, under your profile on the rail.'],
  ['k'=>['book a room','make a booking','reserve','reservation','accommodation','how do i book'],'a'=>'To make a booking here, open Reservations, press New reservation, choose the dates and the room type, add the guest, and save. The public website can also take a booking, and it lands in this same Reservations module.'],
  ['k'=>['room type','deluxe','suite','standard room','room rate','price of a room','available rooms','rooms free'],'a'=>'Room types, their rates and how many are free are all in the Rooms module. Open Rooms to see each room and whether it is available, occupied, dirty or out of service.'],
  ['k'=>['food','menu','order food','restaurant','something to eat','drink','bar'],'a'=>'Food and drink are managed under Restaurant and Bar. The POS and Orders page takes an order and sends it to the kitchen, and Food and Beverage shows the bills. The public website menu writes into the same kitchen queue.'],
  ['k'=>['kitchen','cook','prepare the order','ticket','docket','food ready'],'a'=>'The Kitchen module shows the orders waiting to be cooked. Open Kitchen, read the docket, and mark each order preparing and then ready as it is finished.'],
  ['k'=>['payment','how do i pay','cash','mobile money','mtn','airtel','card','pesapal','gateway'],'a'=>'Payments are recorded in Finance and at the Cashier. A guest may pay by cash, mobile money, card or bank transfer. Online card and mobile money payments are handled by Pesapal, and a payment is only marked paid once Pesapal confirms it.'],
  ['k'=>['receipt','invoice','bill','statement','print a document'],'a'=>'A receipt or an invoice is printed from the record it belongs to. Open the order, the booking, or the Invoices page and press Print. A receipt is always built from a confirmed payment.'],
  ['k'=>['stock','inventory','store room','reorder','low stock'],'a'=>'Stock lives under Inventory. Record every movement there, an issue, a waste, a transfer or a count, and the system raises a low stock alert when an item falls to its reorder level.'],
  ['k'=>['supplier','purchase','procure','requisition','order goods'],'a'=>'Suppliers and purchasing are under Procurement and Stores. Raise a requisition in Purchases, take it through approval, then record the goods received so the stock rises.'],
  ['k'=>['housekeeping','clean a room','room dirty','task','shift'],'a'=>'Housekeeping work is in the Shifts module, where tasks and the cash up are recorded. On the Rooms page you can set a room to cleaning and then inspected once it is ready.'],
  ['k'=>['staff','team','employee','add a user','member of staff','role'],'a'=>'The team and their roles are managed under Team and Users. Add a member there and choose the role. Passwords are never shown to anyone, not even to me.'],
  ['k'=>['notification','alert','bell','unread'],'a'=>'The bell at the top of every page shows your own notifications: new bookings, orders, payments and messages. The Notifications page lists them all and lets you choose which kinds you want to hear about.'],
  ['k'=>['director','general manager','gm','overview','whole house'],'a'=>'As management you hold the widest view. The Director and General Manager dashboards show the whole house, and the Reports, Audit and Approvals pages give you the numbers and the control you need.'],
  ['k'=>['report','sales figures','revenue','occupancy','analytics'],'a'=>'Open Reports to see bookings, room nights, occupancy and sales for any date range, and to print the result.'],
  ['k'=>['check in a guest','check-in','checkin','guest arrived','an arrival'],'a'=>'To check a guest in, open Reservations, find the booking and press Check in. The system allocates a free room of the right type, marks the room occupied and opens the guest folio, so you can post charges and take payments from the same booking.'],
  ['k'=>['check out','checkout a guest','guest leaving','a departure','leaving the room'],'a'=>'To check a guest out, open their booking in Reservations and press Check out. Any balance is settled first, then the room is freed and set to dirty for housekeeping, and a receipt or statement can be printed.'],
  ['k'=>['void','reverse a payment','refund','cancel a payment','payment was wrong'],'a'=>'A payment is reversed in Finance: open the payment, press Reverse and give a reason. An order is cancelled from POS and Orders with a reason. Both are recorded in the Audit Trail.'],
  ['k'=>['invoice','bill a company','invoice number','issue an invoice'],'a'=>'Open Invoices, start a draft, save the customer details and add each line, then issue it. An issued invoice can take a payment, a discount or an adjustment, or be voided, and it can be printed or saved as a PDF from the same page.'],
  ['k'=>['requisition','purchase order','order goods','receive goods','deliveries'],'a'=>'Purchasing runs in order: raise a requisition in Purchases, send it for approval, and once it is approved create a purchase order from it. When the goods arrive, record them received on the order and the stock rises automatically in Inventory.'],
  ['k'=>['cash up','close shift','shift close','the till','variance','counted cash'],'a'=>'Close a shift in Shifts: enter the counted cash and the system compares it with what it expects, showing any variance. The closed shift then appears in Approvals for management to see.'],
  ['k'=>['approval','approve','reject','pending decision','waiting for approval'],'a'=>'The Approvals page gathers everything waiting on a decision: expense requests, stock requests, open shifts and large payments. Approve or reject each one there, and the record updates everywhere it appears.'],
  ['k'=>['audit','who changed','history of changes','the log','trace a change'],'a'=>'The Audit Trail records every change made in the console, with who made it, when, and what changed. Filter it by action, module or person to trace anything back.'],
  ['k'=>['restore','deleted','trash','bring back','removed a record'],'a'=>'Anything deleted goes to Trash rather than vanishing. Open Trash, find the record and press Restore to bring it back, or delete it permanently to remove it for good.'],
  ['k'=>['add a staff','add a user','new account','create a user','member of staff','suspend an account','reset a password'],'a'=>'Team accounts live under Team and Users. Add a member, give them a role and manage their access. You can suspend or reactivate an account and reset a password, but a password is never displayed to anyone, not even to me.'],
  ['k'=>['change my password','my password','update my details','my profile','my photo'],'a'=>'Open My Profile from your name at the top right to change your password, or to update your name, phone and photo.'],
  ['k'=>['push notification','phone alert','ring my phone','notifications on my'],'a'=>'Open Notifications to turn on push alerts for this device, send yourself a test, or choose which kinds of event you want to hear about. The bell at the top lists your own notifications at any time.'],
  ['k'=>['integrity scan','a finding','discrepancy','does not add up','suspect a record'],'a'=>'Integrity and Control runs a scan across the records to find anything that does not add up. Each finding can be reviewed, cleared with a reason or reopened, and the report can be printed, downloaded as a CSV or shared to WhatsApp.'],
  ['k'=>['publish a news','announce','newsroom','update the website','write an update'],'a'=>'The Newsroom lets you write a news item or an update and publish it to the public website, or keep it as a draft until you are ready.'],
  ['k'=>['export','download','csv','spreadsheet'],'a'=>'Where a page offers an export, it downloads a CSV you can open in a spreadsheet. The Integrity report has its own download, and reports can be printed from the Reports page.'],
  ['k'=>['website menu','repair the menu','menu not showing','fix the website menu'],'a'=>'If the website menu and this console ever drift apart, open Food and Beverage and use the repair action to re-sync the website menu from the console.'],
  ['k'=>['kpi','the figures','revenue today','how are we doing','today at a glance'],'a'=>'The Dashboard shows today at a glance: arrivals, who is in house, available rooms, departures, payments and anything awaiting approval. The CEO and Director overview adds yesterday, this month and this year.'],
  ['k'=>['who is signed in','which account','am i logged in','current user'],'a'=>'I can tell you only about your own session. Ask me who am I, and I will read back your name and role. Passwords and other people\'s details are never shared.'],
 ];
}

/** One plain sentence for the page the member is actually looking at, so the
 *  assistant can always say what to do next without guessing. */
function assistant_guides(): array{
 return [
  'dashboard'=>'You are on the Dashboard. It shows today\'s arrivals, who is in house, today\'s payments, what is awaiting approval and low stock. Use the rail on the left to open a module, or the bell at the top for notifications.',
  'reservations'=>'You are on Reservations. Press New reservation, choose the dates and the room type, add the guest and save. Open a booking to check the guest in, post a charge, take a payment, or print the confirmation.',
  'rooms'=>'You are on Rooms. Each room shows its state. Set a room to Cleaning and then Inspected, mark one Out of service for repairs, or open a room to allocate it to a booking.',
  'guests'=>'You are on Guests. This is the guest list. Add a guest with their name and telephone, or open a record to see their stays. Use the search box to find someone quickly.',
  'bar'=>'You are on the Bar Dashboard. It shows the bar orders waiting, what the bar has sold today, the bar list and your shift. Use Take a bar order to open the till at the bar, or Bar bills to take a payment.',
  'fnb'=>'You are on Food and Beverage. This shows the restaurant and bar bills. Open a bill to take a payment and print the receipt.',
  'kitchen'=>'You are on Kitchen. Read each docket, then mark the order Preparing and, when it is done, Ready, so the waiting staff are told.',
  'shifts'=>'You are on Shifts. Housekeeping tasks and the cash up are recorded here. Start a shift, then close it with the counted cash.',
  'inventory'=>'You are on Inventory. Add items, and record every movement: an issue, a waste, a transfer between stores, or a stock count. Low stock raises an alert on its own.',
  'suppliers'=>'You are on Suppliers. Keep the supplier list here, with their contacts and what they supply.',
  'purchases'=>'You are on Purchases. Raise a requisition, take it through approval, then record the goods received so the stock rises.',
  'invoices'=>'You are on Invoices. This is the billing desk. Create an invoice, add the lines, then print it or record a payment against it.',
  'expenses'=>'You are on Expenses. Record a cost, and it joins the approval queue for management to sign off.',
  'finance'=>'You are on Finance. Confirm or reverse payments here, and print the receipt from the record.',
  'approvals'=>'You are on Approvals. Everything waiting for a decision is listed here: expenses, requisitions, shifts and large payments.',
  'reports'=>'You are on Reports. Choose a date range from the top, then read or print the bookings, occupancy and sales figures.',
  'audit'=>'You are on the Audit Trail. Every change is listed here, with who made it and when.',
  'messages'=>'You are on Guest Messages. Answer what guests have sent to your desk, and mark each one resolved when it is done.',
  'news'=>'You are on the Newsroom. Write a news item or an update, then publish it to the website.',
  'users'=>'You are on Team and Users. Add a member, choose their role, and manage access here.',
  'events'=>'You are on Events and Enquiries. Record a function or a venue enquiry, then follow it through to a booking.',
  'notifications'=>'You are on Notifications. This lists everything that has happened to you, and the phones that hear about it.',
  'overview'=>'You are on the CEO and Director overview. It shows the whole house at a glance: today, yesterday, this month and this year, covering revenue, orders, rooms and arrivals, expenses and purchases, voids and unpaid bills. Open a customer to see their stays, orders and payments, and print a receipt or a guest statement from there.',
  'integrity'=>'You are on Integrity and Control. Run a scan to look for anything that does not add up, then mark each finding reviewed, clear it with a reason, or reopen it. You can print the report, download it as a CSV, or share it to WhatsApp.',
  'trash'=>'You are on Trash. Everything removed anywhere in the console lands here, with who removed it and when. Restore a record to bring it back, or delete it permanently, and only then is it truly gone.',
  'profile'=>'You are on My Profile. Update your name, phone and photo here, and change your password. Your role is set by the Administrator under Team and Users.',
 ];
}

/** The configuration the assistant script reads on the page. Nothing secret. */
function assistant_boot(string $active): void{
 $u=current_user();
 $cfg=[
  'name'=>(string)($u['name']??''),
  'role'=>(string)(roles_of()[0]??''),
  'roleLabel'=>role_label(roles_of()[0]??''),
  'page'=>$active,
  'facts'=>assistant_facts(),
  'knowledge'=>assistant_knowledge(),
  'guides'=>assistant_guides(),
 ];
 echo '<script>window.HP_ASSIST='.json_encode($cfg,JSON_UNESCAPED_UNICODE|JSON_UNESCAPED_SLASHES).';</script>';
}

function page_head(string $title,string $active='dashboard',string $sub=''): void{
 $u=current_user();
 $flash=flash_out();
 $me=$u['name']??'';
 $roleKey=roles_of()[0]??'';
 $role=role_label($roleKey);
 echo '<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1,viewport-fit=cover">';
 echo '<title>'.e($title).' | Hotel Paradise on the Nile</title>';
 echo '<link rel="preconnect" href="https://fonts.googleapis.com">';
 echo '<link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700&family=Playfair+Display:wght@500;600;700&display=swap" rel="stylesheet">';
 echo '<link rel="stylesheet" href="'.BASE.'/assets/admin.css">';
 echo '<link rel="icon" type="image/png" sizes="64x64" href="'.SITE_URL.'/images/logo-64.png">';
 echo '<link rel="apple-touch-icon" href="'.SITE_URL.'/images/logo-192.png">';
 echo '</head><body data-page="'.e($active).'" data-role="'.e($roleKey).'"><div class="app">';

 echo '<a class="skipLink" href="#mainContent">Skip to content</a>';
 echo '<div class="sideScrim" id="sideScrim" hidden></div>';

 /* ---- the rail ---- */
 echo '<aside class="side" id="side">';
 echo '<a class="sideBrand" href="'.BASE.'/index.php?page=dashboard"><img class="sideLogo" src="'.SITE_URL.'/images/paradise-logo.png" alt="Hotel Paradise on the Nile logo"><span class="sbText"><span>HOTEL PARADISE</span><small>ON THE NILE</small></span></a>';
 echo '<button class="sideClose" id="sideClose" type="button" aria-label="Close menu"><span></span><span></span></button>';
  echo '<nav class="sideNav" id="sideNav" aria-label="Modules">';
  foreach(nav_groups() as $group){
   /* Only the modules this member may open are offered, so a role never sees a
      door it cannot walk through. A group with nothing left in it disappears. */
   $vis=[];
   foreach($group['items'] as $page=>$label){ if(page_allowed($page)) $vis[$page]=$label; }
   if($vis===[]) continue;
   $hasActive=isset($vis[$active]);
   $gid='grp-'.preg_replace('/[^a-z0-9]+/i','-',strtolower($group['label']));
   echo '<div class="sideGroup'.($hasActive?' hasActive':' fold').'" data-gid="'.e($gid).'">';
   echo '<button class="groupHead" type="button" aria-expanded="'.($hasActive?'true':'false').'" aria-controls="'.e($gid).'">';
   echo '<span class="gIco">'.svg_icon(nav_group_icon($group['label'])).'</span>';
   echo '<span class="gLbl">'.e($group['label']).'</span>';
   echo '<span class="chev">'.svg_icon('chev').'</span>';
   echo '</button>';
   echo '<div class="groupBody" id="'.e($gid).'"><div class="gbInner">';
   foreach($vis as $page=>$label){
    $on=$page===$active;
    echo '<a href="'.BASE.'/index.php?page='.e($page).'"'.($on?' class="on" aria-current="page"':'').'>';
    echo '<span class="ico">'.svg_icon(nav_icon_key($page)).'</span><span class="lbl">'.e($label).'</span></a>';
   }
   echo '</div></div></div>';
  }
  echo '</nav>';
 echo '<div class="sideProfile"><a class="avatar" href="'.BASE.'/index.php?page=profile" aria-label="My profile">'.e(initials($me)).'</a>';
 echo '<span class="sideWho"><b>'.e($me).'</b><small>'.e($role).'</small></span>';
 echo '<a class="sideSignOut" href="'.BASE.'/index.php?page=logout" title="Sign out" aria-label="Sign out">'.svg_icon('logout').'</a></div>';
 echo '<div class="sideFoot">';
 echo '<label class="sideSize" for="sideSize" title="Menu width"><span class="ssIco" aria-hidden="true"><svg viewBox="0 0 24 24"><path d="M4 7h16M4 12h11M4 17h7"/></svg></span><input type="range" id="sideSize" min="196" max="340" step="4" value="250" aria-label="Menu width"><span class="ssWide" aria-hidden="true"><svg viewBox="0 0 24 24"><path d="M4 7h16M4 12h16M4 17h16"/></svg></span></label>';
 echo '<div class="sideFootRow"><a href="'.SITE_URL.'/" target="_blank" rel="noopener">Open website</a>';
 echo '<button class="sideShrink" id="sideShrink" type="button" aria-label="Collapse menu" title="Collapse menu"><svg viewBox="0 0 24 24" aria-hidden="true"><polyline points="13 6 19 12 13 18"/><path d="M5 5v14"/></svg></button>';
 echo '</div></div></aside>';

 /* ---- the header ---- */
 echo '<div class="main" id="mainContent"><div class="ambient" aria-hidden="true"></div><header class="top">';
 echo '<button class="sideToggle" id="sideToggle" type="button" aria-label="Open menu" aria-controls="side" aria-expanded="false"><span></span><span></span><span></span></button>';
 /* Every module but the dashboard carries a way back. It steps through the
    visit when a console page is behind it, and otherwise opens the dashboard,
    so nobody is left with no way out of a deep page. */
 if($active!=='dashboard'){
  echo '<a class="topBack" id="topBack" href="'.BASE.'/index.php?page=dashboard" aria-label="Back to dashboard"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M15 5l-7 7 7 7"/></svg><span>Back</span></a>';
 }
 echo '<div class="topTitles"><h1 class="pageTitle">'.e($title).'</h1>'.($sub?'<p class="pageSub">'.e($sub).'</p>':'').'</div>';
 echo '<div class="topRight">';
 /* The voice control: plays the department welcome, and silences it. It is on
    by default and speaks only on the dashboard, so a member hears a warm hello
    the moment they land and can mute it for good with one tap. */
 $voice=welcome_voice();
 echo '<button class="voiceBtn" id="voiceBtn" type="button" aria-pressed="true" aria-label="Welcome voice" title="Welcome voice" data-text="'.e($voice['text']).'" data-auto="'.($active==='dashboard'?'1':'0').'">';
 echo '<span class="vOn">'.svg_icon('sound').'</span><span class="vOff">'.svg_icon('mute').'</span>';
 echo '</button>';
 /* The ambient instruments: on a dashboard soft, calm music plays behind the
    page, and this button silences it or brings it back. It only ever appears
    where the music plays, so no one meets a control that does nothing. */
 if($active==='dashboard'){
  echo '<button class="musicBtn" id="musicBtn" type="button" aria-pressed="true" aria-label="Ambient music" title="Ambient music">';
  echo '<span class="mOn">'.svg_icon('note').'</span><span class="mOff">'.svg_icon('mute').'</span>';
  echo '</button>';
 }
 /* The assistant: press the microphone, speak a question, and Paradise answers
    from the hotel's verified public facts and this console's own guide. */
 echo '<button class="askBtn" id="askBtn" type="button" aria-pressed="false" aria-label="Ask the Paradise assistant" title="Ask the assistant">';
 echo svg_icon('mic').'<span class="abText">Ask</span></button>';
 /* The guide: a short, plain walk-through of how the console works, openable
    from anywhere and offered once on the dashboard so a new member is never
    left guessing where to press. */
 echo '<button class="guideBtn" id="guideBtn" type="button" aria-haspopup="dialog" aria-expanded="false" aria-controls="guideWrap" aria-label="How to use this console" title="How to use this console" data-auto="'.($active==='dashboard'?'1':'0').'">'.svg_icon('help').'<span class="gbText">Guide</span></button>';
 /* The bell is the same feed as the notifications page: a member sees their
    own events, never anyone else's. It is drawn only when the tables exist. */
 if(notify_ready()){
  $nUnread=notify_unread((int)($u['id']??0));
  $nItems=notify_list((int)($u['id']??0),6);
  echo '<div class="notifyWrap">';
  echo '<button class="notifyBtn" id="notifyBtn" type="button" aria-haspopup="true" aria-expanded="false" aria-controls="notifyMenu" aria-label="Notifications'.($nUnread?' ('.$nUnread.' unread)':'').'">';
  echo svg_icon('bell');
  echo '<span class="notifyBadge" id="notifyBadge"'.($nUnread?'':' hidden').'>'.($nUnread>99?'99+':(int)$nUnread).'</span>';
  echo '</button>';
  echo '<div class="notifyMenu" id="notifyMenu" hidden>';
  echo '<div class="menuHead"><b>Notifications</b><small>'.($nUnread?$nUnread.' unread':'You are up to date').'</small></div>';
  echo '<div class="notifyFeed" id="notifyFeed">';
  if($nItems===[]){ echo '<p class="notifyEmpty">Nothing yet. Bookings, orders and payments will appear here.</p>'; }
  else{
   foreach($nItems as $n){
    $un=$n['read_at']===null?' unread':'';
    echo '<a class="notifyItem'.$un.'" href="'.BASE.'/index.php?page=notifications" data-id="'.(int)$n['id'].'">';
    echo '<span class="nIco">'.svg_icon($n['type']==='payment'?'coins':($n['type']==='order'?'pot':($n['type']==='booking'?'calendar':'bell'))).'</span>';
    echo '<span class="nTxt"><b>'.e($n['title']).'</b><small>'.e($n['body']).'</small><time>'.e(fmtdt($n['created_at'])).'</time></span>';
    echo '</a>';
   }
  }
  echo '</div>';
  echo '<a class="notifyAll" href="'.BASE.'/index.php?page=notifications">View all notifications</a>';
  echo '</div></div>';
 }
 echo '<button class="profBtn" id="profBtn" type="button" aria-haspopup="true" aria-expanded="false" aria-controls="profMenu">';
 echo '<span class="avatar">'.e(initials($me)).'</span>';
 echo '<span class="whoWrap"><span class="who">'.e($me).'</span><span class="whoRole">'.e($role).'</span></span>';
 echo '<svg class="chev" viewBox="0 0 24 24" aria-hidden="true"><polyline points="6 9 12 15 18 9"/></svg>';
 echo '</button>';
 echo '<div class="profMenu" id="profMenu" hidden>';
 echo '<div class="menuHead"><b>'.e($me).'</b><small>'.e($role).' &middot; '.e($u['email']??'').'</small></div>';
 echo '<a href="'.BASE.'/index.php?page=profile">'.svg_icon('user').'My profile</a>';
 echo '<a href="'.SITE_URL.'/" target="_blank" rel="noopener">'.svg_icon('globe').'Open website</a>';
 echo '<a class="danger" href="'.BASE.'/index.php?page=logout">'.svg_icon('logout').'Sign out</a>';
 echo '</div></div></header>';

 /* ---- the guide: where to press, step by step ---- */
 echo '<div class="guideWrap" id="guideWrap" hidden>';
 echo '<div class="guideCard" role="dialog" aria-modal="true" aria-labelledby="guideTitle">';
 echo '<button class="guideX" id="guideX" type="button" aria-label="Close guide">&times;</button>';
 echo '<h2 id="guideTitle">How to use this console</h2>';
 echo '<p class="guideIntro">Everything is a tap away. Here is the way around, on a computer or a phone.</p>';
 echo '<ol class="guideSteps">';
 echo '<li><b>1</b><span>Pick a module from the menu on the left. On a phone, tap the <em>Menu</em> button at the top to slide it in.</span></li>';
 echo '<li><b>2</b><span>Each heading is a group that folds. Tap a heading — like <em>Finance &amp; Control</em> — to open or close the modules under it.</span></li>';
 echo '<li><b>3</b><span>On a phone, drag the <em>width slider</em> at the foot of the menu to make the menu narrower or wider for your hand.</span></li>';
 echo '<li><b>4</b><span>The bell at the top shows new bookings, orders, payments and messages. <em>Back</em> at the top left returns you to the page you came from.</span></li>';
 echo '<li><b>5</b><span>Every page does its work with the buttons along the top of it — add, filter, print or export — and every wide table scrolls sideways on a small screen.</span></li>';
 echo '</ol>';
 echo '<button class="btn guideDone" id="guideDone" type="button">Got it</button>';
 echo '</div></div>';

 /* ---- the assistant: what it heard, and what it answered ---- */
 echo '<div class="assistPanel" id="assistPanel" hidden>';
 echo '<div class="assistCard" role="dialog" aria-modal="false" aria-live="polite" aria-label="Paradise assistant">';
 echo '<button class="assistX" id="assistX" type="button" aria-label="Close assistant">&times;</button>';
 echo '<div class="assistHead"><span class="assistIco">'.svg_icon('spark').'</span><b>Paradise Assistant</b><span class="assistState" id="assistState">Ready</span></div>';
 echo '<div class="assistText" id="assistText">Ask me about the hotel or about how to use this console.</div>';
 echo '<div class="assistActions">';
 echo '<button class="btn sm" id="assistAsk" type="button">'.svg_icon('mic').'<span>Ask a question</span></button>';
 echo '<button class="btnGhost sm" id="assistStop" type="button">Stop voice</button>';
 echo '</div></div></div>';

 /* ---- what the last action left behind, as a notification ---- */
 if($flash){
  $ico=$flash['type']==='bad'?'!':($flash['type']==='warn'?'!':'✓');
  echo '<div class="toastWrap" id="toasts"><div class="toast '.e($flash['type']).'" role="status"><span class="noteIco">'.$ico.'</span><span>'.e($flash['msg']).'</span><button type="button" aria-label="Dismiss">&times;</button></div></div>';
 }
 assistant_boot($active);
 echo '<div class="content">';
}

/** The icon a module carries in the rail. */
function nav_icon_key(string $page): string{
$map=['dashboard'=>'grid','overview'=>'chart','integrity'=>'alert','reservations'=>'calendar','rooms'=>'bed','guests'=>'users','events'=>'event',
   'bar'=>'fork','pos'=>'cart','fnb'=>'fork','kitchen'=>'pot','shifts'=>'clock','inventory'=>'box','suppliers'=>'truck',
   'purchases'=>'bag','expenses'=>'receipt','finance'=>'coins','approvals'=>'check','audit'=>'file',
   'reports'=>'bars','users'=>'users','notifications'=>'bell','trash'=>'trash','profile'=>'user',
   'invoices'=>'file',
   'messages'=>'bell','testimonials'=>'spark'];
 return $map[$page]??'grid';
}

/**
 * One small script for the whole console. It gives the rail a drawer on a
 * narrow screen, the header a member menu, the rail a remembered collapsed
 * state, dismissible notifications, and wraps every data table in a scroll
 * box so a wide report never pushes the page sideways on a phone.
 */
function page_scripts(): void{
 echo <<<'HTML'
<script>
(function(){
  var side=document.getElementById('side'),scrim=document.getElementById('sideScrim'),
      open=document.getElementById('sideToggle'),close=document.getElementById('sideClose');
  function set(on){
    if(!side)return;
    side.classList.toggle('open',on);
    document.body.classList.toggle('navOpen',on);
    if(open)open.setAttribute('aria-expanded',on?'true':'false');
    if(scrim)scrim.hidden=!on;
  }
  if(open)open.addEventListener('click',function(){set(!side.classList.contains('open'))});
  if(close)close.addEventListener('click',function(){set(false)});
  if(scrim)scrim.addEventListener('click',function(){set(false)});
  document.addEventListener('keydown',function(e){if(e.key==='Escape')set(false)});
  var wide=window.matchMedia('(min-width:1081px)');
  var onWide=function(e){if(e.matches)set(false)};
  if(wide.addEventListener)wide.addEventListener('change',onWide);else if(wide.addListener)wide.addListener(onWide);

  /* the member menu in the header */
  var pb=document.getElementById('profBtn'),pm=document.getElementById('profMenu');
  if(pb&&pm){
    var setProf=function(on){pb.setAttribute('aria-expanded',on?'true':'false');pm.hidden=!on;};
    pb.addEventListener('click',function(e){e.stopPropagation();setProf(pm.hidden)});
    document.addEventListener('click',function(e){if(!pm.hidden&&!pm.contains(e.target))setProf(false)});
    document.addEventListener('keydown',function(e){if(e.key==='Escape')setProf(false)});
  }

  /* the bell: the same feed the notifications page shows, refreshed quietly.
     It never blocks the page and gives up silently if the network is gone. */
  var nb=document.getElementById('notifyBtn'),nm=document.getElementById('notifyMenu');
  if(nb&&nm){
    var badge=document.getElementById('notifyBadge'),feed=document.getElementById('notifyFeed');
    var esc=function(s){return String(s==null?'':s).replace(/[&<>"]/g,function(c){return {'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[c]})};
    var setB=function(on){nb.setAttribute('aria-expanded',on?'true':'false');nm.hidden=!on};
    var paint=function(d){
      if(!d||!d.ok)return;
      if(badge){badge.textContent=d.unread>99?'99+':d.unread;badge.hidden=d.unread<=0}
      if(feed&&d.items){
        feed.innerHTML=d.items.map(function(n){
          return '<a class="notifyItem'+(n.read?'':' unread')+'" href="index.php?page=notifications" data-id="'+n.id+'">'
            +'<span class="nTxt"><b>'+esc(n.title)+'</b><small>'+esc(n.body)+'</small><time>'+esc(n.when)+'</time></span></a>';
        }).join('')||'<p class="notifyEmpty">Nothing yet. Bookings, orders and payments will appear here.</p>';
      }
    };
    var load=function(){fetch('notify_api.php?act=feed',{credentials:'same-origin'}).then(function(r){return r.json()}).then(paint).catch(function(){})};
    nb.addEventListener('click',function(e){e.stopPropagation();var on=nm.hidden;setB(on);if(on)load()});
    document.addEventListener('click',function(e){if(!nm.hidden&&!nm.contains(e.target)&&!nb.contains(e.target))setB(false)});
    document.addEventListener('keydown',function(e){if(e.key==='Escape')setB(false)});
    load();
    setInterval(function(){if(!document.hidden)load()},60000);
  }

  /* the rail remembers whether it was left collapsed */
  var sc=document.getElementById('sideShrink');
  if(sc){
    var apply=function(on){
      document.body.classList.toggle('sideCollapsed',on);
      sc.setAttribute('aria-label',on?'Expand menu':'Collapse menu');
      sc.setAttribute('title',on?'Expand menu':'Collapse menu');
    };
    try{if(localStorage.getItem('hpn_side')==='1')apply(true)}catch(e){}
    sc.addEventListener('click',function(){
      var on=!document.body.classList.contains('sideCollapsed');
      apply(on);
      try{localStorage.setItem('hpn_side',on?'1':'0')}catch(e){}
    });
  }

  /* the menu width slider: drag it to make the rail narrower or wider. The
     choice is remembered, and it is what makes the modules comfortable to
     reach on a phone as well as on a wide screen. */
  var ss=document.getElementById('sideSize');
  if(ss){
    var setW=function(px){
      px=Math.max(196,Math.min(340,parseInt(px,10)||250));
      document.documentElement.style.setProperty('--side',px+'px');
      return px;
    };
    var saved=null;try{saved=parseInt(localStorage.getItem('hpn_side_w')||'',10)}catch(e){}
    if(saved&&saved>=196&&saved<=340){ss.value=String(saved);setW(saved)}
    ss.addEventListener('input',function(){setW(ss.value)});
    ss.addEventListener('change',function(){try{localStorage.setItem('hpn_side_w',String(setW(ss.value)))}catch(e){}});
  }

  /* the guide: opened from the header at any time, and shown once on the
     dashboard so a new member meets the way around before they need it. */
  var gb=document.getElementById('guideBtn'),gw=document.getElementById('guideWrap');
  if(gb&&gw){
    var setG=function(on){
      gw.hidden=!on;
      gb.setAttribute('aria-expanded',on?'true':'false');
      document.body.classList.toggle('guideOpen',on);
    };
    var closeG=function(){setG(false)};
    gb.addEventListener('click',function(){setG(gw.hidden)});
    var gx=document.getElementById('guideX'),gd=document.getElementById('guideDone');
    if(gx)gx.addEventListener('click',closeG);
    if(gd)gd.addEventListener('click',closeG);
    gw.addEventListener('click',function(e){if(e.target===gw)closeG()});
    document.addEventListener('keydown',function(e){if(e.key==='Escape'&&!gw.hidden)closeG()});
    if(gb.getAttribute('data-auto')==='1'){
      var seen=false;try{seen=localStorage.getItem('hpn_guide')==='1'}catch(e){}
      if(!seen){setTimeout(function(){setG(true)},600)}
      try{localStorage.setItem('hpn_guide','1')}catch(e){}
    }
  }

   /* notifications: any "ok" note leaves on its own, a warning or an error
      stays until it is read and dismissed */
   var dismiss=function(t){
     if(!t||t.dataset.gone)return;
     t.dataset.gone='1';
     t.classList.add('toastOut');
     setTimeout(function(){if(t.parentNode)t.parentNode.removeChild(t)},300);
   };
   Array.prototype.forEach.call(document.querySelectorAll('#toasts .toast'),function(t){
     var x=t.querySelector('button');
     if(x)x.addEventListener('click',function(){dismiss(t)});
     if(!t.classList.contains('bad')&&!t.classList.contains('warn')){
       setTimeout(function(){dismiss(t)},6000);
     }
   });

   /* lightweight submit loading state - adds .loading to the submitting button */
   document.addEventListener('submit', function(e){
     var frm=e.target;
     if(!frm) return;
     var btn=frm.querySelector('button[type=submit],input[type=submit]');
     if(btn && !btn.disabled){
       btn.classList.add('loading');
       btn.setAttribute('aria-busy','true');
       setTimeout(function(){
         if(btn.parentNode){
           btn.classList.remove('loading');
           btn.removeAttribute('aria-busy');
         }
       }, 8000);
     }
   }, true);

  document.querySelectorAll('table.tbl').forEach(function(t){
    if(t.parentNode&&t.parentNode.classList.contains('tableScroll'))return;
    var w=document.createElement('div');w.className='tableScroll';
    t.parentNode.insertBefore(w,t);w.appendChild(t);
  });

  /* the way back to the top, for the long tables and reports. It waits until
     the page has moved, then jumps or slides according to the guest's own
     motion setting. */
  var tt=document.getElementById('toTop');
  if(tt){
    var tick=function(){tt.classList.toggle('on',window.scrollY>600)};
    tick();
    window.addEventListener('scroll',tick,{passive:true});
    tt.addEventListener('click',function(){
      var reduce=false;
      try{reduce=window.matchMedia('(prefers-reduced-motion: reduce)').matches}catch(e){}
      window.scrollTo({top:0,behavior:reduce?'auto':'smooth'});
    });
  }

  /* the way out of a module: back through the visit when one of ours is
     behind it, else the dashboard the link already points at. */
  var tb=document.getElementById('topBack');
  if(tb){
    tb.addEventListener('click',function(e){
      var ours=false;
      try{
        var r=document.referrer?new URL(document.referrer):null;
        ours=!!r&&r.origin===location.origin&&r.pathname!==location.pathname;
      }catch(err){ours=false}
      if(ours&&history.length>1){e.preventDefault();history.back();}
    });
  }

  /* the rail groups fold away, remember their state, and open the group that
     holds the page in view. On the collapsed rail they stay open so the icons
     are never hidden behind a closed lid. */
  var grp=document.querySelectorAll('.sideGroup');
  if(grp.length){
    var KEY='hpn_navgroups',stored={};
    try{stored=JSON.parse(localStorage.getItem(KEY)||'{}')||{}}catch(e){stored={}}
    var save=function(){
      try{localStorage.setItem(KEY,JSON.stringify(stored))}catch(e){}
    };
    grp.forEach(function(g){
      var head=g.querySelector('.groupHead'),body=g.querySelector('.groupBody');
      if(!head||!body)return;
      var id=g.getAttribute('data-gid');
      /* A group opens only when it holds the page in view, or when the member
         opened it before. Everything else stays folded until it is clicked. */
      var open=g.classList.contains('hasActive')||stored[id]===true;
      var apply=function(on,quiet){
        g.classList.toggle('fold',!on);
        head.setAttribute('aria-expanded',on?'true':'false');
        if(!quiet&&!g.classList.contains('hasActive')){stored[id]=on;save()}
      };
      apply(open,true);
      head.addEventListener('click',function(){apply(g.classList.contains('fold'),false)});
    });
  }

  /* the welcome voice: a warm hello for the department, spoken once on the
     dashboard and replayable from the header. It never blocks the page and
     stays silent when the browser has no voice or the member muted it. */
  var vb=document.getElementById('voiceBtn');
  if(vb){
    var synth=window.speechSynthesis,KEYV='hpn_voice';
    var wanted=function(){try{return localStorage.getItem(KEYV)!=='0'}catch(e){return true}};
    var paint=function(){var on=wanted();vb.classList.toggle('off',!on);vb.setAttribute('aria-pressed',on?'true':'false')};
    var speak=function(){
      if(!synth||!wanted())return;
      try{
        synth.cancel();
        var u=new SpeechSynthesisUtterance(vb.getAttribute('data-text')||'');
        u.rate=0.98;u.pitch=1.0;u.volume=1;
        var v=null,vs=synth.getVoices()||[];
        for(var i=0;i<vs.length;i++){if(/^en[-_]?/i.test(vs[i].lang||'')&&/female|samantha|zira|hazel|serena|aria|libby|sonia/i.test(vs[i].name)){v=vs[i];break}}
        if(!v){for(var j=0;j<vs.length;j++){if(/^en[-_]?/i.test(vs[j].lang||'')){v=vs[j];break}}}
        if(v)u.voice=v;
        vb.classList.add('speaking');
        u.onend=u.onerror=function(){vb.classList.remove('speaking')};
        synth.speak(u);
      }catch(e){vb.classList.remove('speaking')}
    };
    paint();
    vb.addEventListener('click',function(){
      var on=!wanted();
      try{localStorage.setItem(KEYV,on?'1':'0')}catch(e){}
      paint();
      if(on){speak()}else if(synth){try{synth.cancel()}catch(e){}}
    });
    /* speak the welcome on the dashboard, once the voices are ready. A first
       interaction is used as a fallback for browsers that block auto-speech. */
    if(vb.getAttribute('data-auto')==='1'&&wanted()){
      var armed=true,go=function(){
        if(!armed)return;armed=false;
        speak();
        document.removeEventListener('pointerdown',go);
        document.removeEventListener('keydown',go);
      };
      if(synth){
        if(synth.getVoices&&synth.getVoices().length){setTimeout(go,650)}
        else if(synth.onvoiceschanged){synth.onvoiceschanged=function(){setTimeout(go,300)};setTimeout(go,1400)}
        else{setTimeout(go,650)}
      }
      document.addEventListener('pointerdown',go);
      document.addEventListener('keydown',go);
    }
  }
})();</script>
HTML;
}

/**
 * The Paradise assistant: soft, calm instruments behind a dashboard, a warm
 * spoken welcome, and a microphone that listens to a question and answers from
 * the hotel's verified facts and this console's own guide.
 *
 * The instruments are synthesised in the browser with the Web Audio API, so
 * there are no sound files to load and nothing leaves the device. Several
 * timbres rotate as the page sits, and the Director's console uses the calmest
 * African xylophone voices at a slower pace.
 *
 * The music is silenced the instant the assistant speaks or listens, and comes
 * gently back afterwards, so the two never talk over each other. Nothing here
 * is automatic except the welcome on the dashboard: after that the assistant
 * only ever speaks when it is asked.
 */
function assistant_scripts(): void{
 echo <<<'HTML'
<script>
(function(){
  var A=window.HP_ASSIST||{};
  var page=document.body.getAttribute('data-page')||'dashboard';
  var isDash=page==='dashboard';
  var role=A.role||'';
  var calm=(role==='director'||role==='super_admin');
  var synth=('speechSynthesis' in window)?window.speechSynthesis:null;
  var speaking=false,listening=false,ducked=false;
  var AC=null,master=null,duckG=null,verb=null,musicOn=true,musicTimer=null,bankTimer=null,bankIx=0;
  var panel=document.getElementById('assistPanel');
  var ptext=document.getElementById('assistText');
  var pstate=document.getElementById('assistState');

  function firstName(n){var w=String(n==null?'':n).trim().split(/\s+/);return w[0]||'';}
  function phon(s){return String(s==null?'':s).replace(/Otile/gi,'Oh-till-eh');}
  function setState(s){if(pstate)pstate.textContent=s;}
  function pickVoice(){
    if(!synth)return null;
    var vs=synth.getVoices()||[],v=null,i;
    for(i=0;i<vs.length;i++){if(/^en[-_]?/i.test(vs[i].lang||'')&&/samantha|aria|libby|jenny|michelle|zira|hazel|serena|female|google us english/i.test(vs[i].name)){v=vs[i];break;}}
    if(!v){for(i=0;i<vs.length;i++){if(/^en[-_]?us/i.test(vs[i].lang||'')){v=vs[i];break;}}}
    if(!v){for(i=0;i<vs.length;i++){if(/^en[-_]?/i.test(vs[i].lang||'')){v=vs[i];break;}}}
    return v;
  }
  function duck(on){
    ducked=on;
    if(!duckG||!AC)return;
    var t=AC.currentTime;
    try{duckG.gain.cancelScheduledValues(t);duckG.gain.setValueAtTime(duckG.gain.value,t);duckG.gain.linearRampToValueAtTime(on?0.0001:1,t+(on?0.25:1.1));}catch(e){}
  }
  function speak(text,opts){
    opts=opts||{};
    if(!synth||!text){if(opts.after)opts.after();return;}
    try{
      synth.cancel();
      speaking=true;duck(true);setState('Speaking');
      var u=new SpeechSynthesisUtterance(phon(text));
      u.rate=calm?0.9:0.97;u.pitch=calm?0.97:1.02;u.volume=1;u.lang='en-US';
      var v=pickVoice();if(v){u.voice=v;u.lang=v.lang||'en-US';}
      u.onend=u.onerror=function(){speaking=false;duck(listening);setState(listening?'Listening':'Ready');if(opts.after)opts.after();};
      synth.speak(u);
    }catch(e){speaking=false;duck(false);if(opts.after)opts.after();}
  }
  /* Whatever way a browser reports speech or listening, the music is always
     silenced while the assistant is talking and always returns afterwards. */
  setInterval(function(){
    if(!synth)return;
    var talk=synth.speaking||speaking;
    if(talk&&!ducked)duck(true);
    else if(!talk&&!listening&&ducked)duck(false);
  },350);

  /* ---------- ambient instruments (synthesised, no files) ---------- */
  function impulse(dur,decay){
    var rate=AC.sampleRate,len=Math.max(1,Math.floor(rate*dur)),buf=AC.createBuffer(2,len,rate);
    for(var c=0;c<2;c++){var d=buf.getChannelData(c);for(var i=0;i<len;i++){d[i]=(Math.random()*2-1)*Math.pow(1-i/len,decay);}}
    return buf;
  }
  function ensureCtx(){
    if(AC)return AC;
    var C=window.AudioContext||window.webkitAudioContext;if(!C)return null;
    AC=new C();
    master=AC.createGain();master.gain.value=0.0001;master.connect(AC.destination);
    duckG=AC.createGain();duckG.gain.value=1;duckG.connect(master);
    try{verb=AC.createConvolver();verb.buffer=impulse(calm?3.4:2.4,calm?2.6:2.2);var wet=AC.createGain();wet.gain.value=calm?0.42:0.34;verb.connect(wet);wet.connect(master);}catch(e){verb=null;}
    return AC;
  }
  function note(freq,when,dur,type,gain,harm){
    if(!AC)return;
    try{
      var o=AC.createOscillator();o.type=type||'sine';o.frequency.value=freq;
      var g=AC.createGain();g.gain.setValueAtTime(0.0001,when);
      g.gain.exponentialRampToValueAtTime(Math.max(0.0002,gain),when+0.012);
      g.gain.exponentialRampToValueAtTime(0.0001,when+dur);
      o.connect(g);g.connect(duckG);if(verb)g.connect(verb);o.start(when);o.stop(when+dur+0.12);
      if(harm){
        var h=AC.createOscillator();h.type='sine';h.frequency.value=freq*2.01;
        var hg=AC.createGain();hg.gain.setValueAtTime(0.0001,when);
        hg.gain.exponentialRampToValueAtTime(Math.max(0.0002,gain*harm),when+0.01);
        hg.gain.exponentialRampToValueAtTime(0.0001,when+dur*0.6);
        h.connect(hg);hg.connect(duckG);if(verb)hg.connect(verb);h.start(when);h.stop(when+dur);
      }
    }catch(e){}
  }
  var BANKS=[
    {name:'Kalimba',type:'sine',harm:0.22,decay:2.8},
    {name:'Marimba',type:'triangle',harm:0.32,decay:1.7},
    {name:'Glass',type:'sine',harm:0.12,decay:3.4},
    {name:'Flute',type:'sine',harm:0.06,decay:2.4},
    {name:'Ngoma',type:'triangle',harm:0.18,decay:1.2}
  ];
  var CALM_BANKS=[0,2,4];
  var SCALE=[261.63,293.66,329.63,392.00,440.00,523.25,587.33,659.25,783.99];
  var CALM_SCALE=[196.00,220.00,261.63,293.66,329.63,392.00,440.00];
  function pickNote(low){
    var sc=calm?CALM_SCALE:SCALE;
    if(low)return sc[Math.floor(Math.random()*Math.min(4,sc.length))];
    return sc[Math.floor(Math.random()*sc.length)];
  }
  function tick(){
    if(!AC||!musicOn||document.hidden)return;
    var b=BANKS[calm?CALM_BANKS[bankIx%CALM_BANKS.length]:bankIx%BANKS.length];
    var t=AC.currentTime+0.06;
    if(Math.random()<(calm?0.55:0.4))note(pickNote(true),t,b.decay*1.6,b.type,calm?0.07:0.06,b.harm*0.5);
    var n=1+(Math.random()<(calm?0.25:0.45)?1:0);
    for(var i=0;i<n;i++)note(pickNote(false),t+i*(0.32+Math.random()*0.4),b.decay*(0.8+Math.random()*0.4),b.type,calm?0.05:0.055,b.harm);
  }
  function musicState(on){
    musicOn=on;try{localStorage.setItem('hpn_music',on?'1':'0')}catch(e){}
    var mb=document.getElementById('musicBtn');
    if(mb){mb.classList.toggle('off',!on);mb.setAttribute('aria-pressed',on?'true':'false');}
  }
  function startMusic(){
    if(!isDash)return;
    var ctx=ensureCtx();if(!ctx)return;
    if(ctx.state==='suspended'){try{ctx.resume()}catch(e){}}
    if(musicTimer)clearInterval(musicTimer);
    musicTimer=setInterval(tick,calm?2300:1500);
    if(bankTimer)clearInterval(bankTimer);
    bankTimer=setInterval(function(){bankIx=(bankIx+1)%BANKS.length;},26000);
    var t=ctx.currentTime;
    try{master.gain.cancelScheduledValues(t);master.gain.setValueAtTime(master.gain.value,t);master.gain.linearRampToValueAtTime(calm?0.9:1,t+4);}catch(e){}
    tick();
  }
  function stopMusic(){
    if(musicTimer){clearInterval(musicTimer);musicTimer=null;}
    if(bankTimer){clearInterval(bankTimer);bankTimer=null;}
    if(master&&AC){var t=AC.currentTime;try{master.gain.cancelScheduledValues(t);master.gain.setValueAtTime(master.gain.value,t);master.gain.linearRampToValueAtTime(0.0001,t+1.2);}catch(e){}}
  }

  var mb=document.getElementById('musicBtn');
  if(mb){
    try{if(localStorage.getItem('hpn_music')==='0')musicOn=false;}catch(e){}
    mb.classList.toggle('off',!musicOn);mb.setAttribute('aria-pressed',musicOn?'true':'false');
    mb.addEventListener('click',function(){musicState(!musicOn);if(musicOn)startMusic();else stopMusic();});
  }
  /* Start the instruments on the first real interaction (browsers will not
     allow sound before one), and keep trying quietly until they do. */
  if(isDash&&musicOn){
    var begin=function(){if(!musicTimer)startMusic();};
    document.addEventListener('pointerdown',begin);
    document.addEventListener('keydown',begin);
    setTimeout(function(){var c=ensureCtx();if(c&&c.state==='running')begin();},1400);
  }

  /* ---------- the assistant: listen, then answer ---------- */
  function showPanel(text){
    if(panel)panel.hidden=false;
    if(ptext)ptext.textContent=text;
  }
  function guide(){
    return (A.guides||{})[page]||'Use the rail on the left to open a module. Each heading is a group that folds open, and every page does its work with the buttons along the top.';
  }
  function score(q,ks){var s=0;for(var i=0;i<ks.length;i++){if(q.indexOf(ks[i])>=0)s+=ks[i].length+3;}return s;}
  function answer(q){
    var t=' '+String(q||'').toLowerCase().replace(/[^a-z0-9 ]+/g,' ').replace(/\s+/g,' ')+' ';
    if(/(^| )(hi|hello|hey)( |$)/.test(t)||/good (morning|afternoon|evening)/.test(t))
      return 'Hello'+(A.name?', '+firstName(A.name):'')+'. I am here whenever you need me. Ask me about the hotel, or about how to use this console.';
    if(/thank|thanks|appreciate/.test(t))return 'You are very welcome. It is a pleasure to help.';
    if(/who am i|my role|my name|signed in as/.test(t))return 'You are signed in as '+(A.name?A.name+', ':'')+(A.roleLabel||'a member of staff')+'.';
    var gw=['how do i','how can i','what do i do','where am i','what next','what should i','guide me','show me how','how to use','i am stuck','im stuck','help me with'];
    for(var i=0;i<gw.length;i++){if(t.indexOf(gw[i])>=0)return guide();}
    var best=null,bs=0,list=A.knowledge||[];
    for(var j=0;j<list.length;j++){var s=score(t,list[j].k||[]);if(s>bs){bs=s;best=list[j];}}
    if(best&&bs>=4)return best.a;
    if(t.indexOf('help')>=0||t.indexOf('what can you')>=0||t.indexOf('who are you')>=0)
      return 'I am the Paradise assistant. I can help with the hotel\'s history and founders, rooms and rates, dining, bookings, payments, receipts, stock, the team, notifications, and how to use this console. '+guide();
    return 'I do not have that detail to hand. I can help with the hotel\'s history and founders, rooms and rates, dining, bookings, payments, receipts, stock, the team, notifications, and how to use this console. For anything else, please ask a member of the hotel team.';
  }
  function ask(text){
    if(!text)return;
    var a=answer(text);
    showPanel('You: '+text+'\n\nParadise: '+a);
    speak(a);
  }

  var SR=window.SpeechRecognition||window.webkitSpeechRecognition;
  var recog=null;
  var askBtn=document.getElementById('askBtn'),assistAsk=document.getElementById('assistAsk'),assistStop=document.getElementById('assistStop');
  function setAskBtn(on){
    if(!askBtn)return;
    askBtn.classList.toggle('listening',on);
    askBtn.setAttribute('aria-pressed',on?'true':'false');
  }
  function startListen(){
    if(!SR){showPanel('Speech recognition is not available in this browser. Please open the console in Chrome or Edge to speak, or read the answers here.');return;}
    if(!recog){
      recog=new SR();recog.lang='en-US';recog.interimResults=false;recog.maxAlternatives=1;recog.continuous=false;
      recog.onstart=function(){listening=true;duck(true);setState('Listening');setAskBtn(true);if(panel)panel.hidden=false;if(ptext&&ptext.textContent.indexOf('You:')<0)ptext.textContent='Listening…';};
      recog.onresult=function(e){var txt=(e.results&&e.results[0]&&e.results[0][0]&&e.results[0][0].transcript)||'';ask(txt);};
      recog.onerror=function(e){
        listening=false;setAskBtn(false);
        var err=e&&e.error;
        if(err==='not-allowed'||err==='service-not-allowed')showPanel('Microphone access was declined. Please allow the microphone in your browser settings, or read the answers here.');
        else if(err==='no-speech')showPanel('I did not hear anything. Please tap Ask and speak again.');
        else showPanel('I could not use the microphone just now. Please try again, or read the answers here.');
        setState('Ready');
      };
      recog.onend=function(){listening=false;setAskBtn(false);if(!speaking){duck(false);setState('Ready');}};
    }
    try{recog.start();}catch(e){/* already starting */}
  }
  function toggleListen(){if(listening){try{recog.stop();}catch(e){}}else startListen();}
  if(askBtn){askBtn.addEventListener('click',function(){if(panel)panel.hidden=false;if(!SR){showPanel('Speech recognition is not available in this browser. Please open the console in Chrome or Edge to speak, or read the answers here.');return;}toggleListen();});}
  if(assistAsk)assistAsk.addEventListener('click',toggleListen);
  if(assistStop)assistStop.addEventListener('click',function(){try{if(synth)synth.cancel();}catch(e){}speaking=false;duck(listening);setState(listening?'Listening':'Ready');});
  var ax=document.getElementById('assistX');
  if(ax)ax.addEventListener('click',function(){if(panel)panel.hidden=true;if(listening){try{recog.stop();}catch(e){}}try{if(synth)synth.cancel();}catch(e){}speaking=false;duck(false);});
})();
</script>
HTML;
}

function page_foot(): void{
 echo '</div></div>';
 echo '<button class="toTop" id="toTop" type="button" aria-label="Back to top"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 19V6M6 11l6-6 6 6"/></svg><span>Top</span></button>';
 echo '</div>';
 page_scripts();
 assistant_scripts();
 echo '<script src="'.BASE.'/assets/attn.js"></script>';
 echo '</body></html>';
}

function kpi_card(string $label,string $value,string $hint='',string $tone='navy'): void{
  $cards=['navy'=>'#0f2850','gold'=>'#b08d1a','green'=>'#2e7d32','red'=>'#c62828','blue'=>'#0B5D78','ok'=>'#2e7d32','warn'=>'#b26a00'];
  $t = strtolower($tone);
  $k = $cards[$t] ?? $cards['navy'];
  echo '<div class="kpi" style="--k:'.$k.'">'
   .'<span class="kpiIco">'.svg_icon(kpi_icon($label)).'</span>'
   .'<div class="kpiLbl">'.e($label).'</div><div class="kpiVal">'.$value.'</div>'
   .($hint?'<div class="kpiHint">'.e($hint).'</div>':'').'</div>';
}

function filter_bar(string $extra=''): void{
 echo '<div class="toolbar">'.$extra.'</div>';
}

/** The room a panel leaves empty, drawn so it reads as designed rather
 *  than unfinished. */
function empty_state(string $title,string $text=''): void{
 echo '<div class="emptyState"><span class="esIco">'.svg_icon('plate').'</span><h3>'.e($title).'</h3>'
  .($text?'<p>'.e($text).'</p>':'').'</div>';
}

function status_badge(string $status, bool $neutral=false): string{
 $tones=['available'=>'ok','confirmed'=>'blue','checked_in'=>'gold','checked_out'=>'grey','cancelled'=>'bad','no_show'=>'bad','pending'=>'warn','paid'=>'ok','open'=>'gold','successful'=>'ok','accepted'=>'blue','reserved'=>'warn','occupied'=>'gold','dirty'=>'bad','cleaning'=>'blue','inspected'=>'ok','maintenance'=>'grey','out_of_service'=>'grey','approved'=>'ok','rejected'=>'bad','served'=>'ok','preparing'=>'warn','ready'=>'blue','reviewed'=>'blue','cleared'=>'ok'];
 return badge(str_replace('_',' ',$status),$tones[$status]??'grey');
}

function checked(string $v,string $c): string{ return $v===$c?' checked':''; }
function sel(array $opts,string $v): string{ return isset($opts[$v]); }

function form_open(string $page,string $action='',array $extra=[],array $attrs=[]): void{
 $qs=array_merge(['page'=>$page,'act'=>$action?:''],$extra);
 $attr='';
 foreach($attrs as $k=>$v){ $attr.=' '.e((string)$k).'="'.e((string)$v).'"'; }
 echo '<form method="post"'.$attr.' action="'.BASE.'/index.php?'.http_build_query($qs).'">';
}
function form_close(): void{ echo '</form>'; }

/**
 * One labelled input on a console form.
 *
 * Every module that writes a record draws its fields through here so the
 * console keeps one shape: the label, the control, and an optional hint the
 * reader can act on. The value is always escaped, and the field is never the
 * only thing that validates it - the module checks it again on save.
 */
function field(string $label,string $name,string $value,string $type='text',string $hint='',bool $required=false,bool $readonly=false): void{
 echo '<div class="field"><label for="f_'.e($name).'">'.e($label).($required?' <span class="req">*</span>':'').'</label>';
 echo '<input id="f_'.e($name).'" type="'.e($type).'" name="'.e($name).'" value="'.e($value).'"'
  .($required?' required':'').($readonly?' readonly':'').'/>';
 if($hint!=='') echo '<small class="hint">'.e($hint).'</small>';
 echo '</div>';
}

/** One labelled textarea on a console form, paired with field(). */
function area(string $label,string $name,string $value,string $hint='',string $extra='',int $rows=5): void{
 echo '<div class="field"><label for="f_'.e($name).'">'.e($label).'</label>';
 echo '<textarea id="f_'.e($name).'" name="'.e($name).'" rows="'.$rows.'"'.($extra!==''?' '.$extra:'').'>'.e($value).'</textarea>';
 if($hint!=='') echo '<small class="hint">'.e($hint).'</small>';
 echo '</div>';
}

function back_button(string $label='Back'): void{
 echo '<a class="btnGhost sm" href="javascript:history.back()">'.e($label).'</a>';
}

/* ==================================================================
   THE PAPER A DASHBOARD PRINTS ON

   Three of these dashboards print: the kitchen prints a docket, food
   and beverage prints a bill, the director's page prints an order or a
   guest statement. They all work the same way, and it is worth saying
   once why.

   A receipt is handed to receipt_template() as HTML inside a <template>
   element, which the browser keeps out of the layout entirely: it is
   not drawn, it is not in the accessibility tree, and it is not printed
   until something asks for it. receipt_print() then does four jobs:

     1. On the first load of a page, any receipt marked fresh prints
        itself. That is what makes a docket come off the printer as an
        order lands, without anybody touching the screen.
     2. What has been printed is remembered in local storage under
        $key, so the screen refreshes itself every few seconds without
        reprinting yesterday's tickets.
     3. A Print button calls printReceipt(id), which puts exactly that
        one sheet on the paper.
     4. If the module passes a feed address, the page asks it every
        fifteen seconds whether an order exists that this screen has
        not drawn yet, and reloads when one does. The reload draws it,
        and rule 1 prints it.

   The printing itself is one class on <body>: while it is there, the
   console is hidden and the sheet is the only thing on the page.
   ================================================================== */

/** The guest a web order was placed by, read out of the note the site wrote. */
function order_customer(?string $note): ?array{
 if($note===null||$note==='') return null;
 if(!preg_match('/^Web takeaway order from (.+?),\s*([+\d][0-9\s]{6,})/u',$note,$m)) return null;
 return ['name'=>trim($m[1]),'phone'=>trim($m[2])];
}

/** What is left of a line note once the guest's name and number are taken off. */
function prep_note(?string $note): string{
 if($note===null||$note==='') return '';
 if(strpos($note,'Web takeaway order from ')!==0) return trim($note);
 $rest=substr($note,strlen('Web takeaway order from '));
 $parts=preg_split('/\s+-\s+/',$rest,2);
 return isset($parts[1])?trim($parts[1],". \t\n\r"):'';
}

/**
 * The contact details a web order carried: email, the address it is to be
 * delivered to, and any note the guest left. Every field is optional, so a
 * console reading an order from a database that has not run the upgrade gets
 * blanks rather than an error and simply shows what it has.
 */
function order_delivery(?array $order): array{
 $out=['email'=>'','address'=>'','notes'=>''];
 if(!is_array($order)) return $out;
 $out['email']=trim((string)($order['customer_email']??''));
 $out['address']=trim((string)($order['delivery_address']??''));
 $out['notes']=trim((string)($order['delivery_notes']??''));
 return $out;
}

/**
 * The hotel's own details, written once, for anything the console prints on
 * paper: an invoice, a statement, a receipt. The values live here rather than in
 * each module so a phone number or an address can never drift between documents.
 * The name and city are read from the hotel's own record when it has them.
 */
function hotel_brand(): array{
 static $b=null;
 if($b!==null) return $b;
 $h=row('SELECT name,city,country FROM hotels WHERE id=1')?:[];
 $site=defined('SITE_URL')?rtrim(SITE_URL,'/'):'';
 $name=trim((string)($h['name']??''));
 $city=trim((string)($h['city']??''));
 $country=trim((string)($h['country']??''));
 return $b=[
  'name'=>$name!==''?$name:'Hotel Paradise on the Nile',
  'city'=>$city!==''?$city:'Jinja',
  'country'=>$country!==''?$country:'Uganda',
  'legal'=>'Hotel Paradise on the Nile Ltd',
  'address'=>'Plot 12, 19 & 25 Kiira Lane, Jinja, Uganda',
  'po_box'=>'P.O. Box 1139, Jinja, Uganda',
  'phones'=>['+256 759 504 928','+256 773 565 668'],
  'email'=>'frontdesk@hotelparadiseonthenile.info',
  'website'=>'www.hotelparadiseonthenile.info',
  'certification'=>'UNBS Certified, US 130:2017',
  'logo'=>$site.'/images/logo-256.png',
  'crest'=>$site.'/images/logo-64.png',
 ];
}

/**
 * The house style for a printed document - an invoice, a statement, a formal
 * receipt. Returned as a string of CSS so a popup window can write a whole,
 * self-contained page: the navy and gold of the console, a serif for figures
 * that matter, and a quiet A4 sheet that leaves the printer clean.
 */
function document_css(): string{
 return <<<CSS
 @page{size:A4;margin:14mm}
 *{box-sizing:border-box}
 body{margin:0;background:#eef1f5;color:#0b1f38;font:13px/1.55 Georgia,'Times New Roman',serif;-webkit-print-color-adjust:exact;print-color-adjust:exact}
 .doc{max-width:760px;margin:0 auto;background:#fff;position:relative;overflow:hidden;padding:38px 42px 30px;border-top:6px solid #0b2545;box-shadow:0 18px 50px rgba(11,37,69,.14)}
 .docHead{display:flex;justify-content:space-between;gap:24px;align-items:flex-start;padding-bottom:16px;border-bottom:1px solid #e2e6ec}
 .docBrand{display:flex;gap:14px;align-items:center}
 .docLogo{width:62px;height:62px;object-fit:contain}
 .docName{font:700 21px 'Playfair Display',Georgia,serif;letter-spacing:.02em;line-height:1.05;color:#0b2545}
 .docName span{display:block;font-size:10.5px;letter-spacing:.34em;color:#c9a227;font-weight:700;margin-top:4px}
 .docTag{font-size:10.5px;color:#5b6b7f;margin-top:5px;letter-spacing:.06em}
 .docContact{text-align:right;font-size:10.5px;color:#44566c;line-height:1.5}
 .docContact b{color:#0b2545}
 .docTitle{display:flex;justify-content:space-between;align-items:flex-end;margin:20px 0 4px;padding-bottom:10px;border-bottom:2px solid #c9a227}
 .docKind{font:700 30px 'Playfair Display',Georgia,serif;letter-spacing:.14em;color:#0b2545}
 .docNo{font-size:12px;color:#0b2545;background:#f2f5f9;border:1px solid #e2e6ec;border-radius:999px;padding:5px 14px;letter-spacing:.08em}
 .docMeta{display:flex;justify-content:space-between;gap:26px;margin:16px 0 20px}
 .metaBlock{flex:1}
 .metaBlock h4{font:700 9.5px Arial,Helvetica,sans-serif;letter-spacing:.2em;color:#8a99ab;margin:0 0 6px}
 .metaBlock p{margin:0;font-size:12.5px;color:#22344a;line-height:1.6}
 .metaBlock.right{max-width:290px}
 .kv{width:100%;border-collapse:collapse}
 .kv td{padding:3px 0;font-size:12px;border-bottom:1px dotted #d8dee6}
 .kv td:last-child{text-align:right;font-weight:700;color:#0b2545}
 table.lines{width:100%;border-collapse:collapse;margin:6px 0 4px}
 table.lines thead th{background:#0b2545;color:#fff;font:700 10px Arial,Helvetica,sans-serif;letter-spacing:.14em;text-align:left;padding:9px 10px}
 table.lines thead th.num{text-align:right}
 table.lines tbody td{padding:9px 10px;border-bottom:1px solid #e9edf2;font-size:12.5px;vertical-align:top}
 table.lines tbody tr:nth-child(even){background:#f8fafc}
 table.lines td.num{text-align:right;font-variant-numeric:tabular-nums;white-space:nowrap}
 .docFoot{display:flex;justify-content:space-between;gap:26px;margin-top:18px;align-items:flex-start}
 .words{flex:1;font-size:11px;color:#5b6b7f;font-style:italic;padding-top:6px}
 .words b{display:block;font-style:normal;font:700 9.5px Arial,Helvetica,sans-serif;letter-spacing:.18em;color:#8a99ab;margin-bottom:5px}
 .totals{width:300px;border-collapse:collapse}
 .totals td{padding:5px 0;font-size:12.5px;border-bottom:1px solid #eef1f5}
 .totals td:last-child{text-align:right;font-variant-numeric:tabular-nums}
 .totals tr.grand td{border-top:2px solid #0b2545;border-bottom:2px solid #0b2545;font:700 15px 'Playfair Display',Georgia,serif;color:#0b2545;padding:8px 0}
 .totals tr.balance td{color:#a3231f;font-weight:700}
 .docSign{display:flex;justify-content:space-between;align-items:flex-end;margin-top:44px;gap:24px}
 .signLine{width:230px;border-top:1px solid #0b2545;padding-top:5px;font-size:10.5px;color:#5b6b7f;text-align:center}
 .stamp{font:700 22px 'Playfair Display',Georgia,serif;letter-spacing:.18em;color:#1f8a4c;border:3px double #1f8a4c;border-radius:10px;padding:6px 18px;transform:rotate(-7deg);opacity:.85}
 .stamp.void{color:#a3231f;border-color:#a3231f}
 .docTerms{margin-top:20px;padding-top:12px;border-top:1px solid #e2e6ec;font-size:10px;color:#7a8899;line-height:1.65}
 .docCredit{margin-top:10px;text-align:center;font-size:9px;letter-spacing:.14em;text-transform:uppercase;color:#9aa7b6}
 .watermark{position:absolute;top:42%;left:50%;transform:translate(-50%,-50%) rotate(-22deg);font:700 84px 'Playfair Display',Georgia,serif;color:rgba(163,35,31,.07);letter-spacing:.06em;pointer-events:none;z-index:0}
 .doc>*{position:relative;z-index:1}
 @media print{body{background:#fff}.doc{box-shadow:none;max-width:none;padding:0;border-top:0}.docHead{border-top:5px solid #0b2545;padding-top:16px}}
 CSS;
}

/** A whole number written in words, so a bill can carry the sum as well as the digits. */
function int_to_words(int $n): string{
 $n=(int)$n;
 if($n<0) return 'Minus '.int_to_words(-$n);
 if($n===0) return 'Zero';
 $ones=['','One','Two','Three','Four','Five','Six','Seven','Eight','Nine','Ten','Eleven','Twelve','Thirteen','Fourteen','Fifteen','Sixteen','Seventeen','Eighteen','Nineteen'];
 $tens=['','','Twenty','Thirty','Forty','Fifty','Sixty','Seventy','Eighty','Ninety'];
 $chunk=function(int $x) use($ones,$tens): string{
  $s='';
  if($x>=100){ $s.=$ones[intdiv($x,100)].' Hundred'; $x%=100; if($x>0) $s.=' and '; }
  if($x>=20){ $s.=$tens[intdiv($x,10)]; $x%=10; if($x>0) $s.='-'.$ones[$x]; }
  elseif($x>0){ $s.=$ones[$x]; }
  return $s;
 };
 $out=[];
 foreach([[1000000000,'Billion'],[1000000,'Million'],[1000,'Thousand']] as $sc){
  if($n>=$sc[0]){ $out[]=$chunk(intdiv($n,$sc[0])).' '.$sc[1]; $n%=$sc[0]; }
 }
 if($n>0) $out[]=$chunk($n);
 return implode(' ',array_filter($out));
}

/** A sum of money in words: "Three Hundred Twenty-Five Thousand Shillings only". */
function amount_in_words(float $amount,string $currency='Shillings',string $fraction='Cents'): string{
 $amount=round(abs($amount),2);
 $whole=(int)floor($amount);
 $cents=(int)round(($amount-$whole)*100);
 $s=int_to_words($whole).' '.$currency;
 if($cents>0) $s.=' and '.int_to_words($cents).' '.$fraction;
 return $s.' only';
}

/**
 * One sheet of paper.
 *
 * $kind     what the paper is called, in the bar across the top
 * $number   the reference printed large
 * $meta     label/value pairs printed under it: table, time, outlet, guest
 * $lines    each with name, qty, note and amount (amount may be null)
 * $totals   label/value pairs at the foot: subtotal, service, total
 * $foot     the line under the totals, or null
 */
function receipt_sheet(array $r): string{
 $h='<div class="sheet">';
 $h.='<div class="sheetBar">'.e($r['kind']??'RECEIPT').'</div>';
 $b=hotel_brand();
 $h.='<div class="sheetHotel"><img class="sheetLogo" src="'.e($b['crest']).'" alt=""><b>HOTEL PARADISE ON THE NILE</b><span>'.e($b['city']).' &middot; '.e($b['country']).' &middot; '.e($b['phones'][0]).'</span></div>';
 if(isset($r['number'])) $h.='<div class="sheetNo">'.e($r['number']).'</div>';
 if(!empty($r['meta'])){
  $h.='<div class="sheetMeta">';
  foreach($r['meta'] as $k=>$v){ if($v===null||$v==='') continue; $h.='<span><i>'.e($k).'</i>'.e($v).'</span>'; }
  $h.='</div>';
 }
 if(!empty($r['lines'])){
  $h.='<div class="sheetLines">';
  foreach($r['lines'] as $l){
   $h.='<div class="sheetLine"><b>'.e($l['name']??'').'</b>';
   if(isset($l['qty'])&&$l['qty']!=='') $h.='<span class="q">'.e($l['qty']).'</span>';
   if(!empty($l['note'])) $h.='<em>'.e($l['note']).'</em>';
   if(array_key_exists('amount',$l)&&$l['amount']!==null) $h.='<span class="a">'.e($l['amount']).'</span>';
   $h.='</div>';
  }
  $h.='</div>';
 }
 if(!empty($r['totals'])){
  $h.='<div class="sheetTotals">';
  foreach($r['totals'] as $t){
   // Each row is [label, value] or [label, value, 'big']. The label and the
   // figure are written separately because a receipt rules between them.
   $label=(string)($t[0]??$t['label']??'');
   $value=(string)($t[1]??$t['value']??'');
   $big=!empty($t[2])||!empty($t['big']);
   $h.='<span class="'.($big?'big':'').'">'.e($label).'</span><b class="'.($big?'big':'').'">'.e($value).'</b>';
  }
  $h.='</div>';
 }
 if(!empty($r['foot'])) $h.='<div class="sheetFoot">'.$r['foot'].'</div>';
 $h.='<div class="sheetCut">Thank you &middot; Hotel Paradise on the Nile<br><span class="sheetCredit">Designed by Reagansoft Innovation Limited &middot; reagansoftinnovation.com</span></div>';
 $h.='</div>';
 return $h;
}

/** One sheet, waiting in the wings. $fresh means this one prints itself. */
function receipt_template($id,string $html,bool $fresh=false): void{
 echo '<template data-receipt="'.e((string)$id).'"'.($fresh?' data-new="1"':'').'>'.$html.'</template>';
}

/** The printer: prints, remembers, and watches for work this screen has not drawn. */
function receipt_print(string $key,string $feed=''): void{
 echo '<div id="printStack" aria-hidden="true"></div>';
 $keyJs=json_encode('hpn_printed_'.$key);
 $feedJs=json_encode($feed);
 echo <<<HTML
<script>
(function(){
 var KEY={$keyJs},FEED={$feedJs},store={};
 try{store=JSON.parse(localStorage.getItem(KEY)||'{}')||{}}catch(e){store={}}
 var tpl=[].slice.call(document.querySelectorAll('template[data-receipt]'));
 function go(list){
  if(!list.length)return;
  var s=document.getElementById('printStack');if(!s)return;
  /* The stack is emitted inside the console layout, but the print stylesheet
     hides .app while printing. Move it to <body> first so it is not hidden by
     an ancestor and the sheet actually reaches the paper. */
  if(s.parentNode!==document.body)document.body.appendChild(s);
  s.innerHTML='';
  list.forEach(function(t){s.appendChild(t.content.cloneNode(true))});
  document.body.classList.add('printing');
  try{window.print()}catch(e){}
  list.forEach(function(t){store[t.getAttribute('data-receipt')]=1});
  try{localStorage.setItem(KEY,JSON.stringify(store))}catch(e){}
 }
 window.printReceipt=function(id){go(tpl.filter(function(t){return t.getAttribute('data-receipt')===String(id)}))};
 window.addEventListener('afterprint',function(){
  document.body.classList.remove('printing');
  var s=document.getElementById('printStack');if(s)s.innerHTML='';
 });
 var fresh=tpl.filter(function(t){return t.getAttribute('data-new')==='1'&&!store[t.getAttribute('data-receipt')]});
 if(fresh.length)setTimeout(function(){go(fresh)},250);
 if(FEED){
  setInterval(function(){
   fetch(FEED,{headers:{'Accept':'application/json'},credentials:'same-origin'})
    .then(function(r){return r.json()})
    .then(function(d){
     var known={};tpl.forEach(function(t){known[t.getAttribute('data-receipt')]=1});
     if((d.ids||[]).some(function(id){return !known[String(id)]}))location.reload();
    }).catch(function(){});
  },15000);
 }
})();
</script>
HTML;
}
function nav_profile_item(): string {
  return '';
}

