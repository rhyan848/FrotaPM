#!/usr/bin/env bash
set -e

OUTDIR="FrotaPM-site"
ZIPNAME="FrotaPM-site.zip"

echo "Criando diretório $OUTDIR ..."
rm -rf "$OUTDIR" "$ZIPNAME"
mkdir -p "$OUTDIR/.github/workflows"

echo "Escrevendo index.html ..."
cat > "$OUTDIR/index.html" <<'HTML'
<!doctype html>
<html lang="pt-BR">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title>FrotaPM — Gestão e Monitoramento</title>

  <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"
    integrity="sha256-sA+e2g0K6wD9h2hZ6w2s1mG3Q2RYqk1YvV8q2egQv/k=" crossorigin=""/>
  <link rel="stylesheet" href="styles.css" />
</head>
<body>
  <header class="topbar">
    <div class="brand">FrotaPM — Gestão & Monitoramento</div>
    <nav class="navtabs" role="navigation" aria-label="Navegação do site">
      <button data-tab="dashboard" class="active">Dashboard</button>
      <button data-tab="viaturas">Cadastro</button>
      <button data-tab="preventiva">Preventiva</button>
      <button data-tab="os">Ordens de Serviço</button>
      <button data-tab="historico">Histórico</button>
      <button data-tab="rastreamento">Rastreamento</button>
      <button data-tab="kpis">Indicadores</button>
      <button data-tab="relatorios">Relatórios</button>
    </nav>
  </header>

  <main id="app">
    <!-- Dashboard -->
    <section id="dashboard" class="tabcontent">
      <h2>Dashboard</h2>
      <div class="cards">
        <div class="card">
          <div class="card-title">Total de Viaturas</div>
          <div class="card-value" id="total-viaturas">0</div>
        </div>
        <div class="card">
          <div class="card-title">Em Operação</div>
          <div class="card-value" id="viaturas-operacao">0</div>
        </div>
        <div class="card">
          <div class="card-title">Em Manutenção</div>
          <div class="card-value" id="viaturas-manutencao">0</div>
        </div>
        <div class="card">
          <div class="card-title">Indisponíveis</div>
          <div class="card-value" id="viaturas-indisponivel">0</div>
        </div>
      </div>

      <section class="panel">
        <h3>Próximas revisões</h3>
        <ul id="proximas-revisoes" class="list"></ul>
      </section>
    </section>

    <!-- Cadastro de Viaturas -->
    <section id="viaturas" class="tabcontent" hidden>
      <h2>Cadastro de Viaturas</h2>
      <form id="form-viatura" class="form-inline">
        <input name="numero" placeholder="Número da viatura" required />
        <input name="placa" placeholder="Placa" required />
        <input name="modelo" placeholder="Modelo" />
        <input name="ano" type="number" placeholder="Ano" />
        <input name="km_atual" type="number" placeholder="Quilometragem atual" />
        <input name="unidade" placeholder="Unidade responsável" />
        <select name="status">
          <option value="Em operação">Em operação</option>
          <option value="Em manutenção">Em manutenção</option>
          <option value="Indisponível">Indisponível</option>
        </select>
        <input name="ultima_revisao" type="date" placeholder="Última revisão" />
        <input name="proxima_revisao" type="date" placeholder="Próxima revisão" />
        <button type="submit">Salvar</button>
      </form>

      <div class="table-wrap">
        <table id="table-viaturas">
          <thead><tr><th>Número</th><th>Placa</th><th>Modelo</th><th>KM</th><th>Status</th><th>Ações</th></tr></thead>
          <tbody></tbody>
        </table>
      </div>
    </section>

    <!-- Plano de Manutenção Preventiva -->
    <section id="preventiva" class="tabcontent" hidden>
      <h2>Plano de Manutenção Preventiva</h2>
      <form id="form-plano" class="form-inline">
        <input name="item" placeholder="Item (ex: Troca de óleo)" required />
        <input name="frequencia" placeholder="Frequência (ex: 10000 km / 6 meses)" required />
        <button type="submit">Adicionar</button>
      </form>

      <ul id="lista-planos" class="list"></ul>
    </section>

    <!-- Ordens de Serviço -->
    <section id="os" class="tabcontent" hidden>
      <h2>Ordens de Serviço (OS)</h2>
      <form id="form-os" class="form-inline">
        <input name="numero" placeholder="Número da OS" required />
        <input name="data" type="date" value="" required />
        <select name="viatura" id="os-viatura-select"></select>
        <input name="problema" placeholder="Problema identificado" />
        <input name="servico" placeholder="Serviço executado" />
        <input name="responsavel" placeholder="Responsável" />
        <input name="pecas" placeholder="Peças utilizadas" />
        <input name="custo" type="number" placeholder="Custo" />
        <input name="tempo_parada" placeholder="Tempo de parada (hrs)" />
        <button type="submit">Abrir OS</button>
      </form>

      <div class="table-wrap">
        <table id="table-os">
          <thead><tr><th>OS</th><th>Data</th><th>Viatura</th><th>Problema</th><th>Status</th><th>Ações</th></tr></thead>
          <tbody></tbody>
        </table>
      </div>
    </section>

    <!-- Histórico -->
    <section id="historico" class="tabcontent" hidden>
      <h2>Histórico de Manutenção</h2>
      <div id="historico-ficha"></div>
    </section>

    <!-- Rastreamento -->
    <section id="rastreamento" class="tabcontent" hidden>
      <h2>Rastreamento em Tempo Real</h2>
      <div id="map" style="height:60vh"></div>
      <div class="controls">
        <button id="btn-start-sim">Iniciar Simulação</button>
        <button id="btn-stop-sim">Parar Simulação</button>
        <button id="btn-centro">Centralizar mapa</button>
      </div>
      <div id="lista-rastreamento" class="list"></div>
    </section>

    <!-- KPIs -->
    <section id="kpis" class="tabcontent" hidden>
      <h2>Indicadores (KPIs)</h2>
      <div class="cards">
        <div class="card"><div class="card-title">Disponibilidade (%)</div><div class="card-value" id="kpi-disponibilidade">0</div></div>
        <div class="card"><div class="card-title">MTTR (h)</div><div class="card-value" id="kpi-mttr">0</div></div>
        <div class="card"><div class="card-title">MTBF (h)</div><div class="card-value" id="kpi-mtbf">0</div></div>
        <div class="card"><div class="card-title">Custo / Viatura</div><div class="card-value" id="kpi-custo">0</div></div>
      </div>
    </section>

    <!-- Relatórios -->
    <section id="relatorios" class="tabcontent" hidden>
      <h2>Relatórios</h2>
      <div class="controls">
        <button id="export-csv-viaturas">Exportar Viaturas (CSV)</button>
        <button id="export-csv-os">Exportar OS (CSV)</button>
        <button id="print-relatorio">Imprimir Relatório Atual</button>
      </div>
      <div id="relatorio-output"></div>
    </section>
  </main>

  <footer class="footer">
    <small>FrotaPM — Protótipo • Dados salvos no navegador (localStorage)</small>
  </footer>

  <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"
    integrity="sha256-h9+4qC5sQq9YFQZ6k3GH4cQw3b7rI1d3kDk9t6L0h2M=" crossorigin=""></script>
  <script src="app.js"></script>
