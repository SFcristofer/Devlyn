// Script para obtener los nombres reales de las columnas sin importar si hay datos
String table = 'POS_POS_CLIENTE_DIAGNOSTICO_70881450__dlm';
System.debug('--- INSPECCIONANDO ESTRUCTURA DE: ' + table + ' ---');

// Consultamos la tabla de metadatos del sistema de Data Cloud
String sql = 'SELECT column_name, data_type FROM information_schema.columns WHERE table_name = \'' + table + '\'';

try {
    List<Map<String, Object>> columns = TechProfile360Service.executeDataCloudQuery(sql);
    if(columns.isEmpty()) {
        System.debug('ERROR: No se pudieron recuperar metadatos. Intentando con SELECT * LIMIT 0...');
        // Si el catálogo falla, intentamos extraer los nombres de los campos de una consulta vacía
        // Nota: El servicio TechProfile360Service debería devolver las llaves en el mapa si la consulta se ejecuta
    } else {
        for(Map<String, Object> col : columns) {
            System.debug('CAMPO_REAL_ENCONTRADO: ' + col.get('column_name'));
        }
    }
} catch (Exception e) {
    System.debug('ERROR_CRITICO: ' + e.getMessage());
}
