String[] tables = new String[]{'POS_POS_CLIENTE_DIAGNOSTICO_70881450__dlm', 'POS_POS_CLIENTE_ANTECEDENTES_ME_7087__dlm'};
for(String table : tables) {
    System.debug('--- DESCUBRIENDO COLUMNAS DE: ' + table + ' ---');
    String sql = 'SELECT * FROM ' + table + ' LIMIT 1';
    try {
        // En lugar de usar TechProfile360Service, usaremos la llamada pura a la API para ver qué campos devuelve
        List<Map<String, Object>> res = TechProfile360Service.executeDataCloudQuery(sql);
        if(!res.isEmpty()){
            for(String key : res[0].keySet()){
                System.debug('CAMPO_DESCUBIERTO: ' + key);
            }
        } else {
             System.debug('TABLA_VACIA: No se pudo descubrir campos porque no hay registros.');
        }
    } catch(Exception e) {
        System.debug('ERROR_EN_TABLA_' + table + ': ' + e.getMessage());
    }
}
