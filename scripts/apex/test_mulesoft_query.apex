String posId = '13227215';
String queryMulesoft = 'SELECT FECHA__c, ASTIGMATISMO__c, MIOPIA__c, HIPERMETROPIA__c, PRESBICIA__c FROM POS_POS_CLIENTE_DIAGNOSTICO_70881450__dlm WHERE ID_CLIENTE__c = \'' + posId + '\' AND FECHA__c != null ORDER BY FECHA__c DESC LIMIT 1';
String queryLike = 'SELECT FECHA__c, ID_CLIENTE__c FROM POS_POS_CLIENTE_DIAGNOSTICO_70881450__dlm WHERE ID_CLIENTE__c LIKE \'%' + posId + '%\' LIMIT 1';

System.debug('--- INICIANDO PRUEBA DE CONSULTA DATA CLOUD ---');

try {
    // Escenario 1: Consulta original
    List<Map<String, Object>> res1 = TechProfile360Service.executeDataCloudQuery(queryMulesoft);
    System.debug('RESULTADO_MULESOFT (Exacto): ' + (res1.isEmpty() ? 'VACIO' : JSON.serialize(res1[0])));

    // Escenario 2: Búsqueda con LIKE para detectar IDs mal formados
    List<Map<String, Object>> res2 = TechProfile360Service.executeDataCloudQuery(queryLike);
    if(!res2.isEmpty()) {
        String realId = (String)res2[0].get('ID_CLIENTE__c');
        System.debug('RESULTADO_LIKE: Se encontró el ID "' + realId + '" (Longitud: ' + realId.length() + ')');
        if(realId != posId) {
            System.debug('DETECCION: El ID en Data Cloud tiene caracteres extra o espacios.');
        }
    } else {
        System.debug('RESULTADO_LIKE: Tampoco se encontró nada con LIKE.');
    }

} catch (Exception e) {
    System.debug('ERROR_EJECUCION: ' + e.getMessage());
}
