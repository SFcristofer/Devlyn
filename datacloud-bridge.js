const http = require('http');
const { execSync } = require('child_process');

const PORT = 8080;

const server = http.createServer(async (req, res) => {
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'POST, GET, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

    if (req.method === 'OPTIONS') { res.writeHead(204); res.end(); return; }

    // NUEVA RUTA PARA LISTAR TABLAS
    if (req.method === 'GET' && req.url === '/list-tables') {
        try {
            console.log('[Proxy] Listando todas las tablas DLM...');
            const orgInfo = JSON.parse(execSync('sf org display --json').toString());
            const token = orgInfo.result.accessToken;
            const url = orgInfo.result.instanceUrl;

            // Consultar metadatos de Data Cloud
            const response = await fetch(`${url}/services/data/v60.0/ssot/queryv2`, {
                method: 'POST',
                headers: { 'Authorization': `Bearer ${token}`, 'Content-Type': 'application/json' },
                body: JSON.stringify({ sql: "SELECT DISTINCT DeveloperName FROM Metadata_Entity_Definition__dlm WHERE DeveloperName LIKE '%__dlm' ORDER BY DeveloperName ASC" })
            });

            const data = await response.json();
            res.writeHead(200, { 'Content-Type': 'application/json' });
            res.end(JSON.stringify(data));
        } catch (e) {
            res.writeHead(500); res.end(JSON.stringify({ error: e.message }));
        }
        return;
    }

    if (req.method === 'POST' && req.url === '/query') {
        let body = '';
        req.on('data', chunk => { body += chunk.toString(); });
        req.on('end', async () => {
            try {
                const { sql } = JSON.parse(body);
                const orgInfo = JSON.parse(execSync('sf org display --json').toString());
                const token = orgInfo.result.accessToken;
                const url = orgInfo.result.instanceUrl;
                const response = await fetch(`${url}/services/data/v60.0/ssot/queryv2`, {
                    method: 'POST',
                    headers: { 'Authorization': `Bearer ${token}`, 'Content-Type': 'application/json' },
                    body: JSON.stringify({ sql })
                });
                const data = await response.json();
                res.writeHead(response.status, { 'Content-Type': 'application/json' });
                res.end(JSON.stringify(data));
            } catch (e) { res.writeHead(500); res.end(JSON.stringify({ error: e.message })); }
        });
    }
});

server.listen(PORT, '0.0.0.0', () => {
    console.log(`\n🚀 PUENTE CON ESCÁNER ACTIVO`);
    console.log(`LISTAR TABLAS: http://127.0.0.1:8080/list-tables`);
    console.log(`----------------------------------------\n`);
});
