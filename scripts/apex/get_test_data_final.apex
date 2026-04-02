// Script de Búsqueda de IDs Directo
String sql = 'SELECT ssot__Id__c, ssot__FirstName__c, ssot__LastName__c, Id_POS__c FROM UnifiedssotIndividualDev2__dlm WHERE ssot__FirstName__c IS NOT NULL LIMIT 5';

try {
    List<Map<String, Object>> results = TechProfile360Service.executeDataCloudQuery(sql);
    for(Map<String, Object> r : results) {
        System.debug('CLIENTE_DATA_CLOUD: Name=' + r.get('ssot__FirstName__c') + ' ' + r.get('ssot__LastName__c') + ' | UnifiedID=' + r.get('ssot__Id__c') + ' | IdPOS=' + r.get('Id_POS__c'));
    }
} catch (Exception e) {
    System.debug('ERROR: ' + e.getMessage());
}
