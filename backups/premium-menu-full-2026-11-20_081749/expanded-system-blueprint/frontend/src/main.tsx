import React,{useState} from 'react';
import {createRoot} from 'react-dom/client';
import {LayoutDashboard, BedDouble, CalendarDays, Utensils, Wine, Waves, Sparkles, Warehouse, WalletCards, FileText, Users, ShieldCheck, Menu, X, MessageSquare, Settings, LogOut, ChevronRight} from 'lucide-react';
import './styles.css';

const modules=[
 ['Overview',LayoutDashboard],['Owners & Directors',ShieldCheck],['Reception',Users],['Reservations',CalendarDays],['Rooms',BedDouble],['Restaurant & POS',Utensils],['Kitchen',Utensils],['Bar',Wine],['Room Service',Utensils],['Swimming Pool',Waves],['Spa',Sparkles],['Housekeeping',BedDouble],['Laundry',Sparkles],['Store & Inventory',Warehouse],['Procurement',FileText],['Maintenance',Settings],['Events & Conference',CalendarDays],['Transport',CalendarDays],['Finance',WalletCards],['Cashier',WalletCards],['Accounting',FileText],['Auditor',ShieldCheck],['HR',Users],['Communication',MessageSquare],['System Settings',Settings]
];
function App(){const [open,setOpen]=useState(false);const [active,setActive]=useState('Overview');return <div className="app">
<aside className={open?'side open':'side'}><div className="brand"><div className="mark">PN</div><div><b>PARADISE</b><span>ON THE NILE</span></div></div><button className="close" onClick={()=>setOpen(false)}><X/></button><nav>{modules.map(([n,I])=><button className={active===n?'nav active':'nav'} onClick={()=>{setActive(n);setOpen(false)}} key={n}><I size={18}/><span>{n}</span><ChevronRight size={14}/></button>)}</nav></aside>
<main><header><button className="hamb" onClick={()=>setOpen(true)}><Menu/></button><div><small>HOTEL MANAGEMENT SYSTEM</small><h1>{active}</h1></div><div className="head-actions"><span className="live">● LIVE</span><div className="avatar">M</div></div></header>
<section className="hero"><div><p className="eyebrow">HOTEL PARADISE ON THE NILE · JINJA, UGANDA</p><h2>Luxury operations, under one roof.</h2><p>Designed by <b>Reagansoft Innovation Limited</b>. A unified control centre for owners, departments, POS, finance, guests and services.</p></div><div className="hero-stat"><span>Today</span><strong>UGX</strong><b>—</b><small>Connect live finance feed</small></div></section>
<div className="cards"><Card title="Occupancy" value="—" sub="Rooms currently occupied"/><Card title="Arrivals" value="—" sub="Today's expected arrivals"/><Card title="Restaurant / POS" value="—" sub="Live sales feed"/><Card title="Approvals" value="—" sub="Owner actions awaiting review"/></div>
<section className="panel"><div className="panel-head"><div><small>COMMAND CENTRE</small><h3>{active}</h3></div><button className="gold-btn">Open workspace</button></div><div className="empty"><div className="empty-icon"><LayoutDashboard/></div><h4>{active} workspace ready</h4><p>The dashboard shell is connected to the central hotel architecture. Add the department controller/API endpoints to load live records from MySQL.</p></div></section>
<footer><span>© {new Date().getFullYear()} Hotel Paradise on the Nile</span><span>REAGANSOFT INNOVATION LIMITED · Uganda</span></footer></main></div>}
function Card({title,value,sub}:{title:string,value:string,sub:string}){return <div className="card"><small>{title}</small><strong>{value}</strong><span>{sub}</span></div>}
createRoot(document.getElementById('root')!).render(<App/>);
