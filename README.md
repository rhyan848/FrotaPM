# FrotaPM — Monitoramento (Demo)

Este branch adiciona um site estático para monitoramento em tempo real (modo demo) com um mapa e lista de veículos simulados.

Branch: `add-monitoramento-site`

Arquivos adicionados:
- `index.html` — página web estática com mapa (Leaflet) e dados simulados.

Como usar
1. Acesse a branch `add-monitoramento-site` no repositório.
2. Para ver localmente, abra `index.html` em um navegador (não requer servidor, mas recomenda-se servir via `live-server` ou GitHub Pages para evitar bloqueios dependendo do navegador).
3. Para publicar publicamente, ative o GitHub Pages nas configurações do repositório apontando para a branch `add-monitoramento-site` (ou mova os arquivos para `gh-pages`/`main` conforme preferir).

Conectar a uma API real
- Atualmente a página está em modo demo (dados simulados em Blumenau, SC).
- Para conectar a sua API real, edite `index.html` e substitua o bloco de `fetchVehicles()` para realizar `fetch()` ao endpoint real, tratando autenticação, CORS e formato de resposta.
- Atenção: não é seguro colocar chaves privadas diretamente no código cliente. Use um proxy no servidor para injetar a chave com segurança.

Próximos passos que posso fazer por você
- Adaptar a página para usar sua API real (você fornece o endpoint e informa o formato dos campos de localização), substituindo o modo demo.
- Implementar autenticação via proxy para não expor a `api_key` no cliente.
- Adicionar WebSocket/Socket.IO para atualizações em tempo real se sua API suportar (forneça URL de socket).

Se quiser que eu faça o deploy para GitHub Pages (configurar a branch e habilitar Pages), confirme e eu posso criar um pull request ou mover os arquivos para a branch padrão conforme desejar.
