const express = require('express');
const { execSync } = require('child_process');
const https = require('https');
const app = express();
app.use(express.json());
app.use(express.urlencoded({ extended: true })); // Añadido para mayor compatibilidad

const PORT = 8080;

// Función para obtener Token y URL automáticamente
function getOrgAuth() {
    try {
        const orgInfo = JSON.parse(execSync('sf org display --json', { encoding: 'utf8' }));
        return {
            accessToken: orgInfo.result.accessToken,
            instanceUrl: orgInfo.result.instanceUrl
        };
    } catch (e) {
        throw new Error('No se pudo obtener la autenticación de Salesforce. Ejecuta "sf org login web".');
    }
}

app.post('/query', async (req, res) => {
    console.log(`\n[${new Date().toLocaleTimeString()}] --- NUEVA PETICIÓN ---`);
    console.log(`Headers:`, req.headers);
    console.log(`Body recibido:`, req.body);
    
    if (!req.body || Object.keys(req.body).length === 0 || !req.body.sql) {
        console.error('Error: El body está vacío o no tiene el campo "sql"');
        return res.status(400).json({ 
            error: 'Cuerpo de petición inválido', 
            ayuda: 'Asegúrate de enviar un JSON con el campo "sql" y que el Header sea application/json' 
        });
    }

    const { sql } = req.body;
    console.log(`Query recibida: ${sql.substring(0, 50)}...`);

    try {
        const auth = getOrgAuth();
        const url = new URL(auth.instanceUrl);
        
        // Configurar la llamada a la API de Data Cloud (SQL Query V2)
        const options = {
            hostname: url.hostname,
            path: '/services/data/v60.0/ssot/queryv2',
            method: 'POST',
            headers: {
                'Authorization': `Bearer ${auth.accessToken}`,
                'Content-Type': 'application/json'
            }
        };

        const apiReq = https.request(options, (apiRes) => {
            let data = '';
            apiRes.on('data', (chunk) => data += chunk);
            apiRes.on('end', () => {
                try {
                    const result = JSON.parse(data);
                    res.status(apiRes.statusCode).json(result);
                } catch (e) {
                    res.status(500).json({ error: 'Error al procesar respuesta', raw: data });
                }
            });
        });

        apiReq.on('error', (e) => {
            res.status(500).json({ error: 'Error de conexión', details: e.message });
        });

        // Enviamos el SQL exacto que pusiste en Postman
        apiReq.write(JSON.stringify({ sql }));
        apiReq.end();

    } catch (error) {
        res.status(500).json({ error: 'Error de autenticación', details: error.message });
    }
});

app.listen(PORT, () => {
    console.log('==========================================');
    console.log(` BRIDGE DATA CLOUD PROFESIONAL ACTIVO `);
    console.log(` URL: http://127.0.0.1:${PORT}/query`);
    console.log('==========================================');
});
