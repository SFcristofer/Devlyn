String[] tables = new String[]{'POS_POS_CLIENTE_DIAGNOSTICO_70881450__dlm', 'POS_POS_CLIENTE_ANTECEDENTES_ME_7087__dlm'};
for(String table : tables) {
    System.debug('--- INSPECCIONANDO TABLA: ' + table + ' ---');
    String sql = 'SELECT column_name FROM information_schema.columns WHERE table_name = \'' + table + '\'';
    try {
        List<Map<String, Object>> results = TechProfile360Service.executeDataCloudQuery(sql);
        if(results.isEmpty()) {
            System.debug('RESULTADO: No se encontraron columnas o la tabla no es accesible vía SQL API.');
        } else {
            for(Map<String, Object> row : results) {
                System.debug('COLUMNA_REAL: ' + row.get('column_name'));
            }
        }
    } catch(Exception e) {
        System.debug('ERROR_EN_TABLA_' + table + ': ' + e.getMessage());
    }
}
