// Script de Auditoría de Datos Médicos Reales
// Este script busca en TODAS las tablas posibles datos de refracción
System.debug('--- INICIANDO BÚSQUEDA EXHAUSTIVA DE EXPEDIENTES REALES ---');

String[] tables = new String[]{
    'POS_POS_CLIENTE_DIAGNOSTICO_70881450__dlm',
    'POS_POS_CLIENTE_ANTECEDENTES_ME_7087__dlm',
    'POS_POS_CLIENTE_DRIVER_VISUAL_708C22__dlm',
    'POS_POS_CLIENTE_PREG_PODER__dlm'
};

for(String table : tables) {
    try {
        // Buscamos cualquier registro que tenga datos médicos, sin importar el ID
        String sql = 'SELECT * FROM ' + table + ' WHERE FECHA__c != NULL LIMIT 10';
        List<Map<String, Object>> results = TechProfile360Service.executeDataCloudQuery(sql);
        
        if(!results.isEmpty()) {
            System.debug('DATOS_ENCONTRADOS_EN_TABLA: ' + table);
            for(Map<String, Object> row : results) {
                System.debug('REGISTRO: ' + JSON.serialize(row));
            }
        } else {
            System.debug('TABLA_VACIA: ' + table);
        }
    } catch(Exception e) {
        System.debug('ERROR_EN_TABLA_' + table + ': ' + e.getMessage());
    }
}
