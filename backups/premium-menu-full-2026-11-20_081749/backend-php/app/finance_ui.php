<?php
declare(strict_types=1);

function finance_ui_export_buttons(string $page, array $params=[]): string
{
    $url = finance_export_url($page, $params);
    return '<a class="btnGhost sm" href="'.e($url).'">Export CSV</a>'
        .' <button type="button" class="btnGhost sm" onclick="window.print();return false">Print</button>';
}

function finance_ui_print_header(string $title, string $range='', string $sub=''): void
{
    $b = hotel_brand();
    echo '<div class="finPrintHead">'
        .'<img src="'.e($b['logo']).'" alt="">'
        .'<div class="finPrintHouse"><b>'.e($b['name']).'</b><span>'.e($b['address']).'</span>'
        .'<span>'.e($b['po_box']).' &middot; '.e(implode(' / ', $b['phones'])).' &middot; '.e($b['email']).'</span></div>'
        .'<div class="finPrintMeta"><b>'.e($title).'</b><span>'.e($range).'</span><span>Generated '.fmtdt(now_s()).'</span>'.($sub !== '' ? '<span>'.e($sub).'</span>' : '').'</div>'
        .'</div>';
}

function finance_ui_open(string $id, string $title, array $headers, string $hint='', string $tools='', bool $search=true): void
{
    echo '<div class="panel finPanel" id="'.e($id).'Wrap"><div class="panelHead"><div><h2>'.e($title).'</h2>'
        .($hint !== '' ? '<p class="hint">'.e($hint).'</p>' : '')
        .'</div><div class="finTools">'.$tools.'</div></div>';
    if ($search) {
        echo '<div class="finSearch"><label for="'.e($id).'Search">Find</label>'
            .'<input id="'.e($id).'Search" class="finSearchInput" type="search" placeholder="Search this table" autocomplete="off">'
            .'<span class="finCount" data-fin-count>0 rows</span></div>';
    }
    echo '<div class="tableScroll"><table class="tbl finTable" id="'.e($id).'" data-fin-table><thead><tr>';
    foreach ($headers as $key => $label) {
        $sort = is_string($key) ? ' data-sort="'.e($key).'"' : '';
        $num = is_string($key) && str_starts_with($key, 'num:') ? ' class="num"' : '';
        if (is_string($key) && str_starts_with($key, 'num:')) $sort = ' data-sort="'.e(substr($key, 4)).'"';
        echo '<th'.$num.$sort.'>'.e((string)$label).'</th>';
    }
    echo '</tr></thead><tbody>';
}

function finance_ui_empty(int $cols, string $text='No records found.'): void
{
    echo '<tr data-fin-empty><td colspan="'.max(1, $cols).'" class="hint" style="text-align:center">'.e($text).'</td></tr>';
}

function finance_ui_close(int $cols, array $totals=[], string $empty='No records found.'): void
{
    echo '</tbody>';
    if ($totals) {
        echo '<tfoot><tr>';
        for ($i = 0; $i < $cols; $i++) {
            if (array_key_exists($i, $totals)) {
                $t = $totals[$i];
                $money = !empty($t['money']);
                $value = (float)($t['value'] ?? 0);
                $label = (string)($t['label'] ?? '');
                echo '<td class="num finTotal" data-total-col="'.$i.'" data-money="'.($money ? '1' : '0').'"'
                    .' data-prefix="'.e((string)($t['prefix'] ?? '')).'" data-value="'.e((string)$value).'">'
                    .e($label !== '' ? $label.' ' : '').($money ? money($value) : num($value)).'</td>';
            } else {
                echo '<td></td>';
            }
        }
        echo '</tr></tfoot>';
    }
    echo '</table></div>';
    echo '<p class="finNoRows" data-fin-empty-note hidden>'.e($empty).'</p>';
    echo '</div>';
}

