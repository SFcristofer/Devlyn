// Script de Rastreo de Precisión para ID 12388500
String targetId = '12388500';
System.debug('--- RASTREANDO ID REAL: ' + targetId + ' ---');

try {
    // 1. Buscamos en el Individuo Unificado (Lo que usa tu buscador de Salesforce)
    String q1 = 'SELECT ssot__Id__c, ssot__FirstName__c, ssot__LastName__c, Id_POS__c FROM UnifiedssotIndividualDev2__dlm WHERE Id_POS__c LIKE \'%' + targetId + '%\' LIMIT 1';
    List<Map<String, Object>> res1 = TechProfile360Service.executeDataCloudQuery(q1);
    
    if(!res1.isEmpty()) {
        String unifiedId = (String)res1[0].get('ssot__Id__c');
        System.debug('IDENTIDAD_ENCONTRADA: ' + JSON.serialize(res1[0]));
        
        // 2. Con el Unified ID, buscamos su diagnóstico (Lo que Mulesoft debería hacer)
        String q2 = 'SELECT FECHA__c, MIOPIA__c, ASTIGMATISMO__c FROM POS_POS_CLIENTE_DIAGNOSTICO_70881450__dlm WHERE ID_CLIENTE__c = \'' + unifiedId + '\' LIMIT 1';
        List<Map<String, Object>> res2 = TechProfile360Service.executeDataCloudQuery(q2);
        System.debug('DIAGNOSTICO_POR_UNIFIED_ID: ' + (res2.isEmpty() ? 'VACIO (Mismo error que Mulesoft)' : JSON.serialize(res2[0])));
        
        // 3. Buscamos sus órdenes (Lo que viste en el buscador)
        String q3 = 'SELECT ssot__OrderNumber__c, ssot__TotalAmount__c FROM ssot__SalesOrder__dlm WHERE ssot__SoldToCustomerId__c = \'' + targetId + '\' LIMIT 1';
        List<Map<String, Object>> res3 = TechProfile360Service.executeDataCloudQuery(q3);
        System.debug('ORDENES_ENCONTRADAS: ' + (res3.isEmpty() ? 'SIN ORDENES' : JSON.serialize(res3[0])));
    } else {
        System.debug('IDENTIDAD_NO_ENCONTRADA: El buscador de SF está usando un índice diferente.');
    }
} catch (Exception e) {
    System.debug('ERROR_RASTREO: ' + e.getMessage());
}
