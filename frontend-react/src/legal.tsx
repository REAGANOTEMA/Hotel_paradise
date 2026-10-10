import React from 'react';
import {TopBar, PageNav, Footer, BackLink, bgUrl, HOTEL, CALL, telHref, useReveal} from './shared';

/**
 * The shared shell every legal document is set in.
 *
 * A photographed header opens it, a contents rail keeps its place down the
 * side of the page, and each clause is a numbered plate on ivory. The pages
 * that use it pass their own wording in as `clauses`, so the terms, the
 * privacy policy and the cookie policy all read as one family without the
 * layout being written three times.
 */
export type LegalClause = {
 /** The anchor the contents rail links to. */
 id: string;
 /** The heading shown on the clause and in the contents rail. */
 title: string;
 /** The body paragraphs. */
 paras?: string[];
 /** An optional list of points drawn under the paragraphs. */
 list?: string[];
};

export type LegalPageProps = {
 eyebrow: string;
 title: string;
 /** The date the document was last reviewed, written out in full. */
 updated: string;
 intro: string;
 /** A photograph under /images, used behind the header. */
 heroBg: string;
 clauses: LegalClause[];
};

export function LegalPage({eyebrow, title, updated, intro, heroBg, clauses}: LegalPageProps) {
 useReveal();

 return <div>
  <TopBar/>
  <PageNav onDark/>

  <section className="pageHero canvas hasCover" id="main" style={{'--bg': bgUrl(heroBg)} as unknown as React.CSSProperties}>
   <div className="pageHeroInner">
    <BackLink label="Back" fallback="./index.html"/>
    <p className="eyebrow">{eyebrow}</p>
    <h1>{title}</h1>
    <p>{intro}</p>
   </div>
  </section>

  <section className="legal">
   <div className="legalGrid">
    <aside className="legalToc reveal" aria-label="Contents">
     <h2>Contents</h2>
     <div className="legalRule"/>
     <ol>
      {clauses.map(c => <li key={c.id}><a href={'#' + c.id}>{c.title}</a></li>)}
     </ol>
    </aside>

    <div className="legalBody">
     <p className="legalMeta reveal"><b>Last updated</b> {updated}</p>
     <p className="legalLead reveal">{intro}</p>

     {clauses.map((c, i) => (
      <article className="legalClause reveal" id={c.id} key={c.id}>
       <h2><span className="legalNum" aria-hidden="true">{String(i + 1).padStart(2, '0')}</span>{c.title}</h2>
       {c.paras?.map((p, j) => <p key={j}>{p}</p>)}
       {c.list && <ul>{c.list.map((li, j) => <li key={j}>{li}</li>)}</ul>}
      </article>
     ))}

     <div className="legalFoot reveal">
      <h3>Questions about this document?</h3>
      <p>Write to <a href={'mailto:' + HOTEL.email}>{HOTEL.email}</a>, or call the front desk on <a href={telHref(CALL)}>{CALL}</a>. The desk is staffed twenty four hours a day, and a member of our team will be glad to help.</p>
      <a className="btn" href="./index.html">Back to the hotel</a>
     </div>
    </div>
   </div>
  </section>

  <Footer/>
 </div>;
}