function finance_ui_scripts(): void
{
    static $done = false;
    if ($done) return;
    $done = true;
    echo <<<'HTML'
<script>
(function(){
  function formatValue(n,money){
    if(money) return 'UGX '+new Intl.NumberFormat('en-UG',{maximumFractionDigits:0}).format(Math.round(n||0));
    return new Intl.NumberFormat('en-UG',{maximumFractionDigits:0}).format(Math.round(n||0));
  }
  document.querySelectorAll('table[data-fin-table]').forEach(function(table){
    var panel=table.closest('.finPanel');
    if(!panel) return;
    var input=panel.querySelector('.finSearchInput');
    var count=panel.querySelector('[data-fin-count]');
    var body=table.tBodies[0];
    if(!body) return;
    var rows=Array.prototype.slice.call(body.rows);
    var sortCol=-1,sortDir=1;
    function cellNumber(cell){
      if(!cell) return NaN;
      var raw=cell.getAttribute('data-value');
      if(raw!==null && raw!=='') return parseFloat(raw);
      return parseFloat(cell.textContent.replace(/[^0-9.-]/g,''));
    }
    function refresh(){
      var q=input?input.value.trim().toLowerCase():'';
      var shown=0;
      rows.forEach(function(row){
        if(row.hasAttribute('data-fin-empty')) return;
        var ok=!q||row.textContent.toLowerCase().indexOf(q)!==-1;
        row.style.display=ok?'':'none';
        if(ok)shown++;
      });
      if(count) count.textContent=shown+' row'+(shown===1?'':'s');
      var note=panel.querySelector('[data-fin-empty-note]');
      if(note) note.hidden=shown!==0;
      table.querySelectorAll('tfoot [data-total-col]').forEach(function(td){
        var col=parseInt(td.getAttribute('data-total-col'),10);
        var sum=0;
        rows.forEach(function(row){
          if(row.style.display==='none'||row.hasAttribute('data-fin-empty')) return;
          var v=cellNumber(row.cells[col]);
          if(!isNaN(v)) sum+=v;
        });
        td.textContent=(td.getAttribute('data-prefix')||'')+formatValue(sum,td.getAttribute('data-money')==='1');
      });
    }
    if(input) input.addEventListener('input',refresh);
    table.querySelectorAll('th[data-sort]').forEach(function(th,index){
      th.addEventListener('click',function(){
        var col=index;
        if(sortCol===col) sortDir=-sortDir; else {sortCol=col;sortDir=1;}
        var visible=rows.filter(function(r){return !r.hasAttribute('data-fin-empty');});
        visible.sort(function(a,b){
          var av=cellNumber(a.cells[col]),bv=cellNumber(b.cells[col]);
          if(!isNaN(av)&&!isNaN(bv)) return (av-bv)*sortDir;
          return a.cells[col].textContent.localeCompare(b.cells[col].textContent)*sortDir;
        });
        visible.forEach(function(r){body.appendChild(r);});
        table.querySelectorAll('th[data-sort]').forEach(function(h){h.removeAttribute('aria-sort');});
        th.setAttribute('aria-sort',sortDir===1?'ascending':'descending');
        refresh();
      });
    });
    refresh();
  });
})();
</script>
HTML;
}

function finance_ui_kpi_grid(array $cards): void
{
    echo '<div class="kpis finKpis">';
    foreach ($cards as $c) {
        kpi_card((string)$c[0], (string)$c[1], (string)($c[2] ?? ''), (string)($c[3] ?? 'navy'));
    }
    echo '</div>';
}

function finance_ui_range_form(string $page, array $range, array $extra=[]): void
{
    echo '<form method="get" class="finFilter"><input type="hidden" name="page" value="'.e($page).'">';
    foreach ($extra as $k => $v) echo '<input type="hidden" name="'.e($k).'" value="'.e((string)$v).'">';
    echo '<label>From <input type="date" name="from" value="'.e($range['from']).'"></label>'
        .'<label>To <input type="date" name="to" value="'.e($range['to']).'"></label>'
        .'<button class="btn sm">Apply</button>'
        .'<span class="finRangeText">'.e($range['label']).'</span>'
        .'</form>';
}

function finance_ui_alert(string $text, string $tone='warn'): void
{
    echo '<div class="flash '.e($tone).' finAlert"><b>'.e($text).'</b></div>';
}

function finance_ui_status(string $status): string
{
    $tone = match ($status) {
        'successful', 'paid', 'posted', 'approved', 'cleared', 'reconciled' => 'ok',
        'pending', 'draft', 'open', 'recorded', 'reviewed' => 'warn',
        'failed', 'reversed', 'refunded', 'rejected' => 'bad',
        default => 'grey',
    };
    return badge(str_replace('_', ' ', $status), $tone);
}

function finance_ui_severity(string $severity): string
{
    $tone = $severity === 'high' ? 'bad' : ($severity === 'medium' ? 'warn' : 'grey');
    return badge(ucfirst($severity), $tone);
}
