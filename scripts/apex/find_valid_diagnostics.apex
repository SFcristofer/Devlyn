// Script para encontrar IDs reales con diagnóstico médico completo
String query = 'SELECT ID_CLIENTE__c, FECHA__c, MIOPIA__c, ASTIGMATISMO__c ' +
               'FROM POS_POS_CLIENTE_DIAGNOSTICO_70881450__dlm ' +
               'WHERE MIOPIA__c != null AND ASTIGMATISMO__c != null ' +
               'ORDER BY FECHA__c DESC LIMIT 5';

try {
    List<Map<String, Object>> results = TechProfile360Service.executeDataCloudQuery(query);
    if (results.isEmpty()) {
        System.debug('BUSQUEDA_FALLIDA: No se encontraron registros con diagnóstico completo.');
    } else {
        System.debug('IDS_ENCONTRADOS: ' + JSON.serialize(results));
    }
} catch (Exception e) {
    System.debug('ERROR_SQL: ' + e.getMessage());
}