</body>
</html>
HTML

echo "Escrevendo styles.css ..."
cat > "$OUTDIR/styles.css" <<'CSS'
:root{
  --accent:#1e88e5;
  --bg:#f5f7fb;
  --card:#fff;
  --muted:#6b7280;
  --success:#2e7d32;
  --danger:#e53935;
  --sidebar-width:320px;
  font-family:Inter, system-ui, -apple-system, "Segoe UI", Roboto, "Helvetica Neue", Arial;
}

*{box-sizing:border-box}
body{margin:0;background:var(--bg);color:#111827;display:flex;flex-direction:column;min-height:100vh}
.topbar{display:flex;align-items:center;padding:12px 16px;background:linear-gradient(90deg, rgba(30,136,229,0.08), rgba(30,136,229,0.02));border-bottom:1px solid rgba(0,0,0,0.04)}
.brand{font-weight:700}
.navtabs{margin-left:auto;display:flex;gap:6px}
.navtabs button{background:transparent;border:0;padding:8px 10px;border-radius:8px;cursor:pointer}
.navtabs button.active{background:var(--accent);color:#fff}

main{flex:1;padding:16px}

.cards{display:flex;gap:12px;flex-wrap:wrap;margin-bottom:16px}
.card{background:var(--card);padding:12px;border-radius:8px;box-shadow:0 6px 18px rgba(2,6,23,0.04);flex:1;min-width:160px}
.card-title{font-size:13px;color:var(--muted)}
.card-value{font-size:22px;font-weight:700;margin-top:6px}

.panel{background:var(--card);padding:12px;border-radius:8px}
.list{list-style:none;padding:0;margin:0}
.list li{padding:8px;border-bottom:1px solid rgba(0,0,0,0.04)}
.form-inline{display:flex;flex-wrap:wrap;gap:8px;margin-bottom:12px}
.form-inline input,.form-inline select{padding:8px;border-radius:8px;border:1px solid #e5e7eb;background:#fff}
.form-inline button{padding:8px 12px;border-radius:8px;border:0;background:var(--accent);color:#fff;cursor:pointer}

.table-wrap{background:var(--card);border-radius:8px;padding:8px}
table{width:100%;border-collapse:collapse}
table th,table td{padding:8px;border-bottom:1px solid rgba(0,0,0,0.04);text-align:left}
.controls{margin-top:8px;display:flex;gap:8px}

.footer{padding:10px 16px;background:#fff;border-top:1px solid rgba(0,0,0,0.04);font-size:12px;color:var(--muted)}
@media (max-width:900px){
  .cards{flex-direction:column}
  .navtabs{overflow:auto}
}
CSS

echo "Escrevendo app.js ..."
cat > "$OUTDIR/app.js" <<'JS'
// FrotaPM - app.js (protótipo)
// Persistência via localStorage (keys: fpm_viaturas, fpm_planos, fpm_os)

const LS_KEYS = { VIATURAS: 'fpm_viaturas', PLANOS: 'fpm_planos', OS: 'fpm_os' };

function read(key){ try { return JSON.parse(localStorage.getItem(key) || '[]'); } catch(e){ return []; } }
function write(key, val){ localStorage.setItem(key, JSON.stringify(val)); }

// --- Inicialização demo (apenas se vazio) ---
function seedIfEmpty(){
  if(!read(LS_KEYS.VIATURAS).length){
    const demo = [
      { id: 'v1', numero:'001', placa:'ABC-0001', modelo:'Fiat Fiorino', ano:2018, km_atual:45000, unidade:'1ª Cia', status:'Em operação', ultima_revisao:'2024-12-01', proxima_revisao:'2025-06-01', lat:-26.9193, lng:-49.0661 },
      { id: 'v2', numero:'002', placa:'DEF-2345', modelo:'Ford Ranger', ano:2020, km_atual:80000, unidade:'2ª Cia', status:'Em manutenção', ultima_revisao:'2025-01-10', proxima_revisao:'2025-07-10', lat:-26.9250, lng:-49.0700 }
    ];
    write(LS_KEYS.VIATURAS, demo);
  }
  if(!read(LS_KEYS.PLANOS).length){
    write(LS_KEYS.PLANOS, [
      { id:'p1', item:'Troca de óleo', frequencia:'10000 km' },
      { id:'p2', item:'Revisão dos freios', frequencia:'20000 km' },
      { id:'p3', item:'Revisão elétrica', frequencia:'6 meses' }
    ]);
  }
}
seedIfEmpty();

// --- Navegação entre abas ---
const tabs = document.querySelectorAll('.navtabs button');
const tabContents = document.querySelectorAll('.tabcontent');
tabs.forEach(b => b.addEventListener('click', ()=>{ openTab(b.dataset.tab); }));
function openTab(name){
  tabs.forEach(t=>t.classList.toggle('active', t.dataset.tab===name));
  tabContents.forEach(s=> s.id===name ? s.removeAttribute('hidden') : s.setAttribute('hidden',''));
  // atualiza conteúdo dinâmico ao abrir
  if(name==='viaturas') renderViaturasTable();
  if(name==='preventiva') renderPlanos();
  if(name==='os') renderOS();
  if(name==='dashboard') renderDashboard();
  if(name==='rastreamento') startMapOnce();
  if(name==='kpis') calcKPIs();
  if(name==='relatorios') renderRelatorioOutput();
}
openTab('dashboard');

// --- Viaturas CRUD ---
const formViatura = document.getElementById('form-viatura');
formViatura.addEventListener('submit', e=>{
  e.preventDefault();
  const form = e.target;
  const obj = Object.fromEntries(new FormData(form).entries());
  if(!obj.numero || !obj.placa) return alert('Número e Placa obrigatórios');
  const viaturas = read(LS_KEYS.VIATURAS);
  // nova viatura
  const id = 'v'+Date.now();
  obj.id = id;
  obj.km_atual = Number(obj.km_atual) || 0;
  write(LS_KEYS.VIATURAS, [obj, ...viaturas]);
  form.reset();
  renderViaturasTable();
  renderOSViaturasSelect();
  renderDashboard();
});

function renderViaturasTable(){
  const tbody = document.querySelector('#table-viaturas tbody');
  tbody.innerHTML = '';
  const viaturas = read(LS_KEYS.VIATURAS);
  viaturas.forEach(v=>{
    const tr = document.createElement('tr');
    tr.innerHTML = `<td>${v.numero}</td><td>${v.placa}</td><td>${v.modelo||''}</td><td>${v.km_atual||0}</td><td>${v.status||''}</td>
      <td>
        <button class="btn-edit" data-id="${v.id}">Editar</button>
        <button class="btn-del" data-id="${v.id}">Remover</button>
      </td>`;
    tbody.appendChild(tr);
  });
  tbody.querySelectorAll('.btn-del').forEach(btn=>{
    btn.addEventListener('click', ()=>{ removeViatura(btn.dataset.id); });
  });
  tbody.querySelectorAll('.btn-edit').forEach(btn=>{
    btn.addEventListener('click', ()=>{ editViatura(btn.dataset.id); });
  });
  renderOSViaturasSelect();
}

function removeViatura(id){
  if(!confirm('Remover viatura?')) return;
  const v = read(LS_KEYS.VIATURAS).filter(x=>x.id!==id);
  write(LS_KEYS.VIATURAS, v);
  renderViaturasTable(); renderDashboard();
}

function editViatura(id){
  const viaturas = read(LS_KEYS.VIATURAS);
  const v = viaturas.find(x=>x.id===id);
  if(!v) return;
  const form = formViatura;
  Object.entries(v).forEach(([k,val])=>{
    if(form[k]) form[k].value = val;
  });
  // on save: replace existing
  form.removeEventListener('submit', onSaveNew);
  form.addEventListener('submit', function onSaveEdit(e){
    e.preventDefault();
    const obj = Object.fromEntries(new FormData(form).entries());
    obj.km_atual = Number(obj.km_atual) || 0;
    obj.id = id;
    const others = read(LS_KEYS.VIATURAS).filter(x=>x.id!==id);
    write(LS_KEYS.VIATURAS, [obj, ...others]);
    form.reset();
    form.removeEventListener('submit', onSaveEdit);
    renderViaturasTable(); renderDashboard();
  });
}
function onSaveNew(e){ /* placeholder */ }

// --- Planos Preventiva ---
const formPlano = document.getElementById('form-plano');
formPlano.addEventListener('submit', e=>{
  e.preventDefault();
  const obj = Object.fromEntries(new FormData(formPlano).entries());
  obj.id = 'p'+Date.now();
  const planos = read(LS_KEYS.PLANOS);
  write(LS_KEYS.PLANOS, [obj, ...planos]);
  formPlano.reset();
  renderPlanos();
});
function renderPlanos(){
  const ul = document.getElementById('lista-planos');
  ul.innerHTML = '';
  read(LS_KEYS.PLANOS).forEach(p=>{
    const li = document.createElement('li');
    li.innerHTML = `<strong>${p.item}</strong> — ${p.frequencia} <button data-id="${p.id}" class="btn-del">Remover</button>`;
    ul.appendChild(li);
  });
  ul.querySelectorAll('.btn-del').forEach(b=>b.addEventListener('click', ()=>{ removePlano(b.dataset.id); }));
}
function removePlano(id){
  write(LS_KEYS.PLANOS, read(LS_KEYS.PLANOS).filter(x=>x.id!==id));
  renderPlanos();
}

// --- Ordens de Serviço (OS) ---
const formOS = document.getElementById('form-os');
formOS.addEventListener('submit', e=>{
  e.preventDefault();
  const obj = Object.fromEntries(new FormData(formOS).entries());
  obj.id = 'os'+Date.now();
  obj.data = obj.data || new Date().toISOString().slice(0,10);
  obj.status = 'Aberta';
  write(LS_KEYS.OS, [obj, ...read(LS_KEYS.OS)]);
  formOS.reset();
  renderOS();
  renderDashboard();
});

function renderOS(){
  const tbody = document.querySelector('#table-os tbody');
  tbody.innerHTML = '';
  read(LS_KEYS.OS).forEach(o=>{
    const tr = document.createElement('tr');
    tr.innerHTML = `<td>${o.numero}</td><td>${o.data}</td><td>${o.viatura||''}</td><td>${o.problema||''}</td><td>${o.status||''}</td>
      <td>
        <button class="btn-final" data-id="${o.id}">Finalizar</button>
        <button class="btn-print" data-id="${o.id}">Imprimir</button>
      </td>`;
    tbody.appendChild(tr);
  });
  tbody.querySelectorAll('.btn-final').forEach(b=>b.addEventListener('click', ()=>{ finalizarOS(b.dataset.id); }));
  tbody.querySelectorAll('.btn-print').forEach(b=>b.addEventListener('click', ()=>{ imprimirOS(b.dataset.id); }));
}

function finalizarOS(id){
  const os = read(LS_KEYS.OS).map(o=> o.id===id ? Object.assign({},o,{status:'Finalizada'}) : o );
  write(LS_KEYS.OS, os);
  renderOS(); renderHistorico();
}

function imprimirOS(id){
  const o = read(LS_KEYS.OS).find(x=>x.id===id);
  if(!o) return;
  const w = window.open('','_blank');
  w.document.write(`<pre>${JSON.stringify(o, null, 2)}</pre>`);
  w.print();
}

// --- Histórico ---
function renderHistorico(){
  const div = document.getElementById('historico-ficha');
  div.innerHTML = '';
  const viaturas = read(LS_KEYS.VIATURAS);
  viaturas.forEach(v=>{
    const osList = read(LS_KEYS.OS).filter(o=> o.viatura===v.placa || o.viatura===v.numero);
    const totalCusto = osList.reduce((s,x)=>s + (Number(x.custo)||0),0);
    const disp = document.createElement('div');
    disp.className = 'panel';
    disp.innerHTML = `<h4>${v.numero} — ${v.placa} (${v.modelo||''})</h4>
      <div>Custos acumulados: R$ ${totalCusto.toFixed(2)}</div>
      <div>Manutenções: ${osList.length}</div>
      <div>Última revisão: ${v.ultima_revisao||'—'}</div>`;
    div.appendChild(disp);
  });
}
renderHistorico();

// --- Dashboard resumo e próximas revisões ---
function renderDashboard(){
  const viaturas = read(LS_KEYS.VIATURAS);
  document.getElementById('total-viaturas').textContent = viaturas.length;
  document.getElementById('viaturas-operacao').textContent = viaturas.filter(v=>v.status==='Em operação').length;
  document.getElementById('viaturas-manutencao').textContent = viaturas.filter(v=>v.status==='Em manutenção').length;
  document.getElementById('viaturas-indisponivel').textContent = viaturas.filter(v=>v.status==='Indisponível').length;

  const proximas = viaturas.filter(v=>v.proxima_revisao).sort((a,b)=> new Date(a.proxima_revisao) - new Date(b.proxima_revisao)).slice(0,6);
  const ul = document.getElementById('proximas-revisoes');
  ul.innerHTML = proximas.map(v=>`<li>${v.numero} • ${v.placa} — ${v.proxima_revisao}</li>`).join('');
  renderHistorico();
}
renderDashboard();

// --- Select de viaturas para OS ---
function renderOSViaturasSelect(){
  const sel = document.getElementById('os-viatura-select');
  if(!sel) return;
  sel.innerHTML = '';
  read(LS_KEYS.VIATURAS).forEach(v=>{
    const opt = document.createElement('option');
    opt.value = v.placa || v.numero;
    opt.textContent = `${v.numero} — ${v.placa}`;
    sel.appendChild(opt);
  });
}
renderOSViaturasSelect();

// --- Rastreamento: mapa e simulação ---
let map, markersMap = new Map(), simHandle = null;
function startMapOnce(){
  if(map) return;
  // center Blumenau
  map = L.map('map').setView([-26.9193, -49.0661], 13);
  L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',{attribution: '&copy; OpenStreetMap contributors'}).addTo(map);
  // place markers for viaturas
  renderMapMarkers();
  document.getElementById('btn-start-sim').addEventListener('click', startSimulation);
  document.getElementById('btn-stop-sim').addEventListener('click', stopSimulation);
  document.getElementById('btn-centro').addEventListener('click', ()=> map.setView([-26.9193, -49.0661], 13));
}

function renderMapMarkers(){
  const viaturas = read(LS_KEYS.VIATURAS);
  viaturas.forEach(v=>{
    if(v.lat==null || v.lng==null) return;
    const id = v.id;
    if(markersMap.has(id)){
      markersMap.get(id).setLatLng([v.lat, v.lng]);
    } else {
      const m = L.marker([v.lat, v.lng]).addTo(map).bindPopup(`${v.numero} • ${v.placa}`);
      markersMap.set(id, m);
    }
  });
  // update list
  const list = document.getElementById('lista-rastreamento');
  list.innerHTML = read(LS_KEYS.VIATURAS).map(v=> `<li>${v.numero} • ${v.placa} — ${v.lat?.toFixed(5)||'—'}/${v.lng?.toFixed(5)||'—'}</li>`).join('');
}

function jitterAll(){
  const viaturas = read(LS_KEYS.VIATURAS).map(v=>{
    if(v.lat==null || v.lng==null) {
      v.lat = -26.9193 + (Math.random()-0.5)*0.02;
      v.lng = -49.0661 + (Math.random()-0.5)*0.02;
    } else {
      const s = v.status==='Indisponível' ? 0 : 0.0005;
      v.lat = v.lat + (Math.random()-0.5)*s;
      v.lng = v.lng + (Math.random()-0.5)*s;
    }
    return v;
  });
  write(LS_KEYS.VIATURAS, viaturas);
  renderMapMarkers(); renderDashboard();
}

function startSimulation(){
  if(simHandle) return;
  simHandle = setInterval(jitterAll, 2500);
  jitterAll();
}
function stopSimulation(){ if(simHandle) { clearInterval(simHandle); simHandle = null; } }

// --- KPIs (simples) ---
function calcKPIs(){
  const viaturas = read(LS_KEYS.VIATURAS);
  const total = viaturas.length || 1;
  const disponiveis = viaturas.filter(v=>v.status==='Em operação').length;
  const disponibilidade = Math.round((disponiveis/total)*100);
  document.getElementById('kpi-disponibilidade').textContent = `${disponibilidade}%`;

  // MTTR / MTBF / custo simples (baseado em OS)
  const oss = read(LS_KEYS.OS);
  const numRepairs = oss.length || 1;
  const tempoTotal = oss.reduce((s,o)=> s + (Number(o.tempo_parada)||0), 0);
  const mttr = (tempoTotal/numRepairs).toFixed(1);
  document.getElementById('kpi-mttr').textContent = `${mttr}`;

  // MTBF: por simplicidade (horas operacionais / falhas) - simulamos horas = km / 60 => simplificado
  const horasOperacao = viaturas.reduce((s,v)=> s + ((v.km_atual||0)/60), 0);
  const mtbf = Math.round(horasOperacao / numRepairs) || 0;
  document.getElementById('kpi-mtbf').textContent = `${mtbf}`;

  const custoTotal = oss.reduce((s,o)=> s + (Number(o.custo)||0), 0);
  const custoPor = (custoTotal / (total||1)).toFixed(2);
  document.getElementById('kpi-custo').textContent = `R$ ${custoPor}`;
}

// --- Relatórios / Export CSV / Impressão ---
function toCSV(rows, headers){
  const esc = v => `"${String(v||'').replace(/"/g,'""')}"`;
  const csv = [headers.map(esc).join(',')].concat(rows.map(r=> headers.map(h=>esc(r[h])).join(',')));
  return csv.join('\n');
}

document.getElementById('export-csv-viaturas').addEventListener('click', ()=>{
  const rows = read(LS_KEYS.VIATURAS);
  const headers = ['numero','placa','modelo','ano','km_atual','unidade','status','ultima_revisao','proxima_revisao'];
  const csv = toCSV(rows, headers);
  downloadText(csv, 'viaturas.csv');
});
document.getElementById('export-csv-os').addEventListener('click', ()=>{
  const rows = read(LS_KEYS.OS);
  const headers = ['numero','data','viatura','problema','servico','responsavel','pecas','custo','tempo_parada','status'];
  const csv = toCSV(rows, headers);
  downloadText(csv, 'ordens_servico.csv');
});
document.getElementById('print-relatorio').addEventListener('click', ()=>{
  window.print();
});
function downloadText(text, filename){
  const a = document.createElement('a');
  a.href = URL.createObjectURL(new Blob([text], {type:'text/csv'}));
  a.download = filename; document.body.appendChild(a); a.click(); a.remove();
}

function renderRelatorioOutput(){
  const out = document.getElementById('relatorio-output');
  out.innerHTML = `<h4>Resumo</h4>
    <div>Total viaturas: ${read(LS_KEYS.VIATURAS).length}</div>
    <div>Total OS: ${read(LS_KEYS.OS).length}</div>`;
}

// Atualizações periódicas (mantém UI sincronizada)
setInterval(()=>{ renderDashboard(); renderMapMarkers(); renderHistorico(); }, 5000);
JS

echo "Escrevendo workflow deploy-pages.yml ..."
cat > "$OUTDIR/.github/workflows/deploy-pages.yml" <<'YML'
name: Deploy FrotaPM site to GitHub Pages

on:
  push:
    branches: [ add-monitoramento-site ]

permissions:
  contents: read
  pages: write
  id-token: write

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Upload artifact for GitHub Pages
        uses: actions/upload-pages-artifact@v1
        with:
          path: '.'

      - name: Deploy to GitHub Pages
        uses: actions/deploy-pages@v1
YML

echo "Escrevendo README.md ..."
cat > "$OUTDIR/README.md" <<'MD'
# FrotaPM — Monitoramento (Demo)

Protótipo estático do sistema FrotaPM com:
- SPA (Dashboard, Cadastro, Preventiva, OS, Histórico, Rastreamento, KPIs e Relatórios)
- Persistência local (localStorage) para demo
- Mapa com Leaflet e simulação de rastreamento
- Workflow GitHub Actions para publicar a branch add-monitoramento-site em GitHub Pages
MD

echo "Gerando zip $ZIPNAME ..."
( cd "$(dirname "$OUTDIR")" || exit 1
  zip -r "$ZIPNAME" "$(basename "$OUTDIR")" >/dev/null
)

echo "ZIP criado: $ZIPNAME"
echo "Conteúdo:"
zipinfo -1 "$ZIPNAME"
echo "Pronto. Faça upload do $ZIPNAME no repositório ou descompacte e commit os arquivos."