// Script de validación exhaustiva para encontrar un ID que responda en SQL
System.debug('--- BUSCANDO ID COMPATIBLE CON SQL API ---');

// 1. Obtenemos candidatos reales de la base de datos
List<SObject> candidates = Database.query('SELECT ID_CLIENTE__c FROM POS_POS_CLIENTE_DIAGNOSTICO_70881450__dlm WHERE FECHA__c != null ORDER BY FECHA__c DESC LIMIT 20');

for(SObject c : candidates) {
    String posId = (String)c.get('ID_CLIENTE__c');
    String sql = 'SELECT FECHA__c, ASTIGMATISMO__c, MIOPIA__c, HIPERMETROPIA__c, PRESBICIA__c ' +
                 'FROM POS_POS_CLIENTE_DIAGNOSTICO_70881450__dlm ' +
                 'WHERE ID_CLIENTE__c = \'' + posId + '\' AND FECHA__c != null ' +
                 'ORDER BY FECHA__c DESC LIMIT 1';
    
    try {
        List<Map<String, Object>> results = TechProfile360Service.executeDataCloudQuery(sql);
        if(!results.isEmpty()) {
            System.debug('¡EXITO_ENCONTRADO!');
            System.debug('ID_GANADOR: ' + posId);
            System.debug('DATOS: ' + results[0]);
            break; // Ya encontramos uno que funciona
        } else {
            System.debug('ID ' + posId + ' no devolvió datos en SQL API (aunque existe en Apex).');
        }
    } catch(Exception e) {
        System.debug('Error con ID ' + posId + ': ' + e.getMessage());
    }
}
