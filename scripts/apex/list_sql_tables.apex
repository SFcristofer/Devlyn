// Script para listar todas las tablas disponibles para la API de SQL
// Queremos encontrar el nombre exacto de la tabla de diagnósticos
String sql = 'SELECT table_name FROM information_schema.tables WHERE table_name LIKE \'%DIAGNOSTICO%\'';

System.debug('--- BUSCANDO NOMBRE DE TABLA EN CATALOGO SQL ---');
try {
    List<Map<String, Object>> results = TechProfile360Service.executeDataCloudQuery(sql);
    
    if (results.isEmpty()) {
        System.debug('SQL_ERROR: No se encontró ninguna tabla con "DIAGNOSTICO" en el catálogo de la API de SQL.');
        // Buscamos todas las tablas POS
        sql = 'SELECT table_name FROM information_schema.tables WHERE table_name LIKE \'%POS%\' LIMIT 20';
        results = TechProfile360Service.executeDataCloudQuery(sql);
    }

    for (Map<String, Object> row : results) {
        System.debug('TABLA_ENCONTRADA_SQL_API: ' + row.get('table_name'));
    }
} catch (Exception e) {
    System.debug('ERROR_TECNICO: ' + e.getMessage());
}
