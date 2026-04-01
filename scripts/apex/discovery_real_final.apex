String posId = '13218258';
String[] tables = new String[]{'POS_POS_CLIENTE_DIAGNOSTICO_70881450__dlm', 'POS_POS_CLIENTE_ANTECEDENTES_ME_7087__dlm'};

for(String table : tables) {
    System.debug('--- DESCUBRIENDO COLUMNAS REALES DE: ' + table + ' ---');
    // Usamos SELECT * con el ID que ya sabemos que funciona
    String sql = 'SELECT * FROM ' + table + ' WHERE ID_CLIENTE__c = \'' + posId + '\' LIMIT 1';
    try {
        List<Map<String, Object>> res = TechProfile360Service.executeDataCloudQuery(sql);
        if(!res.isEmpty()){
            // Imprimimos todas las llaves (columnas) que nos devolvió Data Cloud
            for(String key : res[0].keySet()){
                System.debug('COLUMNA_DETECTADA: ' + key);
            }
        } else {
            System.debug('AVISO: No se encontraron registros en ' + table + ' para el ID ' + posId);
        }
    } catch(Exception e) {
        System.debug('ERROR_EN_TABLA_' + table + ': ' + e.getMessage());
    }
}
