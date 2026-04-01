// Script para descubrir el esquema real de Data Cloud sin depender de si hay datos o no
String[] tables = new String[]{'POS_POS_CLIENTE_DIAGNOSTICO_70881450__dlm', 'POS_POS_CLIENTE_ANTECEDENTES_ME_7087__dlm'};

for(String table : tables) {
    System.debug('--- ANALIZANDO ESQUEMA DE: ' + table + ' ---');
    // Usamos el catálogo de metadatos de la API de Query
    String sql = 'SELECT column_name, data_type FROM information_schema.columns WHERE table_name = \'' + table + '\' ORDER BY ordinal_position';
    try {
        List<Map<String, Object>> results = TechProfile360Service.executeDataCloudQuery(sql);
        if(results.isEmpty()) {
            System.debug('AVISO: El catálogo no devolvió columnas para ' + table + '. Intentando consulta de estructura...');
            // Intento alternativo: Obtener metadatos de una consulta vacía
            // Nota: executeDataCloudQuery usualmente devuelve solo la data, 
            // pero si falla, el error nos dará pistas.
        } else {
            for(Map<String, Object> col : results) {
                System.debug('CAMPO_REAL: ' + col.get('column_name') + ' (' + col.get('data_type') + ')');
            }
        }
    } catch(Exception e) {
        System.debug('ERROR_METADATOS: ' + e.getMessage());
    }
}
